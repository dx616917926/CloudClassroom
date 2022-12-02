//
//  BJLDocumentFileView.m
//  BJLiveUI-BJLInteractiveClass
//
//  Created by xijia dai on 2018/9/26.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJLDocumentFileView.h"
#import "BJLAppearance.h"
#import "UIView+panGesture.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLDocumentFileView ()

@property (nonatomic, weak) BJLRoom *room;

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIView *topSingleLine;
@property (nonatomic, readwrite) UIButton *closeButton;

// 上传文件 选择栏
@property (nonatomic) UIView *documentTypeLine, *searchSingleLine;
@property (nonatomic, readwrite) UIButton *documentTipButton;
@property (nonatomic, readwrite) UIButton *showDocumentButton;
@property (nonatomic, readwrite) UIButton *showMyCloudFileButton;
@property (nonatomic, readwrite) UIButton *showMyHomeworkButton;

// 搜索视图
@property (nonatomic, readwrite) UIView *searchContainerView, *searchTextFieldContainerView;
@property (nonatomic, readwrite) BJLButton *uploadFileButton, *uploadImageButton;
;
@property (nonatomic, readwrite) BJLButton *allowStudentUploadButton;
@property (nonatomic, readwrite) UITextField *searchTextField;
@property (nonatomic, readwrite) UIButton *clearSearchButton;
@property (nonatomic, readwrite) UITextView *cloudDirectoryTextView;

// 如果存在文档, 显示 tableview
@property (nonatomic, readwrite) UITableView *tableView;
@property (nonatomic, readwrite) UIView *progressHUDLayer;

// 如果不存在文档, 显示 empty view, 所有内容都加到这个视图上
@property (nonatomic, readwrite) UIView *emptyView;
@property (nonatomic, readwrite) UILabel *emptyMessageLabel;

// 当前展示的文档类型
@property (nonatomic, readwrite) BJLDocumentFileLayoutType documentFileLayoutType;

@end

@implementation BJLDocumentFileView

- (instancetype)initWithRoom:(BJLRoom *)room {
    if (self = [super init]) {
        self.room = room;
        self.documentFileLayoutType = -1;
        [self makeSubviewsAndConstraints];
        [self makeObserving];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.showDocumentButton) {
        [self.showDocumentButton bjl_drawRectCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(BJLAppearance.documentFileButtonCornerRadius, BJLAppearance.documentFileButtonCornerRadius)];
        [self updateDocumentTabStyle:self.showDocumentButton shouldSelected:self.showDocumentButton.selected];
    }

    if (self.showMyCloudFileButton) {
        [self.showMyCloudFileButton bjl_drawRectCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(BJLAppearance.documentFileButtonCornerRadius, BJLAppearance.documentFileButtonCornerRadius)];
        [self updateDocumentTabStyle:self.showMyCloudFileButton shouldSelected:self.showMyCloudFileButton.selected];
    }

    if (self.showMyHomeworkButton) {
        [self.showMyHomeworkButton bjl_drawRectCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(BJLAppearance.documentFileButtonCornerRadius, BJLAppearance.documentFileButtonCornerRadius)];
        [self updateDocumentTabStyle:self.showMyHomeworkButton shouldSelected:self.showMyHomeworkButton.selected];
    }
}

#pragma mark - private view

