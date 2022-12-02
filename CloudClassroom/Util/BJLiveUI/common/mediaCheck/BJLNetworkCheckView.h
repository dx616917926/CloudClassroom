//
//  BJLNetworkCheckView.h
//  BJLiveUIBase
//
//  Created by xijia dai on 2021/10/22.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLNetworkInfoBar: UIView

@property (nonatomic) NSString *name, *message;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel *messageLabel;
@property (nonatomic) UIImageView *loadingImageView;
- (instancetype)initWithName:(NSString *)name;
- (void)updateMessage:(NSString *)message;
- (void)updateMessage:(NSString *)message centerStyle:(BOOL)rightStyle;

@end

/** ### 网络自检视图 */
@interface BJLNetworkCheckView: UIView

@property (nonatomic) CGFloat uploadSpeed, downloadSpeed; // 单位 Mbps
@property (nonatomic, nullable) NSString *osString, *versionString, *ipString, *networkTypeString, *downloadSpeedString, *uploadSpeedString;
@property (nonatomic, nullable) void (^networkCheckCompletion)(BOOL success);

@end

NS_ASSUME_NONNULL_END
