//
//  HXNoDataTipView.m
//  HXMinedu
//
//  Created by mac on 2021/4/12.
//

#import "HXNoDataTipView.h"

@interface HXNoDataTipView ()

@property(nonatomic,strong) UIImageView *tipImageView;
@property(nonatomic,strong) UILabel *tipLabel;

@end

@implementation HXNoDataTipView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        self.tipTitle = @"暂无数据~";
        [self createUI];
    }
    return self;
}


#pragma mark - setter
-(void)setTipImage:(UIImage *)tipImage{
    self.tipImageView.image = tipImage;
    self.tipImageView.sd_layout
    .widthIs(_kpw(tipImage.size.width))
    .heightIs(_kpw(tipImage.size.height));
    [self.tipImageView updateLayout];
}

-(void)setTipTitle:(NSString *)tipTitle{
    self.tipLabel.text = tipTitle;
}

-(void)setTipImageViewOffset:(NSInteger)tipImageViewOffset{
    _tipImageViewOffset = tipImageViewOffset;
    self.tipImageView.sd_layout.topSpaceToView(self, _kpw(tipImageViewOffset));
    [self.tipImageView updateLayout];
}

-(void)setTipLabelOffset:(NSInteger)tipLabelOffset{
    _tipLabelOffset = tipLabelOffset;
    self.tipLabel.sd_layout.topSpaceToView(self.tipImageView, tipLabelOffset);
    [self.tipLabel updateLayout];
}

#pragma mark - UI

-(void)createUI{
    
    [self addSubview:self.tipImageView];
    [self addSubview:self.tipLabel];
    
    self.tipImageView.sd_layout
    .topSpaceToView(self, _kpw(86))
    .centerXEqualToView(self)
    .widthIs(_kpw(375))
    .heightIs(_kpw(110));
    [self.tipImageView updateLayout];
    
    self.tipLabel.sd_layout
    .topSpaceToView(self.tipImageView, 8)
    .leftSpaceToView(self, 20)
    .rightSpaceToView(self, 20)
    .autoHeightRatio(0);
    
}

-(UIImageView *)tipImageView{
    if (!_tipImageView) {
        _tipImageView = [[UIImageView alloc] init];
        _tipImageView.contentMode = UIViewContentModeScaleAspectFit;
        _tipImageView.image = [UIImage imageNamed:@"nodata_icon"];
    }
    return _tipImageView;
}

-(UILabel *)tipLabel{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.font = HXFont(12);
        _tipLabel.textColor = COLOR_WITH_ALPHA(0xA9A9A9, 1);
        _tipLabel.numberOfLines = 0;
        _tipLabel.text = self.tipTitle;
    }
    return _tipLabel;
}

@end
