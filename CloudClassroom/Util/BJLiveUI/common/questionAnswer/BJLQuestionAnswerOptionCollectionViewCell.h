//
//  BJLQuestionAnswerOptionCollectionViewCell.h
//  BJLiveUI
//
//  Created by fanyi on 2019/5/29.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString
    *const BJLQuestionAnswerOptionCollectionViewCellID_ChoosenCell,
        *const BJLQuestionAnswerOptionCollectionViewCellID_JudgeCell_right,
            *const BJLQuestionAnswerOptionCollectionViewCellID_JudgeCell_wrong;

/** 答题器选项 */
@interface BJLQuestionAnswerOptionCollectionViewCell: UICollectionViewCell

@property (nonatomic, copy, nullable) void (^optionSelectedCallback)(BOOL selected);

//作答时，更新cell
- (void)updateContentWithOptionKey:(NSString *)optionKey isSelected:(BOOL)isSelected;

- (void)updateContentWithSelected:(BOOL)isSelected text:(NSString *)text;

// 展示选择结果时，更新cell
- (void)updateContentWithOptionKey:(NSString *)optionKey isCorrect:(BOOL)isCorrect;

- (void)updateContentWithJudgOptionKey:(NSString *)optionKey isCorrect:(BOOL)isCorrect;
@end

NS_ASSUME_NONNULL_END
