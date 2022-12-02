//
//  BJLAuthRequestViewController.m
//  BJLiveUIBase
//
//  Created by xijia dai on 2021/10/19.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <BJLiveBase/BJLiveBase.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

#import "BJLAuthRequestViewController.h"
#import "BJLAppearance.h"

@interface BJLAuthRequestView: UIView

@property (nonatomic) void (^selectCallback)(BOOL select);
@property (nonatomic) UIButton *iconImageButton, *checkImageButton;
@property (nonatomic) UILabel *nameLabel, *descriptionLabel;

@end

@implementation BJLAuthRequestView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self makeSubviews];
    }
    return self;
}

- (void)makeSubviews {
    self.backgroundColor = BJLTheme.windowBackgroundColor;

    bjl_weakify(self);
    UITapGestureRecognizer *tapGesture = [UITapGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer *_Nullable gesture) {
        bjl_strongify(self);
        if (self.selectCallback) {
            self.selectCallback(self.checkImageButton.selected);
        }
    }];
    [self addGestureRecognizer:tapGesture];

    self.iconImageButton = ({
        UIButton *button = [BJLImageButton new];
        button.userInteractionEnabled = NO;
        button;
    });
    [self addSubview:self.iconImageButton];
    [self.iconImageButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self).offset(18.0);
        make.top.bottom.equalTo(self).inset(26.0);
        make.width.equalTo(self.iconImageButton.bjl_height);
    }];

    self.nameLabel = ({
        UILabel *label = [UILabel new];
        label.font = [UIFont boldSystemFontOfSize:14.0];
        label.textColor = BJLTheme.viewSubTextColor;
        label.textAlignment = NSTextAlignmentLeft;
        label.numberOfLines = 1;
        label;
    });
    [self addSubview:self.nameLabel];
    [self.nameLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.iconImageButton.bjl_right).offset(10.0);
        make.top.equalTo(self.iconImageButton);
        make.height.equalTo(@20.0);
    }];

    self.descriptionLabel = ({
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:14.0];
        label.textColor = BJLTheme.viewSubTextColor;
        label.textAlignment = NSTextAlignmentLeft;
        label.numberOfLines = 2;
        label;
    });
    [self addSubview:self.descriptionLabel];
    [self.descriptionLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.nameLabel);
        make.top.equalTo(self.nameLabel.bjl_bottom);
    }];

    self.checkImageButton = ({
        UIButton *button = [BJLImageButton new];
        button.userInteractionEnabled = NO;
        [button bjl_setImage:[UIImage bjl_imageNamed:@"bjl_check_select_normal"] forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        [button bjl_setImage:[UIImage bjl_imageNamed:@"bjl_check_select_selected"] forState:UIControlStateSelected possibleStates:UIControlStateHighlighted];
        button;
    });
    [self addSubview:self.checkImageButton];
    [self.checkImageButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.right.equalTo(self);
        make.height.width.equalTo(@32.0);
    }];
    [self updateSelectStyle:NO];
}

- (void)updateSelectStyle:(BOOL)select {
    if (select) {
        self.layer.masksToBounds = NO;
        self.layer.shadowOpacity = 0.1;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0.0, 5.0);
        self.layer.shadowRadius = 10.0;
        self.layer.borderWidth = 0.0;
    }
    else {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 8.0;
        self.layer.borderColor = BJLTheme.roomBackgroundColor.CGColor;
        self.layer.borderWidth = 2.0;
        self.layer.shadowOpacity = 0.0;
    }
    self.iconImageButton.selected = select;
    self.checkImageButton.selected = select;
}

@end

@interface BJLAuthRequestViewController ()

@property (nonatomic) UIView *contentView;
@property (nonatomic) UILabel *welcomeLabel, *noteLabel, *explainLabel;
@property (nonatomic) BJLAuthRequestView *cameraRequestView, *microphoneRequestView, *fileRequestView;
@property (nonatomic) UIButton *enterButton;

@end