- (void)makeSubviewsAndConstraints {
    self.backgroundColor = [UIColor clearColor];
    // shadow
    self.layer.masksToBounds = NO;
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.2].CGColor;
    self.layer.shadowOffset = CGSizeMake(0.0, 5.0);
    self.layer.shadowRadius = 10.0;

    UIView *backgroundView = ({
        UIView *view = [BJLHitTestView new];
        view.backgroundColor = BJLTheme.windowBackgroundColor;
        // border && corner
        view.layer.cornerRadius = 8.0;
        view.layer.masksToBounds = YES;
        view.accessibilityIdentifier = @"backgroundView";
        view;
    });
    [self addSubview:backgroundView];
    [backgroundView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    // title
    self.titleLabel = ({
        UILabel *label = [UILabel new];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = self.room.loginUser.isStudent ? BJLLocalizedString(@"作业区") : BJLLocalizedString(@"选择文件");
        label.textColor = BJLTheme.viewTextColor;
        label.font = [UIFont systemFontOfSize:14.0];
        label;
    });
    [self addSubview:self.titleLabel];
    [self.titleLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(self).offset(16.0);
        make.top.equalTo(self);
        make.height.equalTo(@32.0);
    }];
    // close button
    self.closeButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor clearColor];
        [button setImage:[UIImage bjl_imageNamed:@"window_close_gray"] forState:UIControlStateNormal];
        button;
    });
    [self addSubview:self.closeButton];
    [self.closeButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.right.equalTo(self).offset(-8.0);
        make.top.bottom.equalTo(self.titleLabel);
        make.width.equalTo(self.closeButton.bjl_height);
    }];

    // top shadow line
    self.topSingleLine = [self createShadowSingleLine];
    [self addSubview:self.topSingleLine];
    // 因为设置了不裁切, 所以左右在设置约束的时候减少 1.0, 使得显示时不会到达边界
    [self.topSingleLine bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(self).offset(1.0);
        make.right.equalTo(self).offset(-1.0);
        make.top.equalTo(self.titleLabel.bjl_bottom);
        make.height.equalTo(@(1.0));
    }];

    if (self.room.loginUser.isTeacherOrAssistant) {
        [self makeDocumentTypeChangeView];
    }

    [self makeDocumentSearchView];
    [self makeDocumentsListView];

    [self makeEmptyView];
    if (self.room.loginUser.isTeacherOrAssistant) {
        [self showDocument];
    }
    else {
        [self showMyHomeworkView];
    }

    self.bjl_titleBarHeight = 32.0;
    [self bjl_addTitleBarPanGesture];
}

- (void)makeDocumentTypeChangeView {
    self.showDocumentButton = [self createDocumentTypeButtonWithTitle:BJLLocalizedString(@"直播间文件") image:nil selectedImage:nil accessibilityIdentifier:BJLKeypath(self, showDocumentButton)];
    [self.showDocumentButton addTarget:self action:@selector(showDocument) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:self.showDocumentButton];
    [self.showDocumentButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.topSingleLine).offset(11.0);
        make.width.equalTo(@(BJLAppearance.documentFileButtonWidth));
        make.height.equalTo(@(BJLAppearance.documentFileButtonHeight));
    }];

    if (self.room.cloudDiskVM.enableCloudStorage) {
        self.showMyCloudFileButton = [self createDocumentTypeButtonWithTitle:BJLLocalizedString(@"我的云盘") image:nil selectedImage:nil accessibilityIdentifier:BJLKeypath(self, showMyCloudFileButton)];
        [self.showMyCloudFileButton addTarget:self action:@selector(showMyCloudView) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:self.showMyCloudFileButton];
        [self.showMyCloudFileButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.equalTo(self.showDocumentButton.bjl_right).offset(8);
            make.top.width.height.equalTo(self.showDocumentButton);
        }];
    }

    if (self.room.featureConfig.enableHomework) {
        self.showMyHomeworkButton = [self createDocumentTypeButtonWithTitle:BJLLocalizedString(@"作业区") image:nil selectedImage:nil accessibilityIdentifier:BJLKeypath(self, showMyHomeworkButton)];
        [self.showMyHomeworkButton addTarget:self action:@selector(showMyHomeworkView) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:self.showMyHomeworkButton];
        [self.showMyHomeworkButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            if (self.showMyCloudFileButton || self.showDocumentButton) {
                make.left.equalTo(self.showMyCloudFileButton.bjl_right ?: self.showDocumentButton.bjl_right).offset(8);
                make.top.width.height.equalTo(self.showMyCloudFileButton ?: self.showDocumentButton);
            }
            else {
                make.left.equalTo(self.titleLabel);
                make.top.equalTo(self.topSingleLine).offset(7);
                make.width.equalTo(@(BJLAppearance.documentFileButtonWidth));
                make.height.equalTo(@(BJLAppearance.documentFileButtonHeight));
            }
        }];

        self.documentTipButton = ({
            UIButton *button = [UIButton new];
            [button setTitle:BJLLocalizedString(@"移动端版本未更新的学生无法使用作业功能") forState:UIControlStateNormal];
            [button bjl_setTitleColor:BJLTheme.viewSubTextColor forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
            [button setImage:[UIImage bjl_imageNamed:@"bjl_document_tip"] forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
            [button.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
            button.userInteractionEnabled = NO;
            button;
        });
        [self addSubview:self.documentTipButton];
        [self.documentTipButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.centerY.equalTo(self.showMyHomeworkButton);
            make.right.equalTo(self).offset(-10.0);
            make.left.greaterThanOrEqualTo(self.showMyCloudFileButton.bjl_right ?: self.showDocumentButton.bjl_right).offset(10);
        }];
    }

    self.documentTypeLine = [self createShadowSingleLine];
    [self addSubview:self.documentTypeLine];
    [self.documentTypeLine bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self).offset(1.0);
        make.right.equalTo(self).offset(-1.0);
        make.top.equalTo(self.showDocumentButton.bjl_bottom);
        make.height.equalTo(@(1.0));
    }];
}

