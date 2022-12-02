//
//  BJLMediaAuthCheckView.h
//  BJLiveUIBase
//
//  Created by xijia dai on 2021/10/19.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BJLMediaCheckStep) {
    BJLMediaCheckStep_auth = -1,
    BJLMediaCheckStep_network = 0,
    BJLMediaCheckStep_camera = 1,
    BJLMediaCheckStep_speaker = 2,
    BJLMediaCheckStep_microphone = 3,
    BJLMediaCheckStep_finish = 4
};

/** ### 媒体权限状态、自检状态视图 */
@interface BJLMediaAuthStateView: UIView

- (instancetype)initWithIconSize:(CGFloat)size space:(CGFloat)space;
@property (nonatomic) BOOL networkReachable, cameraAuth, speakerAuth, microphoneAuth;
@property (nonatomic, nullable) void (^selectCheckStepCallback)(BJLMediaCheckStep step);
@property (nonatomic, readonly) NSMutableArray<UIButton *> *authButtons;
@property (nonatomic, readonly) NSMutableArray<UIImageView *> *checkResultViews;
@property (nonatomic, readonly) UIStackView *iconView;

- (void)updateStep:(BJLMediaCheckStep)step selected:(BOOL)selected;
// 显示检测完成的图标，图标根据检测的成功失败决定图片内容
- (void)updateStep:(BJLMediaCheckStep)step checked:(BOOL)checked;
// 显示检测的步骤的选中状态，会将当前步骤之前所有的状态都设置为选中，认为检测完成，当前步骤之后的所有状态设置为未选中，认为未检测完成
- (void)skipToStep:(BJLMediaCheckStep)step;
// 显示当前检测的进度，在检测完成和检测进行的图标中连线
- (void)makeCheckProgressView;
- (void)prepareForRetry;
- (void)makeCheckCompleteView;
- (BOOL)hasCheckedStep:(BJLMediaCheckStep)step;

@end

@interface BJLMediaStateBar: UIView

- (instancetype)initWithCheckStep:(BJLMediaCheckStep)step pass:(BOOL)pass;
@property (nonatomic, readonly) BJLMediaCheckStep step;
@property (nonatomic, readonly) BOOL pass;
@property (nonatomic) UIImageView *iconImageView, *checkImageView;
@property (nonatomic) UILabel *titleLabel, *messageLabel;

@end

/** ### 媒体权限检测视图 */
@interface BJLMediaAuthCheckView: UIView

@property (nonatomic, nullable) void (^authCheckcompletion)(BOOL success);
- (void)startCheck;

@end

NS_ASSUME_NONNULL_END
