//
//  HXCourseArrangingDateModel.h
//  CloudClassroom
//
//  Created by mac on 2022/12/1.
//

#import <Foundation/Foundation.h>
#import "HXFaceTimeCourseDetailModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface HXCourseArrangingDateModel : NSObject

///课程名称
@property(nonatomic,strong) NSString *courseArrangingDate;

//一天的数组
@property(nonatomic, strong) NSArray<HXFaceTimeCourseDetailModel *> *respCourseArranging;

@end

NS_ASSUME_NONNULL_END
