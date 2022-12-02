//
//  HXLivePlaybackInfoModel.h
//  CloudClassroom
//
//  Created by mac on 2022/12/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXLivePlaybackInfoModel : NSObject

///播教室ID
@property(nonatomic, copy) NSString *classID;
///长期房间回放课节参数。如果 classID 对应的课程不是长期房间,可不传;如果 classID 对应的课程是长期房间, 不传则默认返回长期房间的第一个课程
@property(nonatomic, copy) NSString *sessionID;
///回放Token
@property(nonatomic, copy) NSString *token;
///观看回放的用户ID,传int类型正整数；
@property(nonatomic, copy) NSString *user_number;
///观看回放的用户昵称
@property(nonatomic, copy) NSString *user_name;
///直播地址前缀
@property(nonatomic, copy) NSString *private_domain;
///错误信息，如果为空，则表示没有错误，可以直接播放回看
@property(nonatomic, copy) NSString *playMessage;

@end

NS_ASSUME_NONNULL_END
