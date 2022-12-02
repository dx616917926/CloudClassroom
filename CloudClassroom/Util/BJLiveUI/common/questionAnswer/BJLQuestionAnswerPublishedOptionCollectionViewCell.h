//
//  BJLQuestionAnswerPublishedOptionCollectionViewCell.h
//  BJLiveUI
//
//  Created by fanyi on 2019/6/3.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString
    *const BJLQuestionAnswerPublishedOptionCollectionViewCell_ChoosenCell,
        *const BJLQuestionAnswerPublishedOptionCollectionViewCell_JudgeCell_right,
            *const BJLQuestionAnswerPublishedOptionCollectionViewCell_JudgeCell_wrong;

@interface BJLQuestionAnswerPublishedOptionCollectionViewCell: UICollectionViewCell

- (void)updateContentWithOptionKey:(NSString *)optionKey isSelected:(BOOL)isSelected selectedTimes:(NSInteger)times;

- (void)updateContentWithSelected:(BOOL)isSelected selectedTimes:(NSInteger)times;
- (void)updateJudgeOptionTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
