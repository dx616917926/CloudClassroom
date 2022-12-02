//
//  BJLPopoverView.m
//  BJLiveUI-BJLInteractiveClass
//
//  Created by xijia dai on 2018/9/20.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJLPopoverView.h"
#import "BJLAppearance.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLPopoverView ()

@property (nonatomic) BJLPopoverViewType type;
@property (nonatomic, readwrite) CGSize viewSize;
@property (nonatomic, nullable) UIView *backgroundView;

@property (nonatomic) UIView *messageContainerView;
@property (nonatomic, readwrite) UILabel *messageLabel, *detailMessageLabel;
@property (nonatomic, readwrite) UIButton *checkboxButton;

@property (nonatomic, readwrite) UIButton *cancelButton;
@property (nonatomic, readwrite) UIButton *confirmButton;
@property (nonatomic, readwrite, nullable) UIButton *appendButton;

@end

@implementation BJLPopoverView

- (instancetype)init {
    return [self initWithType:BJLPopoverViewDefaultType];
}

- (instancetype)initWithType:(BJLPopoverViewType)type {
    if (self = [super init]) {
        self.type = type;
        self.viewSize = CGSizeMake(BJLAppearance.popoverViewWidth, BJLAppearance.popoverViewHeight);
        [self makeSubviewsAndConstraints];
    }
    return self;
}

- (void)makeSubviewsAndConstraints {
    [self makeCommonView];

    switch (self.type) {
        case BJLExitViewNormal:
            [self makeNormalExitView];
            break;

        case BJLExitViewRemoveFromRoom:
            [self makeExitRemoveFromRoomView];
            break;

        case BJLExitViewTimeOut:
            [self makeTimeOutExitView];
            break;

        case BJLExitViewConnectFail:
            [self makeConnectFailExitView];
            break;

        case BJLExitViewAppend:
            [self makeAppendExitView];
            break;

        case BJLKickOutUser:
            [self makeKickOutUserView];
            break;

        case BJLSwitchStage:
            [self makeSwitchStageView];
            break;

        case BJLFreeBlockedUser:
            [self makeFreeAllBlockedUserView];
            break;

        case BJLStartCloudRecord:
            [self makeStartCloudRecordView];
            break;

        case BJLDisBandGroup:
            [self makeDisBandGroupView];
            break;

        case BJLRevokeWritingBoard:
            [self makeRevokeWritingBoardView];
            break;

        case BJLClearWritingBoard:
            [self makeClearWritingBoardView];
            break;

        case BJLCloseWritingBoard:
            [self makeCloseWritingBoardView];
            break;

        case BJLCloseWebPage:
            [self makeCloseWebPageView];
            break;

        case BJLCloseQuiz:
            [self makeCloseQuizView];
            break;

        case BJLHighLoassRate:
            [self makeHighLoassRateView];
            break;

        case BJLAnimatePPTTimeOut:
            [self makeAnimatePPTTimeOutView];
            break;

        case BJLDeletePPT:
            [self makeDeletePPT];
            break;

        case BJLSupportHomework:
            [self makeSupportHomeworkView];
            break;

        case BJLStopAsCamera:
            [self makeStopAsCameraView];
            break;

        case BJLStudyRoomAddActiveUserFailed:
            [self makeStudyRoomAddActiveUserFailedView];
            break;

        case BJLExitViewKickOut:
            [self makeKickOutExitWithBandView];
            break;

        case BJLExitViewKickOutNotAddBlackList:
            [self makeKickOutExitNotBandView];
            break;

        case BJLExitViewKickOutWithClassEnd:
            [self makeKickOutExitWithClassEndView];
            break;

        case BJLExitViewEnforceForbidClass:
            [self makeEnforceForbidClassView];
            break;

        case BJLSwitchLayout:
            [self makeSwitchLayoutView];
            break;

        case BJLPlayMediaFile:
            [self makePlayMediaFileView];
            break;

        case BJLPlayBDSFile:
            [self makePlayBDSFileView];
            break;

        case BJLHandWritingBoardConnectFailed:
            [self makeHandWritingBoardConnectFailedView];
            break;

        case BJLHandWritingBoardDisconnect:
            [self makeDisconnectHandWritingBoardView];
            break;

        case BJLOpenBluetooth:
            [self makeOpenBluetoothView];
            break;

        case BJLStudyRoomSwitchModeWhenTutor:
            [self makeSwitchStudyRoomModeWhenTutor];
            break;

            // study room
        case BJLStudyRoomTutorEnd:
            [self makeStudyRoomTutorEnd];
            break;

        case BJLStudyRoom1v1Countdown:
            [self makeStudyRoom1v1Countdown];
            break;

        case BJLStudyRoom1v1TutorEnd:
            [self make1v1TutorOutsideExitView];
            break;

        case BJLStudyRoom1v1TutorTeacherWaitTimeout:
            [self make1v1TutorOutsideStopView:YES isTimeout:YES];
            break;

        case BJLStudyRoom1v1TutorStudentWaitTimeout:
            [self make1v1TutorOutsideStopView:NO isTimeout:YES];
            break;

        case BJLStudyRoom1v1TutorTeacherStopTutor:
            [self make1v1TutorOutsideStopView:YES isTimeout:NO];
            break;

        case BJLStudyRoom1v1TutorStudentStopTutor:
            [self make1v1TutorOutsideStopView:NO isTimeout:NO];
            break;

        case BJLSwitchOnlineDoubleRoom:
            [self makeOnlineDoubleSwitchView];
            break;
        default:
            break;
    }
}

#pragma mark -

