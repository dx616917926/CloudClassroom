//
//  HXGenerateSignatureViewController.h
//  CloudClassroom
//
//  Created by mac on 2022/12/29.
//

#import "HXBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^GenerateSignatureCallBack)(void);

@interface HXGenerateSignatureViewController : HXBaseViewController

@property(nonatomic,copy)  GenerateSignatureCallBack generateSignatureCallBack;

@end

NS_ASSUME_NONNULL_END
