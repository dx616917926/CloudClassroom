//
//  HXSemesterHeaderView.h
//  CloudClassroom
//
//  Created by mac on 2022/10/25.
//

#import <UIKit/UIKit.h>
#import "HXSemesterModel.h"
NS_ASSUME_NONNULL_BEGIN

typedef void (^ExpandCallBack)(void);

@interface HXSemesterHeaderView : UITableViewHeaderFooterView

@property(nonatomic,strong) HXSemesterModel *semesterModel;

@property(nonatomic,copy) ExpandCallBack expandCallBack;


@end

NS_ASSUME_NONNULL_END
