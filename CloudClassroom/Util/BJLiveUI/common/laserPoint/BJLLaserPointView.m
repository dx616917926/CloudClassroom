//
//  BJLLaserPointView.m
//  BJLiveUI
//
//  Created by HuangJie on 2018/11/21.
//  Copyright © 2018 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJLLaserPointView.h"
#import "BJLAppearance.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BJLLaserPointType) {
    // 激光笔
    BJLLaserPointType_laserPoint,
    // 画笔落笔前
    BJLLaserPointType_mousePoint,
    // 画笔轨迹
    BJLLaserPointType_paintPoint,
    // 当前用户画笔轨迹
    BJLLaserPointType_selfPaintPoint,
    // 手写板轨迹
    BJLLaserPointType_handWritingboard
};

@interface BJLLaserPointView ()

// common
@property (nonatomic, readonly, weak) BJLRoom *room;
@property (nonatomic) BJLLaserPointType type;
@property (nonatomic) BJLBrushOperateMode operateMode;
@property (nonatomic) BJLDrawingShapeType shapeType;
@property (nonatomic) CGFloat strokeAlpha;
@property (nonatomic) UIImageView *laserPointView;
@property (nonatomic) CGSize showSize;
@property (nonatomic) NSTimeInterval existInterval;

// paint
@property (nonatomic) CGPoint paintImageOffset; // 画笔的图片位置补正
@property (nonatomic) UIColor *paintColor; // 画笔颜色

// laser point
@property (nonatomic) UIPanGestureRecognizer *laserPointMoveGesture;
@property (nonatomic, nullable) NSTimer *requestTimer;
@property (nonatomic) CGPoint laserPoint;

@end

@implementation BJLLaserPointView

- (instancetype)initWithRoom:(BJLRoom *)room {
    self = [super init];
    if (self) {
        self->_room = room;
        self.documentID = BJLBlackboardID;
        self.pageIndex = 0;
        self.blackboardPages = 1;
        self.existInterval = 5.0;
        self.showSize = CGSizeZero;
        self.isPreview = NO;
        self.type = BJLLaserPointType_laserPoint;
        self.operateMode = BJLBrushOperateMode_defaut;
        self.shapeType = BJLDrawingShapeType_laserPoint;
        UIImage *image = [self imageWithType:self.type];
        self.paintImageOffset = CGPointMake(image.size.width / 2.0, image.size.height / 2.0);
        [self setupSubviews];
        [self setupLaserPointMoveGesture];
        [self setupObservers];
    }
    return self;
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.requestTimer invalidate];
    self.requestTimer = nil;
}

- (void)updateShapeShowSize:(CGSize)size {
    self.showSize = size;

    if (!self.laserPointView.hidden) {
        if (CGSizeEqualToSize(size, CGSizeZero)) {
            size = self.bounds.size;
        }

        CGPoint realLocation = CGPointMake(self.laserPoint.x * size.width, self.laserPoint.y * size.height);
        [self updateLaserPointToLocation:realLocation];
    }
}

#pragma mark - subviews

- (void)setupSubviews {
    self.laserPointView = ({
        UIImage *image = [self imageWithType:self.type];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(0.0, 0.0, 32.0, 32.0);
        imageView.hidden = YES;
        imageView;
    });
    [self addSubview:self.laserPointView];
}

#pragma mark - observers

- (void)setupObservers {
    bjl_weakify(self);

    // 激光笔
    [self bjl_observe:BJLMakeMethod(self.room.drawingVM, didLaserPointMoveToLocation:documentID:pageIndex:)
             observer:(BJLMethodObserver) ^ BOOL(CGPoint location, NSString * documentID, NSUInteger pageIndex) {
                 bjl_strongify(self);
                 [self updateLaserPointViewWithType:BJLLaserPointType_laserPoint];
                 [self updateLaserPointWithLocation:location documentID:documentID pageIndex:pageIndex];
                 return YES;
             }];

    // 鼠标落笔前位置
    [self bjl_observe:BJLMakeMethod(self.room.drawingVM, didMousePointMoveToLocation:documentID:pageIndex:color:)
             observer:(BJLMethodObserver) ^ BOOL(CGPoint location, NSString * documentID, NSUInteger pageIndex, UIColor * color) {
                 bjl_strongify(self);
                 [self updateLaserPointViewWithType:BJLLaserPointType_mousePoint];
                 self.paintColor = color;
                 [self updateLaserPointWithLocation:location documentID:documentID pageIndex:pageIndex];
                 return YES;
             }];

    // 画笔轨迹
    [self bjl_observe:BJLMakeMethod(self.room.drawingVM, didPaintPointMoveToLocation:documentID:pageIndex:color:fromCurrentUser:)
             observer:(BJLMethodObserver) ^ BOOL(CGPoint location, NSString * documentID, NSUInteger pageIndex, UIColor * color, BOOL fromCurrentUser) {
                 bjl_strongify(self);
                 [self updateLaserPointViewWithType:fromCurrentUser ? BJLLaserPointType_selfPaintPoint : BJLLaserPointType_paintPoint];
                 self.paintColor = color;
                 [self updateLaserPointWithLocation:location documentID:documentID pageIndex:pageIndex];
                 return YES;
             }];

    [self bjl_observe:BJLMakeMethod(self.room.drawingVM, didHandWritingBoardPointMoveToLocation:documentID:pageIndex:)
             observer:(BJLMethodObserver) ^ BOOL(CGPoint location, NSString * documentID, NSInteger pageIndex) {
                 bjl_strongify(self);
                 [self updateLaserPointViewWithType:BJLLaserPointType_handWritingboard];
                 self.paintColor = [UIColor bjl_colorWithHexString:self.room.drawingVM.strokeColor];
                 [self updateLaserPointWithLocation:location documentID:documentID pageIndex:pageIndex];
                 return YES;
             }];

    [self bjl_kvoMerge:@[BJLMakeProperty(self.room.drawingVM, drawingEnabled),
        BJLMakeProperty(self.room.drawingVM, drawingShapeType)]
              observer:^(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
                  bjl_strongify(self);
                  self.userInteractionEnabled = (self.room.drawingVM.drawingEnabled
                                                 && self.room.drawingVM.drawingShapeType == BJLDrawingShapeType_laserPoint);
              }];
}

