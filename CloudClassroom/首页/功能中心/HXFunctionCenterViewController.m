//
//  HXFunctionCenterViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/19.
//

#import "HXFunctionCenterViewController.h"
#import "HXFinancePaymentViewController.h"//财务缴费
#import "HXPaymentQueryViewController.h"//缴费查询
#import "HXScoreQueryViewController.h"//成绩查询
#import "HXMyBuKaoViewController.h"//我的补考
#import "HXLiveCourseViewController.h"//直播课程
#import "HXZiLiaoUploadViewController.h"//资料上传
#import "HXDegreeEnglishShowView.h"
#import "HXHomeMenuModel.h"
#import "SDWebImage.h"

@interface HXFunctionCenterViewController ()

@property(nonatomic,strong) NSMutableArray *bujuArray;
@property(nonatomic,strong) NSMutableArray *bujuBtns;
@property(nonatomic,strong) UIView *btnsContainerView;

@end

@implementation HXFunctionCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UI
    [self createUI];
    //获取首页菜单
    [self getHomeMenu];
}

#pragma mark - 获取首页菜单
-(void)getHomeMenu{
    
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetHomeMenu needMd5:NO  withDictionary:nil success:^(NSDictionary * _Nonnull dictionary) {
        
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            NSArray *list = [HXHomeMenuModel mj_objectArrayWithKeyValuesArray:[dictionary dictionaryValueForKey:@"data"]];
            [self refreshHomeMenuLayout:list];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}
#pragma mark - 重新布局功能模块
-(void)refreshHomeMenuLayout:(NSArray<HXHomeMenuModel*>*)list{
    ///移除重新布局
    [self.bujuBtns removeAllObjects];
    [self.btnsContainerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
        obj = nil;
    }];
    
    [self.bujuArray removeAllObjects];
    [list enumerateObjectsUsingBlock:^(HXHomeMenuModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj.isShow==1){
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            btn.titleLabel.font = HXFont(13);
            [btn setTitle:obj.moduleName forState:UIControlStateNormal];
            [btn setTitleColor:COLOR_WITH_ALPHA(0x333333, 1) forState:UIControlStateNormal];
            NSString *baseUreStr = [HXPublicParamTool sharedInstance].schoolDomainURL;
            [btn sd_setImageWithURL:HXSafeURL(obj.moduleIcon)  forState:UIControlStateNormal placeholderImage:nil];
            [btn addTarget:self action:@selector(handleHomeMenuClick:) forControlEvents:UIControlEventTouchUpInside];
            [_btnsContainerView addSubview:btn];
            [self.bujuBtns addObject:btn];
            
            btn.sd_layout.heightIs(73);
            btn.imageView.sd_layout
                .centerXEqualToView(btn)
                .topSpaceToView(btn, 0)
                .widthIs(47)
                .heightEqualToWidth();
            
            btn.titleLabel.sd_layout
                .bottomSpaceToView(btn, 0)
                .leftEqualToView(btn)
                .rightEqualToView(btn)
                .heightIs(17);
        }
    }];
    [self.btnsContainerView setupAutoMarginFlowItems:self.bujuBtns withPerRowItemsCount:4 itemWidth:60 verticalMargin:20 verticalEdgeInset:20 horizontalEdgeInset:20];
}