- (void)makeDeletePPT {
    [self makePureMessageView];
    [self makeDoubleHorizontalButtonViewWithButtonSize:CGSizeMake(120.0, 40.0) space:52.0 positive:NO];
    self.messageLabel.text = BJLLocalizedString(@"确定删除课件吗?");
    self.messageLabel.textAlignment = NSTextAlignmentCenter;

    self.cancelButton.backgroundColor = BJLTheme.subButtonBackgroundColor;
    [self.cancelButton setTitle:BJLLocalizedString(@"取消") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:BJLTheme.subButtonTextColor forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = BJLTheme.warningColor;
    [self.confirmButton setTitle:BJLLocalizedString(@"确认删除") forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
}

- (void)makeSwitchStudyRoomModeWhenTutor {
    [self makePureMessageView];
    [self makeDoubleHorizontalButtonViewWithButtonSize:CGSizeMake(120.0, 40.0) space:52.0 positive:NO];
    self.messageLabel.text = BJLLocalizedString(@"正在进行辅导，切换模式将中断辅导，确定继续吗？");
    self.messageLabel.textAlignment = NSTextAlignmentCenter;

    self.cancelButton.backgroundColor = BJLTheme.subButtonBackgroundColor;
    [self.cancelButton setTitle:BJLLocalizedString(@"取消") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:BJLTheme.subButtonTextColor forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = BJLTheme.brandColor;
    [self.confirmButton setTitle:BJLLocalizedString(@"确定") forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
}

- (void)makeStudyRoomTutorEnd {
    [self makePureMessageView];
    [self makeDoubleHorizontalButtonViewWithButtonSize:CGSizeMake(120.0, 40.0) space:52.0 positive:NO];
    self.messageLabel.text = BJLLocalizedString(@"结束辅导后将返回自习，确定结束吗？");
    self.messageLabel.textAlignment = NSTextAlignmentCenter;

    self.cancelButton.backgroundColor = BJLTheme.subButtonBackgroundColor;
    [self.cancelButton setTitle:BJLLocalizedString(@"取消") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:BJLTheme.subButtonTextColor forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = BJLTheme.brandColor;
    [self.confirmButton setTitle:BJLLocalizedString(@"确定") forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
}

- (void)makeStudyRoom1v1Countdown {
    [self makeSingleMessageView];
    [self makePassiveExitButtonViewWithButtonSize:CGSizeMake(140.0, 40.0)];

    self.messageLabel.text = BJLLocalizedString(@"进入一对一辅导");
    self.messageLabel.textAlignment = NSTextAlignmentCenter;

    self.detailMessageLabel.text = BJLLocalizedString(@"已匹配到辅导老师，即将进入辅导直播间");
    self.detailMessageLabel.font = [UIFont systemFontOfSize:12];
    self.detailMessageLabel.textAlignment = NSTextAlignmentCenter;

    self.confirmButton.backgroundColor = BJLTheme.brandColor;
    [self.confirmButton setTitle:BJLLocalizedString(@"立即进入") forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
}

- (void)makeNormalExitView {
    [self makeSingleMessageView];
    [self makeDoubleHorizontalButtonViewWithButtonSize:CGSizeMake(120.0, 40.0) space:52.0 positive:NO];
    self.messageLabel.text = BJLLocalizedString(@"正在关闭直播间, 是否结束授课?");

    self.cancelButton.backgroundColor = BJLTheme.subButtonBackgroundColor;
    [self.cancelButton setTitle:BJLLocalizedString(@"取消") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:BJLTheme.subButtonTextColor forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = BJLTheme.warningColor;
    [self.confirmButton setTitle:BJLLocalizedString(@"关闭直播间") forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
}

- (void)make1v1TutorOutsideExitView {
    [self makeDoubleMessageView];
    [self makeDoubleHorizontalButtonViewWithButtonSize:CGSizeMake(120.0, 40.0) space:52.0 positive:NO];
    self.messageLabel.text = BJLLocalizedString(@"结束辅导将无法再返回本辅导直播间，确认结束吗？");

    self.cancelButton.backgroundColor = BJLTheme.subButtonBackgroundColor;
    [self.cancelButton setTitle:BJLLocalizedString(@"取消") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:BJLTheme.subButtonTextColor forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = BJLTheme.warningColor;
    [self.confirmButton setTitle:BJLLocalizedString(@"确定") forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
}

- (void)make1v1TutorOutsideStopView:(BOOL)isTeacher isTimeout:(BOOL)isTimeout {
    NSString *title = nil;
    NSString *subtitle = nil;
    if (isTimeout) {
        title = isTeacher ? BJLLocalizedString(@"老师未进入直播间 \n") : BJLLocalizedString(@"学生未进入直播间 \n");
        subtitle = isTeacher ? BJLLocalizedString(@"直播间关闭，即将返回自习室") : BJLLocalizedString(@"直播间关闭，即将返回自习辅导");
    }
    else {
        title = isTeacher ? BJLLocalizedString(@"老师已结束辅导 \n") : BJLLocalizedString(@"学生已结束辅导 \n");
        subtitle = isTeacher ? BJLLocalizedString(@"直播间关闭，即将返回自习室") : BJLLocalizedString(@"直播间关闭，即将返回自习辅导");
    }
    [self setAsStudyRoomDoubleLineMessageAndOneButtonAlertStyleWithTitle:title subtitle:subtitle];
}

- (void)makeExitRemoveFromRoomView {
    [self makeSingleMessageView];
    [self makePassiveExitButtonViewWithButtonSize:CGSizeMake(120.0, 40.0)];
    [self.confirmButton setTitle:BJLLocalizedString(@"确定") forState:UIControlStateNormal];
    self.messageLabel.text = BJLLocalizedString(@"您已被移出直播间");
}

- (void)makeTimeOutExitView {
    [self makeSingleMessageView];
    [self makePassiveExitButtonViewWithButtonSize:CGSizeMake(120.0, 40.0)];
    [self.confirmButton setTitle:BJLLocalizedString(@"关闭") forState:UIControlStateNormal];
    self.messageLabel.text = BJLLocalizedString(@"严重超时! 直播间已自动关闭");
}

- (void)makeConnectFailExitView {
    [self makeSingleMessageView];
    self.viewSize = CGSizeMake(450, BJLAppearance.popoverViewHeight);
    [self makeDoubleHorizontalButtonViewWithButtonSize:CGSizeMake(120.0, 40.0) space:52.0 positive:NO];
    self.messageLabel.text = BJLLocalizedString(@"连接超时! 请尝试重新登录");

    self.cancelButton.backgroundColor = BJLTheme.subButtonBackgroundColor;
    [self.cancelButton setTitle:BJLLocalizedString(@"退出直播间") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:BJLTheme.warningColor forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = [BJLTheme brandColor];
    [self.confirmButton setTitle:BJLLocalizedString(@"继续连接") forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:[BJLTheme buttonTextColor] forState:UIControlStateNormal];
}

- (void)makeAppendExitView {
    [self makeSingleMessageView];
    [self makeAppendButtonView];
    self.viewSize = CGSizeMake(422.0, 287.0);
    self.messageLabel.text = BJLLocalizedString(@"正在关闭直播间, 是否结束授课?");

    self.cancelButton.backgroundColor = [BJLTheme subButtonBackgroundColor];
    [self.cancelButton setTitle:BJLLocalizedString(@"取消") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[BJLTheme subButtonTextColor] forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = BJLTheme.warningColor;
    [self.confirmButton setTitle:BJLLocalizedString(@"关闭直播间") forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
    self.appendButton.backgroundColor = [BJLTheme brandColor];
    [self.appendButton setTitle:BJLLocalizedString(@"下课并查看学情报告") forState:UIControlStateNormal];
    [self.appendButton setTitleColor:[BJLTheme buttonTextColor] forState:UIControlStateNormal];
}

- (void)makeKickOutUserView {
    [self makeCheckboxMessageView];
    [self makeDoubleHorizontalButtonViewWithButtonSize:CGSizeMake(120.0, 40.0) space:52.0 positive:NO];
    self.messageLabel.text = BJLLocalizedString(@"是否将用户踢出直播间?");
    [self.checkboxButton setTitle:BJLLocalizedString(@"加入黑名单，本节课禁止进入") forState:UIControlStateNormal];

    self.cancelButton.backgroundColor = BJLTheme.subButtonBackgroundColor;
    [self.cancelButton setTitle:BJLLocalizedString(@"取消") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:BJLTheme.subButtonTextColor forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = BJLTheme.warningColor;
    [self.confirmButton setTitle:BJLLocalizedString(@"踢出直播间") forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
}

- (void)makeSwitchStageView {
    [self makePureMessageView];
    [self makeDoubleHorizontalButtonViewWithButtonSize:CGSizeMake(120.0, 40.0) space:52.0 positive:NO];

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 4.0;
    paragraphStyle.paragraphSpacing = 4.0;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:BJLLocalizedString(@"坐席已满\n请设置下台后继续操作")
                                                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                                                                             NSForegroundColorAttributeName: BJLTheme.viewTextColor,
                                                                             NSParagraphStyleAttributeName: paragraphStyle}];
    self.messageLabel.attributedText = attributedText;

    self.confirmButton.backgroundColor = [BJLTheme brandColor];
    [self.confirmButton setTitle:BJLLocalizedString(@"去设置下台") forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:[BJLTheme buttonTextColor] forState:UIControlStateNormal];
    self.cancelButton.backgroundColor = [BJLTheme subButtonBackgroundColor];
    [self.cancelButton setTitle:BJLLocalizedString(@"取消操作") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[BJLTheme subButtonTextColor] forState:UIControlStateNormal];
}

- (void)makeFreeAllBlockedUserView {
    [self makePureMessageView];
    [self makeDoubleHorizontalButtonViewWithButtonSize:CGSizeMake(120.0, 40.0) space:52.0 positive:NO];

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 4.0;
    paragraphStyle.paragraphSpacing = 4.0;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:BJLLocalizedString(@"是否将黑名单全部成员解禁？")
                                                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                                                                             NSForegroundColorAttributeName: BJLTheme.viewTextColor,
                                                                             NSParagraphStyleAttributeName: paragraphStyle}];
    self.messageLabel.attributedText = attributedText;

    self.confirmButton.backgroundColor = [BJLTheme brandColor];
    [self.confirmButton setTitle:BJLLocalizedString(@"再想想") forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:[BJLTheme buttonTextColor] forState:UIControlStateNormal];
    self.cancelButton.backgroundColor = [BJLTheme subButtonBackgroundColor];
    [self.cancelButton setTitle:BJLLocalizedString(@"全部解禁") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[BJLTheme subButtonTextColor] forState:UIControlStateNormal];
}

- (void)makeStartCloudRecordView {
    [self makePureMessageView];
    [self makeDoubleHorizontalButtonViewWithButtonSize:CGSizeMake(120.0, 40.0) space:52.0 positive:NO];
    //    self.titleLabel.text = BJLLocalizedString(@"云端录制");
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 14.0;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    NSDictionary *attributedDic = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0],
        NSForegroundColorAttributeName: BJLTheme.viewTextColor,
        NSParagraphStyleAttributeName: paragraphStyle};
    self.messageLabel.attributedText = [[NSAttributedString alloc] initWithString:BJLLocalizedString(@"重新开启云端录制 \n 继续前一次云端录制还是开启新的云端录制?") attributes:attributedDic];

    self.cancelButton.backgroundColor = [BJLTheme subButtonBackgroundColor];
    [self.cancelButton setTitle:BJLLocalizedString(@"新的录制") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[BJLTheme subButtonTextColor] forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = [BJLTheme brandColor];
    [self.confirmButton setTitle:BJLLocalizedString(@"继续录制") forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:[BJLTheme buttonTextColor] forState:UIControlStateNormal];
}

- (void)makeDisBandGroupView {
    [self makeSingleMessageView];
    [self makeDoubleHorizontalButtonViewWithButtonSize:CGSizeMake(120.0, 40.0) space:52.0 positive:NO];
    self.messageLabel.text = BJLLocalizedString(@"是否解散全部分组");

    self.cancelButton.backgroundColor = [BJLTheme brandColor];
    [self.cancelButton setTitle:BJLLocalizedString(@"取消") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[BJLTheme buttonTextColor] forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = [BJLTheme subButtonBackgroundColor];
    [self.confirmButton setTitle:BJLLocalizedString(@"全部解散") forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:[BJLTheme subButtonTextColor] forState:UIControlStateNormal];
}

- (void)makeRevokeWritingBoardView {
    [self makePureMessageView];
    [self updateWritingBoardViewConstraints];
    [self makeDoubleHorizontalButtonViewWithButtonSize:CGSizeMake(96.0, 32.0) space:16.0 positive:NO];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 14.0;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attributedDic = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0],
        NSForegroundColorAttributeName: BJLTheme.viewTextColor,
        NSParagraphStyleAttributeName: paragraphStyle};
    self.messageLabel.attributedText = [[NSAttributedString alloc] initWithString:BJLLocalizedString(@"撤销小黑板将不保留学生数据\n确定要继续吗?") attributes:attributedDic];

    self.cancelButton.backgroundColor = [BJLTheme subButtonBackgroundColor];
    [self.cancelButton setTitle:BJLLocalizedString(@"取消") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[BJLTheme subButtonTextColor] forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = [BJLTheme brandColor];
    [self.confirmButton setTitle:BJLLocalizedString(@"确定") forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:[BJLTheme buttonTextColor] forState:UIControlStateNormal];
}

- (void)makeClearWritingBoardView {
    [self makePureMessageView];
    [self updateWritingBoardViewConstraints];
    [self makeDoubleHorizontalButtonViewWithButtonSize:CGSizeMake(96.0, 32.0) space:16.0 positive:NO];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 10.0;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attributedDic = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0],
        NSForegroundColorAttributeName: BJLTheme.viewTextColor,
        NSParagraphStyleAttributeName: paragraphStyle};
    self.messageLabel.attributedText = [[NSAttributedString alloc] initWithString:BJLLocalizedString(@"清空小黑板无法恢复\n是否继续清空") attributes:attributedDic];

    self.cancelButton.backgroundColor = [BJLTheme subButtonBackgroundColor];
    [self.cancelButton setTitle:BJLLocalizedString(@"取消") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[BJLTheme subButtonTextColor] forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = [BJLTheme brandColor];
    [self.confirmButton setTitle:BJLLocalizedString(@"确定") forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:[BJLTheme buttonTextColor] forState:UIControlStateNormal];
}

- (void)makeCloseWritingBoardView {
    [self makePureMessageView];
    [self updateWritingBoardViewConstraints];
    [self makeDoubleHorizontalButtonViewWithButtonSize:CGSizeMake(96.0, 32.0) space:16.0 positive:NO];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 14.0;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attributedDic = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0],
        NSForegroundColorAttributeName: BJLTheme.viewTextColor,
        NSParagraphStyleAttributeName: paragraphStyle};
    self.messageLabel.attributedText = [[NSAttributedString alloc] initWithString:BJLLocalizedString(@"关闭窗口将收回学生页面\n确定要继续吗?") attributes:attributedDic];

    self.cancelButton.backgroundColor = [BJLTheme subButtonBackgroundColor];
    [self.cancelButton setTitle:BJLLocalizedString(@"取消") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[BJLTheme subButtonTextColor] forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = [BJLTheme brandColor];
    [self.confirmButton setTitle:BJLLocalizedString(@"确定") forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:[BJLTheme buttonTextColor] forState:UIControlStateNormal];
}

- (void)makeCloseWebPageView {
    [self makePureMessageView];
    [self makeDoubleHorizontalButtonViewWithButtonSize:CGSizeMake(120.0, 40.0) space:52.0 positive:NO];
    self.messageLabel.text = BJLLocalizedString(@"学生端将同步关闭窗口 是否继续？");

    self.cancelButton.backgroundColor = [BJLTheme subButtonBackgroundColor];
    [self.cancelButton setTitle:BJLLocalizedString(@"关闭") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[BJLTheme subButtonTextColor] forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = [BJLTheme brandColor];
    [self.confirmButton setTitle:BJLLocalizedString(@"取消") forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:[BJLTheme buttonTextColor] forState:UIControlStateNormal];
}

- (void)makeCloseQuizView {
    [self makeSingleMessageView];
    [self makeDoubleHorizontalButtonViewWithButtonSize:CGSizeMake(120.0, 40.0) space:52.0 positive:NO];
    self.messageLabel.text = BJLLocalizedString(@"确认关闭测验？");

    self.cancelButton.backgroundColor = [BJLTheme subButtonBackgroundColor];
    [self.cancelButton setTitle:BJLLocalizedString(@"取消") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[BJLTheme subButtonTextColor] forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = [BJLTheme brandColor];
    [self.confirmButton setTitle:BJLLocalizedString(@"关闭") forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:[BJLTheme buttonTextColor] forState:UIControlStateNormal];
}

- (void)makeHighLoassRateView {
    [self makePureMessageView];
    [self makePassiveExitButtonViewWithButtonSize:CGSizeMake(160.0, 40.0)];
    self.messageLabel.text = BJLLocalizedString(@"哎呀，您的网络开小差了，检测网络后重新进入直播间");
    self.confirmButton.backgroundColor = [BJLTheme brandColor];
    [self.confirmButton setTitle:BJLLocalizedString(@"好的") forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:[BJLTheme buttonTextColor] forState:UIControlStateNormal];
}

- (void)makeAnimatePPTTimeOutView {
    [self makePureMessageView];
    [self makeDoubleHorizontalButtonViewWithButtonSize:CGSizeMake(120.0, 40.0) space:52.0 positive:NO];
    self.messageLabel.text = BJLLocalizedString(@"PPT动画加载失败！\n网络较差建议跳过动画");

    self.cancelButton.backgroundColor = BJLTheme.subButtonBackgroundColor;
    [self.cancelButton setTitle:BJLLocalizedString(@"跳过动画") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:BJLTheme.subButtonTextColor forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = BJLTheme.brandColor;
    [self.confirmButton setTitle:BJLLocalizedString(@"重新加载") forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
}

- (void)makeSupportHomeworkView {
    [self makePureMessageView];
    [self makeDoubleHorizontalButtonViewWithButtonSize:CGSizeMake(120.0, 40.0) space:52.0 positive:NO];
    self.messageLabel.text = BJLLocalizedString(@"您授课的直播间中，有部分学员未更新到App最新版本，作业模块暂无法使用，请在直播间中叮嘱学员及时更新，避免影响正常直播间秩序!");
    self.messageLabel.textAlignment = NSTextAlignmentCenter;

    self.cancelButton.backgroundColor = BJLTheme.subButtonBackgroundColor;
    [self.cancelButton setTitle:BJLLocalizedString(@"不再提醒") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:BJLTheme.subButtonTextColor forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = BJLTheme.brandColor;
    [self.confirmButton setTitle:BJLLocalizedString(@"知道了") forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
}

- (void)makeStopAsCameraView {
    [self makeCheckboxMessageView];
    [self makeDoubleHorizontalButtonViewWithButtonSize:CGSizeMake(120.0, 40.0) space:52.0 positive:NO];
    self.messageLabel.text = BJLLocalizedString(@"终止外接设备直播");
    [self.checkboxButton setTitle:BJLLocalizedString(@"打开主设备摄像头") forState:UIControlStateNormal];

    self.cancelButton.backgroundColor = BJLTheme.subButtonBackgroundColor;
    [self.cancelButton setTitle:BJLLocalizedString(@"取消") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:BJLTheme.subButtonTextColor forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = BJLTheme.brandColor;
    [self.confirmButton setTitle:BJLLocalizedString(@"确定") forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
}

- (void)makeStudyRoomAddActiveUserFailedView {
    NSString *title = BJLLocalizedString(@"没有抢到位置哦 \n ");
    NSString *subtitle = BJLLocalizedString(@"手慢了，位置已经被占了~");
    [self setAsStudyRoomDoubleLineMessageAndOneButtonAlertStyleWithTitle:title subtitle:subtitle];
}

- (void)makeKickOutExitWithClassEndView {
    NSString *title = BJLLocalizedString(@"直播已结束\n ");
    NSString *subtitle = BJLLocalizedString(@"欢迎您下次继续观看~");
    [self setAsStudyRoomDoubleLineMessageAndOneButtonAlertStyleWithTitle:title subtitle:subtitle];
}

- (void)makeEnforceForbidClassView {
    [self makeDoubleMessageView];
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.textAlignment = NSTextAlignmentLeft;
    [self makePassiveExitButtonViewWithButtonSize:CGSizeMake(120.0, 40.0)];
    self.confirmButton.backgroundColor = BJLTheme.brandColor;
    [self.confirmButton setTitle:BJLLocalizedString(@"确定") forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
}

- (void)makeKickOutExitNotBandView {
    NSString *title = BJLLocalizedString(@"你已被请出直播间 \n ");
    NSString *subtitle = BJLLocalizedString(@"你已被请出直播间，请重新进入直播间~");
    [self setAsStudyRoomDoubleLineMessageAndOneButtonAlertStyleWithTitle:title subtitle:subtitle];
}

- (void)makeKickOutExitWithBandView {
    NSString *title = BJLLocalizedString(@"你已被请出直播间 \n ");
    NSString *subtitle = BJLLocalizedString(@"你已被请出直播间，本课节将无法再次进入~");
    [self setAsStudyRoomDoubleLineMessageAndOneButtonAlertStyleWithTitle:title subtitle:subtitle];
}

- (void)makeSwitchLayoutView {
    [self makeDoubleMessageView];
    [self makeDoubleHorizontalButtonViewWithButtonSize:CGSizeMake(120.0, 40.0) space:52.0 positive:NO];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 10.0;
    paragraphStyle.paragraphSpacing = 10.0;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:BJLLocalizedString(@"是否切换布局？")
                                                                                attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                                                                                    NSForegroundColorAttributeName: BJLTheme.viewTextColor,
                                                                                    NSParagraphStyleAttributeName: paragraphStyle}];
    [message appendAttributedString:[[NSAttributedString alloc] initWithString:BJLLocalizedString(@"\n切换布局将关闭媒体播放")
                                                                    attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.0],
                                                                        NSForegroundColorAttributeName: BJLTheme.viewSubTextColor,
                                                                        NSParagraphStyleAttributeName: paragraphStyle}]];
    self.messageLabel.attributedText = message;
    self.cancelButton.backgroundColor = BJLTheme.subButtonBackgroundColor;
    [self.cancelButton setTitle:BJLLocalizedString(@"取消") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:BJLTheme.subButtonTextColor forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = BJLTheme.brandColor;
    [self.confirmButton setTitle:BJLLocalizedString(@"确定") forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
}

- (void)makePlayMediaFileView {
    [self makeDoubleMessageView];
    [self makeDoubleHorizontalButtonViewWithButtonSize:CGSizeMake(120.0, 40.0) space:52.0 positive:NO];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 10.0;
    paragraphStyle.paragraphSpacing = 10.0;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:BJLLocalizedString(@"确定打开播放文件吗？")
                                                                                attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                                                                                    NSForegroundColorAttributeName: BJLTheme.viewTextColor,
                                                                                    NSParagraphStyleAttributeName: paragraphStyle}];
    [message appendAttributedString:[[NSAttributedString alloc] initWithString:BJLLocalizedString(@"\n新打开播放文件将停止当前正在播放的内容，是否继续？")
                                                                    attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.0],
                                                                        NSForegroundColorAttributeName: BJLTheme.viewSubTextColor,
                                                                        NSParagraphStyleAttributeName: paragraphStyle}]];
    self.messageLabel.attributedText = message;
    self.cancelButton.backgroundColor = BJLTheme.subButtonBackgroundColor;
    [self.cancelButton setTitle:BJLLocalizedString(@"取消") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:BJLTheme.subButtonTextColor forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = BJLTheme.brandColor;
    [self.confirmButton setTitle:BJLLocalizedString(@"确定") forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
}

- (void)makePlayBDSFileView {
    [self makeDoubleMessageView];
    [self makeDoubleHorizontalButtonViewWithButtonSize:CGSizeMake(120.0, 40.0) space:52.0 positive:NO];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 14.0;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attributedDic = @{NSFontAttributeName: [UIFont systemFontOfSize:16.0],
        NSForegroundColorAttributeName: BJLTheme.viewTextColor,
        NSParagraphStyleAttributeName: paragraphStyle};
    self.messageLabel.attributedText = [[NSAttributedString alloc] initWithString:BJLLocalizedString(@"动态黑板文件将覆盖当前黑板，\n且不可恢复，请谨慎操作！") attributes:attributedDic];

    self.cancelButton.backgroundColor = BJLTheme.subButtonBackgroundColor;
    [self.cancelButton setTitle:BJLLocalizedString(@"取消") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:BJLTheme.subButtonTextColor forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = BJLTheme.brandColor;
    [self.confirmButton setTitle:BJLLocalizedString(@"确定") forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
}

#pragma mark -

- (void)makeHandWritingBoardConnectFailedView {
    [self makeDoubleMessageView];
    [self makeDoubleHorizontalButtonViewWithButtonSize:CGSizeMake(120.0, 40.0) space:52.0 positive:NO];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 4.0;
    paragraphStyle.paragraphSpacing = 4.0;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:BJLLocalizedString(@"手写板连接失败，请重新连接")
                                                                                attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0],
                                                                                    NSForegroundColorAttributeName: BJLTheme.viewTextColor,
                                                                                    NSParagraphStyleAttributeName: paragraphStyle}];
    [message appendAttributedString:[[NSAttributedString alloc] initWithString:BJLLocalizedString(@"\n请确定“外接手写板”已打开且在通信范围内")
                                                                    attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.0],
                                                                        NSForegroundColorAttributeName: BJLTheme.viewSubTextColor,
                                                                        NSParagraphStyleAttributeName: paragraphStyle}]];
    self.messageLabel.attributedText = message;
    self.cancelButton.backgroundColor = BJLTheme.subButtonBackgroundColor;
    [self.cancelButton setTitle:BJLLocalizedString(@"取消") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:BJLTheme.subButtonTextColor forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = BJLTheme.brandColor;
    [self.confirmButton setTitle:BJLLocalizedString(@"重新连接") forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
}

- (void)makeDisconnectHandWritingBoardView {
    [self makeSingleMessageView];
    [self makeDoubleHorizontalButtonViewWithButtonSize:CGSizeMake(120.0, 40.0) space:52.0 positive:NO];
    self.messageLabel.text = BJLLocalizedString(@"确定断开蓝牙连接吗？");

    self.cancelButton.backgroundColor = BJLTheme.subButtonBackgroundColor;
    [self.cancelButton setTitle:BJLLocalizedString(@"取消") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:BJLTheme.subButtonTextColor forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = BJLTheme.brandColor;
    [self.confirmButton setTitle:BJLLocalizedString(@"确定") forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
}

- (void)makeOpenBluetoothView {
    [self makeSingleMessageView];
    [self makePassiveExitButtonViewWithButtonSize:CGSizeMake(120.0, 40.0)];
    self.messageLabel.text = BJLLocalizedString(@"你的蓝牙未开启，请开启蓝牙");

    self.confirmButton.backgroundColor = BJLTheme.brandColor;
    [self.confirmButton setTitle:BJLLocalizedString(@"确定") forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
}

- (void)makeOnlineDoubleSwitchView {
    [self makePureMessageView];
    [self makeDoubleHorizontalButtonViewWithButtonSize:CGSizeMake(120.0, 40.0) space:52.0 positive:NO];
    self.messageLabel.text = BJLLocalizedString(@"确定切换到大班吗？");
    self.messageLabel.textAlignment = NSTextAlignmentCenter;

    self.cancelButton.backgroundColor = BJLTheme.subButtonBackgroundColor;
    [self.cancelButton setTitle:BJLLocalizedString(@"取消") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:BJLTheme.subButtonTextColor forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = BJLTheme.brandColor;
    [self.confirmButton setTitle:BJLLocalizedString(@"确定") forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
}

#pragma mark -

- (void)setAsStudyRoomDoubleLineMessageAndOneButtonAlertStyleWithTitle:(NSString *)title subtitle:(NSString *)subtitle {
    if (!(title.length > 0 && subtitle.length > 0)) {
        return;
    }

    [self makeDoubleMessageView];
    [self makePassiveExitButtonViewWithButtonSize:CGSizeMake(120.0, 40.0)];

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 10.0;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;

    NSAttributedString *attributedTitleText = [[NSAttributedString alloc] initWithString:title
                                                                              attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                                                                                  NSForegroundColorAttributeName: BJLTheme.viewTextColor,
                                                                                  NSParagraphStyleAttributeName: paragraphStyle}];

    NSAttributedString *attributedSubtitleText = [[NSAttributedString alloc] initWithString:subtitle
                                                                                 attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.0],
                                                                                     NSForegroundColorAttributeName: BJLTheme.viewSubTextColor,
                                                                                     NSParagraphStyleAttributeName: paragraphStyle}];

    NSMutableAttributedString *messageAttributedText = [[NSMutableAttributedString alloc] initWithAttributedString:attributedTitleText];
    [messageAttributedText appendAttributedString:attributedSubtitleText];
    self.messageLabel.attributedText = messageAttributedText;

    [self.confirmButton setTitle:BJLLocalizedString(@"确定") forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = BJLTheme.brandColor;
    [self.confirmButton setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
}

#pragma mark - wheel

- (void)makeCommonView {
    // shadow
    self.layer.masksToBounds = NO;
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowColor = BJLTheme.windowShadowColor.CGColor;
    self.layer.shadowOffset = CGSizeMake(0.0, 4.0);
    self.layer.shadowRadius = 10.0;

    // 背景色
    self.backgroundView = ({
        UIView *view = [UIView new];
        // border && corner
        view.layer.cornerRadius = 4.0;
        view.layer.masksToBounds = YES;
        view.layer.borderWidth = 1.0;
        view.layer.borderColor = [UIColor bjl_colorWithHex:0XDDDDDD alpha:0.1].CGColor;
        view.backgroundColor = BJLTheme.windowBackgroundColor;
        view;
    });
    [self addSubview:self.backgroundView];
    [self.backgroundView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

// 提示消息为一行
- (void)makeSingleMessageView {
    self.messageContainerView = ({
        UIView *view = [BJLHitTestView new];
        view.accessibilityIdentifier = BJLKeypath(self, messageContainerView);
        view;
    });
    [self addSubview:self.messageContainerView];
    [self.messageContainerView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.equalTo(self).offset(16.0);
        make.left.equalTo(self).offset(20.0);
        make.right.equalTo(self).offset(-20.0);
        make.height.equalTo(@(90.0));
    }];

    // message
    self.messageLabel = ({
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = BJLTheme.viewTextColor;
        label.numberOfLines = 1;
        label.font = [UIFont systemFontOfSize:16.0];
        label.accessibilityIdentifier = BJLKeypath(self, messageLabel);
        label;
    });
    [self addSubview:self.messageLabel];
    [self.messageLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.center.equalTo(self.messageContainerView);
    }];

    // detailMessageLabel
    self.detailMessageLabel = ({
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = BJLTheme.viewSubTextColor;
        label.numberOfLines = 1;
        label.font = [UIFont systemFontOfSize:14.0];
        label.accessibilityIdentifier = BJLKeypath(self, detailMessageLabel);
        label;
    });
    [self addSubview:self.detailMessageLabel];
    [self.detailMessageLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.centerX.equalTo(self.messageContainerView);
        make.left.right.equalTo(self.messageContainerView);
        make.bottom.lessThanOrEqualTo(self.messageContainerView);
        make.top.equalTo(self.messageLabel.bjl_bottom).offset(10.0);
    }];
}

// 提示消息为两行
- (void)makeDoubleMessageView {
    self.messageContainerView = ({
        UIView *view = [BJLHitTestView new];
        view.accessibilityIdentifier = BJLKeypath(self, messageContainerView);
        view;
    });
    [self addSubview:self.messageContainerView];
    [self.messageContainerView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.equalTo(self).offset(16.0);
        make.left.equalTo(self).offset(20.0);
        make.right.equalTo(self).offset(-20.0);
        make.height.equalTo(@(100.0));
    }];

    // message
    self.messageLabel = ({
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = BJLTheme.viewTextColor;
        label.numberOfLines = 2;
        label.font = [UIFont systemFontOfSize:16.0];
        label;
    });
    [self addSubview:self.messageLabel];
    [self.messageLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.messageContainerView);
    }];
}

// 纯文字消息提示
- (void)makePureMessageView {
    self.messageContainerView = ({
        UIView *view = [BJLHitTestView new];
        view.accessibilityIdentifier = BJLKeypath(self, messageContainerView);
        view;
    });
    [self addSubview:self.messageContainerView];
    [self.messageContainerView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.equalTo(self).offset(36.0);
        make.left.equalTo(self).offset(40.0);
        make.right.equalTo(self).offset(-40.0);
        make.height.equalTo(@(90.0));
    }];

    self.messageLabel = ({
        UILabel *label = [UILabel new];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = BJLTheme.viewTextColor;
        label.font = [UIFont systemFontOfSize:16.0];
        label;
    });
    [self addSubview:self.messageLabel];
    [self.messageLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.center.equalTo(self.messageContainerView);
        make.left.right.equalTo(self.messageContainerView);
    }];
}

// 带有复选框消息
- (void)makeCheckboxMessageView {
    self.messageContainerView = ({
        UIView *view = [BJLHitTestView new];
        view.accessibilityIdentifier = BJLKeypath(self, messageContainerView);
        view;
    });
    [self addSubview:self.messageContainerView];
    [self.messageContainerView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.equalTo(self).offset(36.0);
        make.left.equalTo(self).offset(40.0);
        make.right.equalTo(self).offset(-40.0);
        make.height.equalTo(@(90.0));
    }];

    self.messageLabel = ({
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = BJLTheme.viewTextColor;
        label.numberOfLines = 1;
        label.font = [UIFont systemFontOfSize:16.0];
        label;
    });
    [self addSubview:self.messageLabel];
    [self.messageLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.left.right.equalTo(self.messageContainerView);
        make.height.equalTo(@20.0);
    }];

    self.checkboxButton = ({
        BJLButton *button = [BJLButton new];
        button.titleLabel.font = [UIFont systemFontOfSize:12.0];
        button.midSpace = 10.0;
        [button setTitleColor:BJLTheme.viewSubTextColor forState:UIControlStateNormal];
        [button bjl_setImage:[UIImage bjl_imageNamed:@"bjl_popover_checkbox_normal"] forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        [button bjl_setImage:[UIImage bjl_imageNamed:@"bjl_popover_checkbox_selected"] forState:UIControlStateSelected possibleStates:UIControlStateHighlighted];
        [button bjl_addHandler:^(UIButton *_Nonnull button) {
            button.selected = !button.selected;
        }];
        button;
    });
    [self addSubview:self.checkboxButton];
    [self.checkboxButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.messageLabel.bjl_bottom).offset(BJLAppearance.popoverViewSpace);
        make.centerX.equalTo(self.messageContainerView);
        make.height.equalTo(@20.0);
    }];
}

// 二个选项
- (void)makeDoubleHorizontalButtonViewWithButtonSize:(CGSize)size space:(CGFloat)space positive:(BOOL)positive {
    UIButton *leftButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.layer.cornerRadius = 3.0;
        button.layer.masksToBounds = YES;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.font = [UIFont systemFontOfSize:16.0];
        button;
    });
    [self addSubview:leftButton];
    [leftButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(self);
        make.right.equalTo(self.bjl_centerX).offset(-space / 2);
        make.top.equalTo(self.messageContainerView.bjl_bottom).offset(BJLAppearance.popoverViewSpace);
        make.height.equalTo(@(size.height));
        make.width.equalTo(@(size.width));
    }];

    UIButton *rightButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.layer.cornerRadius = 3.0;
        button.layer.masksToBounds = YES;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.font = [UIFont systemFontOfSize:16.0];
        button;
    });
    [self addSubview:rightButton];
    [rightButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.right.lessThanOrEqualTo(self);
        make.left.equalTo(self.bjl_centerX).offset(space / 2);
        make.top.equalTo(leftButton);
        make.height.equalTo(@(size.height));
        make.width.equalTo(@(size.width));
    }];
    if (positive) {
        self.confirmButton = leftButton;
        self.cancelButton = rightButton;
    }
    else {
        self.cancelButton = leftButton;
        self.confirmButton = rightButton;
    }
}

// 三个选项
- (void)makeAppendButtonView {
    [self makeDoubleHorizontalButtonViewWithButtonSize:CGSizeMake(96.0, 40.0) space:32.0 positive:NO];

    // append
    self.appendButton = ({
        UIButton *button = [UIButton new];
        button.layer.cornerRadius = 3.0;
        button.layer.masksToBounds = YES;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.font = [UIFont systemFontOfSize:16.0];
        button;
    });
    [self addSubview:self.appendButton];
    [self.appendButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.cancelButton.bjl_bottom).offset(24.0);
        make.centerX.equalTo(self);
        make.left.height.equalTo(self.cancelButton);
        make.right.equalTo(self.confirmButton.bjl_right);
    }];
}

// 单个选项
- (void)makePassiveExitButtonViewWithButtonSize:(CGSize)size {
    // confirm
    self.confirmButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [BJLTheme brandColor];
        button.layer.cornerRadius = 3.0;
        button.layer.masksToBounds = YES;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [button setTitleColor:[BJLTheme buttonTextColor] forState:UIControlStateNormal];
        button;
    });
    [self addSubview:self.confirmButton];
    [self.confirmButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.messageContainerView.bjl_bottom).offset(BJLAppearance.popoverViewSpace);
        make.height.equalTo(@(size.height));
        make.width.equalTo(@(size.width));
    }];
}

- (void)updateWritingBoardViewConstraints {
    self.viewSize = CGSizeMake(294.0, 132.0);
    [self.messageContainerView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
        make.top.equalTo(self).offset(10.0);
        make.left.equalTo(self).offset(30.0);
        make.right.equalTo(self).offset(-30.0);
        make.height.equalTo(@(50.0));
    }];
}
@end

NS_ASSUME_NONNULL_END
