//
//  HXXinXiYouWuShowView.h
//  CloudClassroom
//
//  Created by mac on 2022/9/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ConfirmErrorInfoCallBack)(NSString *errorInfo);

@interface HXXinXiYouWuShowView : UIView

@property(nonatomic,copy) ConfirmErrorInfoCallBack confirmErrorInfoCallBack;

-(void)show;

@end

NS_ASSUME_NONNULL_END
