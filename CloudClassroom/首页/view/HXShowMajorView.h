//
//  HXShowMajorView.h
//  CloudClassroom
//
//  Created by mac on 2022/9/1.
//

#import <UIKit/UIKit.h>
#import "HXMajorInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^SelectMajorCallBack)(BOOL isRefresh,HXMajorInfoModel *selectMajorModel,NSInteger idx);

@interface HXShowMajorView : UIView

@property(nonatomic,strong) NSArray<HXMajorInfoModel *> *dataArray;

@property(nonatomic,copy) SelectMajorCallBack selectMajorCallBack;

-(void)show;

@end

NS_ASSUME_NONNULL_END
