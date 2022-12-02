//
//  BJLScToolView.m
//  BJLiveUI
//
//  Created by xijia dai on 2019/9/20.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJLScToolView.h"
#import "BJLScAppearance.h"
#import "BJLUser+RollCall.h"

@interface BJLScToolView ()

@property (nonatomic, weak) BJLRoom *room;

@property (nonatomic, readwrite) BOOL expectedHidden;
@property (nonatomic) UIView *singleLine;

@property (nonatomic, readwrite) UIButton
    *PPTButton, // ppt开关按钮
    *selectButton, // 普通选择
    *paintBrushButton, // 画笔
    *markPenButton, // 马克笔
    *shapeButton, // 形状
    *textButton, // 文字
    *laserPointerButton, // 激光笔
    *eraserButton, // 橡皮
    *coursewareButton, // 课件
    *teachingAidButton; // 教具工具箱
@property (nonatomic) UILabel *teachingAidButtonBadgeLabel; // 教具工具箱

@property (nonatomic, nullable) UIButton *currentSelectedButton;
@property (nonatomic) NSArray<UIView *> *views;
@property (nonatomic) BOOL ignoreDrawingTypeChange;

@end

@implementation BJLScToolView

- (instancetype)initWithRoom:(BJLRoom *)room {
    if (self = [super initWithFrame:CGRectZero]) {
        self.room = room;
        self.expectedHidden = YES;
        [self makeSubviews];
        [self remakeToolButtonConstraints];
        [self makeObserving];

        self.currentToolboxShape = BJLDrawingShapeType_segment;
        self.doodleStrokeWidth = room.drawingVM.doodleStrokeWidth;
        self.markStrokeWidth = 8.0;
    }
    return self;
}

- (CGSize)expectedSize {
    NSInteger toolCount = self.views.count;

    CGSize size = CGSizeZero;
    if (!toolCount) {
        return size;
    }

    BOOL iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    if (iPhone) {
        size = CGSizeMake(BJLScToolViewWidth, toolCount * BJLScToolViewWidth + (toolCount + 1) * BJLScToolViewButtonSpace);
    }
    else {
        size = CGSizeMake(toolCount * BJLScToolViewButtonWidth + (toolCount + 1) * BJLScToolViewButtonSpace, BJLScToolViewWidth);
    }
    return size;
}

#pragma mark - init view

