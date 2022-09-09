//
//  HXMyMessageCell.m
//  CloudClassroom
//
//  Created by mac on 2022/9/9.
//

#import "HXMyMessageCell.h"

@interface HXMyMessageCell ()

@property(nonatomic,strong) UIView *bigBackgroundView;
@property(nonatomic,strong) UIImageView *messageIcon;
@property(nonatomic,strong) UILabel *timeLabel;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UILabel *contentLabel;

@end

@implementation HXMyMessageCell

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

#pragma mark - UI
-(void)createUI{

    self.contentView.backgroundColor = VCBackgroundColor;
    self.backgroundColor =VCBackgroundColor;
    
    [self.contentView addSubview:self.bigBackgroundView];
    [self.bigBackgroundView addSubview:self.messageIcon];
    [self.bigBackgroundView addSubview:self.titleLabel];
    [self.bigBackgroundView addSubview:self.timeLabel];
    [self.bigBackgroundView addSubview:self.contentLabel];
   
    
    self.bigBackgroundView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(6, 12, 6, 12));
    self.bigBackgroundView.sd_cornerRadius = @8;
    
    self.messageIcon.sd_layout
    .centerYEqualToView(self.bigBackgroundView)
    .leftSpaceToView(self.bigBackgroundView, 12)
    .widthIs(29)
    .heightEqualToWidth();
    
    self.timeLabel.sd_layout
    .topSpaceToView(self.bigBackgroundView, 16)
    .rightSpaceToView(self.bigBackgroundView, 16)
    .heightIs(17);
    [self.timeLabel setSingleLineAutoResizeWithMaxWidth:120];
    
    
    self.titleLabel.sd_layout
    .centerYEqualToView(self.timeLabel)
    .leftSpaceToView(self.messageIcon, 12)
    .rightSpaceToView(self.timeLabel, 16)
    .heightIs(21);
    
    self.contentLabel.sd_layout
    .topSpaceToView(self.titleLabel, 8)
    .leftEqualToView(self.titleLabel)
    .rightEqualToView(self.timeLabel)
    .heightIs(18);
    
    
    
   
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

- (UIImageView *)messageIcon{
    if (!_messageIcon) {
        _messageIcon = [[UIImageView alloc] init];
        _messageIcon.image = [UIImage imageNamed:@"messasgeweidu_icon"];
    }
    return _messageIcon;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = HXBoldFont(15);
        _titleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _titleLabel.text = @"暑假学习情况";
    }
    return _titleLabel;
}

- (UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.font = HXFont(12);
        _timeLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _timeLabel.text = @"2022.07.28 09:37";
    }
    return _timeLabel;
}


- (UILabel *)contentLabel{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.font = HXFont(13);
        _contentLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _contentLabel.text = @"您的课程学习未完成50%，请您尽快完成学习...";
    }
    return _contentLabel;
}




@end


