//
//  BJLEnvelopesRainView.h
//  BJLiveUI
//
//  Created by xyp on 2021/1/8.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveCore/BJLiveCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLEnvelopesRainView: UIView

/// 实例化一个创建红包雨的view
+ (instancetype)createEnvelopesRainViewWithRoom:(BJLRoom *)room;

/// 实例化一个创建红包雨结束的view
/// @param isTeacher yes: 老师, no: 助教
+ (instancetype)resultEnvelopesRainViewIsTeacher:(BOOL)isTeacher;

@property (nonatomic, copy) void (^closeCallback)(void);

// 发起红包雨
@property (nonatomic, copy) void (^createRainCallback)(NSInteger count, NSInteger score, NSInteger duration);

// 查看结果
@property (nonatomic, copy) void (^showResultCallback)(BJLEnvelopesRainView *resultView);
// 再发一次
@property (nonatomic, copy) void (^onceMoreCallback)(void);

@property (nonatomic, readonly) UITextField *countTextField, *scoreTextField;

@end

NS_ASSUME_NONNULL_END
