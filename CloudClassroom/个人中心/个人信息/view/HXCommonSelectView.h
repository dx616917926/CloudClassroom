//
//  HXCommonSelectView.h
//  CloudClassroom
//
//  Created by mac on 2023/1/11.
//

#import <UIKit/UIKit.h>
#import "HXCommonSelectModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^SeletConfirmBlock)(BOOL isRefresh,HXCommonSelectModel *selectModel,NSInteger idx);

@interface HXCommonSelectView : UIView

///数据源
@property(nonatomic,strong) NSArray<HXCommonSelectModel*> *dataArray;

@property(nonatomic,strong) NSString *title;

@property(nonatomic,copy) SeletConfirmBlock seletConfirmBlock;

-(void)show;

@end

NS_ASSUME_NONNULL_END
