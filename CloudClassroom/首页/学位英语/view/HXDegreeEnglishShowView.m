//
//  HXDegreeEnglishShowView.m
//  CloudClassroom
//
//  Created by mac on 2022/9/21.
//

#import "HXDegreeEnglishShowView.h"

@interface HXDegreeEnglishShowView ()

@property(nonatomic,strong) UIView *maskView;
@property(nonatomic,strong) UIView *bigBackGroundView;
@property(nonatomic,strong) UIImageView *tipImageView;
@property(nonatomic,strong) UILabel *tipTitleLabel;
@property(nonatomic,strong) UILabel *tipContentLabel;
@property(nonatomic,strong) UIButton *closeButton;


@end

@implementation HXDegreeEnglishShowView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//- (instancetype)showToView:(UIView *)view upView:(UIView *)upView  dataSource:(NSArray *)dataSource
//{
//
//}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self creatUI];
    }
    return self;
}

#pragma mark - Setter
-(void)setType:(DegreeEnglishType)type{
    _type = type;
    switch (type) {
        case FeiBenKeShengType:
        {
            self.tipTitleLabel.text = @"非本科生，不能申请学位证书";
            self.tipContentLabel.text = nil;
        }
            break;
        case WeiKaiFangBaoMingType:
        {
            self.tipTitleLabel.text = @"学位申请暂未开放报名";
            self.tipContentLabel.text = @"具体报名时间可以联系助学点老师";
        }
            break;
        case WeiManZuTiaoJianType:
        {
            self.tipTitleLabel.text = @"未满足学位申请的条件";
            self.tipContentLabel.text = @"详情请联系助学点老师";
        }
            break;
            
        default:
            break;
    }
}

-(void)show{
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.maskView];
}

-(void)dismiss{
    [self.maskView removeFromSuperview];
     self.maskView = nil;
}

#pragma mark -UI
-(void)creatUI{
    [self.maskView addSubview:self];
    [self addSubview:self.bigBackGroundView];
    [self.bigBackGroundView addSubview:self.tipImageView];
    [self.bigBackGroundView addSubview:self.tipTitleLabel];
    [self.bigBackGroundView addSubview:self.tipContentLabel];
    [self.bigBackGroundView addSubview:self.closeButton];
    
    
    self.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    
    self.bigBackGroundView.sd_layout
    .centerXEqualToView(self)
    .centerYEqualToView(self).offset(-kScreenBottomMargin)
    .widthIs(277)
    .heightIs(250);
    self.bigBackGroundView.sd_cornerRadius = @5;
    
    self.tipImageView.sd_layout
    .topSpaceToView(self.bigBackGroundView, 20)
    .centerXEqualToView(self.bigBackGroundView)
    .widthIs(132)
    .heightIs(103);
    
    self.tipTitleLabel.sd_layout
    .topSpaceToView(self.tipImageView, 15)
    .leftSpaceToView(self.bigBackGroundView, 16)
    .rightSpaceToView(self.bigBackGroundView, 16)
    .heightIs(21);
    
    self.tipContentLabel.sd_layout
    .topSpaceToView(self.tipTitleLabel, 2)
    .leftEqualToView(self.tipTitleLabel)
    .rightEqualToView(self.tipTitleLabel)
    .heightIs(17);
    
    self.closeButton.sd_layout
    .bottomSpaceToView(self.bigBackGroundView, 25)
    .centerXEqualToView(self.bigBackGroundView)
    .widthIs(160)
    .heightIs(36);
    self.closeButton.sd_cornerRadiusFromHeightRatio=@0.5;

}



#pragma mark -LazyLoad
-(UIView *)maskView{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _maskView.backgroundColor = COLOR_WITH_ALPHA(0x000000, 0.5);
    }
    return _maskView;
}



-(UIView *)bigBackGroundView{
    if (!_bigBackGroundView) {
        _bigBackGroundView = [[UIView alloc] init];
        _bigBackGroundView.backgroundColor = UIColor.whiteColor;
    }
    return _bigBackGroundView;
}

-(UIImageView *)tipImageView{
    if (!_tipImageView) {
        _tipImageView = [[UIImageView alloc] init];
        _tipImageView.image = [UIImage imageNamed:@"degreeenglish_icon"];
    }
    return _tipImageView;
}




-(UILabel *)tipTitleLabel{
    if (!_tipTitleLabel) {
        _tipTitleLabel = [[UILabel alloc] init];
        _tipTitleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _tipTitleLabel.font = HXBoldFont(15);
        _tipTitleLabel.textAlignment = NSTextAlignmentCenter;
        _tipTitleLabel.numberOfLines = 1;
    }
    return _tipTitleLabel;
}

-(UILabel *)tipContentLabel{
    if (!_tipContentLabel) {
        _tipContentLabel = [[UILabel alloc] init];
        _tipContentLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _tipContentLabel.font = HXFont(12);
        _tipContentLabel.textAlignment = NSTextAlignmentCenter;
        _tipContentLabel.numberOfLines = 1;
    }
    return _tipContentLabel;
}


-(UIButton *)closeButton{
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.titleLabel.font =HXBoldFont(14);
        _closeButton.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        [_closeButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_closeButton setTitle:@"我知道了" forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}



@end


