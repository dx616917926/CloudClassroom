//
//  BJLDocumentFileCell.m
//  BJLiveUI
//
//  Created by 凡义 on 2020/9/17.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJLDocumentFileCell.h"
#import "BJLAnnularProgressView.h"
#import "BJLAppearance.h"

NSString
    *const BJLDocumentCellReuseIdentifier = @"kIcDocumentCellReuseIdentifier",
           *const BJLCloudCellReuseIdentifier = @"kIcCloudCellReuseIdentifier",
           *const BJLHomeworkCellReuseIdentifier = @"kIcHomeworkCellReuseIdentifier";

@interface BJLDocumentFileCell ()

@property (nonatomic) BJLUser *loginUser;
@property (nonatomic) BJLDocumentFile *file;

@property (nonatomic) UIImageView *docIcon, *stickyIcon, *relatedDocIcon;
@property (nonatomic) UILabel *documentNameLabel, *documentSizeLabel, *documentFromUserLabel, *uploadTimeLabel;
@property (nonatomic) UILabel *stateLabel;
@property (nonatomic) UIView *optionContainerView;
@property (nonatomic) UIButton *deleteButton, *playButton, *cancelUploadButton, *failedDetailButton, *reuploadButton, *turnToNormalButton, *downloadButton;
@property (nonatomic) BJLAnnularProgressView *downloadProgressView;

@end

@implementation BJLDocumentFileCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUpSubviews];
        [self prepareForReuse];
    }
    return self;
}

- (void)setUpSubviews {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([self.reuseIdentifier isEqualToString:BJLDocumentCellReuseIdentifier]) {
        [self makeDocumentViewsAndConstraints];
    }
    else if ([self.reuseIdentifier isEqualToString:BJLCloudCellReuseIdentifier]) {
        [self makeCloudViewsAndConstraints];
    }
    else if ([self.reuseIdentifier isEqualToString:BJLHomeworkCellReuseIdentifier]) {
        [self makeHomeworkViewsAndConstraints];
    }
}

- (void)makeCommonViewsAndConstraints {
    self.docIcon = [UIImageView new];
    self.documentNameLabel = [self makeLabelWithAccessibilityIdentifier:BJLKeypath(self, documentNameLabel)];
    self.stateLabel = [self makeLabelWithAccessibilityIdentifier:BJLKeypath(self, stateLabel)];
    self.stateLabel.hidden = YES;
    self.stateLabel.textAlignment = NSTextAlignmentCenter;

    self.optionContainerView = [BJLHitTestView new];
    self.optionContainerView.accessibilityIdentifier = BJLKeypath(self, optionContainerView);
    self.deleteButton = [self makeImageButtonWithTitlt:nil image:[UIImage bjl_imageNamed:@"bjl_document_delete"] highLightImage:[UIImage bjl_imageNamed:@"bjl_document_delete_highlight"]];
    self.playButton = [self makeImageButtonWithTitlt:nil image:[UIImage bjl_imageNamed:@"bjl_document_play"] highLightImage:[UIImage bjl_imageNamed:@"bjl_document_play_highlight"]];
    self.failedDetailButton = [self makeImageButtonWithTitlt:BJLLocalizedString(@"失败详情") image:nil highLightImage:nil];
    self.cancelUploadButton = ({
        UIButton *button = [UIButton new];
        [button bjl_setTitle:BJLLocalizedString(@"取消上传") forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        [button bjl_setTitleColor:BJLTheme.viewTextColor forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
        button;
    });

    [self.deleteButton addTarget:self action:@selector(deleteDocument) forControlEvents:UIControlEventTouchUpInside];
    [self.playButton addTarget:self action:@selector(showDocument) forControlEvents:UIControlEventTouchUpInside];
    [self.failedDetailButton addTarget:self action:@selector(showError) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelUploadButton addTarget:self action:@selector(deleteDocument) forControlEvents:UIControlEventTouchUpInside];

    [self.contentView addSubview:self.docIcon];
    [self.contentView addSubview:self.documentNameLabel];
    [self.contentView addSubview:self.stateLabel];
    [self.contentView addSubview:self.optionContainerView];
    [self.contentView addSubview:self.deleteButton];
    [self.contentView addSubview:self.playButton];
    [self.contentView addSubview:self.failedDetailButton];
    [self.contentView addSubview:self.cancelUploadButton];

    [self.docIcon bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(8.0);
        make.width.height.equalTo(@(32.0));
    }];

    [self.stateLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.documentNameLabel.bjl_right);
        make.right.equalTo(self.failedDetailButton.bjl_left);
        make.centerY.equalTo(self.contentView);
    }];

    [self.optionContainerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.height.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-8);
        make.width.equalTo(@(0.0));
    }];

    [self.failedDetailButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.optionContainerView.bjl_left);
    }];
}

