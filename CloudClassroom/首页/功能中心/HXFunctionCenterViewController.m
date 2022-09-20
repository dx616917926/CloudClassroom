//
//  HXFunctionCenterViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/19.
//

#import "HXFunctionCenterViewController.h"
#import "HXScoreQueryViewController.h"//成绩查询
#import "HXMyBuKaoViewController.h"//我的补考

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
}


#pragma mark - Event
-(void)handleMiddleClick:(UIButton *)sender{
    NSInteger tag = sender.tag;
    switch (tag) {
        case 5000:
        {
           
        }
            break;
        case 5001:
        {
            
        }
            break;
        case 5002:
        {
            HXScoreQueryViewController *vc = [[HXScoreQueryViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 5003:
        {
            HXMyBuKaoViewController *vc = [[HXMyBuKaoViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 5004:
        {
           
        }
            break;
        case 5005:
        {
           
        }
            break;
            
        default:
            break;
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
    
    [self.btnsContainerView setupAutoMarginFlowItems:self.bujuBtns withPerRowItemsCount:4 itemWidth:70 verticalMargin:20 verticalEdgeInset:20 horizontalEdgeInset:20];
    self.btnsContainerView.sd_cornerRadius = @8;
    
}

#pragma mark - LazyLoad
-(NSMutableArray *)bujuArray{
    if (!_bujuArray) {
        _bujuArray = [NSMutableArray array];
        [_bujuArray addObjectsFromArray:@[
            [@{@"title":@"财务缴费",@"iconName":@"caiwujiaofei_icon",@"handleEventTag":@(5000),@"isShow":@(1)} mutableCopy],
            [@{@"title":@"缴费查询",@"iconName":@"payquery_icon",@"handleEventTag":@(5001),@"isShow":@(1)} mutableCopy],
            [@{@"title":@"成绩查询",@"iconName":@"scorequery_icon",@"handleEventTag":@(5002),@"isShow":@(1)} mutableCopy],
            [@{@"title":@"我的补考",@"iconName":@"mybukao_icon",@"handleEventTag":@(5003),@"isShow":@(1)} mutableCopy],
            [@{@"title":@"毕业论文",@"iconName":@"lunwen_icon",@"handleEventTag":@(5004),@"isShow":@(1)} mutableCopy],
            [@{@"title":@"学位英语",@"iconName":@"english_icon",@"handleEventTag":@(5005),@"isShow":@(1)} mutableCopy],
            [@{@"title":@"我的直播",@"iconName":@"zhibo_icon",@"handleEventTag":@(5006),@"isShow":@(1)} mutableCopy],
            [@{@"title":@"资料上传",@"iconName":@"zlupload_icon",@"handleEventTag":@(5007),@"isShow":@(1)} mutableCopy],
            [@{@"title":@"毕业登记表",@"iconName":@"biyedengjibiao_icon",@"handleEventTag":@(5008),@"isShow":@(1)} mutableCopy]
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
            [btn addTarget:self action:@selector(handleMiddleClick:) forControlEvents:UIControlEventTouchUpInside];
            [_btnsContainerView addSubview:btn];
            [self.bujuBtns addObject:btn];
        }
    }
    return _btnsContainerView;;
}



@end
