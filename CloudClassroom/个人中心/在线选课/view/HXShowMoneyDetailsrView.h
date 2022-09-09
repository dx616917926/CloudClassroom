//
//  HXShowMoneyDetailsrView.h
//  CloudClassroom
//
//  Created by mac on 2022/9/8.
//

#import <UIKit/UIKit.h>
#import "HXMajorModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^CallBack)(void);

@interface HXShowMoneyDetailsrView : UIView

@property(nonatomic,strong) NSArray *dataArray;

@property(nonatomic,assign) BOOL isShow;

@property(nonatomic,copy) CallBack callBack;

-(void)show;
-(void)dismiss;

@end

NS_ASSUME_NONNULL_END
