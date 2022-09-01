//
//  HXShowMajorView.h
//  CloudClassroom
//
//  Created by mac on 2022/9/1.
//

#import <UIKit/UIKit.h>
#import "HXMajorModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^SelectMajorCallBack)(BOOL isRefresh,HXMajorModel *selectMajorModel);

@interface HXShowMajorView : UIView

@property(nonatomic,strong) NSArray *dataArray;

-(void)show;

@property(nonatomic,copy) SelectMajorCallBack selectMajorCallBack;

@end

NS_ASSUME_NONNULL_END
