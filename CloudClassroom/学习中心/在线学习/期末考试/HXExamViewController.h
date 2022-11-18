//
//  HXExamViewController.h
//  CloudClassroom
//
//  Created by mac on 2022/11/16.
//

#import "HXBaseViewController.h"
#import "HXExamPaperModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXExamViewController : HXBaseViewController
///考卷模型
@property(nonatomic, strong) HXExamPaperModel *examPaperModel;

@end

NS_ASSUME_NONNULL_END
