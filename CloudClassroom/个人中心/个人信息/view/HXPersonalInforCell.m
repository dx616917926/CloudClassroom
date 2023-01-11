//
//  HXPersonalInforCell.m
//  CloudClassroom
//
//  Created by mac on 2022/9/8.
//

#import "HXPersonalInforCell.h"

@interface HXPersonalInforCell ()<UITextViewDelegate>

@property(nonatomic,strong) UIView *bigBackgroundView;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UILabel *contentLabel;

@property(nonatomic,strong) UIImageView *editImageView;
@property(nonatomic,strong) UIImageView *arrowImageView;
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
    self.contentTextView.text = personalInforModel.content;
    
    if (personalInforModel.canedit) {
        self.contentTextView.sd_layout.heightIs(45);
        self.editImageView.hidden = self.contentTextView.hidden = NO;
        self.contentLabel.hidden = YES;
        self.contentTextView.placeholder =[NSString stringWithFormat: @"请填写%@",personalInforModel.title];
    }else{
        self.contentTextView.sd_layout.heightIs(0);
        self.editImageView.hidden = self.contentTextView.hidden = YES;
        self.contentLabel.hidden = NO;
    
    }
    
    if ([personalInforModel.title isEqualToString:@"民族"]||[personalInforModel.title isEqualToString:@"政治面貌"]) {
        self.arrowImageView.hidden = NO;
        self.contentLabel.sd_layout.rightSpaceToView(self.bigBackgroundView, 43);
    }else{
        self.arrowImageView.hidden = YES;
        self.contentLabel.sd_layout.rightSpaceToView(self.bigBackgroundView, 20);
    }
    
}

#pragma mark - <UITextViewDelegate>
- (void)textViewDidChange:(UITextView *)textView{
    self.personalInforModel.content = textView.text;
}

#pragma mark - UI
-(void)createUI{
    
    [self.contentView addSubview:self.bigBackgroundView];
    [self.bigBackgroundView addSubview:self.titleLabel];
    [self.bigBackgroundView addSubview:self.contentLabel];
    [self.bigBackgroundView addSubview:self.contentTextView];
    [self.bigBackgroundView addSubview:self.editImageView];
    [self.bigBackgroundView addSubview:self.arrowImageView];
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
    
    self.arrowImageView.sd_layout
    .centerYEqualToView(self.bigBackgroundView)
    .rightSpaceToView(self.bigBackgroundView, 20)
    .widthIs(15)
    .heightEqualToWidth();
    
    self.contentLabel.sd_layout
    .topEqualToView(self.titleLabel)
    .rightSpaceToView(self.arrowImageView, 20)
    .leftSpaceToView(self.titleLabel, 20)
    .autoHeightRatio(0);
    
    self.contentTextView.sd_layout
    .topSpaceToView(self.bigBackgroundView, 10)
    .rightSpaceToView(self.bigBackgroundView, 43)
    .leftSpaceToView(self.titleLabel, 20)
    .heightIs(45);
    
    self.editImageView.sd_layout
    .topSpaceToView(self.bigBackgroundView, 20)
    .rightSpaceToView(self.bigBackgroundView, 20)
    .widthIs(15)
    .heightEqualToWidth();
    
    self.lineView.sd_layout
    .topSpaceToView(@[self.titleLabel,self.contentLabel,self.contentTextView], 18)
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


-(IQTextView *)contentTextView{
    if (!_contentTextView) {
        _contentTextView = [[IQTextView alloc] init];
        _contentTextView.textAlignment = NSTextAlignmentRight;
        _contentTextView.backgroundColor = UIColor.clearColor;
        _contentTextView.font = HXBoldFont(15);
        _contentTextView.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _contentTextView.delegate = self;
        _contentTextView.placeholderTextColor = COLOR_WITH_ALPHA(0xBBBBBB, 1);
        
    }
    return _contentTextView;
}

-(UIImageView *)editImageView{
    if (!_editImageView) {
        _editImageView = [[UIImageView alloc] init];
        _editImageView.image = [UIImage imageNamed:@"edit_icon"];
    }
    return _editImageView;
}


-(UIImageView *)arrowImageView{
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] init];
        _arrowImageView.image = [UIImage imageNamed:@"gray_arrow"];
    }
    return _arrowImageView;
}



@end
