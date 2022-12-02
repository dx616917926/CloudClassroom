//
//  BJLStudentQuestionAnswerWindowViewController.m
//  BJLiveUI
//
//  Created by fanyi on 2019/6/3.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import <BJLiveCore/BJLiveCore.h>

#import "BJLStudentQuestionAnswerWindowViewController.h"
#import "BJLQuestionAnswerOptionCollectionViewCell.h"
#import "BJLWindowTopBar.h"
#import "BJLWindowBottomBar.h"
#import "BJLAppearance.h"

#define onePixel (1.0 / [UIScreen mainScreen].scale)

@interface BJLStudentQuestionAnswerWindowViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, readonly, weak) BJLRoom *room;
@property (nonatomic) BJLAnswerSheet *answerSheet;
@property (nonatomic) NSInteger countDownTime;
@property (nonatomic) BOOL hasSubmit;

@property (nonatomic) BJLWindowTopBar *topBar;
@property (nonatomic) BJLWindowBottomBar *bottomBar;
@property (nonatomic) UIView *containerView;
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) UILabel *commentsLabel, *countDownTimeLabel, *countDownTipLabel;
@property (nonatomic) NSTimer *countDownTimer, *leftTipTimer;

@property (nonatomic) UIView *bottomContainView;
@property (nonatomic) UIButton *submitButton;

@property (nonatomic) NSArray<BJLAnswerSheetOption *> *selectedOptions;
@property (nonatomic) UIView *answerResultContentView;
@property (nonatomic) UICollectionView *optionsResultView;

//由于判断题目下，无法区分选择的是对还是错，所以使用chooseWrong来表示我是否选择的”错“
@property (nonatomic) BOOL chooseWrong;

@end

@implementation BJLStudentQuestionAnswerWindowViewController

