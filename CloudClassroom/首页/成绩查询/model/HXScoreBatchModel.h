//
//  HXScoreBatchModel.h
//  CloudClassroom
//
//  Created by mac on 2022/10/13.
//

#import <Foundation/Foundation.h>
#import "HXScoreModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXScoreBatchModel : NSObject

///批次名称
@property(nonatomic, copy) NSString *batchName;

///批次名称
@property(nonatomic, strong) NSArray<HXScoreModel*> *bkInfo;

//是否选中 默认否
@property(nonatomic, assign) BOOL isSelected;

@end

NS_ASSUME_NONNULL_END