- (void)makeDocumentSearchView {
    self.searchContainerView = [BJLHitTestView new];
    [self addSubview:self.searchContainerView];
    [self.searchContainerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.documentTypeLine.bjl_bottom ?: self.topSingleLine.bjl_bottom);
        make.height.equalTo(@47.0);
    }];

    // 右侧搜索输入框
    self.searchTextFieldContainerView = ({
        UIView *view = [UIView new];
        view.accessibilityIdentifier = @"searchContainerView";
        view.layer.cornerRadius = BJLAppearance.documentFileButtonCornerRadius;
        view.layer.masksToBounds = YES;
        view.layer.borderWidth = 1.0;
        view.layer.borderColor = BJLTheme.buttonBorderColor.CGColor;
        view.backgroundColor = [UIColor clearColor];
        view;
    });
    [self.searchContainerView addSubview:self.searchTextFieldContainerView];
    [self.searchTextFieldContainerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.equalTo(self.searchContainerView.bjl_right).offset(-10.0);
        make.centerY.equalTo(self.searchContainerView);
        make.height.equalTo(@24.0);
        make.width.equalTo(@220.0);
    }];

    UIButton *searchButton = ({
        UIButton *button = [UIButton new];
        button.accessibilityIdentifier = @"searchButton";
        button.backgroundColor = [UIColor clearColor];
        button.alpha = 0.5;
        [button setImage:[UIImage bjl_imageNamed:@"window_search"] forState:UIControlStateNormal];
        button;
    });
    [self.searchTextFieldContainerView addSubview:searchButton];
    [searchButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.bottom.top.equalTo(self.searchTextFieldContainerView);
        make.width.equalTo(searchButton.bjl_height);
    }];

    self.searchTextField = ({
        self.clearSearchButton = ({
            UIButton *button = [UIButton new];
            button.frame = CGRectMake(0, 0, 32.0, 32.0);
            [button setImage:[UIImage bjl_imageNamed:@"window_cleartext"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(clearSearchText) forControlEvents:UIControlEventTouchUpInside];
            button.hidden = YES;
            button;
        });
        UITextField *textField = [UITextField new];
        textField.accessibilityIdentifier = BJLKeypath(self, searchTextField);
        textField.backgroundColor = [UIColor clearColor];
        NSAttributedString *messageAttributedText = [[NSAttributedString alloc] initWithString:BJLLocalizedString(@"请输入文件名搜索")
                                                                                    attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.0],
                                                                                        NSForegroundColorAttributeName: BJLTheme.viewSubTextColor}];
        textField.attributedPlaceholder = messageAttributedText;
        textField.textColor = BJLTheme.viewTextColor;
        textField.returnKeyType = UIReturnKeyGo;
        textField.rightView = self.clearSearchButton;
        textField.rightViewMode = UITextFieldViewModeAlways;
        textField.keyboardType = UIKeyboardTypeURL;
        textField.font = [UIFont systemFontOfSize:14.0];
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.enablesReturnKeyAutomatically = YES;
        textField;
    });
    [self.searchTextFieldContainerView addSubview:self.searchTextField];
    [self.searchTextField bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(searchButton.bjl_right);
        make.top.equalTo(self.searchTextFieldContainerView);
        make.bottom.equalTo(self.searchTextFieldContainerView).offset(-1);
        make.right.equalTo(self.searchTextFieldContainerView);
    }];

    // 左侧操作区域
    self.uploadFileButton = (BJLButton *)[self createDocumentTypeButtonWithTitle:BJLLocalizedString(@"上传文件") image:[UIImage bjl_imageNamed:@"bjl_ic_uploadFile_normal"] selectedImage:[UIImage bjl_imageNamed:@"bjl_ic_uploadFile_normal"] accessibilityIdentifier:@"uploadButton"];
    [self.uploadFileButton bjl_setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
    [self.uploadFileButton setBackgroundColor:[UIColor bjl_colorWithHex:0X1795FF alpha:0.5]];
    self.uploadFileButton.layer.cornerRadius = BJLAppearance.documentFileButtonCornerRadius;
    [self.uploadFileButton addTarget:self action:@selector(uploadFile:) forControlEvents:UIControlEventTouchUpInside];
    [self.searchContainerView addSubview:self.uploadFileButton];
    [self.uploadFileButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        if (self.showDocumentButton) {
            make.left.size.equalTo(self.showDocumentButton);
        }
        else {
            make.left.equalTo(self.titleLabel);
            make.width.equalTo(@(96));
            make.height.equalTo(@(24));
        }
        make.centerY.equalTo(self.searchContainerView);
    }];

    self.uploadImageButton = (BJLButton *)[self createDocumentTypeButtonWithTitle:BJLLocalizedString(@"上传图片") image:[UIImage bjl_imageNamed:@"bjl_ic_uploadImage_normal"] selectedImage:[UIImage bjl_imageNamed:@"bjl_ic_uploadImage_normal"] accessibilityIdentifier:@"uploadImageButton"];
    [self.uploadImageButton bjl_setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
    [self.uploadImageButton setBackgroundColor:[UIColor bjl_colorWithHex:0X1795FF alpha:0.5]];
    self.uploadImageButton.layer.cornerRadius = BJLAppearance.documentFileButtonCornerRadius;
    [self.uploadImageButton addTarget:self action:@selector(uploadImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.searchContainerView addSubview:self.uploadImageButton];
    [self.uploadImageButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.uploadFileButton.bjl_right).offset(20);
        make.width.height.equalTo(self.uploadFileButton);
        make.centerY.equalTo(self.uploadFileButton);
    }];

    if (self.room.loginUser.isTeacherOrAssistant) {
        self.allowStudentUploadButton = (BJLButton *)[self createDocumentTypeButtonWithTitle:BJLLocalizedString(@"允许学生上传") image:[UIImage bjl_imageNamed:@"bjl_homework_forbidUpload"] selectedImage:[UIImage bjl_imageNamed:@"bjl_homework_allowUpload"] accessibilityIdentifier:@"allowButton"];
        self.allowStudentUploadButton.midSpace = 5.0;
        [self.allowStudentUploadButton bjl_setTitleColor:BJLTheme.viewTextColor forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        [self.allowStudentUploadButton bjl_setTitleColor:BJLTheme.brandColor forState:UIControlStateSelected possibleStates:UIControlStateHighlighted];
        [self.allowStudentUploadButton addTarget:self action:@selector(allowStudentUpload:) forControlEvents:UIControlEventTouchUpInside];
        [self.searchContainerView addSubview:self.allowStudentUploadButton];
        [self.allowStudentUploadButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.equalTo(self.uploadImageButton.bjl_right).offset(20);
            make.centerY.equalTo(self.searchContainerView);
            make.horizontal.hugging.compressionResistance.required();
        }];
    }

    UIButton *refreshButton = [BJLImageButton new];
    [refreshButton setImage:[UIImage bjl_imageNamed:@"bjl_homework_refresh"] forState:UIControlStateNormal];
    [refreshButton setImage:[UIImage bjl_imageNamed:@"bjl_homework_refresh_highlight"] forState:UIControlStateHighlighted];
    [refreshButton setImage:[UIImage bjl_imageNamed:@"bjl_homework_refresh_highlight"] forState:UIControlStateNormal | UIControlStateHighlighted];
    [refreshButton addTarget:self action:@selector(refreshHomeworkList:) forControlEvents:UIControlEventTouchUpInside];

    [self.searchContainerView addSubview:refreshButton];
    [refreshButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.equalTo(self.searchTextFieldContainerView.bjl_left).offset(-15);
        make.centerY.equalTo(self.searchContainerView);
        make.width.height.equalTo(@(24));
    }];

    self.cloudDirectoryTextView = ({
        UITextView *textView = [UITextView new];
        textView.textAlignment = NSTextAlignmentLeft;
        textView.font = [UIFont systemFontOfSize:12];
        textView.textColor = BJLTheme.viewTextColor;
        textView.textContainerInset = UIEdgeInsetsZero;
        textView.textContainer.lineFragmentPadding = 0;
        textView.textContainer.maximumNumberOfLines = 1;
        textView.backgroundColor = [UIColor clearColor];
        textView.selectable = YES;
        textView.editable = NO;
        textView.scrollEnabled = NO;
        textView.userInteractionEnabled = YES;
        textView.accessibilityIdentifier = BJLKeypath(self, cloudDirectoryTextView);
        textView.hidden = YES;
        textView;
    });
    [self.searchContainerView addSubview:self.cloudDirectoryTextView];
    NSAttributedString *rootDirectoryString = [[NSAttributedString alloc] initWithString:BJLLocalizedString(@"我的云盘")
                                                                              attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.0],
                                                                                  NSForegroundColorAttributeName: BJLTheme.viewTextColor}];
    CGRect rect = [rootDirectoryString boundingRectWithSize:CGSizeMake(MAXFLOAT, 12.0) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGFloat height = ceil(rect.size.height);
    [self.cloudDirectoryTextView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.titleLabel);
        make.centerY.equalTo(self.searchContainerView).offset(5);
        make.right.equalTo(refreshButton.bjl_left).offset(-10);
        make.height.equalTo(@(height + 10));
    }];

    // 搜索区分割线
    self.searchSingleLine = [self createShadowSingleLine];
    [self.searchContainerView addSubview:self.searchSingleLine];
    [self.searchSingleLine bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self).offset(1.0);
        make.right.equalTo(self).offset(-1.0);
        make.bottom.equalTo(self.searchContainerView.bjl_bottom);
        make.height.equalTo(@(1.0));
    }];
}

