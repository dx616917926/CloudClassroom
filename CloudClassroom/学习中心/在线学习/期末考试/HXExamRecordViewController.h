//
//  HXExamRecordViewController.h
//  CloudClassroom
//
//  Created by mac on 2022/12/7.
//

#import "HXBaseViewController.h"
#import "HXExamParaModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXExamRecordViewController : HXBaseViewController

@property(nonatomic, copy) NSString *examId;

@property(nonatomic, strong) HXExamParaModel *examPara;

@end

NS_ASSUME_NONNULL_END