@implementation BJLAuthRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeSubviews];
}

- (void)makeSubviews {
    if (!BJLTheme.hasInitial) {
        [BJLTheme setupColorWithConfig:nil];
    }
    self.view.backgroundColor = BJLTheme.windowBackgroundColor;
    BOOL iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    bjl_weakify(self);
    self.enterButton = ({
        UIButton *button = [UIButton new];
        button.layer.cornerRadius = 28.0;
        button.clipsToBounds = YES;
        [button bjl_setTitle:BJLLocalizedString(@"进入APP") forState:UIControlStateNormal];
        [button bjl_setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
        [button bjl_setBackgroundColor:BJLTheme.brandColor forState:UIControlStateNormal];
        [button bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            if (self.enterCallback) {
                self.enterCallback();
            }
        }];
        button;
    });
    [self.view addSubview:self.enterButton];
    [self.enterButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.bottom.equalTo(self.view.bjl_safeAreaLayoutGuide).offset(iPhone ? -24.0 : -40.0);
        make.size.equal.sizeOffset(CGSizeMake(330.0, 56.0));
        make.centerX.equalTo(self.view);
    }];

    self.contentView = ({
        UIView *view = [UIView new];
        view;
    });
    [self.view addSubview:self.contentView];
    [self.contentView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.enterButton.bjl_top);
        make.width.lessThanOrEqualTo(self.view);
        make.width.equalTo(@375.0).priorityHigh();
    }];

    CGFloat contentInset = 20.0;
    CGFloat requestViewSpace = 12.0;
    CGFloat requestViewHeight = 108.0;

    self.cameraRequestView = ({
        BJLAuthRequestView *view = [BJLAuthRequestView new];
        view.nameLabel.text = BJLLocalizedString(@"摄像头");
        view.descriptionLabel.text = BJLLocalizedString(@"授课过程中，如果需要视频直播展示\n我们想使用该权限");
        [view.iconImageButton bjl_setImage:[UIImage bjl_imageNamed:@"bjl_check_camera_normal"] forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        [view.iconImageButton bjl_setImage:[UIImage bjl_imageNamed:@"bjl_check_camera_selected"] forState:UIControlStateSelected possibleStates:UIControlStateHighlighted];
        bjl_weakify(view);
        [view setSelectCallback:^(BOOL select) {
            bjl_strongify(view);
            if (select) {
                return;
            }
            [BJLAuthorization checkMicrophoneAccessAndRequest:YES callback:^(BOOL granted, UIAlertController *_Nullable alert) {
                if (granted) {
                    [view updateSelectStyle:YES];
                }
                else if (alert) {
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }];
        }];
        view;
    });

    self.microphoneRequestView = ({
        BJLAuthRequestView *view = [BJLAuthRequestView new];
        view.nameLabel.text = BJLLocalizedString(@"麦克风");
        view.descriptionLabel.text = BJLLocalizedString(@"授课过程中，如果需要语音沟通交流\n我们想使用该权限");
        [view.iconImageButton bjl_setImage:[UIImage bjl_imageNamed:@"bjl_check_mic_normal"] forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        [view.iconImageButton bjl_setImage:[UIImage bjl_imageNamed:@"bjl_check_mic_selected"] forState:UIControlStateSelected possibleStates:UIControlStateHighlighted];
        bjl_weakify(view);
        [view setSelectCallback:^(BOOL select) {
            bjl_strongify(view);
            if (select) {
                return;
            }
            [BJLAuthorization checkCameraAccessAndRequest:YES callback:^(BOOL granted, UIAlertController *_Nullable alert) {
                if (granted) {
                    [view updateSelectStyle:YES];
                }
                else if (alert) {
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }];
        }];
        view;
    });

    self.fileRequestView = ({
        BJLAuthRequestView *view = [BJLAuthRequestView new];
        view.nameLabel.text = BJLLocalizedString(@"文件访问");
        view.descriptionLabel.text = BJLLocalizedString(@"授课过程中，如果需要上传课件图片\n我们想使用该权限");
        [view.iconImageButton bjl_setImage:[UIImage bjl_imageNamed:@"bjl_check_file_normal"] forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        [view.iconImageButton bjl_setImage:[UIImage bjl_imageNamed:@"bjl_check_file_selected"] forState:UIControlStateSelected possibleStates:UIControlStateHighlighted];
        bjl_weakify(view);
        [view setSelectCallback:^(BOOL select) {
            bjl_strongify(view);
            [BJLAuthorization checkPhotosAccessAndRequest:YES callback:^(BOOL granted, UIAlertController *_Nullable alert) {
                if (select) {
                    return;
                }
                if (granted) {
                    [view updateSelectStyle:YES];
                }
                else if (alert) {
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }];
        }];
        view;
    });

    AVAuthorizationStatus cameraAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    [self.cameraRequestView updateSelectStyle:cameraAuthStatus == AVAuthorizationStatusAuthorized];
    AVAuthorizationStatus microphoneAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    [self.microphoneRequestView updateSelectStyle:microphoneAuthStatus == AVAuthorizationStatusAuthorized];
    PHAuthorizationStatus photoAuthStatus = PHAuthorizationStatusNotDetermined;
    if (@available(iOS 14.0, *)) {
        photoAuthStatus = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
    }
    else {
        photoAuthStatus = [PHPhotoLibrary authorizationStatus];
    }
    [self.fileRequestView updateSelectStyle:photoAuthStatus == PHAuthorizationStatusAuthorized];

    NSArray<UIView *> *requestViews = @[self.cameraRequestView, self.microphoneRequestView, self.fileRequestView];
    UIStackView *authRequestStackView = ({
        UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:requestViews];
        stackView.spacing = requestViewSpace;
        stackView.axis = UILayoutConstraintAxisVertical;
        stackView.alignment = UIStackViewAlignmentFill;
        stackView.distribution = UIStackViewDistributionEqualSpacing;
        stackView;
    });
    [self.contentView addSubview:authRequestStackView];
    [authRequestStackView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.center.equalTo(self.contentView);
        make.left.right.equalTo(self.contentView).inset(contentInset);
        make.height.equalTo(@(requestViewHeight * requestViews.count + requestViewSpace * (requestViews.count - 1)));
    }];

    self.noteLabel = ({
        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"为保证您能正常使用云端课堂相关功能\n需要向您申请以下权限：");
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:14.0];
        label.textColor = BJLTheme.viewTextColor;
        label.numberOfLines = 2;
        label;
    });
    [self.contentView addSubview:self.noteLabel];
    [self.noteLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.contentView).offset(contentInset);
        make.bottom.equalTo(authRequestStackView.bjl_top).offset(-24.0);
        make.height.equalTo(@46.0);
    }];

    self.welcomeLabel = ({
        UILabel *label = [UILabel new];
        label.font = [UIFont boldSystemFontOfSize:28.0];
        label.text = BJLLocalizedString(@"欢迎使用");
        label.textColor = BJLTheme.viewTextColor;
        label.textAlignment = NSTextAlignmentLeft;
        label.numberOfLines = 1;
        label;
    });
    [self.contentView addSubview:self.welcomeLabel];
    [self.welcomeLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.contentView).offset(contentInset);
        make.height.equalTo(@40.0);
        make.bottom.equalTo(self.noteLabel.bjl_top);
    }];

    self.explainLabel = ({
        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"以上选项为直播互动授课必要功能，如无授权将有可能直接影响您正常上课体验，授权开启后您也可以在系统设置中关闭相应授权，也可在APP内设置关闭相关功能。");
        label.textColor = BJLTheme.viewTextColor;
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:14.0];
        label;
    });
    [self.contentView addSubview:self.explainLabel];
    [self.explainLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(authRequestStackView.bjl_bottom).offset(24.0);
        make.left.right.equalTo(self.contentView).inset(contentInset);
    }];
}

@end