// 存在文档时显示的视图
- (void)makeDocumentsListView {
    self.tableView = ({
        UITableView *tableView = [UITableView new];
        tableView.estimatedRowHeight = 50;
        tableView.rowHeight = 50;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.tableFooterView = [UIView new];
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.separatorColor = BJLTheme.separateLineColor;
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        tableView.hidden = YES;
        tableView;
    });
    [self addSubview:self.tableView];
    [self.tableView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.searchContainerView.bjl_bottom);
        make.right.bottom.equalTo(self);
    }];

    self.progressHUDLayer = ({
        UIView *layer = [BJLHitTestView new];
        layer.accessibilityIdentifier = BJLKeypath(self, progressHUDLayer);
        layer;
    });
    [self addSubview:self.progressHUDLayer];
    [self.progressHUDLayer bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.searchContainerView.bjl_bottom);
        make.right.left.bottom.equalTo(self);
    }];
}

// 不存在文档时显示的视图
- (void)makeEmptyView {
    // empty view
    self.emptyView = [BJLHitTestView new];
    [self addSubview:self.emptyView];
    [self.emptyView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.top.equalTo(self.documentTypeLine.bjl_bottom ?: self.topSingleLine.bjl_bottom);
    }];

    // containerView
    UIView *containerView = [UIView new];
    [self.emptyView addSubview:containerView];
    [containerView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.emptyView);
    }];
    // empty label
    self.emptyMessageLabel = ({
        UILabel *label = [UILabel new];
        label.accessibilityIdentifier = BJLKeypath(self, emptyMessageLabel);
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = BJLLocalizedString(@"课程没有关联文件");
        label.textColor = BJLTheme.viewSubTextColor;
        label.font = [UIFont systemFontOfSize:16.0];
        label;
    });
    [containerView addSubview:self.emptyMessageLabel];
    [self.emptyMessageLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.right.equalTo(containerView);
        make.height.equalTo(@16.0);
        make.centerY.equalTo(containerView).offset(4.0);
    }];
    // empty image
    UIImageView *emptyImageView = [UIImageView new];
    emptyImageView.image = [UIImage bjl_imageNamed:@"bjl_document_empty"];
    [containerView addSubview:emptyImageView];
    [emptyImageView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.centerX.equalTo(containerView);
        make.bottom.equalTo(self.emptyMessageLabel.bjl_top).offset(-15);
        make.height.greaterThanOrEqualTo(@50.0);
        make.height.equalTo(@94.0).priorityHigh();
        make.width.equalTo(emptyImageView.bjl_height).multipliedBy(emptyImageView.image.size.width / emptyImageView.image.size.height);
    }];
}