#pragma mark - receive

- (void)updateLaserPointWithLocation:(CGPoint)location documentID:(NSString *)documentID pageIndex:(NSInteger)pageIndex {
    self.laserPoint = location;
    CGSize showSize = self.showSize;
    if (CGSizeEqualToSize(showSize, CGSizeZero)) {
        showSize = self.bounds.size;
    }

    CGPoint realLocation = CGPointZero;
    if (self.type == BJLLaserPointType_paintPoint || self.type == BJLLaserPointType_selfPaintPoint) {
        if ([documentID isEqualToString:BJLBlackboardID]) {
            CGFloat totalHeight = self.blackboardPages * showSize.height;
            CGFloat startOffset = (self.blackboardIndex / self.blackboardPages) * totalHeight;
            CGFloat position = location.y * totalHeight - startOffset;
            realLocation = CGPointMake(location.x * showSize.width + self.paintImageOffset.x, position - self.paintImageOffset.y);
        }
        else {
            if (self.requirePointCallback) {
                realLocation = self.requirePointCallback(documentID, location);
            }
            else {
                realLocation = CGPointMake(location.x * showSize.width, location.y * showSize.height);
            }
        }
    }
    else {
        realLocation = CGPointMake(location.x * showSize.width, location.y * showSize.height);
    }
    self.laserPointView.tintColor = self.type != BJLLaserPointType_laserPoint ? self.paintColor : nil;
    [self updateLaserPointToLocation:realLocation];
    self.documentID = documentID;
    self.pageIndex = pageIndex;
}

#pragma mark - gesture

- (void)setupLaserPointMoveGesture {
    bjl_weakify(self);
    self.laserPointMoveGesture = [UIPanGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer *_Nullable gesture) {
        bjl_strongify(self);
        CGPoint location = [gesture locationInView:gesture.view];
        if (gesture.state == UIGestureRecognizerStateBegan) {
            [self moveLaserPointToLocation:location];
            [self requestUpdateLaserPoint];
            [self startRequestTimer];
        }
        else if (gesture.state == UIGestureRecognizerStateChanged) {
            [self moveLaserPointToLocation:location];
        }
        else if (gesture.state == UIGestureRecognizerStateEnded) {
            [self moveLaserPointToLocation:location];
            [self requestUpdateLaserPoint];
            [self stopRequestTimer];
        }
    }];
    [self addGestureRecognizer:self.laserPointMoveGesture];
}

#pragma mark - request timer

- (void)startRequestTimer {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideLaserPoint) object:nil];
    self.laserPointView.hidden = NO;
    if (self.requestTimer && self.requestTimer.isValid) {
        return;
    }

    bjl_weakify(self);
    self.requestTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer *_Nonnull timer) {
        bjl_strongify(self);
        if (!self) {
            [timer invalidate];
            return;
        }

        [self requestUpdateLaserPoint];
    }];
}

- (void)stopRequestTimer {
    [self.requestTimer invalidate];
    [self performSelector:@selector(hideLaserPoint) withObject:nil afterDelay:5.0];
}

#pragma mark - laser point view

