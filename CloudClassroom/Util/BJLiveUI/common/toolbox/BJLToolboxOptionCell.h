//
//  BJLToolboxOptionCell.h
//  BJLiveUI
//
//  Created by HuangJie on 2018/10/29.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLToolboxOptionCell: UICollectionViewCell

@property (nonatomic) BOOL showSelectBorder;
@property (nonatomic, nullable, copy) void (^selectCallback)(BOOL selected);

- (void)updateBackgroundIcon:(UIImage *)icon
                selectedIcon:(UIImage *)selectedIcon
                 description:(NSString *_Nullable)description
                  isSelected:(BOOL)selected;

- (void)updateBackgroundIcon:(UIImage *)icon
                selectedIcon:(UIImage *)selectedIcon
             backgroundColor:(nullable UIColor *)backgroundColor
                 description:(NSString *_Nullable)description
                  isSelected:(BOOL)selected;

- (void)updateContentWithOptionIcon:(UIImage *)icon
                       selectedIcon:(UIImage *_Nullable)selectedIcon
                        description:(NSString *_Nullable)description
                         isSelected:(BOOL)selected;

@end

NS_ASSUME_NONNULL_END