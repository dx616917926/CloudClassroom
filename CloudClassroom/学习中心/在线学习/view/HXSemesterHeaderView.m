//
//  HXSemesterHeaderView.m
//  CloudClassroom
//
//  Created by mac on 2022/10/25.
//

#import "HXSemesterHeaderView.h"

@interface HXSemesterHeaderView ()
@property(nonatomic,strong) UIControl *bigBackgroundControl;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UIImageView *foldImageView;

@end

@implementation HXSemesterHeaderView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */


-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
    }
    return self;
}


-(void)setSemesterModel:(HXSemesterModel *)semesterModel{
    _semesterModel = semesterModel;
    _titleLabel.text = HXSafeString(semesterModel.termName);
    self.foldImageView.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:0.5 animations:^{
        if (self.semesterModel.isExpand) {
            self.foldImageView.transform = CGAffineTransformMakeRotation(M_PI_2);
        }else{
            self.foldImageView.transform = CGAffineTransformIdentity;
        }
    } completion:^(BOOL finished) {
        
    }];
}


#pragma mark - Event
-(void)expend{
    self.semesterModel.isExpand = !self.semesterModel.isExpand;
    
    self.foldImageView.transform = CGAffineTransformIdentity;
    if (self.semesterModel.isExpand) {
        self.foldImageView.transform = CGAffineTransformRotate(self.foldImageView.transform,M_PI_2);
    }else{
        self.foldImageView.transform = CGAffineTransformRotate(self.foldImageView.transform,M_PI_2);
    }
    [UIView animateWithDuration:0.25 animations:^{
        
    } completion:^(BOOL finished) {
        
    }];
    

    if (self.expandCallBack) {
        self.expandCallBack();
    }
}


#pragma mark - UI
-(void)createUI{
    self.contentView.backgroundColor = COLOR_WITH_ALPHA(0xECF0FB, 1);
    self.backgroundColor = COLOR_WITH_ALPHA(0xECF0FB, 1);
    
    [self.contentView addSubview:self.bigBackgroundControl];
    [self.bigBackgroundControl addSubview:self.titleLabel];
    [self.bigBackgroundControl addSubview:self.foldImageView];
    
    
    self.bigBackgroundControl.sd_layout.spaceToSuperView(UIEdgeInsetsMake(6, 12, 6, 12));
    self.bigBackgroundControl.layer.cornerRadius = 5;
    
   
    self.foldImageView.sd_layout
    .centerYEqualToView(self.bigBackgroundControl)
    .rightSpaceToView(self.bigBackgroundControl,16)
    .widthIs(15)
    .heightEqualToWidth();
    
    
    self.titleLabel.sd_layout
    .centerYEqualToView(self.bigBackgroundControl)
    .leftSpaceToView(self.bigBackgroundControl, 16)
    .rightSpaceToView(self.foldImageView,16)
    .heightIs(20);
    
}

#pragma mark - lazyload

-(UIControl *)bigBackgroundControl{
    if (!_bigBackgroundControl) {
        _bigBackgroundControl = [[UIControl alloc] init];
        _bigBackgroundControl.backgroundColor = [UIColor whiteColor];
        [_bigBackgroundControl addTarget:self action:@selector(expend) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bigBackgroundControl;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _titleLabel.font = HXFont(14);
        
    }
    return _titleLabel;;
}



-(UIImageView *)foldImageView{
    if (!_foldImageView) {
        _foldImageView = [[UIImageView alloc] init];
        _foldImageView.image = [UIImage imageNamed:@"set_arrow"];
        _foldImageView.layer.anchorPoint = CGPointMake(0.5,0.5);
    }
    return _foldImageView;
}

@end

