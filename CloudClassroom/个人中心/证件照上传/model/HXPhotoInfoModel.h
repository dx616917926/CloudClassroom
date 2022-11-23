//
//  HXPhotoInfoModel.h
//  CloudClassroom
//
//  Created by mac on 2022/11/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXPhotoInfoModel : NSObject

///照片确认状态    0:未确认       1:已确认
@property(nonatomic, assign) NSInteger comStatus;
///审核状态         0:未审核       1:已审核
@property(nonatomic, assign) NSInteger auditStatus;
///证件图片URL
@property(nonatomic, copy) NSString *imgUrl;
///时间范围状态 0:在范围     1:不在范围
@property(nonatomic, assign) NSInteger isPhotoTime;


@end

NS_ASSUME_NONNULL_END
