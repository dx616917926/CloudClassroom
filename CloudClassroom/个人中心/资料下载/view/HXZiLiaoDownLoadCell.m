//
//  HXZiLiaoDownLoadCell.m
//  CloudClassroom
//
//  Created by mac on 2022/9/23.
//

#import "HXZiLiaoDownLoadCell.h"

@interface HXZiLiaoDownLoadCell ()

@property(nonatomic,strong) UIView *bigBackgroundView;
@property(nonatomic,strong) UIButton *stateBtn;
@property(nonatomic,strong) UILabel *titleLabel;

@property(nonatomic,strong) UIControl *ziLiaoControl;
@property(nonatomic,strong) UIImageView *ziLiaoIcon;
@property(nonatomic,strong) UILabel *ziLiaoNameLabel;
@property(nonatomic,strong) UIImageView *ziLiaoDownIcon;

@property(nonatomic,strong) UILabel *publishTimeLabel;
@property(nonatomic,strong) UILabel *publishPersonLabel;


@end

@implementation HXZiLiaoDownLoadCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
    }
    return self;
}

#pragma mark - Event


#pragma mark - UI
-(void)createUI{

    self.contentView.backgroundColor = VCBackgroundColor;
    self.backgroundColor =VCBackgroundColor;
    
    [self.contentView addSubview:self.bigBackgroundView];
    [self.bigBackgroundView addSubview:self.stateBtn];
    [self.bigBackgroundView addSubview:self.titleLabel];
    [self.bigBackgroundView addSubview:self.ziLiaoControl];
    [self.ziLiaoControl addSubview:self.ziLiaoIcon];
    [self.ziLiaoControl addSubview:self.ziLiaoDownIcon];
    [self.ziLiaoControl addSubview:self.ziLiaoNameLabel];
    [self.bigBackgroundView addSubview:self.publishTimeLabel];
    [self.bigBackgroundView addSubview:self.publishPersonLabel];
  
    
    self.bigBackgroundView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(6, 12, 6, 12));
    self.bigBackgroundView.sd_cornerRadius = @4;
    
   
    self.stateBtn.sd_layout
    .topSpaceToView(self.bigBackgroundView, 16)
    .leftSpaceToView(self.bigBackgroundView, 12);
    [self.stateBtn setupAutoSizeWithHorizontalPadding:10 buttonHeight:20];
    
    self.titleLabel.sd_layout
    .centerYEqualToView(self.stateBtn)
    .leftSpaceToView(self.stateBtn, 10)
    .rightSpaceToView(self.bigBackgroundView, 12)
    .heightIs(21);
    
    self.ziLiaoControl.sd_layout
    .topSpaceToView(self.stateBtn, 18)
    .leftEqualToView(self.stateBtn)
    .rightEqualToView(self.titleLabel)
    .heightIs(27);
    self.ziLiaoControl.sd_cornerRadius=@2;
    
    self.ziLiaoIcon.sd_layout
    .centerYEqualToView(self.ziLiaoControl)
    .leftSpaceToView(self.ziLiaoControl, 8)
    .widthIs(14)
    .heightIs(17);
    
    self.ziLiaoDownIcon.sd_layout
    .centerYEqualToView(self.ziLiaoControl)
    .rightSpaceToView(self.ziLiaoControl, 10)
    .widthIs(19)
    .heightEqualToWidth();
    
    self.ziLiaoNameLabel.sd_layout
    .centerYEqualToView(self.ziLiaoControl)
    .leftSpaceToView(self.ziLiaoIcon, 8)
    .rightSpaceToView(self.ziLiaoDownIcon, 10)
    .heightIs(17);
    
    self.publishTimeLabel.sd_layout
    .topSpaceToView(self.ziLiaoControl, 16)
    .leftEqualToView(self.stateBtn)
    .heightIs(17);
    [self.publishTimeLabel setSingleLineAutoResizeWithMaxWidth:180];
    
    self.publishPersonLabel.sd_layout
    .centerYEqualToView(self.publishTimeLabel)
    .leftSpaceToView(self.publishTimeLabel, 16)
    .rightEqualToView(self.titleLabel)
    .heightIs(17);
}


#pragma mark - LazyLoad
-(UIView *)bigBackgroundView{
    if (!_bigBackgroundView) {
        _bigBackgroundView = [[UIView alloc] init];
        _bigBackgroundView.backgroundColor = [UIColor whiteColor];
        _bigBackgroundView.clipsToBounds = YES;
    }
    return _bigBackgroundView;
}

- (UIButton *)stateBtn{
    if (!_stateBtn) {
        _stateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _stateBtn.backgroundColor = COLOR_WITH_ALPHA(0xFEF6EA, 1);
        _stateBtn.titleLabel.font = HXBoldFont(12);
        [_stateBtn setTitleColor:COLOR_WITH_ALPHA(0xF29D1C, 1) forState:UIControlStateNormal];
        [_stateBtn setTitle:@"公开" forState:UIControlStateNormal];
        _stateBtn.userInteractionEnabled =NO;
    }
    return _stateBtn;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = HXBoldFont(15);
        _titleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _titleLabel.text = @"这里是资源标题";
    }
    return _titleLabel;
}

-(UIControl *)ziLiaoControl{
    if (!_ziLiaoControl) {
        _ziLiaoControl = [[UIControl alloc] init];
        _ziLiaoControl.clipsToBounds = YES;
        _ziLiaoControl.layer.borderWidth = 1;
        _ziLiaoControl.layer.borderColor = COLOR_WITH_ALPHA(0xE6EBFD, 1).CGColor;
    }
    return _ziLiaoControl;
}

- (UIImageView *)ziLiaoIcon{
    if (!_ziLiaoIcon) {
        _ziLiaoIcon = [[UIImageView alloc] init];
        _ziLiaoIcon.userInteractionEnabled = YES;
        _ziLiaoIcon.image = [UIImage imageNamed:@"word_icon"];
    }
    return _ziLiaoIcon;
}

- (UIImageView *)ziLiaoDownIcon{
    if (!_ziLiaoDownIcon) {
        _ziLiaoDownIcon = [[UIImageView alloc] init];
        _ziLiaoDownIcon.userInteractionEnabled = YES;
        _ziLiaoDownIcon.image = [UIImage imageNamed:@"ziLiaodown_icon"];
    }
    return _ziLiaoDownIcon;
}

- (UILabel *)ziLiaoNameLabel{
    if (!_ziLiaoNameLabel) {
        _ziLiaoNameLabel = [[UILabel alloc] init];
        _ziLiaoNameLabel.font = HXFont(12);
        _ziLiaoNameLabel.textColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        _ziLiaoNameLabel.text = @"资料名称资料名称.docx";
    }
    return _ziLiaoNameLabel;
}

- (UILabel *)publishTimeLabel{
    if (!_publishTimeLabel) {
        _publishTimeLabel = [[UILabel alloc] init];
        _publishTimeLabel.font = HXFont(12);
        _publishTimeLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _publishTimeLabel.text = @"发布时间：2021.11.02 17:08:46";
    }
    return _publishTimeLabel;
}

- (UILabel *)publishPersonLabel{
    if (!_publishPersonLabel) {
        _publishPersonLabel = [[UILabel alloc] init];
        _publishPersonLabel.textAlignment = NSTextAlignmentRight;
        _publishPersonLabel.font = HXFont(12);
        _publishPersonLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _publishPersonLabel.text = @"发布人：  张三";
    }
    return _publishPersonLabel;
}




@end



