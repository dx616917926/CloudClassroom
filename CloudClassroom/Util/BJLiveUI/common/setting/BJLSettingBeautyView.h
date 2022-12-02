//
//  BJLSettingBeautyView.h
//  BJLiveUIBigClass
//
//  Created by 辛亚鹏 on 2021/10/8.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLSettingBeautyView: UIView

- (instancetype)initWithTitle:(NSString *)title normalImage:(NSString *)normalImage disableImage:(NSString *)disableImage value:(float)value;

// value 取值范围: [0, 9]
@property (nonatomic, copy) void (^valueChangeCallback)(CGFloat value);

- (void)beautyOn:(BOOL)isOn;

@end

NS_ASSUME_NONNULL_END
