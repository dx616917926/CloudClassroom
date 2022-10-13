//
//  HXZaiXianXueQiCell.m
//  CloudClassroom
//
//  Created by mac on 2022/9/6.
//

#import "HXZaiXianXueQiCell.h"

@interface HXZaiXianXueQiCell ()

@property(nonatomic,strong) UIView *bigBackGroundView;
@property(nonatomic,strong) UILabel *titleLabel;


@end

@implementation HXZaiXianXueQiCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor clearColor];
        [self createUI];
    }
    return self;
}

#pragma mark - Setter
-(void)setScoreBatchModel:(HXScoreBatchModel *)scoreBatchModel{
    
    _scoreBatchModel = scoreBatchModel;
    
    self.titleLabel.text = scoreBatchModel.batchName;
    
    if(scoreBatchModel.isSelected){
        self.bigBackGroundView.backgroundColor = COLOR_WITH_ALPHA(0xDDE4FF, 1);
        self.titleLabel.textColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        self.titleLabel.font = HXBoldFont(12);
    }else{
        self.bigBackGroundView.backgroundColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
        self.titleLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        self.titleLabel.font = HXFont(12);
    }
}

#pragma mark - UI布局
-(void)createUI{
    [self addSubview:self.bigBackGroundView];
    [self addSubview:self.titleLabel];
    
    self.bigBackGroundView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    self.bigBackGroundView.sd_cornerRadius = @5;
    [self.bigBackGroundView updateLayout];
    self.titleLabel.sd_layout.spaceToSuperView(UIEdgeInsetsMake(5, 5, 5, 5));
}


-(UIView *)bigBackGroundView{
    if (!_bigBackGroundView) {
        _bigBackGroundView = [[UIView alloc] init];
        _bigBackGroundView.backgroundColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
    }
    return _bigBackGroundView;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = HXFont(12);
        _titleLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        
    }
    return _titleLabel;
}

@end