- (void)makeSubviews {
    self.backgroundColor = BJLTheme.toolboxBackgroundColor;
    self.layer.cornerRadius = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 2.0 : 4.0;
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [UIColor bjl_colorWithHex:0XDDDDDD alpha:0.1].CGColor;
    self.layer.cornerRadius = 4.0;
    self.layer.masksToBounds = NO;
    self.layer.shadowOpacity = 0.3;
    self.layer.shadowColor = BJLTheme.windowShadowColor.CGColor;
    self.layer.shadowOffset = CGSizeMake(0.0, 2.0);
    self.layer.shadowRadius = 2.0;

    self.PPTButton = [self makeButtonWithImage:@"bjl_toolbox_ppt_normal" selectedImage:@"bjl_toolbox_ppt_selected" accessibilityIdentifier:BJLKeypath(self, PPTButton)];
    self.selectButton = [self makeButtonWithImage:@"bjl_toolbox_select_normal" selectedImage:@"bjl_toolbox_select_selected" accessibilityIdentifier:BJLKeypath(self, selectButton)];
    self.paintBrushButton = [self makeButtonWithImage:@"bjl_toolbox_paintbrush_normal" selectedImage:@"bjl_toolbox_paintbrush_selected" accessibilityIdentifier:BJLKeypath(self, paintBrushButton)];
    self.markPenButton = [self makeButtonWithImage:@"bjl_toolbox_marker_normal" selectedImage:@"bjl_toolbox_marker_selected" accessibilityIdentifier:BJLKeypath(self, markPenButton)];
    self.shapeButton = [self makeButtonWithImage:@"bjl_toolbox_draw_shape_segment_normal" selectedImage:@"bjl_toolbox_draw_shape_segment_selected" accessibilityIdentifier:BJLKeypath(self, shapeButton)];
    self.textButton = [self makeButtonWithImage:@"bjl_toolbox_text_normal" selectedImage:@"bjl_toolbox_text_selected" accessibilityIdentifier:BJLKeypath(self, textButton)];
    self.laserPointerButton = [self makeButtonWithImage:@"bjl_toolbox_laserpointer_normal" selectedImage:@"bjl_toolbox_laserpointer_selected" accessibilityIdentifier:BJLKeypath(self, laserPointerButton)];
    self.eraserButton = [self makeButtonWithImage:@"bjl_toolbox_eraser_normal" selectedImage:@"bjl_toolbox_eraser_selected" accessibilityIdentifier:BJLKeypath(self, eraserButton)];
    self.teachingAidButton = [self makeButtonWithImage:@"bjl_toolbox_teachingaid_normal" selectedImage:@"bjl_toolbox_teachingaid_selected" accessibilityIdentifier:BJLKeypath(self, teachingAidButton)];
    [self.teachingAidButton addSubview:self.teachingAidButtonBadgeLabel];
    [self.teachingAidButtonBadgeLabel bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        BOOL iphone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
        make.centerX.equalTo(self.teachingAidButton.bjl_right).offset(iphone ? -3 : -1);
        make.centerY.equalTo(self.teachingAidButton.bjl_top).offset(iphone ? 2 : 0);
        make.width.height.equalTo(@5.0);
    }];

    self.coursewareButton = [self makeButtonWithImage:@"bjl_toolbox_courseware_normal" accessibilityIdentifier:BJLKeypath(self, coursewareButton)];

    self.paintStrokeColorView = [self makeStrokeColorView:BJLKeypath(self, paintStrokeColorView)];
    self.markStrokeColorView = [self makeStrokeColorView:BJLKeypath(self, markStrokeColorView)];
    self.shapeStrokeColorView = [self makeStrokeColorView:BJLKeypath(self, shapeStrokeColorView)];
    self.textStrokeColorView = [self makeStrokeColorView:BJLKeypath(self, textStrokeColorView)];
}

- (void)remakeStrokeColorConstraints {
    BOOL iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);

    NSArray<UIView *> *buttons = @[self.paintBrushButton, self.markPenButton, self.shapeButton, self.textButton];
    NSArray<UIView *> *colorViews = @[self.paintStrokeColorView, self.markStrokeColorView, self.shapeStrokeColorView, self.textStrokeColorView];
    for (NSInteger i = 0; i < buttons.count; i++) {
        UIView *button = [buttons bjl_objectAtIndex:i];
        UIView *colorView = [colorViews bjl_objectAtIndex:i];
        [self addSubview:colorView];
        if (iPhone) {
            [colorView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.right.equalTo(self);
                make.centerY.equalTo(button);
                make.height.equalTo(@(BJLScToolViewColorLength));
                make.width.equalTo(@(BJLScToolViewColorSize));
            }];
        }
        else {
            [colorView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.bottom.equalTo(self);
                make.centerX.equalTo(button);
                make.width.equalTo(@(BJLScToolViewColorLength));
                make.height.equalTo(@(BJLScToolViewColorSize));
            }];
        }
    }
}

#pragma mark - Observing

- (void)makeObserving {
    bjl_weakify(self);
    BJLPropertyFilter ifIntegerChanged = ^BOOL(NSNumber *_Nullable now, NSNumber *_Nullable old, BJLPropertyChange *_Nullable change) {
        // bjl_strongify(self);
        return now != old;
    };

    [self bjl_kvo:BJLMakeProperty(self.room, state)
           filter:ifIntegerChanged
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             if (self.room.state == BJLRoomState_connected) {
                 [self remakeToolButtonConstraints];
             }
             return YES;
         }];

    if (!self.room.loginUser.isTeacherOrAssistant) {
        [self bjl_kvoMerge:@[BJLMakeProperty(self.room.drawingVM, drawingGranted),
            BJLMakeProperty(self.room.speakingRequestVM, speakingEnabled),
            BJLMakeProperty(self.room.documentVM, authorizedH5PPT)]
                    filter:ifIntegerChanged
                  observer:^(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                      bjl_strongify(self);
                      [self remakeToolButtonConstraints];
                  }];
    }

    if (self.room.loginUser.isAssistant) {
        [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveAssistantaAuthorityChanged)
                 observer:^BOOL {
                     bjl_strongify(self);
                     // 权限变更  重新布局
                     [self remakeToolButtonConstraints];
                     return YES;
                 }];
    }