- (instancetype)initWithRoom:(BJLRoom *)room
                 answerSheet:(BJLAnswerSheet *)answerSheet {
    self = [super init];
    if (self) {
        self->_room = room;
        self.answerSheet = answerSheet;
        self.countDownTime = self.answerSheet.duration;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = BJLTheme.windowBackgroundColor;

    [self makeSubViews];
    [self makeObservering];
    [self startCountTimer];
}

- (void)dealloc {
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;

    if (self.optionsResultView) {
        self.optionsResultView.delegate = nil;
        self.optionsResultView.dataSource = nil;
    }

    if (self.leftTipTimer) {
        [self.leftTipTimer invalidate];
        self.leftTipTimer = nil;
    }
}

#pragma mark - private
- (CGSize)presentationSize {
    CGRect screenBounds = UIScreen.mainScreen.bounds;
    CGFloat optionHeight = [self answerCollectionViewHeight:10 ipad:25 count:self.answerSheet.options.count];
    CGFloat minWindowHeight = MIN(180 + optionHeight, 300);
    if (self.answerSheet.questionDescription.length) {
        minWindowHeight = minWindowHeight;
    }
    else {
        minWindowHeight = minWindowHeight - 20.0;
    }
    CGFloat minWindowWidth = 260.0;

    CGFloat relativeWidth = minWindowWidth / (CGRectGetWidth(screenBounds) ?: 600.0);
    CGFloat relativeHeight = minWindowHeight / (CGRectGetHeight(screenBounds) ?: 300.0);
    return CGSizeMake(relativeWidth * screenBounds.size.width, relativeHeight * screenBounds.size.height);
}

- (CGFloat)relativeHeightWithRelativeWidth:(CGFloat)relativeWidth aspectRatio:(CGFloat)aspectRatio {
    CGFloat relativeHeight = relativeWidth * BJLAppearance.blackboardAspectRatio;
    return relativeHeight / aspectRatio;
}

- (void)makeSubViews {
    BOOL isPortrait = UIScreen.mainScreen.bounds.size.height > UIScreen.mainScreen.bounds.size.width;

    UIView *topGapLine = ({
        UIView *view = [BJLHitTestView new];
        view.backgroundColor = BJLTheme.separateLineColor;
        bjl_return view;
    });

    self.topBar = ({
        BJLWindowTopBar *view = [BJLWindowTopBar new];
        view.accessibilityIdentifier = BJLKeypath(self, topBar);
        view.captionLabel.text = BJLLocalizedString(@"答题器");
        view.fullscreenButton.hidden = YES;
        view.maximizeButton.hidden = YES;
        view.closeButton.hidden = NO;
        [view.closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:view];
        bjl_return view;
    });

    [self.topBar bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.equalTo(@(BJLAppearance.userWindowDefaultBarHeight));
    }];

    [self.topBar addSubview:topGapLine];
    [topGapLine bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.bottom.left.right.equalTo(self.topBar);
        make.height.equalTo(@(onePixel));
    }];

    self.containerView = ({
        UIView *view = [BJLHitTestView new];
        view.accessibilityIdentifier = BJLKeypath(self, containerView);
        [self.view addSubview:view];
        bjl_return view;
    });
    [self.containerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.topBar.bjl_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.bottomBar.bjl_top);
    }];

    self.countDownTimeLabel = ({
        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"答题倒计时：0:0");
        label.textColor = BJLTheme.viewTextColor;
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentLeft;
        label.accessibilityIdentifier = BJLKeypath(self, countDownTimeLabel);
        [self.containerView addSubview:label];
        bjl_return label;
    });
    [self updateCountDownShowTime];

    self.countDownTipLabel = ({
        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"5秒后自动关闭");
        label.textColor = BJLTheme.viewTextColor;
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentRight;
        label.hidden = YES;
        label.accessibilityIdentifier = BJLKeypath(self, countDownTipLabel);
        [self.containerView addSubview:label];
        bjl_return label;
    });

    self.commentsLabel = ({
        UILabel *label = [UILabel new];
        label.text = self.answerSheet.questionDescription;
        label.textColor = BJLTheme.viewTextColor;
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.accessibilityIdentifier = BJLKeypath(self, commentsLabel);
        [self.containerView addSubview:label];
        bjl_return label;
    });

    UIView *midderView = ({
        UIView *view = [BJLHitTestView new];
        [self.containerView addSubview:view];
        bjl_return view;
    });

    self.collectionView = ({
        // layout
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsZero;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;

        // view
        UICollectionView *view = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        view.backgroundColor = [UIColor clearColor];
        view.showsHorizontalScrollIndicator = NO;
        view.bounces = NO;
        view.alwaysBounceVertical = YES;
        view.pagingEnabled = YES;
        view.dataSource = self;
        view.delegate = self;
        view.accessibilityIdentifier = BJLKeypath(self, collectionView);
        [view registerClass:[BJLQuestionAnswerOptionCollectionViewCell class] forCellWithReuseIdentifier:BJLQuestionAnswerOptionCollectionViewCellID_ChoosenCell];
        [view registerClass:[BJLQuestionAnswerOptionCollectionViewCell class] forCellWithReuseIdentifier:BJLQuestionAnswerOptionCollectionViewCellID_JudgeCell_wrong];
        [view registerClass:[BJLQuestionAnswerOptionCollectionViewCell class] forCellWithReuseIdentifier:BJLQuestionAnswerOptionCollectionViewCellID_JudgeCell_right];
        [midderView addSubview:view];
        bjl_return view;
    });

    [self.countDownTipLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.containerView).offset(BJLAppearance.userWindowDefaultBarHeight + 8);
        make.right.equalTo(self.containerView).offset(-10);
        make.height.equalTo(@(18));
    }];

    [self.countDownTimeLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.containerView).offset(5.0);
        make.left.equalTo(self.containerView.bjl_left).offset(10);
        make.right.lessThanOrEqualTo(self.countDownTipLabel.bjl_left).offset(-10);
        make.height.equalTo(@(18));
    }];

    [midderView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.left.right.equalTo(self.containerView);
        if (isPortrait) {
            make.top.equalTo(self.countDownTimeLabel.bjl_bottom).offset(40.0);
        }
        else {
            make.top.greaterThanOrEqualTo(self.countDownTimeLabel.bjl_bottom);
            make.centerY.equalTo(self.containerView.bjl_centerY).offset(5.0);
        }
        make.bottom.lessThanOrEqualTo(self.containerView).offset(-40);
    }];
    CGFloat optionsViewHeight = 0;
    CGFloat optionsViewWidth = 0;
    BOOL isIphone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    if (self.answerSheet.answerType == BJLAnswerSheetType_Choosen) {
        optionsViewHeight = [self answerCollectionViewHeight:10 ipad:25 count:self.answerSheet.options.count];
        optionsViewWidth = [self.answerSheet.options count] <= 4
                               ? (BJLAppearance.questionAnswerOptionButtonHeight * [self.answerSheet.options count] + (isIphone ? 10 : 25) * ([self.answerSheet.options count] - 1))
                               : (BJLAppearance.questionAnswerOptionButtonHeight * 4 + (isIphone ? 10 : 25) * 3);
    }
    else {
        optionsViewHeight = 75;
        optionsViewWidth = BJLAppearance.questionAnswerOptionButtonHeight * 2 + 25;
    }

    [self.collectionView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.top.equalTo(midderView);
        make.height.equalTo(@(optionsViewHeight));
        make.width.equalTo(@(optionsViewWidth));
        if (!self.answerSheet.questionDescription.length) {
            make.bottom.equalTo(midderView);
        }
    }];

    self.commentsLabel.hidden = !self.answerSheet.questionDescription.length;
    if (self.answerSheet.questionDescription.length) {
        [self.commentsLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.vertical.hugging.compressionResistance.required();
            make.top.equalTo(self.collectionView.bjl_bottom).offset(10);
            make.left.equalTo(midderView).offset(10);
            make.right.equalTo(midderView).offset(-10);
            make.bottom.equalTo(midderView);
        }];
    }

    // bottom bar
    self.bottomBar = ({
        BJLWindowBottomBar *view = [BJLWindowBottomBar new];
        view.accessibilityIdentifier = BJLKeypath(self, bottomBar);
        view.resizeHandleImageView.hidden = isPortrait;
        view.hidden = isPortrait;
        [self.view insertSubview:view belowSubview:self.topBar];
        bjl_return view;
    });
    [self.bottomBar bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.equalTo(@40.0);
    }];

    UIView *bottomGapLine = ({
        UIView *view = [BJLHitTestView new];
        view.backgroundColor = BJLTheme.separateLineColor;
        bjl_return view;
    });
    [self.bottomBar addSubview:bottomGapLine];
    [bottomGapLine bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.left.right.equalTo(self.bottomBar);
        make.height.equalTo(@(onePixel));
    }];

    self.bottomContainView = ({
        UIView *view = [BJLHitTestView new];
        view.accessibilityIdentifier = BJLKeypath(self, bottomContainView);
        [self.bottomBar addSubview:view];
        bjl_return view;
    });
    self.submitButton = ({
        UIButton *button = [UIButton new];
        button.layer.cornerRadius = 4.0;
        button.layer.masksToBounds = YES;
        button.accessibilityIdentifier = BJLKeypath(self, submitButton);
        button.backgroundColor = [BJLTheme brandColor];
        button.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [button setTitle:BJLLocalizedString(@"提交") forState:UIControlStateNormal];
        [button setTitleColor:[BJLTheme buttonTextColor] forState:UIControlStateNormal];
        [button setTitle:BJLLocalizedString(@"修改答案") forState:UIControlStateSelected];
        [button setTitleColor:[BJLTheme buttonTextColor] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
        if (isPortrait) {
            [self.containerView addSubview:button];
        }
        else {
            [self.bottomContainView addSubview:button];
        }
        bjl_return button;
    });

    [self.bottomContainView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.bottomBar);
    }];

    if (isPortrait) {
        [self.submitButton bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.width.equalTo(@120.0);
            make.centerX.equalTo(self.containerView);
            make.top.equalTo(midderView.bjl_bottom).offset(30.0);
        }];
    }
    else {
        [self.submitButton bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.center.equalTo(self.bottomContainView);
            make.top.bottom.equalTo(self.bottomContainView).inset(8.0);
            make.width.equalTo(@80.0);
        }];
    }

    UIView *view = [BJLHitTestView new];
    view.backgroundColor = UIColor.clearColor;
    [self.view addSubview:view];
    [view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.topBar.bjl_bottom);
        make.bottom.equalTo(self.bottomBar.bjl_top);
    }];
}

