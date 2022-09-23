//
//  HXMainTabBar.m
//  HXXiaoGuan
//
//  Created by mac on 2021/5/31.
//

#import "HXMainTabBar.h"
#import "HXCustomBtn.h"

@interface HXMainTabBar ()

@property(nonatomic,strong) HXCustomBtn *centerBtn;
@property(nonatomic,strong)NSMutableArray *btnArr;
@property(nonatomic,copy)NSArray *titArr;
@property(nonatomic,copy)NSArray *imgArr;
@property(nonatomic,copy)NSArray *sImgArr;

@end

@implementation HXMainTabBar

@dynamic delegate;


- (instancetype)initWithTitArr:(NSArray *)titArr imgArr:(NSArray *)imgArr sImgArr:(NSArray *)sImgArr
{
    self = [super init];
    if (self) {
        self.backgroundColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
        self.btnArr = [NSMutableArray array];
        self.titArr = titArr;
        self.imgArr = imgArr;
        self.sImgArr = sImgArr;
        [self creatSubView];
    }
    return self;
}
-(void)creatSubView{
    
    UIView *backV = [[UIView alloc] initWithFrame:CGRectMake(0, -1, kScreenWidth, kTabBarHeight)];
    backV.backgroundColor = [UIColor whiteColor];
    backV.layer.shadowColor = COLOR_WITH_ALPHA(0xADB3CD, 0.12).CGColor;
    backV.layer.shadowOffset = CGSizeMake(0,-2.5);
    backV.layer.shadowOpacity = 1;
    backV.layer.shadowRadius = 25;
    [self addSubview:backV];
    
//      
    
    CGFloat btnW = kScreenWidth/self.titArr.count;
    for (NSInteger index = 0; index < self.titArr.count; index ++) {
        
        HXCustomBtn *btn = [HXCustomBtn new];
        [btn setTitle:self.titArr[index] forState:UIControlStateNormal];
        [btn setTitleColor:COLOR_WITH_ALPHA(0x5E6065, 1) forState:UIControlStateNormal];
        [btn setTitleColor:COLOR_WITH_ALPHA(0x5E6065, 1) forState:UIControlStateSelected];
        [btn setImage:[UIImage imageNamed:self.sImgArr[index]] forState:UIControlStateSelected];
        [btn setImage:[UIImage imageNamed:self.imgArr[index]] forState:UIControlStateNormal];
        btn.titleLabel.font = HXBoldFont(12);
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        btn.frame = CGRectMake(btnW*index, 0, btnW, kTabBarHeight);
        btn.imageView.sd_layout
        .topSpaceToView(btn, 5)
        .centerXEqualToView(btn)
        .widthIs(24)
        .heightEqualToWidth();
        
        btn.titleLabel.sd_layout
        .topSpaceToView(btn.imageView, 3)
        .centerXEqualToView(btn)
        .widthRatioToView(btn, 1)
        .heightIs(17);
        
        
        
        btn.tag = 2020 +index;
        [self addSubview:btn];
        [self.btnArr addObject:btn];
        if (index == 0) {
            btn.selected = YES;
        }
    }
    
}

#pragma mark -切换索引
-(void)btnAction:(HXCustomBtn *)btn{
    for (HXCustomBtn *indexBtn in self.btnArr) {
        indexBtn.selected = btn.tag == indexBtn.tag ? YES:NO;
    }

    if ([self.delegate respondsToSelector:@selector(changeIndex:)]) {
        [self.delegate changeIndex:(btn.tag - 2020)];
    }
}
-(void)setTabIndex:(NSInteger)tabIndex{
    _tabIndex = tabIndex;
    [self.btnArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HXCustomBtn *btn = obj;
        btn.selected = (idx == _tabIndex ? YES:NO);
    }];
}
//#pragma mark -重写hitTest方法，去监听发布按钮的点击，目的是为了让凸出的部分点击也有反应
//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//
//    //这一个判断是关键，不判断的话push到其他页面，点击添加按钮的位置也是会有反应的，这样就不好了
//    //self.isHidden == NO 说明当前页面是有tabbar的，那么肯定是在导航控制器的根控制器页面
//    //在导航控制器根控制器页面，那么我们就需要判断手指点击的位置是否在添加按钮身上
//    //是的话，让添加按钮自己处理点击事件，不是的话让系统去处理点击事件就可以了
//    if (self.isHidden == NO) {
//
//        //将当前tabbar的触摸点转换坐标系，转换到添加按钮的身上，生成一个新的点
//        CGPoint newP = [self convertPoint:point toView:self.centerBtn];
//
//        //判断如果这个新的点是在添加按钮身上，那么处理点击事件最合适的view就是发布按钮
//        if ( [self.centerBtn pointInside:newP withEvent:event]) {
//            return self.centerBtn;
//        }else{//如果点不在添加按钮身上，直接让系统处理就可以了
//            return [super hitTest:point withEvent:event];
//        }
//    }
//    else {//tabbar隐藏了，那么说明已经push到其他的页面了，这个时候还是让系统去判断最合适的view处理就好了
//        return [super hitTest:point withEvent:event];
//    }
//}
#pragma mark -彻底干掉系统UITabBarItem
- (NSArray<UITabBarItem *> *)items {
    return @[];
}
- (void)setItems:(NSArray<UITabBarItem *> *)items {
}
- (void)setItems:(NSArray<UITabBarItem *> *)items animated:(BOOL)animated {
}




@end

