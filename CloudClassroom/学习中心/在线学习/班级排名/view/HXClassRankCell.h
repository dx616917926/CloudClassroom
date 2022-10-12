//
//  HXClassRankCell.h
//  CloudClassroom
//
//  Created by mac on 2022/9/5.
//

#import <UIKit/UIKit.h>
#import "HXCourseScoreRankModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXClassRankCell : UITableViewCell

@property(nonatomic,assign) NSInteger idx;

@property(nonatomic,strong) HXCourseScoreRankModel *courseScoreRankModel;

@end

NS_ASSUME_NONNULL_END
