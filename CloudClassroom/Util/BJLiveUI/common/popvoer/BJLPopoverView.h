//
//  BJLPopoverView.h
//  BJLiveUI-BJLInteractiveClass
//
//  Created by xijia dai on 2018/9/20.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BJLPopoverViewType) {
    // exit
    BJLExitViewNormal, // 正常退出
    BJLExitViewRemoveFromRoom, // 被移出
    BJLExitViewTimeOut, // 超时退出
    BJLExitViewConnectFail, // 连接失败退出
    BJLExitViewAppend, // 附加其他操作的退出
    // actions
    BJLKickOutUser, // 踢出用户
    BJLSwitchStage, // 切换上下台
    BJLFreeBlockedUser, // 解除全员黑名单
    BJLStartCloudRecord, // 云端录制
    BJLDisBandGroup, // 解散分组
    BJLRevokeWritingBoard, // 撤销小黑板
    BJLClearWritingBoard, // 清空小黑板
    BJLCloseWritingBoard, // 关闭小黑板
    BJLCloseWebPage, // 关闭网页
    BJLCloseQuiz, // 关闭测验
    BJLHighLoassRate, // 弱网阻塞UI
    BJLAnimatePPTTimeOut, // 动画ppt加载超时
    BJLDeletePPT, // 课件管理删除PPT
    BJLSupportHomework, // 作业功能提示
    BJLStopAsCamera, // 停止外接设备
    BJLStudyRoomAddActiveUserFailed, // 自习室抢位置失败
    BJLExitViewKickOut, // 被踢出
    BJLExitViewKickOutNotAddBlackList, // 被踢出，但没有加黑名单
    BJLExitViewKickOutWithClassEnd, // 课程结束
    BJLExitViewEnforceForbidClass, // 直播间被禁用
    BJLSwitchLayout, // 切换直播间布局
    BJLPlayMediaFile, // 播放音视频课件
    BJLPlayBDSFile, // 打开黑板画笔文件
    BJLSwitchOnlineDoubleRoom, // 线上双师切换大小班
    // hand writing board
    BJLHandWritingBoardConnectFailed, // 手写板连接失败
    BJLHandWritingBoardDisconnect, // 断开手写板连接
    BJLOpenBluetooth, // 打开蓝牙
    // study room
    BJLStudyRoomSwitchModeWhenTutor, // 自习室在进行辅导的时候切换模式
    BJLStudyRoomTutorEnd, // 自习室在结束辅导
    BJLStudyRoom1v1Countdown, // 自习室开始进行1v1辅导倒计时
    BJLStudyRoom1v1TutorEnd, // 自习室场外1v1结束辅导
    BJLStudyRoom1v1TutorTeacherWaitTimeout, // 自习室场外1v1老师等待超时
    BJLStudyRoom1v1TutorStudentWaitTimeout, // 自习室场外1v1学生等待超时
    BJLStudyRoom1v1TutorTeacherStopTutor, // 自习室场外1v1老师主动结束
    BJLStudyRoom1v1TutorStudentStopTutor, // 自习室场外1v1学生主动结束
    // default
    BJLPopoverViewDefaultType = BJLExitViewNormal,
};

NS_ASSUME_NONNULL_BEGIN

@interface BJLPopoverView: UIView

/** 取消 */
@property (nonatomic, readonly) UIButton *cancelButton;

/** 确认 */
@property (nonatomic, readonly) UIButton *confirmButton;

/** 附加操作 */
@property (nonatomic, readonly, nullable) UIButton *appendButton;

/** 存在复选框的按钮 */
@property (nonatomic, readonly) UIButton *checkboxButton;

/** 具体消息，一般不用设置，存在默认信息 */
@property (nonatomic, readonly) UILabel *messageLabel;

/** 详细描述信息，默认信息为空 */
@property (nonatomic, readonly) UILabel *detailMessageLabel;

/** 提示视图大小，默认为 BJLPopoverViewWidth 和 BJLPopoverViewHeight */
@property (nonatomic, readonly) CGSize viewSize;

/**
 提示视图
 #param type BJLPopoverViewType
 #return self
 */
- (instancetype)initWithType:(BJLPopoverViewType)type;

@end

NS_ASSUME_NONNULL_END
