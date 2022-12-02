//
//  BJLWritingBoard.h
//  BJLiveCore
//
//  Created by 凡义 on 2019/3/27.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BJLUser.h"

NS_ASSUME_NONNULL_BEGIN

/** 小黑板状态 */
typedef NS_ENUM(NSInteger, BJLIcWriteBoardStatus) {
    /** 默认状态 */
    BJLIcWriteBoardStatus_None,
    /** 老师编辑小黑板 */
    BJLIcWriteBoardStatus_teacherEditing,
    /** 老师已发布小黑板未收回 */
    BJLIcWriteBoardStatus_teacherPublished,
    /** 老师已收回小黑板 */
    BJLIcWriteBoardStatus_teacherGathered,
    /** 分享 */
    BJLIcWriteBoardStatus_teacherShare,
    /** 学生作答中 */
    BJLIcWriteBoardStatus_studentEdit
};

/** 小黑板发布操作 */
typedef NS_ENUM(NSInteger, BJLWritingBoardPublishOperate) {
    /** 结束 */
    BJLWritingBoardPublishOperate_end,
    /** 开始 */
    BJLWritingBoardPublishOperate_begin,
    /** 撤销 */
    BJLWritingBoardPublishOperate_revoke,
    /** 删除 */
    BJLWritingBoardPublishOperate_delete
};

@interface BJLWritingBoard: NSObject

@property (nonatomic, readonly) NSString *boardID;
@property (nonatomic, readonly) NSInteger pageIndex;

@property (nonatomic) BOOL isActive;
@property (nonatomic) BOOL isToAll;
@property (nonatomic) NSInteger duration;
@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) BJLWritingBoardPublishOperate operate;

@property (nonatomic, readonly) BJLUser *fromUser; // only user `ID、number、avatar、name` available
@property (nonatomic, readonly) NSArray<BJLUser *> *submitedUsers;
@property (nonatomic, readonly) NSArray<BJLUser *> *participatedUsers;

/* 小黑板所属user的name , 用于分享的窗口显示用户名*/
@property (nonatomic, nullable) NSString *userName;

- (instancetype)initWithBoardID:(NSString *)boardID pageIndex:(NSInteger)pageIndex;

@end

NS_ASSUME_NONNULL_END
