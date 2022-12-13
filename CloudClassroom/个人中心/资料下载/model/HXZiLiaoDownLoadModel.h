//
//  HXZiLiaoDownLoadModel.h
//  CloudClassroom
//
//  Created by mac on 2022/12/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXZiLiaoDownLoadModel : NSObject

///资源id
@property(nonatomic, copy) NSString *resourceId;
///发布人
@property(nonatomic, copy) NSString *operatorName;
///资源标题
@property(nonatomic, copy) NSString *resourceRemarks;
///发布时间
@property(nonatomic, copy) NSString *sendTime;
///发布时间
@property(nonatomic, copy) NSString *sendTimeStr;
///资源状态 1公开 私密
@property(nonatomic, assign) NSInteger isPublic;
///资源名称
@property(nonatomic, copy) NSString *fileName;
///资源存储路径
@property(nonatomic, copy) NSString *filePath;


@end

NS_ASSUME_NONNULL_END