#pragma mark - strokeColor

    // 小黑板使用中，老师取消授权画笔时，重置画笔工具状态
    [self bjl_kvo:BJLMakeProperty(self.room.drawingVM, brushOperateMode)
        filter:^BJLControlObserving(NSNumber *_Nullable value, NSNumber *_Nullable oldValue, BJLPropertyChange *_Nullable change) {
            //        bjl_strongify(self);
            BJLBrushOperateMode mode = value.integerValue;
            return (BJLBrushOperateMode_defaut == mode && value.integerValue != oldValue.integerValue);
        }
        observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
            bjl_strongify(self);
            [self cancelCurrentSelectedButton];
            return YES;
        }];

    //    此处主要是处理文字画笔工具再编辑时,更新画笔工具的状态
    [self bjl_kvo:BJLMakeProperty(self.room.drawingVM, brushOperateMode)
        filter:^BJLControlObserving(NSNumber *_Nullable value, NSNumber *_Nullable oldValue, BJLPropertyChange *_Nullable change) {
            bjl_strongify(self);
            BJLBrushOperateMode mode = value.integerValue;
            return (BJLBrushOperateMode_draw == mode
                    && value.integerValue != oldValue.integerValue
                    && self.room.drawingVM.drawingShapeType == BJLDrawingShapeType_text);
        }
        observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
            bjl_strongify(self);
            if (self.currentSelectedButton == self.selectButton) {
                [self cancelCurrentSelectedButton];

                self.currentSelectedButton = self.textButton;
                self.currentSelectedButton.selected = YES;
            }
            return YES;
        }];

    [self bjl_kvo:BJLMakeProperty(self.room.drawingVM, doodleStrokeWidth)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             CGFloat strokeWidth = self.room.drawingVM.doodleStrokeWidth;
             if (self.markPenButton.selected) {
                 self.markStrokeWidth = strokeWidth;
             }
             else {
                 self.doodleStrokeWidth = strokeWidth;
             }
             return YES;
         }];

    [self bjl_kvo:BJLMakeProperty(self.room.drawingVM, hasSelectedShape)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             UIImage *image = self.room.drawingVM.hasSelectedShape ? [UIImage bjl_imageNamed:@"bjl_toolbox_delete_normal"] : [UIImage bjl_imageNamed:@"bjl_toolbox_eraser_normal"];
             UIImage *selectedImage = self.room.drawingVM.hasSelectedShape ? [UIImage bjl_imageNamed:@"bjl_toolbox_delete_selected"] : [UIImage bjl_imageNamed:@"bjl_toolbox_eraser_selected"];
             [self.eraserButton bjl_setImage:image forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
             [self.eraserButton bjl_setImage:selectedImage forState:UIControlStateSelected possibleStates:UIControlStateHighlighted];
             return YES;
         }];

    // 学生本地页面和远端老师页码不一致时，需要更新drawingEnabled
    [self bjl_kvo:BJLMakeProperty(self.room.slideshowViewController, pageIndex)
         observer:^BOOL(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             if (self.room.slideshowViewController.pageIndex != self.room.documentVM.currentSlidePage.documentPageIndex) {
                 if (!self.room.loginUser.isTeacherOrAssistant
                     && self.room.slideshowViewController.drawingEnabled) {
                     [self.room.drawingVM updateDrawingEnabled:NO];
                 }
             }
             return YES;
         }];

#pragma mark - 手写板

    // 其他位置触发画笔模式变更时，更新按钮选中状态
    [self bjl_kvoMerge:@[BJLMakeProperty(self.room.drawingVM, brushOperateMode),
        BJLMakeProperty(self.room.drawingVM, drawingShapeType)]
              observer:^(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                  bjl_strongify(self);
                  if (self.ignoreDrawingTypeChange) {
                      return;
                  }
                  UIButton *button = [self selectedButtonWithCurrentDrawingState];
                  if (button && !button.selected) {
                      [self didSelectButton:button needNotShowSubWindow:YES];
                  }
              }];

    [self.room.drawingVM setRequestChangeFocusPageCallback:^(BOOL nextPage) {
        bjl_strongify(self);
        if (nextPage) {
            [self.room.slideshowViewController pageStepForward];
        }
        else {
            [self.room.slideshowViewController pageStepBackward];
        }
    }];
}

