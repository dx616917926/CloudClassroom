//
//  HXFaceTimeTableShowView.h
//  CloudClassroom
//
//  Created by mac on 2022/9/29.
//

#import <UIKit/UIKit.h>
#import "HXFaceTimeCourseDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXFaceTimeTableShowView : UIView

@property(nonatomic,strong) HXFaceTimeCourseDetailModel *faceTimeCourseDetailModel;

-(void)show;

@end

NS_ASSUME_NONNULL_END
