//
//  BJLSettingCell.h
//  BJLiveUIBigClass
//
//  Created by 凡义 on 2021/9/18.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLSettingCell: UICollectionViewCell

- (void)updateContentWithTitle:(NSString *)title selectd:(BOOL)isSelectd;

@end

NS_ASSUME_NONNULL_END