- (void)makeObserving {
    BOOL allow = self.room.homeworkVM.allowStudentUploadHomework;
    self.allowStudentUploadButton.selected = allow;
    if (self.room.loginUser.isStudent) { // 学生需要更新隐藏/展示上传按钮
        self.uploadFileButton.hidden = !allow;
        self.uploadImageButton.hidden = !allow;
    }

    bjl_weakify(self);
    [self bjl_observe:BJLMakeMethod(self.room.homeworkVM, didReceiveAllowStudentUploadHomework:)
             observer:(BJLMethodObserver) ^ BOOL(BOOL allow) {
                 bjl_strongify(self);
                 // 更新老师助教端的按钮状态
                 self.allowStudentUploadButton.selected = allow;

                 if (self.room.loginUser.isStudent) { // 学生需要更新隐藏/展示上传按钮
                     self.uploadFileButton.hidden = !allow;
                     self.uploadImageButton.hidden = !allow;
                 }
                 return YES;
             }];
}

#pragma mark - public

- (void)updateDocumentFileViewHidden:(BOOL)hidden {
    // 如果不存在文档
    if (hidden) {
        // 显示 empty view
        self.tableView.hidden = YES;
        self.emptyMessageLabel.text = [self emptyViewMessage];
        self.emptyView.hidden = NO;
        [self.emptyView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
            make.bottom.right.equalTo(self);
            make.left.equalTo(self);
            make.top.equalTo(self.searchContainerView.bjl_bottom);
        }];
    }
    // 如果存在文档
    else {
        // 隐藏 empty 视图
        self.emptyView.hidden = YES;
        self.tableView.hidden = NO;
    }
}