- (void)makeDocumentViewsAndConstraints {
    [self makeCommonViewsAndConstraints];

    self.relatedDocIcon = [UIImageView new];
    [self.relatedDocIcon setImage:[UIImage bjl_imageNamed:@"bjl_document_related"]];
    self.documentSizeLabel = [self makeLabelWithAccessibilityIdentifier:BJLKeypath(self, documentSizeLabel)];
    self.documentFromUserLabel = [self makeLabelWithAccessibilityIdentifier:BJLKeypath(self, documentFromUserLabel)];

    self.reuploadButton = [self makeImageButtonWithTitlt:nil image:[UIImage bjl_imageNamed:@"bjl_document_reupload"] highLightImage:[UIImage bjl_imageNamed:@"bjl_document_reupload_highlight"]];
    self.turnToNormalButton = [self makeImageButtonWithTitlt:nil image:[UIImage bjl_imageNamed:@"bjl_document_toNormal"] highLightImage:[UIImage bjl_imageNamed:@"bjl_document_toNormal_highlight"]];

    [self.reuploadButton addTarget:self action:@selector(reupload) forControlEvents:UIControlEventTouchUpInside];
    [self.turnToNormalButton addTarget:self action:@selector(turnToNormalDocument) forControlEvents:UIControlEventTouchUpInside];

    [self.contentView addSubview:self.documentSizeLabel];
    [self.contentView addSubview:self.documentFromUserLabel];
    [self.contentView addSubview:self.relatedDocIcon];
    [self.contentView addSubview:self.reuploadButton];
    [self.contentView addSubview:self.turnToNormalButton];

    [self.documentNameLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.horizontal.hugging.compressionResistance.required();
        make.left.equalTo(self.docIcon.bjl_right).offset(8.0);
        make.centerY.equalTo(self.contentView);
        make.width.lessThanOrEqualTo(self.contentView.bjl_width).multipliedBy(2.0 / 5.0);
    }];

    [self.relatedDocIcon bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.documentNameLabel.bjl_right).offset(10);
        make.width.height.equalTo(@(12.0));
        make.centerY.equalTo(self.documentNameLabel);
    }];

    [self.documentSizeLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.horizontal.hugging.compressionResistance.required();
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(419);
    }];

    [self.documentFromUserLabel bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.documentSizeLabel.bjl_left).offset(60);
        make.right.equalTo(self.optionContainerView.bjl_left).offset(-10);
    }];
}

- (void)makeCloudViewsAndConstraints {
    [self makeCommonViewsAndConstraints];

    self.documentSizeLabel = [self makeLabelWithAccessibilityIdentifier:BJLKeypath(self, documentSizeLabel)];
    self.uploadTimeLabel = [self makeLabelWithAccessibilityIdentifier:BJLKeypath(self, uploadTimeLabel)];

    self.reuploadButton = [self makeImageButtonWithTitlt:nil image:[UIImage bjl_imageNamed:@"bjl_document_reupload"] highLightImage:[UIImage bjl_imageNamed:@"bjl_document_reupload_highlight"]];
    self.turnToNormalButton = [self makeImageButtonWithTitlt:nil image:[UIImage bjl_imageNamed:@"bjl_document_toNormal"] highLightImage:[UIImage bjl_imageNamed:@"bjl_document_toNormal_highlight"]];

    [self.reuploadButton addTarget:self action:@selector(reupload) forControlEvents:UIControlEventTouchUpInside];
    [self.turnToNormalButton addTarget:self action:@selector(turnToNormalDocument) forControlEvents:UIControlEventTouchUpInside];

    [self.contentView addSubview:self.documentSizeLabel];
    [self.contentView addSubview:self.uploadTimeLabel];
    [self.contentView addSubview:self.reuploadButton];
    [self.contentView addSubview:self.turnToNormalButton];

    [self.documentNameLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.docIcon.bjl_right).offset(8.0);
        make.centerY.equalTo(self.contentView);
        make.right.lessThanOrEqualTo(self.documentSizeLabel.bjl_left).offset(-10);
        make.width.equalTo(self.contentView.bjl_width).multipliedBy(2.0 / 5.0).priorityHigh();
    }];

    [self.documentSizeLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.contentView);
        make.width.equalTo(@(60));
        make.right.equalTo(self.uploadTimeLabel.bjl_left).offset(-20);
    }];

    [self.uploadTimeLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.horizontal.hugging.compressionResistance.required();
        make.centerY.equalTo(self.contentView);
        make.width.equalTo(@(110));
        make.right.equalTo(self.contentView).offset(-120);
    }];
}