- (void)startCountTimer {
    [self stopCountDownTimer];
    self.countDownTime--;

    bjl_weakify(self);
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer *_Nonnull timer) {
        bjl_strongify(self);
        if (!self) {
            [timer invalidate];
            return;
        }

        // 倒计时结束
        if (self.countDownTime <= 0) {
            [timer invalidate];

            //            if (!self.hasSubmit) {
            //                [self submit:YES];
            //            }
            // 倒计时时间到就关闭窗口
            if (!self.answerSheet.shouldShowCorrectAnswer) {
                [self close];
            }
            return;
        }

        [self updateCountDownShowTime];
        self.countDownTime--;
    }];
    [[NSRunLoop currentRunLoop] addTimer:self.countDownTimer forMode:NSRunLoopCommonModes];
}

// 销毁倒计时
- (void)stopCountDownTimer {
    if (self.countDownTimer || [self.countDownTimer isValid]) {
        [self.countDownTimer invalidate];
        self.countDownTimer = nil;
    }
}

- (void)updateCountDownShowTime {
    int minutes = ((int)self.countDownTime) / 60;
    int second = ((int)self.countDownTime) % 60;

    self.countDownTimeLabel.text = [NSString stringWithFormat:BJLLocalizedString(@"答题倒计时：%02i:%02i"), minutes, second];
}

