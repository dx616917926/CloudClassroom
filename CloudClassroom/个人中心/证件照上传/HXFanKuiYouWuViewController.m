//
//  HXFanKuiYouWuViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/13.
//

#import "HXFanKuiYouWuViewController.h"
#import "IQTextView.h"
@interface HXFanKuiYouWuViewController ()<UITextViewDelegate>

@property(nonatomic,strong) UIView *topContainerView;
@property(nonatomic,strong) UIButton *submitBtn;
@property(nonatomic,strong) IQTextView *textView;
@property(nonatomic,strong) UILabel *ziShuLabel;

@end

@implementation HXFanKuiYouWuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //UI
    [self createUI];
}

#pragma mark -提交反馈
-(void)submit:(UIButton *)sender{
    sender.userInteractionEnabled =NO;
    NSString *student_id = [HXPublicParamTool sharedInstance].student_id;
    NSDictionary *dic =@{
        @"student_id":HXSafeString(student_id),
        @"comstatus":@(1),
        @"comments":HXSafeString(self.textView.text)
    };
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_ComfirmPhoto needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        sender.userInteractionEnabled = YES;
        BOOL success = [dictionary boolValueForKey:@"success"];
        NSString *message =[dictionary stringValueForKey:@"message"];
        if (success) {
            [self.view showSuccessWithMessage:message];
            [self.navigationController popViewControllerAnimated:YES];
            if (self.fanKuiYouWuCallBack) {
                self.fanKuiYouWuCallBack();
            }
        }else{
            [self.view showTostWithMessage:message];;
        }
    } failure:^(NSError * _Nonnull error) {
        sender.userInteractionEnabled = YES;
    }];
    
}

#pragma mark - <UITextViewDelegate>
- (void)textViewDidChange:(UITextView *)textView{
    NSString *toBeString = textView.text;
    NSString *lang = [[UIApplication sharedApplication] textInputMode].primaryLanguage;
    //简体中文输入，包括简体拼音，健体五笔，简体手写
    if([lang isEqualToString:@"zh-Hans"] || [lang isEqualToString:@"zh-Hant"]){
        UITextRange *selectedRange = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > 100) {
                textView.text = [toBeString substringToIndex:100];
            }
        }else{ // 有高亮选择的字符串，则暂不对文字进行统计和限制
            
        }
    }else{//中文输入法以外
        if (toBeString.length > 100) {
            textView.text = [toBeString substringToIndex:100];
        }
    }
    
    self.ziShuLabel.text = [NSString stringWithFormat:@"%lu/100",(unsigned long)textView.text.length];
}

#pragma mark - UI
-(void)createUI{
    self.sc_navigationBar.title = @"反馈有误";
    
    [self.view addSubview:self.topContainerView];
    [self.view addSubview:self.submitBtn];
    
    [self.topContainerView addSubview:self.textView];
    [self.topContainerView addSubview:self.ziShuLabel];
    
    self.topContainerView.sd_layout
        .topSpaceToView(self.view, kNavigationBarHeight+16)
        .leftSpaceToView(self.view,12)
        .rightSpaceToView(self.view,12)
        .heightIs(260);
    self.topContainerView.sd_cornerRadius = @10;
    
    self.submitBtn.sd_layout
        .topSpaceToView(self.topContainerView, 20)
        .leftSpaceToView(self.view,12)
        .rightSpaceToView(self.view,12)
        .heightIs(36);
    self.submitBtn.sd_cornerRadiusFromHeightRatio=@0.5;
    
    self.ziShuLabel.sd_layout
        .bottomSpaceToView(self.topContainerView, 10)
        .rightSpaceToView(self.topContainerView, 16)
        .widthIs(150)
        .heightIs(15);
    
    self.textView.sd_layout
        .topSpaceToView(self.topContainerView, 16)
        .leftSpaceToView(self.topContainerView,16)
        .rightSpaceToView(self.topContainerView,16)
        .bottomSpaceToView(self.topContainerView, 16);
    
    
}


-(UIView *)topContainerView{
    if (!_topContainerView) {
        _topContainerView = [[UIView alloc] init];
        _topContainerView.backgroundColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
    }
    return _topContainerView;
}

-(IQTextView *)textView{
    if (!_textView) {
        _textView = [[IQTextView alloc] init];
        _textView.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _textView.font = HXFont(14);
        _textView.delegate = self;
        _textView.placeholder = @"请填写有误原因";
        _textView.placeholderTextColor = COLOR_WITH_ALPHA(0x999999, 1);
    }
    return _textView;
}

-(UILabel *)ziShuLabel{
    if (!_ziShuLabel) {
        _ziShuLabel = [[UILabel alloc] init];
        _ziShuLabel.textAlignment = NSTextAlignmentRight;
        _ziShuLabel.font = HXBoldFont(11);
        _ziShuLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _ziShuLabel.text = @"0/100";
    }
    return _ziShuLabel;
}


-(UIButton *)submitBtn{
    if (!_submitBtn) {
        _submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _submitBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _submitBtn.titleLabel.font = HXBoldFont(14);
        [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_submitBtn setTitle:@"提交反馈" forState:UIControlStateNormal];
        _submitBtn.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        [_submitBtn addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitBtn;
}

@end
