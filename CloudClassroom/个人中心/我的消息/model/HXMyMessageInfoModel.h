//
//  HXMyMessageInfoModel.h
//  CloudClassroom
//
//  Created by mac on 2022/11/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXMyMessageInfoModel : NSObject

///消息子表ID
@property(nonatomic, copy) NSString *messageSub_Id;
///消息详情id
@property(nonatomic, copy) NSString *user_Id;
///消息标题
@property(nonatomic, copy) NSString *messagetitle;
///消息内容
@property(nonatomic, copy) NSString *messagecontent;
///发送消息时间
@property(nonatomic, copy) NSString *sendtime;
///消息子表阅读状态 0表示未读  1表示已读
@property(nonatomic, assign) NSInteger statusID;
///消息主表ID
@property(nonatomic, copy) NSString *message_Id;
///子表对应的学生ID拼接串
@property(nonatomic, copy) NSString *addresseeIDs;
///子表对应的学生姓名拼接串
@property(nonatomic, copy) NSString *addresseeNames;
///
@property(nonatomic, copy) NSString *redirectURL;

@property(nonatomic, assign) NSInteger count;
///消息类型，0或者空表示是消息管理处来的消息    1表示证件照上传的提示消息2表示成绩导入录入的提示消息
@property(nonatomic, assign) NSInteger mtype;
///是否强制标记
@property(nonatomic, assign) NSInteger isforce;
///是否已读
@property(nonatomic, assign) NSInteger isYdStr;
///发送者
@property(nonatomic, copy) NSString *userNmae;

@end

NS_ASSUME_NONNULL_END
