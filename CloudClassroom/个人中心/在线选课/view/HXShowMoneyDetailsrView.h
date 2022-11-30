//
//  HXShowMoneyDetailsrView.h
//  CloudClassroom
//
//  Created by mac on 2022/9/8.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

typedef void (^CallBack)(void);

@interface HXShowMoneyDetailsrView : UIView

//fromFalg 1:在线选课  2:财务缴费
@property(nonatomic,assign) NSInteger fromFalg;

@property(nonatomic,strong) NSArray *dataArray;

@property(nonatomic,assign) BOOL isShow;
//是否有学期
@property(nonatomic,assign) BOOL isHaveXueQi;

@property(nonatomic,copy) CallBack callBack;

-(void)show;

-(void)dismiss;

@end

NS_ASSUME_NONNULL_END
