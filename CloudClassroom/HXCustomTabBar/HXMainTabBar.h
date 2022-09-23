//
//  HXMainTabBar.h
//  HXXiaoGuan
//
//  Created by mac on 2021/5/31.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol HXMainTabBarDelegate <NSObject>

-(void)changeIndex:(NSInteger)index;

-(void)clickCenterBtn;

@end

@interface HXMainTabBar : UITabBar

@property(nonatomic,assign) NSInteger tabIndex;

@property(nonatomic,weak) id delegate;

- (instancetype)initWithTitArr:(NSArray *)titArr imgArr:(NSArray *)imgArr sImgArr:(NSArray *)sImgArr;

@end

NS_ASSUME_NONNULL_END
