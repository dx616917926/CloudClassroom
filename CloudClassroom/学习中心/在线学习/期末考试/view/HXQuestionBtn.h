//
//  HXQuestionBtn.h
//  CloudClassroom
//
//  Created by mac on 2022/11/21.
//

#import <UIKit/UIKit.h>
#import "HXExamPaperSuitQuestionModel.h"
#import "HXExamPaperSubQuestionModel.h"

NS_ASSUME_NONNULL_BEGIN


@interface HXQuestionBtn : UIButton
///保存题目的信息
@property (nonatomic,strong) HXExamPaperSuitQuestionModel *info;
///保存子题目的信息
@property (nonatomic,strong) HXExamPaperSubQuestionModel *subInfo;
///是否是复合题型
@property (nonatomic,assign) BOOL isFuhe;
///题的位置（从0 开始）
@property (nonatomic,assign) NSInteger position;
///保存复合题中小题的位置（从0 开始）
@property (nonatomic,assign) NSInteger fuhe_position;

@end

NS_ASSUME_NONNULL_END
