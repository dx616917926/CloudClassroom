//
//  HXClassRankCell.m
//  CloudClassroom
//
//  Created by mac on 2022/9/5.
//

#import "HXClassRankCell.h"
#import "SDWebImage.h"

@interface HXClassRankCell ()

@property(nonatomic,strong) UIView *bigBackgroundView;
@property(nonatomic,strong) UIImageView *jiangPaiImageView;
@property(nonatomic,strong) UILabel *rankLabel;
@property(nonatomic,strong) UIImageView *headImageView;
@property(nonatomic,strong) UILabel *nameLabel;
@property(nonatomic,strong) UILabel *deFenLabel;

@end

@implementation HXClassRankCell

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
-(void)setCourseScoreRankModel:(HXCourseScoreRankModel *)courseScoreRankModel{
    _courseScoreRankModel = courseScoreRankModel;
    
    [self.headImageView sd_setImageWithURL:HXSafeURL(courseScoreRankModel.imgUrl) placeholderImage:[UIImage imageNamed:@"defaulthead_icon"] options:SDWebImageRefreshCached];

    self.nameLabel.text = courseScoreRankModel.name;
    self.deFenLabel.text = [NSString stringWithFormat:@"%.0f分",courseScoreRankModel.finalScore];
    
    if (courseScoreRankModel.rownum<=3) {
        self.rankLabel.hidden = YES;
        self.jiangPaiImageView.hidden = NO;
        if (courseScoreRankModel.rownum==1) {
            self.jiangPaiImageView.image = [UIImage imageNamed:@"jinpai_icon"];
        }else if (courseScoreRankModel.rownum==2) {
            self.jiangPaiImageView.image = [UIImage imageNamed:@"yinpai_icon"];
        }else{
            self.jiangPaiImageView.image = [UIImage imageNamed:@"tongpai_icon"];
        }
    }else{
        self.rankLabel.hidden = NO;
        self.jiangPaiImageView.hidden = YES;
        self.rankLabel.text =[NSString stringWithFormat:@"%ld",(long)courseScoreRankModel.rownum];
    }
    
}


#pragma mark - UI
-(void)createUI{
    
    [self.contentView addSubview:self.bigBackgroundView];
    [self.bigBackgroundView addSubview:self.jiangPaiImageView];
    [self.bigBackgroundView addSubview:self.rankLabel];
    [self.bigBackgroundView addSubview:self.headImageView];
    [self.bigBackgroundView addSubview:self.nameLabel];
    [self.bigBackgroundView addSubview:self.deFenLabel];
    
    self.bigBackgroundView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    
    self.jiangPaiImageView.sd_layout
    .centerYEqualToView(self.bigBackgroundView)
    .leftSpaceToView(self.bigBackgroundView, 23)
    .widthIs(27)
    .heightIs(35);
    
    self.rankLabel.sd_layout
    .centerYEqualToView(self.jiangPaiImageView)
    .centerXEqualToView(self.jiangPaiImageView)
    .widthIs(27)
    .heightIs(35);
    
    self.headImageView.sd_layout
    .centerYEqualToView(self.bigBackgroundView)
    .leftSpaceToView(self.jiangPaiImageView, 41)
    .widthIs(31)
    .heightEqualToWidth();
    self.headImageView.sd_cornerRadiusFromHeightRatio = @0.5;
    
    self.deFenLabel.sd_layout
    .centerYEqualToView(self.bigBackgroundView)
    .rightSpaceToView(self.bigBackgroundView, 10)
    .widthIs(60)
    .heightIs(21);
    
    self.nameLabel.sd_layout
    .centerYEqualToView(self.bigBackgroundView)
    .leftSpaceToView(self.headImageView, 22)
    .rightSpaceToView(self.deFenLabel, 22)
    .heightIs(21);
    
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

-(UIImageView *)jiangPaiImageView{
    if (!_jiangPaiImageView) {
        _jiangPaiImageView = [[UIImageView alloc] init];
        _jiangPaiImageView.userInteractionEnabled = YES;
        _jiangPaiImageView.image = [UIImage imageNamed:@"tongpai_icon"];
    }
    return _jiangPaiImageView;
}



-(UILabel *)rankLabel{
    if (!_rankLabel) {
        _rankLabel = [[UILabel alloc] init];
        _rankLabel.textAlignment = NSTextAlignmentCenter;
        _rankLabel.font = HXFont(15);
        _rankLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _rankLabel.text = @"3";
    }
    return _rankLabel;
}


-(UIImageView *)headImageView{
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] init];
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
        _headImageView.clipsToBounds = YES;
        _headImageView.userInteractionEnabled = YES;
        _headImageView.image = [UIImage imageNamed:@"defaulthead_icon"];
    }
    return _headImageView;
}


-(UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.font = HXFont(15);
        _nameLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _nameLabel.text = @"肖益晓";
    }
    return _nameLabel;
}


-(UILabel *)deFenLabel{
    if (!_deFenLabel) {
        _deFenLabel = [[UILabel alloc] init];
        _deFenLabel.textAlignment = NSTextAlignmentLeft;
        _deFenLabel.font = HXFont(15);
        _deFenLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _deFenLabel.text = @"86分";
    }
    return _deFenLabel;
}

@end