#pragma mark - oberseving
- (void)makeObservering {
    bjl_weakify(self);
    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveEndQuestionAnswerWithEndTime:) observer:(BJLMethodObserver) ^ BOOL(NSTimeInterval endTime) {
        bjl_strongify(self);
        if (self.room.loginUser.isAudition) {
            return YES;
        }
        [self stopCountDownTimer];
        self.hasReceiveEndMessage = YES;

        if (self.errorCallback) {
            self.errorCallback(BJLLocalizedString(@"答题器已结束"));
        }

        //        如果学生未曾提交，自动提交
        //        if (!self.hasSubmit) {
        //            [self submit:YES];
        //        }

        if (self.answerSheet.shouldShowCorrectAnswer) {
            [self showCorrectAnswer];
        }
        else {
            [self startTipForAutoClose];
        }
        return YES;
    }];

    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveRevokeQuestionAnswerWithEndTime:) observer:^BOOL(NSTimeInterval endTime) {
        bjl_strongify(self);
        if (self.room.loginUser.isAudition) {
            return YES;
        }

        [self stopCountDownTimer];
        self.hasReceiveEndMessage = YES;

        if (self.errorCallback) {
            self.errorCallback(BJLLocalizedString(@"答题器已被撤销"));
        }
        [self startTipForAutoClose];
        return YES;
    }];
}

- (void)startTipForAutoClose {
    self.containerView.userInteractionEnabled = NO;
    self.submitButton.backgroundColor = [UIColor bjl_colorWithHex:0X9B9B9B];
    self.countDownTipLabel.hidden = NO;

    bjl_weakify(self);
    __block NSInteger leftTipTime = 5;
    self.leftTipTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer *_Nonnull timer) {
        bjl_strongify(self);
        if (!self || leftTipTime <= 0) {
            [self.leftTipTimer invalidate];
            return;
        }

        NSString *message = [NSString stringWithFormat:BJLLocalizedString(@"%td秒后自动关闭"), leftTipTime];
        self.countDownTipLabel.text = message;
        leftTipTime--;
    }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self) {
            [self close];
        }
    });
}

- (void)updateSelectedArrayInfo {
    NSMutableArray<BJLAnswerSheetOption *> *optionsArray = [NSMutableArray new];

    self.chooseWrong = NO;
    for (NSInteger i = 0; i < [self.answerSheet.options count]; i++) {
        BJLAnswerSheetOption *option = [self.answerSheet.options bjl_objectAtIndex:i];
        if (option.key.length && option.selected) {
            [optionsArray addObject:[option copy]];

            if (self.answerSheet.answerType == BJLAnswerSheetType_Judgement && i == 1) {
                self.chooseWrong = YES;
            }
        }
    }
    self.selectedOptions = [optionsArray copy];
}

