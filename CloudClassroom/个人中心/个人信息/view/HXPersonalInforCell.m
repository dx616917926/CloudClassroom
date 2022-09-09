//
//  HXPersonalInforCell.m
//  CloudClassroom
//
//  Created by mac on 2022/9/8.
//

#import "HXPersonalInforCell.h"

@interface HXPersonalInforCell ()

@property(nonatomic,strong) UIView *bigBackgroundView;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UILabel *contentLabel;
@property(nonatomic,strong) UIView *lineView;

@end

@implementation HXPersonalInforCell

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


#pragma mark - Setter
-(void)setPersonalInforModel:(HXPersonalInforModel *)personalInforModel{
    
    _personalInforModel = personalInforModel;
    
    self.titleLabel.text = personalInforModel.title;
    self.contentLabel.text = personalInforModel.content;
}

#pragma mark - UI
-(void)createUI{
    
    [self.contentView addSubview:self.bigBackgroundView];
    [self.bigBackgroundView addSubview:self.titleLabel];
    [self.bigBackgroundView addSubview:self.contentLabel];
    [self.bigBackgroundView addSubview:self.lineView];
    
    self.bigBackgroundView.sd_layout
    .topEqualToView(self.contentView)
    .leftEqualToView(self.contentView)
    .rightEqualToView(self.contentView);
    
    self.titleLabel.sd_layout
    .topSpaceToView(self.bigBackgroundView, 18)
    .leftSpaceToView(self.bigBackgroundView, 20)
    .widthIs(120)
    .heightIs(21);
    
    self.contentLabel.sd_layout
    .topEqualToView(self.titleLabel)
    .rightSpaceToView(self.bigBackgroundView, 20)
    .leftSpaceToView(self.titleLabel, 20)
    .autoHeightRatio(0);
    
    self.lineView.sd_layout
    .topSpaceToView(@[self.titleLabel,self.contentLabel], 18)
    .leftSpaceToView(self.bigBackgroundView, 20)
    .rightSpaceToView(self.bigBackgroundView, 20)
    .heightIs(0.5);
    
    [self.bigBackgroundView setupAutoHeightWithBottomView:self.lineView bottomMargin:0];
    ///设置cell高度自适应
    [self setupAutoHeightWithBottomView:self.bigBackgroundView bottomMargin:0];
    
}


#pragma mark - LazyLoad
-(UIView *)bigBackgroundView{
    if (!_bigBackgroundView) {
        _bigBackgroundView = [[UIView alloc] init];
        _bigBackgroundView.clipsToBounds = YES;
        _bigBackgroundView.backgroundColor =UIColor.whiteColor;
    }
    return _bigBackgroundView;
}

-(UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.clipsToBounds = YES;
        _lineView.backgroundColor = COLOR_WITH_ALPHA(0xE6E6E6, 1);
    }
    return _lineView;
}



-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = HXFont(15);
        _titleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        
    }
    return _titleLabel;
}

-(UILabel *)contentLabel{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.textAlignment = NSTextAlignmentRight;
        _contentLabel.font = HXBoldFont(15);
        _contentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
       
    }
    return _contentLabel;
}

@end
