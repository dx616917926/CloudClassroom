//
//  HXMyMessageDetailModel.h
//  CloudClassroom
//
//  Created by mac on 2022/11/25.
//

#import <Foundation/Foundation.h>
#import "HXMyMessageInfoModel.h"
#import "HXMessageAttachmentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXMyMessageDetailModel : NSObject

///消息内容
@property(nonatomic, strong) HXMyMessageInfoModel *respMyMessageInfo;

///消息附件数组
@property(nonatomic, strong) NSArray<HXMessageAttachmentModel *> *respMessageAttaches;

@end

NS_ASSUME_NONNULL_END