- (void)updateCloudDirectoryHidden:(BOOL)hidden {
    self.uploadFileButton.hidden = !hidden;
    self.uploadImageButton.hidden = !hidden;
    self.cloudDirectoryTextView.hidden = hidden;
    if (hidden) {
        return;
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(currentCloudDirectoryString)]) {
        [self.delegate currentCloudDirectoryString];
    }
}

#pragma mark - actions

- (void)clearSearchText {
    if (!self.searchTextField.text.length) {
        return;
    }

    self.searchTextField.text = nil;
    self.shouldShowSearchResult = NO;
    self.clearSearchButton.hidden = YES;

    // 调整布局之后抛出回调, 由外界控制数据源
    if (self.willshowFilelistCallback) {
        self.willshowFilelistCallback();
    }
}

- (NSString *)emptyViewMessage {
    switch (self.documentFileLayoutType) {
        case BJLDocumentFileLayoutTypeDocument: {
            if (self.shouldShowSearchResult) {
                return BJLLocalizedString(@"没有找到课件~");
            }
            else {
                return BJLLocalizedString(@"暂无文件");
            }
        }
        case BJLDocumentFileLayoutTypeCloud:
            return BJLLocalizedString(@"暂无文件");
        case BJLDocumentFileLayoutTypeHomework: {
            if (self.shouldShowSearchResult) {
                return BJLLocalizedString(@"没有找到作业~");
            }
            else {
                return BJLLocalizedString(@"暂无作业");
            }
        }
        default:
            return BJLLocalizedString(@"暂无文件");
            break;
    }
}