#pragma mark - Event
-(void)handleHomeMenuClick:(UIButton *)sender{
    
    NSString *tittle = [sender titleForState:UIControlStateNormal];
    
    if([tittle isEqualToString:@"在线缴费"]){
        HXFinancePaymentViewController *vc = [[HXFinancePaymentViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if([tittle isEqualToString:@"缴费查询"]){
        HXPaymentQueryViewController *vc = [[HXPaymentQueryViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if([tittle isEqualToString:@"成绩查询"]){
        HXScoreQueryViewController *vc = [[HXScoreQueryViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if([tittle isEqualToString:@"我的补考"]){
        HXMyBuKaoViewController *vc = [[HXMyBuKaoViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if([tittle isEqualToString:@"毕业论文"]){
        
        
    }else if([tittle isEqualToString:@"学位英语"]){
        HXDegreeEnglishShowView *degreeEnglishShowView =[[HXDegreeEnglishShowView alloc] init];
        degreeEnglishShowView.type = WeiKaiFangBaoMingType;
        [degreeEnglishShowView show];
    }else if([tittle isEqualToString:@"我的直播"]){
        HXLiveCourseViewController *vc = [[HXLiveCourseViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if([tittle isEqualToString:@"资料上传"]){
        HXZiLiaoUploadViewController *vc = [[HXZiLiaoUploadViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if([tittle isEqualToString:@"毕业登记表"]){
        
    }
    
}
#pragma mark - UI
-(void)createUI{
    
    self.sc_navigationBar.title = @"功能中心";
    
    [self.view addSubview:self.btnsContainerView];
    
    self.btnsContainerView.sd_layout
    .topSpaceToView(self.view, kNavigationBarHeight+16)
    .leftSpaceToView(self.view, 12)
    .rightSpaceToView(self.view,12);
    
    for (UIButton *btn in self.bujuBtns) {
        btn.sd_layout.heightIs(73);
        btn.imageView.sd_layout
            .centerXEqualToView(btn)
            .topSpaceToView(btn, 0)
            .widthIs(47)
            .heightEqualToWidth();
        
        btn.titleLabel.sd_layout
            .bottomSpaceToView(btn, 0)
            .leftEqualToView(btn)
            .rightEqualToView(btn)
            .heightIs(17);
    }
    
    [self.btnsContainerView setupAutoMarginFlowItems:self.bujuBtns withPerRowItemsCount:4 itemWidth:60 verticalMargin:20 verticalEdgeInset:20 horizontalEdgeInset:20];
    self.btnsContainerView.sd_cornerRadius = @8;
    
}

#pragma mark - LazyLoad
-(NSMutableArray *)bujuArray{
    if (!_bujuArray) {
        _bujuArray = [NSMutableArray array];
        [_bujuArray addObjectsFromArray:@[
            [@{@"title":@"在线缴费",@"iconName":@"caiwujiaofei_icon",@"handleEventTag":@(5000),@"isShow":@(1)} mutableCopy],
            [@{@"title":@"缴费查询",@"iconName":@"payquery_icon",@"handleEventTag":@(5001),@"isShow":@(1)} mutableCopy],
            [@{@"title":@"成绩查询",@"iconName":@"scorequery_icon",@"handleEventTag":@(5002),@"isShow":@(1)} mutableCopy],
            [@{@"title":@"我的补考",@"iconName":@"mybukao_icon",@"handleEventTag":@(5003),@"isShow":@(1)} mutableCopy],
            [@{@"title":@"毕业论文",@"iconName":@"lunwen_icon",@"handleEventTag":@(5004),@"isShow":@(1)} mutableCopy],
            [@{@"title":@"学位英语",@"iconName":@"english_icon",@"handleEventTag":@(5005),@"isShow":@(1)} mutableCopy],
            [@{@"title":@"我的直播",@"iconName":@"zhibo_icon",@"handleEventTag":@(5006),@"isShow":@(1)} mutableCopy],
            [@{@"title":@"资料上传",@"iconName":@"zlupload_icon",@"handleEventTag":@(5007),@"isShow":@(1)} mutableCopy],
            [@{@"title":@"毕业登记表",@"iconName":@"bydjb_icon",@"handleEventTag":@(5007),@"isShow":@(1)} mutableCopy],
        ]];
    }
    return _bujuArray;
}


-(NSMutableArray *)bujuBtns{
    if (!_bujuBtns) {
        _bujuBtns = [NSMutableArray array];
    }
    return _bujuBtns;
}


- (UIView *)btnsContainerView{
    if (!_btnsContainerView) {
        _btnsContainerView = [[UIView alloc] init];
        _btnsContainerView.backgroundColor = UIColor.whiteColor;
        for (int i = 0; i<self.bujuArray.count; i++) {
            NSDictionary *dic = self.bujuArray[i];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            btn.titleLabel.font = HXFont(13);
            btn.tag = [dic[@"handleEventTag"] integerValue];
            [btn setTitle:dic[@"title"] forState:UIControlStateNormal];
            [btn setTitleColor:COLOR_WITH_ALPHA(0x333333, 1) forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:dic[@"iconName"]] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(handleHomeMenuClick:) forControlEvents:UIControlEventTouchUpInside];
            [_btnsContainerView addSubview:btn];
            [self.bujuBtns addObject:btn];
        }
    }
    return _btnsContainerView;;
}


@end
