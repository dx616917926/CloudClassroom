//
//  HXCurrentLearCell.h
//  CloudClassroom
//
//  Created by mac on 2022/8/30.
//

#import <UIKit/UIKit.h>
#import "HXCourseInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol HXCurrentLearCellDelegate <NSObject>

//flag:  8000:课件学习    8001:平时作业   8002:期末考试   8003:答疑室   8004:学习报告  8005:班级排名   8006:得分
-(void)handleClickEvent:(NSInteger)flag courseInfoModel:(HXCourseInfoModel *)courseInfoModel;

@end

@interface HXCurrentLearCell : UITableViewCell

@property(nonatomic, weak) id<HXCurrentLearCellDelegate> delegate;

@property(nonatomic, strong) HXCourseInfoModel *courseInfoModel;

@end

NS_ASSUME_NONNULL_END