- (void)showCorrectAnswer {
    self.topBar.captionLabel.text = BJLLocalizedString(@"答题结果");
    NSString *answerString = @"";
    for (BJLAnswerSheetOption *option in self.answerSheet.options) {
        if (option.key.length && option.isAnswer) {
            answerString = [answerString stringByAppendingString:option.key];
            answerString = [answerString stringByAppendingString:@" "];
        }
    }

    self.answerResultContentView = ({
        UIView *view = [BJLHitTestView new];
        view.accessibilityIdentifier = BJLKeypath(self, answerResultContentView);
        view.backgroundColor = BJLTheme.windowBackgroundColor;
        [self.view addSubview:view];
        view;
    });
    [self.answerResultContentView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.containerView);
    }];

    UILabel *tipLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 0;
        label.textColor = BJLTheme.viewTextColor;
        label.font = [UIFont systemFontOfSize:13.0];
        label.text = BJLLocalizedString(@"我的答案");
        label;
    });
    [self.answerResultContentView addSubview:tipLabel];
    [tipLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.equalTo(self.answerResultContentView).offset(5.0);
        make.left.equalTo(self.answerResultContentView).offset(10.0);
        make.height.equalTo(@(20));
    }];

    UIView *view = [UIView new];
    view.layer.borderColor = BJLTheme.buttonBorderColor.CGColor;
    view.layer.borderWidth = onePixel;
    view.layer.cornerRadius = 8.0;
    [self.answerResultContentView addSubview:view];
    [view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(tipLabel.bjl_bottom).offset(10.0);
        make.left.right.equalTo(tipLabel);
        make.centerX.equalTo(self.answerResultContentView);
    }];

    if ([self.selectedOptions count]) {
        // options view
        self.optionsResultView = ({
            // layout
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.sectionInset = UIEdgeInsetsZero;
            layout.scrollDirection = UICollectionViewScrollDirectionVertical;

            // view
            UICollectionView *view = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
            view.backgroundColor = [UIColor clearColor];
            view.showsHorizontalScrollIndicator = NO;
            view.bounces = NO;
            view.alwaysBounceVertical = YES;
            view.pagingEnabled = YES;
            view.dataSource = self;
            view.delegate = self;
            view.userInteractionEnabled = NO;
            [view registerClass:[BJLQuestionAnswerOptionCollectionViewCell class] forCellWithReuseIdentifier:BJLQuestionAnswerOptionCollectionViewCellID_ChoosenCell];
            [view registerClass:[BJLQuestionAnswerOptionCollectionViewCell class] forCellWithReuseIdentifier:BJLQuestionAnswerOptionCollectionViewCellID_JudgeCell_wrong];
            [view registerClass:[BJLQuestionAnswerOptionCollectionViewCell class] forCellWithReuseIdentifier:BJLQuestionAnswerOptionCollectionViewCellID_JudgeCell_right];
            view.accessibilityIdentifier = BJLKeypath(self, optionsResultView);
            view;
        });
        CGFloat optionsViewHeight = 0;
        CGFloat optionsViewWidth = 0;
        BOOL isIphone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
        if (self.answerSheet.answerType == BJLAnswerSheetType_Choosen) {
            optionsViewHeight = [self answerCollectionViewHeight:10 ipad:25 count:self.selectedOptions.count];
            optionsViewWidth = [self.selectedOptions count] <= 4
                                   ? (BJLAppearance.questionAnswerOptionButtonHeight * [self.selectedOptions count] + (isIphone ? 10 : 25) * ([self.selectedOptions count] - 1))
                                   : (BJLAppearance.questionAnswerOptionButtonHeight * 4 + (isIphone ? 10 : 25) * 3);
        }
        else {
            optionsViewHeight = 75;
            optionsViewWidth = BJLAppearance.questionAnswerOptionButtonHeight * [self.selectedOptions count] + 25 * ([self.selectedOptions count] - 1);
        }

        [view addSubview:self.optionsResultView];
        [self.optionsResultView bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.center.equalTo(view);
            make.height.equalTo(@(optionsViewHeight));
            make.width.equalTo(@(optionsViewWidth));
        }];
    }
    else {
        UILabel *label = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            label.textColor = BJLTheme.viewTextColor;
            label.font = [UIFont systemFontOfSize:13.0];
            label.text = BJLLocalizedString(@"您未参与作答~");
            label;
        });
        label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label];
        [label bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.center.equalTo(view);
            make.left.greaterThanOrEqualTo(view);
            make.right.lessThanOrEqualTo(view);
            make.height.equalTo(@(30));
        }];
    }

    UILabel *correctAnswerLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 0;
        label.textColor = BJLTheme.viewTextColor;
        label.font = [UIFont systemFontOfSize:13.0];
        label.text = BJLLocalizedString(@"正确答案：");
        label;
    });

    UILabel *answerLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 0;
        label.textColor = BJLTheme.brandColor;
        label.font = [UIFont systemFontOfSize:13.0];
        label.text = answerString;
        label;
    });
    [self.answerResultContentView addSubview:correctAnswerLabel];
    [self.answerResultContentView addSubview:answerLabel];
    [correctAnswerLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.equalTo(view.bjl_bottom).offset(10.0);
        make.left.equalTo(tipLabel);
        make.height.equalTo(@(20.0));
        make.bottom.equalTo(self.answerResultContentView).offset(-12.0);
    }];
    [answerLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.height.equalTo(correctAnswerLabel);
        make.left.equalTo(correctAnswerLabel.bjl_right).offset(5.0);
    }];
    self.bottomBar.hidden = YES;
    [self.topBar updateConstraints];
}