- (void)showDocument {
    NSAttributedString *messageAttributedText = [[NSAttributedString alloc] initWithString:BJLLocalizedString(@"请输入文件名搜索")
                                                                                attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.0],
                                                                                    NSForegroundColorAttributeName: BJLTheme.viewSubTextColor}];
    self.searchTextField.attributedPlaceholder = messageAttributedText;
    [self switchDocumentType:BJLDocumentFileLayoutTypeDocument];
}

- (void)showMyCloudView {
    NSAttributedString *messageAttributedText = [[NSAttributedString alloc] initWithString:BJLLocalizedString(@"请输入文件名搜索")
                                                                                attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.0],
                                                                                    NSForegroundColorAttributeName: BJLTheme.viewSubTextColor}];
    self.searchTextField.attributedPlaceholder = messageAttributedText;
    [self switchDocumentType:BJLDocumentFileLayoutTypeCloud];
}

- (void)showMyHomeworkView {
    NSAttributedString *messageAttributedText = [[NSAttributedString alloc] initWithString:BJLLocalizedString(@"请输入作业名/昵称")
                                                                                attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.0],
                                                                                    NSForegroundColorAttributeName: BJLTheme.viewSubTextColor}];
    self.searchTextField.attributedPlaceholder = messageAttributedText;
    [self switchDocumentType:BJLDocumentFileLayoutTypeHomework];
    if (self.room.loginUser.isTeacherOrAssistant) {
        if (self.switchToHomeworkCallback) {
            self.switchToHomeworkCallback();
        };
    }
}

- (void)allowStudentUpload:(UIButton *)button {
    button.selected = !button.selected;
    if (self.allowStudentUploadFileCallback) {
        self.allowStudentUploadFileCallback(button.selected);
    }
}

- (void)refreshHomeworkList:(UIButton *)button {
    bjl_returnIfRobot(1);
    if (self.refreshCallback) {
        self.refreshCallback();
    }
}

- (void)uploadFile:(UIButton *)button {
    bjl_returnIfRobot(1);
    if (self.uploadFileCallback) {
        self.uploadFileCallback();
    }
}

- (void)uploadImage:(UIButton *)button {
    bjl_returnIfRobot(1);
    if (self.uploadImageCallback) {
        self.uploadImageCallback(button);
    }
}

