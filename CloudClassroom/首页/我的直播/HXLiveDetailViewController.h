//
//  HXLiveDetailViewController.h
//  CloudClassroom
//
//  Created by mac on 2022/10/18.
//

#import "HXBaseViewController.h"
#import "HXLiveDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXLiveDetailViewController : HXBaseViewController


///直播类型 （1公开课 2非公开课）
@property(nonatomic, assign) NSInteger dbType;
///学生ID
@property(nonatomic, copy) NSString *student_id;
///每一次直播ID
@property(nonatomic, copy) NSString *detailID;


@end

NS_ASSUME_NONNULL_END