- (void)close {
    if (self.closeCallback) {
        self.closeCallback();
        return;
    }
    [self bjl_removeFromParentViewControllerAndSuperiew];
}

- (CGFloat)answerCollectionViewHeight:(CGFloat)iphone ipad:(CGFloat)ipad count:(NSInteger)count {
    BOOL isIphone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    CGFloat optionsViewHeight = 0;
    if (count <= 4) {
        optionsViewHeight = BJLAppearance.questionAnswerOptionButtonHeight;
        if (self.answerSheet.answerType == BJLAnswerSheetType_Judgement) {
            optionsViewHeight = BJLAppearance.questionAnswerOptionButtonHeight * 2;
        }
    }
    else if (count <= 4 * 2) {
        optionsViewHeight = BJLAppearance.questionAnswerOptionButtonHeight * 2 + (isIphone ? iphone : ipad);
    }
    else {
        optionsViewHeight = BJLAppearance.questionAnswerOptionButtonHeight * 3 + (isIphone ? iphone : ipad) * 2;
    }
    return optionsViewHeight;
}

#pragma mark - action
- (void)submit {
    if (self.hasReceiveEndMessage) {
        return;
    }

    if (self.hasSubmit) {
        //修改答案
        if (!self.submitButton.selected) {
            //直接提交
            [self updateSelectedArrayInfo];
            self.submitButton.selected = [self submit:NO];
            self.collectionView.userInteractionEnabled = !self.submitButton.selected;
        }
        else {
            //清空选项数据
            self.submitButton.selected = !self.submitButton.selected;
            for (BJLAnswerSheetOption *perOption in self.answerSheet.options) {
                perOption.selected = NO;
            }
            [self.collectionView reloadData];
            self.collectionView.userInteractionEnabled = YES;
        }
    }
    else {
        [self updateSelectedArrayInfo];

        // 首次提交， 直接提交， 然后变为选中状态“修改答案”
        self.hasSubmit = [self submit:NO] || self.hasSubmit;
        self.submitButton.selected = self.hasSubmit;
        self.collectionView.userInteractionEnabled = !self.submitButton.selected;
    }
}

- (BOOL)submit:(BOOL)isAutoSubmit {
    BOOL hasSelectAnswer = NO;
    for (BJLAnswerSheetOption *option in self.answerSheet.options) {
        if (option.selected) {
            hasSelectAnswer = YES;
            break;
        }
    }

    if (!hasSelectAnswer) {
        if (self.errorCallback && !isAutoSubmit) {
            self.errorCallback(BJLLocalizedString(@"请选择答案"));
        }
        return NO;
    }

    if (self.submitCallback) {
        return self.submitCallback(self.answerSheet);
    }

    return YES;
}

