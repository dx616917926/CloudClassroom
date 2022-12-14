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
    
    UIView *backV = [[UIView alloc]initWithFrame:CGRectMake(0, -1, kScreenWidth, kTabBarHeight)];
    backV.backgroundColor = [UIColor whiteColor];
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
        .widthIs(20)
        .heightEqualToWidth();
        
        btn.titleLabel.sd_layout
        .topSpaceToView(btn.imageView, 5)
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

#pragma mark -????????????
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
//#pragma mark -??????hitTest?????????????????????????????????????????????????????????????????????????????????????????????
//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//
//    //??????????????????????????????????????????push???????????????????????????????????????????????????????????????????????????????????????
//    //self.isHidden == NO ????????????????????????tabbar????????????????????????????????????????????????????????????
//    //??????????????????????????????????????????????????????????????????????????????????????????????????????????????????
//    //????????????????????????????????????????????????????????????????????????????????????????????????????????????
//    if (self.isHidden == NO) {
//
//        //?????????tabbar????????????????????????????????????????????????????????????????????????????????????
//        CGPoint newP = [self convertPoint:point toView:self.centerBtn];
//
//        //??????????????????????????????????????????????????????????????????????????????????????????view??????????????????
//        if ( [self.centerBtn pointInside:newP withEvent:event]) {
//            return self.centerBtn;
//        }else{//?????????????????????????????????????????????????????????????????????
//            return [super hitTest:point withEvent:event];
//        }
//    }
//    else {//tabbar??????????????????????????????push????????????????????????????????????????????????????????????????????????view???????????????
//        return [super hitTest:point withEvent:event];
//    }
//}
#pragma mark -??????????????????UITabBarItem
- (NSArray<UITabBarItem *> *)items {
    return @[];
}
- (void)setItems:(NSArray<UITabBarItem *> *)items {
}
- (void)setItems:(NSArray<UITabBarItem *> *)items animated:(BOOL)animated {
}




@end

