//
//  HXMessageInfoModel.h
//  CloudClassroom
//
//  Created by mac on 2022/10/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXMessageInfoModel : NSObject

///消息id
@property(nonatomic, copy) NSString *message_Id;
///消息详情id
@property(nonatomic, copy) NSString *detailId;
///消息标题
@property(nonatomic, copy) NSString *messageTitle;
///发送时间
@property(nonatomic, copy) NSString *sendTime;
///
@property(nonatomic, copy) NSString *statusId;
///
@property(nonatomic, copy) NSString *redirectUrl;
///
@property(nonatomic, copy) NSString *mtype;
///
@property(nonatomic, copy) NSString *isforce;

@end

NS_ASSUME_NONNULL_END
