//
//  HXEnterLiveInfoModel.h
//  CloudClassroom
//
//  Created by mac on 2022/12/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXEnterLiveInfoModel : NSObject
///教室/直播间ID
@property(nonatomic, copy) NSString *room_id;
///可传客户账号体系下的用户ID号,不带符号的正整数 ，最大支持19位
@property(nonatomic, copy) NSString *user_number;
///显示的用户昵称
@property(nonatomic, copy) NSString *user_name;
///0:学生 1:老师 2:管理员
@property(nonatomic, assign) NSInteger user_role;
///用户头像，传url
@property(nonatomic, copy) NSString *user_avatar;
///签名
@property(nonatomic, copy) NSString *sign;
///直播地址前缀
@property(nonatomic, copy) NSString *private_domain;

@end

NS_ASSUME_NONNULL_END