- (NSInteger)answerSheetOptionsCount {
    NSInteger count = [self.answerSheet.options count];
    if (self.answerSheet.answerType == BJLAnswerSheetType_Judgement) {
        count = 5;
    }
    if (self.answerSheet.questionDescription.length) {
        count += 4;
    }
    return count;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (collectionView == self.optionsResultView) {
        return ([self.selectedOptions count] / 4) + !!([self.selectedOptions count] % 4);
    }
    return ([self.answerSheet.options count] / 4) + !!([self.answerSheet.options count] % 4);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.optionsResultView) {
        return (([self.selectedOptions count] / 4) > section) ? 4 : ([self.selectedOptions count] % 4);
    }

    return (([self.answerSheet.options count] / 4) > section) ? 4 : ([self.answerSheet.options count] % 4);
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.section * 4 + indexPath.row;
    if (collectionView == self.optionsResultView) {
        BJLAnswerSheetOption *option = [self.selectedOptions bjl_objectAtIndex:index];
        BJLQuestionAnswerOptionCollectionViewCell *cell;
        if (self.answerSheet.answerType == BJLAnswerSheetType_Choosen) {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:BJLQuestionAnswerOptionCollectionViewCellID_ChoosenCell forIndexPath:indexPath];
            [cell updateContentWithOptionKey:option.key isCorrect:option.isAnswer];
        }
        else {
            if (!self.chooseWrong) {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:BJLQuestionAnswerOptionCollectionViewCellID_JudgeCell_right forIndexPath:indexPath];
                [cell updateContentWithJudgOptionKey:option.key isCorrect:option.isAnswer];
            }
            else {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:BJLQuestionAnswerOptionCollectionViewCellID_JudgeCell_wrong forIndexPath:indexPath];
                [cell updateContentWithJudgOptionKey:option.key isCorrect:option.isAnswer];
            }
        }
        return cell;
    }

    BJLAnswerSheetOption *option = [self.answerSheet.options bjl_objectAtIndex:index];

    BJLQuestionAnswerOptionCollectionViewCell *cell;
    if (self.answerSheet.answerType == BJLAnswerSheetType_Choosen) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:BJLQuestionAnswerOptionCollectionViewCellID_ChoosenCell forIndexPath:indexPath];
        [cell updateContentWithOptionKey:option.key isSelected:option.selected];
    }
    else if (self.answerSheet.answerType == BJLAnswerSheetType_Judgement) {
        if (indexPath.row == 0) {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:BJLQuestionAnswerOptionCollectionViewCellID_JudgeCell_right forIndexPath:indexPath];
            [cell updateContentWithSelected:option.selected text:option.key];
        }
        else {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:BJLQuestionAnswerOptionCollectionViewCellID_JudgeCell_wrong forIndexPath:indexPath];
            [cell updateContentWithSelected:option.selected text:option.key];
        }
    }
    bjl_weakify(self);
    [cell setOptionSelectedCallback:^(BOOL selected) {
        bjl_strongify(self);
        NSInteger indexInArray = indexPath.section * 4 + indexPath.row;
        BJLAnswerSheetOption *option = [self.answerSheet.options bjl_objectAtIndex:indexInArray];
        option.selected = selected;

        // 对错题，在选中对的一个之后， 需要把其他的置为错
        if (selected && (self.answerSheet.answerType == BJLAnswerSheetType_Judgement)) {
            for (BJLAnswerSheetOption *perOption in self.answerSheet.options) {
                if (![perOption.key isEqualToString:option.key]) {
                    perOption.selected = NO;
                }
            }
            [self.collectionView reloadData];
        }
        else if (selected && (self.answerSheet.answerType == BJLAnswerSheetType_Choosen)) {
            NSInteger answerCount = 0;
            for (BJLAnswerSheetOption *perOption in self.answerSheet.options) {
                if (perOption.isAnswer) {
                    answerCount++;
                }
            }
            // 选择题为单选题时,选择之后需要把其他的选择清空
            if (answerCount == 1) {
                for (BJLAnswerSheetOption *perOption in self.answerSheet.options) {
                    if (![perOption.key isEqualToString:option.key]) {
                        perOption.selected = NO;
                    }
                }
                [self.collectionView reloadData];
            }
        }
    }];
    return cell ?: [collectionView dequeueReusableCellWithReuseIdentifier:@"sth new" forIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self itemSize];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewFlowLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    CGSize itemSize = [self itemSize];
    BOOL isIphone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    CGFloat itemGap = (isIphone ? 10 : 25);
    NSInteger numberOfItems = [collectionView numberOfItemsInSection:section];
    CGFloat combinedItemWidth = (numberOfItems * itemSize.width) + ((numberOfItems - 1) * itemGap);
    if (numberOfItems < 4) {
        CGFloat padding = (collectionView.bounds.size.width - combinedItemWidth) / 2;
        CGFloat screenScale = [UIScreen mainScreen].scale;
        padding = floor(padding * screenScale) / screenScale;
        return UIEdgeInsetsMake(section != 0 ? itemGap : 0.0, padding, 0.0, 0.0);
    }
    else {
        return UIEdgeInsetsMake(section != 0 ? itemGap : 0.0, 0.0, 0.0, 0.0);
    }
}

- (CGSize)itemSize {
    if (self.answerSheet.answerType == BJLAnswerSheetType_Choosen) {
        return CGSizeMake(BJLAppearance.questionAnswerOptionButtonHeight, BJLAppearance.questionAnswerOptionButtonHeight);
    }
    else {
        return CGSizeMake(BJLAppearance.questionAnswerOptionButtonHeight, 75);
    }
}

@end
