//
//  HXMyMessageInfoModel.h
//  CloudClassroom
//
//  Created by mac on 2022/11/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXMyMessageInfoModel : NSObject

///信息详情id
@property(nonatomic, copy) NSString *messageDetail_Id;
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


@end

NS_ASSUME_NONNULL_END
