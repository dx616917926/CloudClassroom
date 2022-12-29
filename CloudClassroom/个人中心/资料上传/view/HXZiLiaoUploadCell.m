//
//  HXZiLiaoUploadCell.m
//  CloudClassroom
//
//  Created by mac on 2022/9/27.
//

#import "HXZiLiaoUploadCell.h"

@interface HXZiLiaoUploadCell ()
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UILabel *tipLabel;
@property(nonatomic,strong) UIView *bigBackgroundView;
@property(nonatomic,strong) UIImageView *ziLiaoImageView;
@property(nonatomic,strong) UIButton *addBtn;

@end

@implementation HXZiLiaoUploadCell

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
-(void)setImgModel:(HXImgModel *)imgModel{
    _imgModel = imgModel;
    
    self.titleLabel.text = imgModel.imgTitle;
    
    [self.ziLiaoImageView sd_setImageWithURL:HXSafeURL(imgModel.imgUrl) placeholderImage:nil];
    
    self.addBtn.hidden = ![HXCommonUtil isNull:imgModel.imgUrl];
    
}
#pragma mark - Event
-(void)clickAddBtn:(UIButton *)sender{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(addPhotoForZiLiaoImageView:hiddenAddBtn:imgModel:)]) {
        [self.delegate addPhotoForZiLiaoImageView:self.ziLiaoImageView hiddenAddBtn:sender imgModel:self.imgModel];
    }
}

-(void)tapZiLiaoImageView:(UIGestureRecognizer *)tap{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(tapZiLiaoImageView:imgModel:)]) {
        [self.delegate tapZiLiaoImageView:self.ziLiaoImageView imgModel:self.imgModel];
    }
}

#pragma mark - UI
-(void)createUI{

    self.contentView.backgroundColor = VCBackgroundColor;
    self.backgroundColor =VCBackgroundColor;
    
    [self.contentView addSubview:self.bigBackgroundView];
    [self.bigBackgroundView addSubview:self.titleLabel];
    [self.bigBackgroundView addSubview:self.tipLabel];
    [self.bigBackgroundView addSubview:self.ziLiaoImageView];
    [self.ziLiaoImageView addSubview:self.addBtn];
  
    
    self.bigBackgroundView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(10, 0, 10, 0));
    
    self.titleLabel.sd_layout
    .topSpaceToView(self.bigBackgroundView, 10)
    .leftSpaceToView(self.bigBackgroundView, 20)
    .heightIs(21);
    [self.titleLabel setSingleLineAutoResizeWithMaxWidth:250];
    
    self.tipLabel.sd_layout
    .centerYEqualToView(self.titleLabel)
    .leftSpaceToView(self.titleLabel, 0)
    .rightSpaceToView(self.bigBackgroundView, 20)
    .heightIs(17);
   
    self.ziLiaoImageView.sd_layout
    .topSpaceToView(self.titleLabel, 12)
    .leftSpaceToView(self.bigBackgroundView, 20)
    .rightSpaceToView(self.bigBackgroundView, 20)
    .heightIs(167);
    self.ziLiaoImageView.sd_cornerRadius=@4;
    
    
    self.addBtn.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    
    self.addBtn.imageView.sd_layout
    .centerYEqualToView(self.addBtn)
    .centerXEqualToView(self.addBtn)
    .widthIs(41)
    .heightEqualToWidth();
    
    
}


#pragma mark - LazyLoad
-(UIView *)bigBackgroundView{
    if (!_bigBackgroundView) {
        _bigBackgroundView = [[UIView alloc] init];
        _bigBackgroundView.backgroundColor = VCBackgroundColor;
        _bigBackgroundView.clipsToBounds = YES;
    }
    return _bigBackgroundView;
}


- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = HXBoldFont(15);
        _titleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
    }
    return _titleLabel;
}

- (UILabel *)tipLabel{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = HXFont(12);
        _tipLabel.textColor = COLOR_WITH_ALPHA(0xEF5959, 1);
    }
    return _tipLabel;
}

- (UIImageView *)ziLiaoImageView{
    if (!_ziLiaoImageView) {
        _ziLiaoImageView = [[UIImageView alloc] init];
        _ziLiaoImageView.userInteractionEnabled = YES;
        _ziLiaoImageView.backgroundColor=UIColor.whiteColor;
        _ziLiaoImageView.clipsToBounds=YES;
        _ziLiaoImageView.contentMode = UIViewContentModeScaleAspectFill;
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapZiLiaoImageView:)];
        [_ziLiaoImageView addGestureRecognizer:tap];
    }
    return _ziLiaoImageView;
}

- (UIButton *)addBtn{
    if (!_addBtn) {
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addBtn setImage:[UIImage imageNamed:@"ziliaoaddphoto_icon"] forState:UIControlStateNormal];
        [_addBtn addTarget:self action:@selector(clickAddBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addBtn;
}


@end