- (void)updateLaserPointViewWithType:(BJLLaserPointType)type {
    if (self.type == type
        && self.room.drawingVM.drawingShapeType == self.shapeType
        && self.room.drawingVM.brushOperateMode == self.operateMode
        && self.room.drawingVM.strokeAlpha == self.strokeAlpha) {
        return;
    }
    self.type = type;
    self.shapeType = self.room.drawingVM.drawingShapeType;
    self.operateMode = self.room.drawingVM.brushOperateMode;
    self.strokeAlpha = self.room.drawingVM.strokeAlpha;
    self.existInterval = (type == BJLLaserPointType_paintPoint
                             || type == BJLLaserPointType_selfPaintPoint
                             || type == BJLLaserPointType_handWritingboard)
                             ? 2.0
                             : 5.0;
    self.laserPointView.image = [self imageWithType:type];
}

- (void)moveLaserPointToLocation:(CGPoint)location {
    [self updateLaserPointViewWithType:BJLLaserPointType_laserPoint];
    CGSize showSize = self.showSize;
    if (CGSizeEqualToSize(showSize, CGSizeZero)) {
        showSize = self.bounds.size;
    }
    CGSize pointSize = self.laserPointView.bounds.size;
    location.x = MIN(showSize.width - pointSize.width, MAX(location.x - 30.0, 0.0));
    location.y = MIN(showSize.height - pointSize.height, MAX(location.y - 30.0, 0.0));
    [self updateLaserPointToLocation:location];
}

- (void)updateLaserPointToLocation:(CGPoint)location {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideLaserPoint) object:nil];
    BOOL needAnimation = !self.laserPointView.hidden;
    self.laserPointView.hidden = NO;
    // center -> origin
    if (needAnimation) {
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.laserPointView.frame = bjl_set(self.laserPointView.frame, {
                set.origin.x = location.x - set.size.width / 2.0;
                set.origin.y = location.y - set.size.height / 2.0;
            });
        } completion:nil];
    }
    else {
        self.laserPointView.frame = bjl_set(self.laserPointView.frame, {
            set.origin.x = location.x - set.size.width / 2.0;
            set.origin.y = location.y - set.size.height / 2.0;
        });
    }
    if (!self.requestTimer.isValid) {
        [self performSelector:@selector(hideLaserPoint) withObject:nil afterDelay:self.existInterval];
    }
}

- (void)requestUpdateLaserPoint {
    // 预览的课件激光笔不发送信令
    if (self.isPreview) {
        return;
    }

    CGSize showSize = self.showSize;
    if (CGSizeEqualToSize(showSize, CGSizeZero)) {
        showSize = self.bounds.size;
    }

    if (showSize.width <= 0.0 || showSize.height <= 0.0) {
        return;
    }

    CGRect frame = self.laserPointView.frame;
    // origin -> center
    CGFloat pointX = frame.origin.x + frame.size.width / 2.0;
    CGFloat pointY = frame.origin.y + frame.size.height / 2.0;
    CGPoint relativePoint = CGPointMake(pointX / showSize.width,
        pointY / showSize.height);
    [self.room.drawingVM moveLaserPointToLocation:relativePoint
                                       documentID:self.documentID
                                        pageIndex:self.pageIndex];
}

- (void)hideLaserPoint {
    self.laserPointView.hidden = YES;
}

- (nullable UIImage *)imageWithType:(BJLLaserPointType)type {
    switch (type) {
        case BJLLaserPointType_laserPoint:
            return [UIImage bjl_imageNamed:@"bjl_blackboard_laserpoint"];

        case BJLLaserPointType_mousePoint:
            return [[UIImage bjl_imageNamed:@"bjl_blackboard_paintpoint"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

        case BJLLaserPointType_paintPoint:
            return [[UIImage bjl_imageNamed:@"bjl_blackboard_paintpoint"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

        case BJLLaserPointType_selfPaintPoint:
        case BJLLaserPointType_handWritingboard: {
            UIImage *image = nil;
            if (self.room.drawingVM.brushOperateMode == BJLBrushOperateMode_erase) {
                image = [UIImage bjl_imageNamed:@"bjl_blackboard_erase"];
            }
            else if (self.room.drawingVM.brushOperateMode == BJLBrushOperateMode_select) {
                image = [[UIImage bjl_imageNamed:@"bjl_blackboard_paintpoint"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }
            else if (self.room.drawingVM.brushOperateMode == BJLBrushOperateMode_draw) {
                if (self.room.drawingVM.drawingShapeType == BJLDrawingShapeType_doodle) {
                    if (self.room.drawingVM.strokeAlpha < 1.0) {
                        image = [[UIImage bjl_imageNamed:@"bjl_blackboard_markpen"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    }
                    else {
                        image = [[UIImage bjl_imageNamed:@"bjl_blackboard_paintpoint"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    }
                }
                else {
                    image = [UIImage bjl_imageNamed:@"bjl_blackboard_arrow"];
                }
            }
            return image;
        }

        default:
            return nil;
    }
}

@end

NS_ASSUME_NONNULL_END