- (void)makeHomeworkViewsAndConstraints {
    BOOL iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    [self makeCommonViewsAndConstraints];
    self.stickyIcon = ({
        UIImageView *imageView = [UIImageView new];
        [imageView setImage:[UIImage bjl_imageNamed:@"bjl_homework_stickyIcon"]];
        imageView.contentMode = UIViewContentModeTopLeft;
        imageView;
    });
    self.documentFromUserLabel = [self makeLabelWithAccessibilityIdentifier:BJLKeypath(self, documentFromUserLabel)];
    self.documentSizeLabel = [self makeLabelWithAccessibilityIdentifier:BJLKeypath(self, documentSizeLabel)];
    self.uploadTimeLabel = [self makeLabelWithAccessibilityIdentifier:BJLKeypath(self, uploadTimeLabel)];

    self.downloadButton = [self makeImageButtonWithTitlt:nil image:[UIImage bjl_imageNamed:@"bjl_homework_download"] highLightImage:[UIImage bjl_imageNamed:@"bjl_homework_download_highlight"]];
    self.downloadProgressView = ({
        BJLAnnularProgressView *progressView = [BJLAnnularProgressView new];
        progressView.size = 14;
        progressView.annularWidth = 1.0;
        progressView.color = [BJLTheme brandColor];
        progressView.userInteractionEnabled = NO;
        progressView.hidden = YES;
        progressView;
    });
    [self.downloadButton addTarget:self action:@selector(downloadDocument) forControlEvents:UIControlEventTouchUpInside];

    [self.contentView addSubview:self.stickyIcon];
    [self.contentView addSubview:self.documentFromUserLabel];
    [self.contentView addSubview:self.documentSizeLabel];
    [self.contentView addSubview:self.uploadTimeLabel];
    [self.contentView addSubview:self.downloadButton];
    [self.downloadButton addSubview:self.downloadProgressView];
    [self.downloadProgressView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.downloadButton);
    }];

    [self.documentNameLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.docIcon.bjl_right).offset(8.0);
        make.centerY.equalTo(self.contentView);
        if (iPhone) {
            make.width.equalTo(@(140));
        }
        else {
            make.width.equalTo(self.contentView.bjl_width).multipliedBy(2.0 / 5.0);
        }
    }];

    [self.documentSizeLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.contentView);
        make.width.equalTo(@(60));
        make.left.equalTo(self.documentNameLabel.bjl_right).offset(10.0);
    }];
    [self.documentFromUserLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.documentSizeLabel.bjl_right).offset(iPhone ? 10.0 : 30.0);
        make.right.lessThanOrEqualTo(self.uploadTimeLabel.bjl_left).offset(-20);
    }];
    [self.uploadTimeLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.horizontal.hugging.compressionResistance.required();
        make.centerY.equalTo(self.contentView);
        make.width.equalTo(@(110));
        make.right.equalTo(self.contentView).offset(-120);
    }];
}

#pragma mark - action

- (void)showDocument {
    bjl_returnIfRobot(1);
    if (self.showDocumentCallback) {
        self.showDocumentCallback();
    }
}

- (void)deleteDocument {
    bjl_returnIfRobot(1);
    if (self.deleteDocumentCallback) {
        self.deleteDocumentCallback();
    }
}

- (void)showError {
    bjl_returnIfRobot(1);
    if (self.showErrorCallback) {
        self.showErrorCallback(self.failedDetailButton);
    }
}

