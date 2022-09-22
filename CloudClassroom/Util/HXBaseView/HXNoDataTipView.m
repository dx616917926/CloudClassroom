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
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        [self createUI];
    }
    return self;
}


#pragma mark - setter
-(void)setType:(NoDataType)type{
    _type = type;
    switch (type) {
        case NoType:
            self.tipImageView.image = [UIImage imageNamed:@"nodata_icon"];
            break;
        case NoType2:
            self.tipImageView.image = [UIImage imageNamed:@"nodata_icon2"];
            break;
        case NoType3:
            self.tipImageView.image = [UIImage imageNamed:@"nodata_icon3"];
            break;
            
        default:
            break;
    }
}
-(void)setTipImage:(UIImage *)tipImage{
    _tipImage = tipImage;
    self.tipImageView.image = tipImage;
    self.tipImageView.sd_layout
    .widthIs(tipImage.size.width)
    .heightIs(tipImage.size.width);
    [self.tipImageView updateLayout];
}

-(void)setTipTitle:(NSString *)tipTitle{
    _tipTitle = tipTitle;
    self.tipLabel.text = tipTitle;
}

-(void)setTipImageViewOffset:(NSInteger)tipImageViewOffset{
    _tipImageViewOffset = tipImageViewOffset;
    self.tipImageView.sd_layout.topSpaceToView(self, tipImageViewOffset);
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
    .topSpaceToView(self, 114)
    .centerXEqualToView(self)
    .widthIs(180)
    .heightIs(120);
    [self.tipImageView updateLayout];
    
    self.tipLabel.sd_layout
    .topSpaceToView(self.tipImageView, 30)
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
        _tipLabel.font = HXFont(13);
        _tipLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _tipLabel.numberOfLines = 0;
        _tipLabel.text = @"暂无数据~";;
    }
    return _tipLabel;
}

@end