- (void)updateDocumentTabStyle:(UIButton *)button shouldSelected:(BOOL)isSelected {
    if (!button) {
        return;
    }
    button.selected = isSelected;
    CGFloat borderWidth = isSelected ? 0 : 1.0;
    UIColor *borderColor = (isSelected ? [UIColor clearColor] : BJLTheme.buttonBorderColor);
    [button bjl_drawBorderWidth:borderWidth
                    borderColor:borderColor
                        corners:UIRectCornerTopLeft | UIRectCornerTopRight
                    cornerRadii:CGSizeMake(BJLAppearance.documentFileButtonCornerRadius, BJLAppearance.documentFileButtonCornerRadius)];
    [button setBackgroundColor:(!isSelected ? [UIColor clearColor] : BJLTheme.brandColor)];
}

- (void)switchDocumentType:(BJLDocumentFileLayoutType)documentFileLayoutType {
    if (self.documentFileLayoutType == documentFileLayoutType) {
        return;
    }

    self.shouldShowSearchResult = NO;
    self.searchTextField.text = nil;

    self.documentFileLayoutType = documentFileLayoutType;
    BOOL isRelatedDocument = (self.documentFileLayoutType == BJLDocumentFileLayoutTypeDocument);
    BOOL isMyCloud = (self.documentFileLayoutType == BJLDocumentFileLayoutTypeCloud);
    BOOL isHomework = (self.documentFileLayoutType == BJLDocumentFileLayoutTypeHomework);

    // 调整UI布局
    [self updateDocumentTabStyle:self.showDocumentButton shouldSelected:isRelatedDocument];
    [self updateDocumentTabStyle:self.showMyCloudFileButton shouldSelected:isMyCloud];
    [self updateDocumentTabStyle:self.showMyHomeworkButton shouldSelected:isHomework];

    self.documentTipButton.hidden = !isHomework;
    self.allowStudentUploadButton.hidden = !isHomework;

    BOOL shouldHiddenSearchTextField = isHomework && self.room.loginUser.isStudent;
    self.searchTextFieldContainerView.hidden = shouldHiddenSearchTextField;
    [self.searchTextFieldContainerView bjl_updateConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.width.equalTo(shouldHiddenSearchTextField ? @(0.0) : @(220.0));
    }];

    [self.tableView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.right.bottom.equalTo(self);
        make.top.equalTo(self.searchContainerView.bjl_bottom);
    }];

    self.emptyMessageLabel.text = [self emptyViewMessage];
    [self.emptyView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.top.equalTo(self.searchContainerView.bjl_bottom);
    }];

    // 调整布局之后抛出回调, 由外界控制数据源
    if (self.willshowFilelistCallback) {
        self.willshowFilelistCallback();
    }

    [self setNeedsLayout];
}

#pragma mark - wheel

- (UIView *)createShadowSingleLine {
    UIView *view = [UIView bjl_createSeparateLine];
    // shadow
    view.layer.masksToBounds = NO;
    view.layer.shadowOpacity = 0.2;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.0, 5.0);
    view.layer.shadowRadius = 10.0;
    return view;
}

- (UIButton *)createDocumentTypeButtonWithTitle:(nullable NSString *)title
                                          image:(nullable UIImage *)image
                                  selectedImage:(nullable UIImage *)selectedImage
                        accessibilityIdentifier:(NSString *)accessibilityIdentifier {
    UIButton *button = [BJLButton new];
    [button setBackgroundColor:[UIColor clearColor]];

    if (title) {
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateNormal | UIControlStateHighlighted];
        [button bjl_setTitleColor:BJLTheme.viewTextColor forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        [button bjl_setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateSelected possibleStates:UIControlStateHighlighted];
    }

    if (image) {
        [button setImage:image forState:UIControlStateNormal];
        [button setImage:image forState:UIControlStateNormal | UIControlStateHighlighted];
    }
    if (selectedImage) {
        [button setImage:selectedImage forState:UIControlStateSelected];
        [button setImage:selectedImage forState:UIControlStateSelected | UIControlStateHighlighted];
    }
    [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
    button.accessibilityIdentifier = accessibilityIdentifier;
    return button;
}

@end

NS_ASSUME_NONNULL_END
