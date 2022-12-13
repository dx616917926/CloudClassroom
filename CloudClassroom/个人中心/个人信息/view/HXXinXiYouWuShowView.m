//
//  HXXinXiYouWuShowView.m
//  CloudClassroom
//
//  Created by mac on 2022/9/27.
//

#import "HXXinXiYouWuShowView.h"
#import "IQTextView.h"

@interface HXXinXiYouWuShowView ()<UITextViewDelegate>

@property(nonatomic,strong) UIView *maskView;
@property(nonatomic,strong) UIView *bigBackGroundView;
@property(nonatomic,strong) UIButton *tipButton;
@property(nonatomic,strong) UIButton *closeButton;
@property(nonatomic,strong) UIView *grayView;
@property(nonatomic,strong) IQTextView *textView;
@property(nonatomic,strong) UIButton *cancelButton;
@property(nonatomic,strong) UIButton *submitButton;

@end

@implementation HXXinXiYouWuShowView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//- (instancetype)showToView:(UIView *)view upView:(UIView *)upView  dataSource:(NSArray *)dataSource
//{
//
//}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self creatUI];
    }
    return self;
}


-(void)show{
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.maskView];
}

-(void)dismiss{
    [self.maskView removeFromSuperview];
     self.maskView = nil;
}

-(void)submit{
    [self dismiss];
    if (self.confirmErrorInfoCallBack) {
        self.confirmErrorInfoCallBack(self.textView.text);
    }
}

#pragma mark -UI
-(void)creatUI{
    [self.maskView addSubview:self];
    [self addSubview:self.bigBackGroundView];
    [self.bigBackGroundView addSubview:self.closeButton];
    [self.bigBackGroundView addSubview:self.tipButton];
    [self.bigBackGroundView addSubview:self.grayView];
    [self.grayView addSubview:self.textView];
    [self.bigBackGroundView addSubview:self.cancelButton];
    [self.bigBackGroundView addSubview:self.submitButton];
    
    self.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    
    self.bigBackGroundView.sd_layout
    .centerXEqualToView(self)
    .centerYEqualToView(self)
    .widthIs(_kpw(275))
    .heightIs(300);
    self.bigBackGroundView.sd_cornerRadius = @5;
    
    self.tipButton.sd_layout
    .topSpaceToView(self.bigBackGroundView, 21)
    .centerXEqualToView(self.bigBackGroundView)
    .heightIs(21);
    
    self.tipButton.imageView.sd_layout
    .centerYEqualToView(self.tipButton)
    .leftEqualToView(self.tipButton)
    .widthIs(21)
    .heightEqualToWidth();
    
    self.tipButton.titleLabel.sd_layout
    .centerYEqualToView(self.tipButton)
    .leftSpaceToView(self.tipButton.imageView, 5)
    .heightIs(15);
    [self.tipButton.titleLabel setSingleLineAutoResizeWithMaxWidth:150];
    
    [self.tipButton setupAutoWidthWithRightView:self.tipButton.titleLabel rightMargin:0];
   
   
    self.closeButton.sd_layout
    .centerYEqualToView(self.tipButton)
    .rightEqualToView(self.bigBackGroundView)
    .widthIs(48)
    .heightEqualToWidth();
    
    self.closeButton.imageView.sd_layout
    .centerXEqualToView(self.closeButton)
    .centerYEqualToView(self.closeButton)
    .widthIs(25)
    .heightEqualToWidth();
    
    self.grayView.sd_layout
    .topSpaceToView(self.tipButton, 10)
    .leftSpaceToView(self.bigBackGroundView, 20)
    .rightSpaceToView(self.bigBackGroundView, 20)
    .heightIs(175);
    
    self.textView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(12, 12, 12, 12));
    
    self.cancelButton.sd_layout
    .topSpaceToView(self.grayView, 18)
    .leftSpaceToView(self.bigBackGroundView, 30)
    .widthIs(100)
    .heightIs(36);
    self.cancelButton.sd_cornerRadiusFromHeightRatio=@0.5;
    
    self.submitButton.sd_layout
    .centerYEqualToView(self.cancelButton)
    .rightSpaceToView(self.bigBackGroundView, 30)
    .widthRatioToView(self.cancelButton, 1)
    .heightRatioToView(self.cancelButton, 1);
    self.submitButton.sd_cornerRadiusFromHeightRatio=@0.5;

}



#pragma mark -LazyLoad
-(UIView *)maskView{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _maskView.backgroundColor = COLOR_WITH_ALPHA(0x000000, 0.5);
    }
    return _maskView;
}



-(UIView *)bigBackGroundView{
    if (!_bigBackGroundView) {
        _bigBackGroundView = [[UIView alloc] init];
        _bigBackGroundView.backgroundColor = UIColor.whiteColor;
    }
    return _bigBackGroundView;
}

-(UIButton *)tipButton{
    if (!_tipButton) {
        _tipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _tipButton.titleLabel.font = HXBoldFont(15);
        [_tipButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_tipButton setImage:[UIImage imageNamed:@"gantan_icon"] forState:UIControlStateNormal];
        [_tipButton setTitle:@"个人信息有误" forState:UIControlStateNormal];
    }
    return _tipButton;
}

-(UIButton *)closeButton{
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"close_icon"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

-(UIView *)grayView{
    if (!_grayView) {
        _grayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _grayView.backgroundColor = COLOR_WITH_ALPHA(0x000000, 0.02);
    }
    return _grayView;
}

-(IQTextView *)textView{
    if (!_textView) {
        _textView = [[IQTextView alloc] init];
        _textView.backgroundColor = UIColor.clearColor;
        _textView.font = HXFont(13);
        _textView.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _textView.delegate = self;
        _textView.placeholder = @"请您填写需要调整的信息";
        _textView.placeholderTextColor = COLOR_WITH_ALPHA(0x999999, 1);
    }
    return _textView;
}


-(UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.titleLabel.font = HXBoldFont(14);
        _cancelButton.backgroundColor= UIColor.whiteColor;
        _cancelButton.layer.borderWidth =1;
        _cancelButton.layer.borderColor =COLOR_WITH_ALPHA(0x2E5BFD, 1).CGColor;
        [_cancelButton setTitleColor:COLOR_WITH_ALPHA(0x2E5BFD, 1) forState:UIControlStateNormal];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

-(UIButton *)submitButton{
    if (!_submitButton) {
        _submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _submitButton.titleLabel.font = HXBoldFont(14);
        _submitButton.backgroundColor= COLOR_WITH_ALPHA(0x2E5BFD, 1);
        [_submitButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_submitButton setTitle:@"提交" forState:UIControlStateNormal];
        [_submitButton addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitButton;
}



@end