- (void)downloadDocument {
    bjl_returnIfRobot(1);
    if (self.downloadDocumentCallback) {
        self.downloadDocumentCallback(self.downloadButton);
    }
}

- (void)reupload {
    bjl_returnIfRobot(1);
    if (self.reuploadCallback) {
        self.reuploadCallback();
    }
}

- (void)turnToNormalDocument {
    bjl_returnIfRobot(1);
    if (self.turnToNormalDocumentCallback) {
        self.turnToNormalDocumentCallback();
    }
}

#pragma mark - public

- (void)updateWithDocumentFile:(nullable BJLDocumentFile *)file
                  downloadItem:(nullable BJLHomeworkDownloadItem *)downloadItem
                     loginUser:(BJLUser *)loginUser
                   isCloudSync:(BOOL)isCloudSync {
    self.file = file;
    self.loginUser = loginUser;

    self.docIcon.image = [UIImage bjl_imageNamed:self.file.suggestImageName];
    self.documentNameLabel.text = self.file.name;
    self.relatedDocIcon.hidden = !file.isRelatedDocument;

    if ([self.reuseIdentifier isEqualToString:BJLDocumentCellReuseIdentifier]) {
        BOOL mediaFile = file.type == BJLDocumentFileAudio || file.type == BJLDocumentFileVideo;
        self.documentSizeLabel.text = mediaFile ? [self sizeToString:file.remoteMediaFile.infos.firstObject.size] : [self sizeToString:file.remoteDocument.byteSize];
        self.documentFromUserLabel.text = self.file.remoteDocument.fromUser.name;
        if (self.file.remoteDocument.isH5LinkCourseware) {
            self.docIcon.image = [UIImage bjl_imageNamed:@"bjl_document_html5"];
            self.documentSizeLabel.text = @"-";
        }
    }
    else if ([self.reuseIdentifier isEqualToString:BJLCloudCellReuseIdentifier]) {
        self.uploadTimeLabel.text = [self getUploadTimeWith:self.file.remoteCloudFile.lastTimeInterval];
        if (self.file.remoteCloudFile.isDirectory) {
            self.docIcon.image = [UIImage bjl_imageNamed:@"bjl_cloud_file"];
            self.documentSizeLabel.text = @"-";
        }
        else {
            self.documentSizeLabel.text = [self sizeToString:file.remoteCloudFile.byteSize];
        }
        if (self.file.type == BJLDocumentFileWebLink) {
            self.documentSizeLabel.text = @"-";
        }
    }
    else if ([self.reuseIdentifier isEqualToString:BJLHomeworkCellReuseIdentifier]) {
        BOOL isStickyFile = file.remoteHomework.fromUserRole != BJLUserRole_student && file.state == BJLDocumentFileNormal;
        self.stickyIcon.hidden = !isStickyFile;
        if (isStickyFile) {
            self.contentView.backgroundColor = [UIColor bjl_colorWithHex:0x9FA8B5 alpha:0.1];
        }
        else {
            self.contentView.backgroundColor = [UIColor clearColor];
        }

        self.documentSizeLabel.text = [self sizeToString:file.remoteHomework.byteSize];
        self.documentFromUserLabel.text = self.file.remoteHomework.fromUserName;
        self.uploadTimeLabel.text = [self getUploadTimeWith:self.file.remoteHomework.lastTimeInterval];

        self.downloadProgressView.hidden = YES;
        [self.downloadButton bjl_setImage:[UIImage bjl_imageNamed:@"bjl_homework_download"] forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        if (!downloadItem) {
            [self updateFileState];
            return;
        }

        if (downloadItem.state == BJLDownloadItemState_running) {
            self.downloadProgressView.hidden = NO;
            self.downloadProgressView.progress = downloadItem.progress.fractionCompleted;
        }
        else if (downloadItem.state == BJLDownloadItemState_completed && !downloadItem.error) {
            [self.downloadButton bjl_setImage:[UIImage bjl_imageNamed:@"bjl_homework_openfile"] forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        }
        else if (downloadItem.state == BJLDownloadItemState_paused && !downloadItem.error) {
            //            [self.downloadButton bjl_setImage:[UIImage bjl_imageNamed:@"bjl_homework_pause"] forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        }
        else if (downloadItem.error) {
            [self.downloadButton bjl_setImage:[UIImage bjl_imageNamed:@"bjl_homework_downloadfailed"] forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        }
    }

    [self updateFileState];
}

- (void)updateFileState {
    self.stateLabel.text = nil;
    self.stateLabel.hidden = YES;
    self.documentSizeLabel.hidden = YES;
    self.documentFromUserLabel.hidden = YES;
    self.uploadTimeLabel.hidden = YES;
    self.failedDetailButton.hidden = YES;
    self.deleteButton.enabled = YES;

    [self.playButton removeFromSuperview];
    [self.downloadButton removeFromSuperview];
    [self.deleteButton removeFromSuperview];
    [self.reuploadButton removeFromSuperview];
    [self.turnToNormalButton removeFromSuperview];
    [self.cancelUploadButton removeFromSuperview];

    if (!self.file) {
        return;
    }

    self.stateLabel.textColor = BJLTheme.viewTextColor;
    NSArray<UIButton *> *buttons = nil;

    switch (self.file.state) {
        case BJLDocumentFileNormal: {
            self.documentSizeLabel.hidden = NO;
            self.documentFromUserLabel.hidden = NO;
            self.uploadTimeLabel.hidden = NO;

            self.playButton.enabled = !self.file.remoteDocument.isH5LinkCourseware;
            self.deleteButton.enabled = ([self.reuseIdentifier isEqualToString:BJLHomeworkCellReuseIdentifier] && self.loginUser.isTeacherOrAssistant && !self.file.remoteHomework.isRelatedFile)
                                        || ([self.reuseIdentifier isEqualToString:BJLCloudCellReuseIdentifier])
                                        || ([self.reuseIdentifier isEqualToString:BJLDocumentCellReuseIdentifier] && !self.file.isRelatedDocument);

            if ([self.reuseIdentifier isEqualToString:BJLDocumentCellReuseIdentifier]) {
                buttons = @[self.playButton, self.deleteButton];
            }
            else if ([self.reuseIdentifier isEqualToString:BJLCloudCellReuseIdentifier]) {
                if (self.file.remoteCloudFile.isPublicFile) {
                    buttons = @[self.playButton];
                }
                else {
                    buttons = @[self.playButton, self.deleteButton];
                }
            }
            else if ([self.reuseIdentifier isEqualToString:BJLHomeworkCellReuseIdentifier]) {
                if (self.loginUser.isTeacherOrAssistant && self.file.remoteHomework.canPreview) {
                    buttons = @[self.playButton, self.downloadButton, self.deleteButton];
                }
                else if (self.loginUser.isTeacherOrAssistant) {
                    buttons = @[self.downloadButton, self.deleteButton];
                }
                if (self.loginUser.isStudent) {
                    buttons = @[self.downloadButton];
                }
            }
        }

        break;

        case BJLDocumentFileTranscodeError:
        case BJLDocumentFileUploadError: {
            self.stateLabel.hidden = NO;
            self.stateLabel.text = (self.file.state == BJLDocumentFileTranscodeError) ? BJLLocalizedString(@"转码失败") : BJLLocalizedString(@"上传失败");
            self.stateLabel.textColor = [UIColor bjl_colorWithHex:0XFF2A4C];
            self.failedDetailButton.hidden = NO;

            if (self.file.errorCode == 10012 || self.file.errorCode == 10011
                || BJLDocumentFileUploadError == self.file.state
                || [self.reuseIdentifier isEqualToString:BJLHomeworkCellReuseIdentifier]) {
                buttons = @[self.deleteButton];
            }
            else {
                if (self.file.type == BJLDocumentFileAnimatedPPT) {
                    buttons = @[self.turnToNormalButton, self.reuploadButton, self.deleteButton];
                }
                else {
                    buttons = @[self.reuploadButton, self.deleteButton];
                }
            }
        }

        break;
        case BJLDocumentFileUploading: {
            self.stateLabel.hidden = NO;
            self.stateLabel.text = BJLLocalizedString(@"上传中...");
            buttons = @[self.cancelUploadButton];
        }

        break;
        case BJLDocumentFileTranscoding: {
            self.stateLabel.hidden = NO;
            self.stateLabel.text = BJLLocalizedString(@"转码中...");
            buttons = @[self.deleteButton];
        }

        break;

        default:
            break;
    }

    if ([self.reuseIdentifier isEqualToString:BJLCloudCellReuseIdentifier]
        && self.file.remoteCloudFile.isDirectory) {
        buttons = nil;
    }
    [self updateOptionsButtonConstraintsWith:buttons];
}

- (void)updateOptionsButtonConstraintsWith:(NSArray<UIButton *> *)buttons {
    if (![buttons count]) {
        return;
    }
    CGFloat buttonWidth = 24;
    if ([buttons containsObject:self.cancelUploadButton]) {
        buttonWidth = 50;
    }

    [self.optionContainerView bjl_updateConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.width.equalTo(@([buttons count] * (buttonWidth + 10)));
    }];
    UIButton *lastButton = nil;
    for (UIButton *button in buttons) {
        [self.contentView addSubview:button];
        [button bjl_remakeConstraints:^(BJLConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            // 上一个按钮为空, 则按钮大小可以为图片大小, 后续的按钮与第一个按钮大小保持一致
            if (lastButton) {
                make.width.height.equalTo(lastButton);
            }
            else {
                make.width.height.equalTo(@(24)).priorityHigh();
            }
            make.left.equalTo(lastButton.bjl_right ?: self.optionContainerView.bjl_left).offset(4);
            if (button == buttons.lastObject) {
                // 最后一个 button 右侧约束
                make.right.equalTo(self.optionContainerView);
            }
        }];
        lastButton = button;
    }
}

#pragma mark - wheel

- (NSString *)getUploadTimeWith:(NSTimeInterval)lastTimeInterval {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:lastTimeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"zh_Hans_CN"];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:+28800];
    dateFormatter.dateFormat = @"yyyy/MM/dd HH:mm";
    NSString *tempstr = [dateFormatter stringFromDate:date];
    return tempstr;
}

// 转换大小格式
- (NSString *)sizeToString:(CGFloat)size {
    CGFloat kbSize = size / pow(1024.0, 1.0);
    CGFloat mbSize = size / pow(1024.0, 2.0);
    if (mbSize < 1.0) {
        return [NSString stringWithFormat:@"%.2fK", kbSize];
    }
    CGFloat gbSize = size / pow(1024.0, 3.0);
    if (gbSize < 1.0) {
        return [NSString stringWithFormat:@"%.2fM", mbSize];
    }
    CGFloat tbSize = size / pow(1024.0, 4.0);
    if (tbSize < 1.0) {
        return [NSString stringWithFormat:@"%.2fG", gbSize];
    }
    return [NSString stringWithFormat:@"%.2fT", tbSize];
}

- (UILabel *)makeLabelWithAccessibilityIdentifier:(NSString *)accessibilityIdentifier {
    UILabel *label = [UILabel new];
    label.numberOfLines = 1;
    label.textColor = BJLTheme.viewTextColor;
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:12];
    label.accessibilityIdentifier = accessibilityIdentifier;
    label.backgroundColor = [UIColor clearColor];
    return label;
}

- (UIButton *)makeImageButtonWithTitlt:(NSString *)title image:(UIImage *)image highLightImage:(UIImage *)highLightImage {
    UIButton *button = [UIButton new];
    if (title) {
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:BJLTheme.viewTextColor forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
    }
    if (image) {
        [button setImage:image forState:UIControlStateNormal];
    }
    if (highLightImage) {
        [button setImage:highLightImage forState:UIControlStateHighlighted];
        [button setImage:highLightImage forState:UIControlStateNormal | UIControlStateHighlighted];
    }
    return button;
}

#pragma mark - class method

+ (NSArray<NSString *> *)allCellIdentifiers {
    return @[BJLDocumentCellReuseIdentifier,
        BJLCloudCellReuseIdentifier,
        BJLHomeworkCellReuseIdentifier];
}
+ (NSString *)cellIdentifierForCellType:(BJLDocumentFileCellType)type {
    switch (type) {
        case BJLDocumentFileCellTypeHomework:
            return BJLHomeworkCellReuseIdentifier;
            break;

        case BJLDocumentFileCellTypeCloud:
            return BJLCloudCellReuseIdentifier;
            break;

        default:
            return BJLDocumentCellReuseIdentifier;
            break;
    }
}

@end