#pragma mark - update toolbox shape

- (void)updateToolboxShape:(NSString *)shapeKey {
    UIImage *image = [UIImage bjl_imageNamed:[NSString stringWithFormat:@"bjl_toolbox_%@_normal", shapeKey]];
    UIImage *selectedImage = [UIImage bjl_imageNamed:[NSString stringWithFormat:@"bjl_toolbox_%@_selected", shapeKey]];
    [self.shapeButton bjl_setImage:image forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
    [self.shapeButton bjl_setImage:selectedImage forState:UIControlStateSelected possibleStates:UIControlStateHighlighted];
}

- (BOOL)pptButtonIsSelect {
    return (self.currentSelectedButton == self.PPTButton) && (self.PPTButton.superview != nil);
}

- (void)showTeachingAidButtonBadgePoint:(BOOL)show {
    self.teachingAidButtonBadgeLabel.hidden = !show;
}

#pragma mark - action

- (void)cancelCurrentSelectedButton {
    self.currentSelectedButton.selected = NO;
    self.currentSelectedButton = nil;
    [self updatePPTUserInteractState];
}

- (void)updatePPTUserInteractState {
    BOOL havePermission = self.room.loginUser.isTeacherOrAssistant || self.room.documentVM.authorizedH5PPT;
    BOOL enablePPTInteract = havePermission && [self pptButtonIsSelect];
    [self.room.slideshowViewController updateWebPPTInteractable:enablePPTInteract];
}

- (void)didSelectButton:(UIButton *)button {
    [self didSelectButton:button needNotShowSubWindow:NO];
}

- (void)didSelectButton:(UIButton *)button needNotShowSubWindow:(BOOL)needNotShowSubWindow {
    self.ignoreDrawingTypeChange = YES;
    // 画笔开关: TODO: coding style
    BOOL drawingEnabled = (button != self.currentSelectedButton
                           && (button == self.selectButton
                               || button == self.paintBrushButton
                               || button == self.markPenButton
                               || button == self.shapeButton
                               || button == self.textButton
                               || button == self.laserPointerButton
                               || button == self.eraserButton));
    if (drawingEnabled) {
        if (self.room.loginUser.isTeacherOrAssistant) {
            if (!self.room.roomVM.liveStarted) {
                [self showErrorMessage:BJLLocalizedString(@"上课状态才能开启画笔")];
                return;
            }
        }
        else if (!self.room.drawingVM.drawingGranted) {
            [self showErrorMessage:BJLLocalizedString(@"未被授权使用画笔")];
            return;
        }

        if (self.room.slideshowViewController.pageIndex != self.room.documentVM.currentSlidePage.documentPageIndex) {
            [self showErrorMessage:BJLLocalizedString(@"PPT 翻页与老师不同步，不能开启画笔")];
            return;
        }
    }

    BOOL enableSelectButton = self.room.drawingVM.hasSelectedShape;
    // 如果点击当前选中的 button
    if ([button isEqual:self.currentSelectedButton]) {
        [self cancelCurrentSelectedButton];
    }
    // 点击的 button 不是当前选中的 button
    else {
        // 选中点击的 button
        self.currentSelectedButton.selected = NO;
        self.currentSelectedButton = button;
        self.currentSelectedButton.selected = YES;
    }

    [self updatePPTUserInteractState];

    BJLError *requestError = [self.room.drawingVM updateDrawingEnabled:drawingEnabled];
    if (self.paintBrushButton.selected) {
        // UI上虚线和涂鸦画笔互斥
        self.room.drawingVM.drawingShapeType = BJLDrawingShapeType_doodle;
        self.room.drawingVM.isDottedLine = NO;
    }

    // 普通画笔、马克笔线宽及透明度设置
    if (self.markPenButton.selected) {
        self.room.drawingVM.drawingShapeType = BJLDrawingShapeType_doodle;
        self.room.drawingVM.doodleStrokeWidth = self.markStrokeWidth;
        self.room.drawingVM.strokeAlpha = 0.3;
    }
    else {
        self.room.drawingVM.doodleStrokeWidth = self.doodleStrokeWidth;
        self.room.drawingVM.strokeAlpha = 1.0;
    }

    // 画笔模式操作模式
    BJLBrushOperateMode operateMode = BJLBrushOperateMode_defaut;
    if (drawingEnabled
        && !self.selectButton.selected
        && !self.eraserButton.selected) {
        // 添加画笔开关
        operateMode = BJLBrushOperateMode_draw;
    }
    else if (self.selectButton.selected) {
        // 画笔选择开关
        operateMode = BJLBrushOperateMode_select;
    }
    else if (self.eraserButton.selected) {
        // 橡皮擦开关
        operateMode = BJLBrushOperateMode_erase;
    }

    requestError = [self.room.drawingVM updateBrushOperateMode:operateMode] ?: requestError;

    // request 之后画笔的开关状态, writingBoardEnabled = YES 则返回有画笔权限
    drawingEnabled = self.room.drawingVM.drawingEnabled;
    // 激光笔
    if (self.laserPointerButton.selected) {
        if (drawingEnabled) {
            self.room.drawingVM.drawingShapeType = BJLDrawingShapeType_laserPoint;
        }
    }
    else {
        if (self.room.drawingVM.drawingShapeType == BJLDrawingShapeType_laserPoint) {
            self.room.drawingVM.drawingShapeType = BJLDrawingShapeType_doodle;
            self.room.drawingVM.isDottedLine = NO;
        }
    }

    // 文字
    if (self.textButton.selected) {
        if (drawingEnabled) {
            self.room.drawingVM.drawingShapeType = BJLDrawingShapeType_text;
        }
    }
    else {
        if (self.room.drawingVM.drawingShapeType == BJLDrawingShapeType_text) {
            self.room.drawingVM.drawingShapeType = BJLDrawingShapeType_doodle;
        }
    }

    // 图形
    if (self.shapeButton.selected) {
        if (drawingEnabled) {
            // 设置图形
            if (self.shapeFill && !self.room.drawingVM.fillColor) {
                self.room.drawingVM.fillColor = self.room.drawingVM.strokeColor;
            }
            self.room.drawingVM.drawingShapeType = self.currentToolboxShape;
        }
    }

    //requestError 是获取的大黑板的drawingEnabled, 如果有小黑板的画笔权限不报错
    if (requestError && !drawingEnabled) {
        if (self.showErrorMessageCallback) {
            self.showErrorMessageCallback(requestError.localizedFailureReason);
        }
        [self cancelCurrentSelectedButton];
    }

    // 特别的，橡皮擦删除了框选画笔之后，重置为选择按钮
    if (self.currentSelectedButton == self.eraserButton
        && enableSelectButton) {
        [self.selectButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }

    if (self.toolButtonClickCallback) {
        self.toolButtonClickCallback([self toolViewButtonTypeWithButton:button], button.isSelected, needNotShowSubWindow);
    }
    self.ignoreDrawingTypeChange = NO;
}

- (void)buttonClickAction:(UIButton *)button {
    // 单独处理 coursewareButton
    if (button == self.coursewareButton) {
        if (self.toolButtonClickCallback) {
            self.toolButtonClickCallback([self toolViewButtonTypeWithButton:button], button.isSelected, NO);
        }
    }
}

- (void)showErrorMessage:(NSString *)message {
    if (self.showErrorMessageCallback) {
        self.showErrorMessageCallback(message);
    }
}

#pragma mark - wheel

- (UIView *)makeStrokeColorView:(NSString *)accessibilityIdentifier {
    UIView *view = [UIView new];
    NSString *strokeColor = self.room.drawingVM.strokeColor;
    view.backgroundColor = [UIColor bjl_colorWithHexString:strokeColor];
    self.paintStrokeColor = self.markStrokeColor = self.shapeStrokeColor = self.textStrokeColor = strokeColor;
    view.accessibilityIdentifier = accessibilityIdentifier;
    return view;
}

- (UIButton *)makeButtonWithImage:(NSString *)imageName accessibilityIdentifier:(NSString *)accessibilityIdentifier {
    UIButton *button = [UIButton new];
    button.backgroundColor = [UIColor clearColor];
    CGFloat inset = 2.0;
    button.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset);
    button.accessibilityIdentifier = accessibilityIdentifier;
    UIImage *image = [[UIImage bjl_imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    if (image) {
        [button bjl_setImage:image forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
    }
    [button addTarget:self action:@selector(buttonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)makeButtonWithImage:(nullable NSString *)imageName
                    selectedImage:(nullable NSString *)selectedImageName
          accessibilityIdentifier:(NSString *)accessibilityIdentifier {
    // create custom button
    BJLCornerImageButton *button = [BJLCornerImageButton new];

    button.accessibilityIdentifier = accessibilityIdentifier;
    CGFloat inset = 2.0;
    button.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset);

    button.backgroundSize = CGSizeMake(BJLScToolViewButtonWidth, BJLScToolViewButtonWidth);
    button.backgroundCornerRadius = BJLScToolViewCornerRadius;

    // yes:禁止同时点击; 默认为no，可以同时点击
    button.exclusiveTouch = YES;

    // selected no tint color
    button.tintColor = [UIColor clearColor];
    [button addTarget:self action:@selector(didSelectButton:) forControlEvents:UIControlEventTouchUpInside];

    // use origin image
    UIImage *image = [[UIImage bjl_imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *selectedImage = [[UIImage bjl_imageNamed:selectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    if (image) {
        [button bjl_setImage:image forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
    }
    if (selectedImage) {
        [button bjl_setImage:selectedImage forState:UIControlStateSelected possibleStates:UIControlStateHighlighted];
        button.selectedColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    }
    return button;
}

- (BJLScToolViewButtonType)toolViewButtonTypeWithButton:(UIButton *)button {
    if ([button isEqual:self.selectButton]) {
        return BJLScToolViewButtonType_select;
    }
    else if ([button isEqual:self.PPTButton]) {
        return BJLScToolViewButtonType_ppt;
    }
    else if ([button isEqual:self.paintBrushButton]) {
        return BJLScToolViewButtonType_paintBrush;
    }
    else if ([button isEqual:self.markPenButton]) {
        return BJLScToolViewButtonType_markPen;
    }
    else if ([button isEqual:self.shapeButton]) {
        return BJLScToolViewButtonType_shape;
    }
    else if ([button isEqual:self.textButton]) {
        return BJLScToolViewButtonType_text;
    }
    else if ([button isEqual:self.laserPointerButton]) {
        return BJLScToolViewButtonType_laserPointer;
    }
    else if ([button isEqual:self.eraserButton]) {
        return BJLScToolViewButtonType_eraser;
    }
    else if ([button isEqual:self.coursewareButton]) {
        return BJLScToolViewButtonType_courseware;
    }
    else if ([button isEqual:self.teachingAidButton]) {
        return BJLScToolViewButtonType_teachingAid;
    }

    return BJLScToolViewButtonType_none;
}

- (nullable UIButton *)selectedButtonWithCurrentDrawingState {
    if (self.room.drawingVM.brushOperateMode == BJLBrushOperateMode_erase) {
        return self.eraserButton;
    }
    else if (self.room.drawingVM.brushOperateMode == BJLBrushOperateMode_select) {
        return self.selectButton;
    }
    else if (self.room.drawingVM.brushOperateMode == BJLBrushOperateMode_draw) {
        switch (self.room.drawingVM.drawingShapeType) {
            case BJLDrawingShapeType_doodle:
                return self.room.drawingVM.strokeAlpha == 1.0 ? self.paintBrushButton : self.markPenButton;

            case BJLDrawingShapeType_laserPoint:
                return self.laserPointerButton;

            case BJLDrawingShapeType_oval:
            case BJLDrawingShapeType_arrow:
            case BJLDrawingShapeType_triangle:
            case BJLDrawingShapeType_segment:
            case BJLDrawingShapeType_rectangle:
            case BJLDrawingShapeType_doubleSideArrow:
                return self.shapeButton;

            case BJLDrawingShapeType_text:
                return self.textButton;

            default:
                return nil;
        }
    }
    return nil;
}

#pragma mark - remake

- (void)remakeToolButtonConstraints {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    BOOL iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);

    BOOL is1toN = self.room.roomInfo.roomType == BJLRoomType_1vNClass;
    BOOL drawingGranted = NO;
    if (self.room.loginUser.isTeacher) {
        drawingGranted = YES;
    }
    else if (self.room.loginUser.isAssistant) {
        drawingGranted = [self.room.roomVM getAssistantaAuthorityWithPainter];
    }
    else {
        drawingGranted = (self.room.speakingRequestVM.speakingEnabled || !is1toN) && self.room.drawingVM.drawingGranted;
    }
    NSMutableArray<UIView *> *views = [NSMutableArray new];
    if (self.room.loginUser.isTeacherOrAssistant || self.room.documentVM.authorizedH5PPT) {
        [views bjl_addObject:self.PPTButton];
    }
    if (drawingGranted) {
        [views addObjectsFromArray:[self drawingButtons]];
    }
    // 不论助教是否有上传文档的权限,都需要有coursewareButton按钮
    if (self.room.loginUser.isTeacherOrAssistant && self.room.loginUser.groupID == 0) {
        [views addObjectsFromArray:[self documentButtons]];
        [views addObjectsFromArray:[self optionButtons]];
    }

    else if ([self.room.loginUser canLaunchRollCallWithRoom:self.room]) {
        [views addObjectsFromArray:[self optionButtons]];
    }
    self.views = views;
    BOOL expectedHidden = !self.views.count || self.room.loginUser.isAudition || self.room.loadingVM;
    if (self.expectedHidden != expectedHidden) {
        self.expectedHidden = expectedHidden;
    }

    UIView *last = nil;
    for (UIView *view in views) {
        [self addSubview:view];
        if (iPhone) {
            [view bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                if (last) {
                    make.top.equalTo(last.bjl_bottom).offset(BJLScToolViewButtonSpace);
                    make.centerX.width.height.equalTo(last);
                }
                else {
                    make.top.equalTo(self).offset(BJLScToolViewButtonSpace);
                    make.left.right.equalTo(self);
                    make.height.equalTo(view.bjl_width);
                }
            }];
        }
        else {
            [view bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                if (last) {
                    make.left.equalTo(last.bjl_right).offset(BJLScToolViewButtonSpace);
                    make.centerY.width.height.equalTo(last);
                }
                else {
                    make.left.equalTo(self).offset(BJLScToolViewButtonSpace);
                    make.height.equalTo(@(BJLScToolViewButtonWidth));
                    make.centerY.equalTo(self);
                    make.width.equalTo(view.bjl_height);
                }
            }];
        }
        last = view;
    }
    if (self.remakeConstraintsCallback) {
        self.remakeConstraintsCallback();
    }
    if (drawingGranted) {
        [self remakeStrokeColorConstraints];
    }

    self.PPTButton.selected = NO;
    [self updatePPTUserInteractState];
}

- (NSArray *)drawingButtons {
    return @[self.selectButton, self.paintBrushButton, self.markPenButton, self.shapeButton, self.textButton, self.laserPointerButton, self.eraserButton];
}

- (NSArray *)documentButtons {
    return @[self.coursewareButton];
}

- (NSArray *)optionButtons {
    return @[self.teachingAidButton];
}

- (UILabel *)teachingAidButtonBadgeLabel {
    if (!_teachingAidButtonBadgeLabel) {
        _teachingAidButtonBadgeLabel = [[UILabel alloc] init];
        _teachingAidButtonBadgeLabel.font = [UIFont systemFontOfSize:14];
        _teachingAidButtonBadgeLabel.textColor = [UIColor bjlsc_blueBrandColor];
        _teachingAidButtonBadgeLabel.backgroundColor = [UIColor bjlsc_blueBrandColor];
        _teachingAidButtonBadgeLabel.clipsToBounds = YES;
        _teachingAidButtonBadgeLabel.layer.cornerRadius = 2.5;
        _teachingAidButtonBadgeLabel.hidden = YES;
    }
    return _teachingAidButtonBadgeLabel;
}
@end
