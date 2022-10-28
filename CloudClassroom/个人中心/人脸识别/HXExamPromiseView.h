//
//  HXExamPromiseView.h
//  CloudClassroom
//
//  Created by mac on 2022/10/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^HXExamPromiseViewSureSelectBlock)(void);

//考试须知的弹框
@interface HXExamPromiseView : UIView

@property (copy, nonatomic) HXExamPromiseViewSureSelectBlock sureSelectBlock;

@property (nonatomic, strong) NSArray *alterUrl;

/// 倒计时，默认3秒
@property(nonatomic, assign) NSInteger countDown;

/// 是否显示取消按钮
@property(nonatomic, assign) BOOL showCancelButton;

//弹出
- (void)showInViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
