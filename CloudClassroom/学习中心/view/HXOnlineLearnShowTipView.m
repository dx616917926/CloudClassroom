//
//  HXOnlineLearnShowTipView.m
//  CloudClassroom
//
//  Created by mac on 2022/9/1.
//

#import "HXOnlineLearnShowTipView.h"

@interface HXOnlineLearnShowTipView ()

@property(nonatomic,strong) UIView *maskView;
@property(nonatomic,strong) UIView *bigBackGroundView;
@property(nonatomic,strong) UIButton *tipButton;
@property(nonatomic,strong) UIButton *closeButton;
@property(nonatomic,strong) UILabel *tipContentLabel;

@end

@implementation HXOnlineLearnShowTipView

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
    [self.bigBackGroundView addSubview:self.closeButton];
    [self.bigBackGroundView addSubview:self.tipButton];
    [self.bigBackGroundView addSubview:self.tipContentLabel];
    
    self.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    
    self.bigBackGroundView.sd_layout
    .centerXEqualToView(self)
    .centerYEqualToView(self)
    .widthIs(_kpw(335))
    .heightIs(316);
    self.bigBackGroundView.sd_cornerRadius = @5;
    
    self.tipButton.sd_layout
    .topSpaceToView(self.bigBackGroundView, 24)
    .centerXEqualToView(self.bigBackGroundView)
    .heightIs(30);
    
    self.tipButton.imageView.sd_layout
    .centerYEqualToView(self.tipButton)
    .leftEqualToView(self.tipButton)
    .widthIs(22)
    .heightEqualToWidth();
    
    self.tipButton.titleLabel.sd_layout
    .centerYEqualToView(self.tipButton)
    .leftSpaceToView(self.tipButton.imageView, 10)
    .heightIs(30);
    [self.tipButton.titleLabel setSingleLineAutoResizeWithMaxWidth:80];
    
    [self.tipButton setupAutoWidthWithRightView:self.tipButton.titleLabel rightMargin:0];
   
   
    self.closeButton.sd_layout
    .topEqualToView(self.bigBackGroundView)
    .rightEqualToView(self.bigBackGroundView)
    .widthIs(48)
    .heightEqualToWidth();
    
    self.closeButton.imageView.sd_layout
    .centerXEqualToView(self.closeButton)
    .centerYEqualToView(self.closeButton)
    .widthIs(25)
    .heightEqualToWidth();
    
    self.tipContentLabel.sd_layout
    .topSpaceToView(self.tipButton, 12)
    .leftSpaceToView(self.bigBackGroundView, 16)
    .rightSpaceToView(self.bigBackGroundView, 16)
    .autoHeightRatio(0);

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

-(UIButton *)tipButton{
    if (!_tipButton) {
        _tipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _tipButton.titleLabel.font = HXBoldFont(15);
        [_tipButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_tipButton setImage:[UIImage imageNamed:@"gantan_icon"] forState:UIControlStateNormal];
        [_tipButton setTitle:@"温馨提示" forState:UIControlStateNormal];
    }
    return _tipButton;
}

-(UIButton *)closeButton{
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"close_icon"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}


-(UILabel *)tipContentLabel{
    if (!_tipContentLabel) {
        _tipContentLabel = [[UILabel alloc] init];
        _tipContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _tipContentLabel.font = HXFont(14);
        _tipContentLabel.textAlignment = NSTextAlignmentLeft;
        _tipContentLabel.numberOfLines = 0;
        _tipContentLabel.text = @"1. 同一帐号打开多个课件成绩计算无效。\n\n2. 不能拖着视频快进，会影响课件计时。\n\n3. 视频中可能弹出确认是否在电脑前的确认框，不确认会停止计时。\n\n4. 推荐使用chrome浏览器学习。\n\n5. 使用手机学习需下载APP，不建议使用手机自带浏览器学习，可能影响计时。\n\n6. 每日课件学习的成绩更新时间为次日8：00。";
    }
    return _tipContentLabel;
}




@end

