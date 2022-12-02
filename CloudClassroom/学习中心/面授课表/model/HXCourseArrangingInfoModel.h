//
//  HXCourseArrangingInfoModel.h
//  CloudClassroom
//
//  Created by mac on 2022/12/1.
//

#import <Foundation/Foundation.h>
#import "HXCourseArrangingDateModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface HXCourseArrangingInfoModel : NSObject
///查询日期 星期 第几周
@property(nonatomic,strong) NSString *arrangingDateName;

//七天的数组
@property(nonatomic, strong) NSArray<HXCourseArrangingDateModel *> *respCourseArrangingDates;

@end

NS_ASSUME_NONNULL_END
