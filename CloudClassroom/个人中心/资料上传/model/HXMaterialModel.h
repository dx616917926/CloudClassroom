//
//  HXMaterialModel.h
//  CloudClassroom
//
//  Created by mac on 2022/12/29.
//

#import <Foundation/Foundation.h>
#import "HXImgModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface HXMaterialModel : NSObject

///审核状态 0-待审核 1-审核通过 2-重新上传  (1-审核通过不能再上传了)
@property(nonatomic, assign) NSInteger checkStatus;

///图片数组
@property(nonatomic, strong) NSArray<HXImgModel *> *imgList;

@end

NS_ASSUME_NONNULL_END
