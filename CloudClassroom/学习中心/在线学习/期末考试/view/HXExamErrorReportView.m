//
//  HXExamErrorReportView.m
//  zikaoks
//
//  Created by Mac on 2021/12/10.
//  Copyright © 2021 华夏大地教育网. All rights reserved.
//

#import "HXExamErrorReportView.h"
#import "IQTextView.h"

const int HXExamErrorReportViewTag = 21237;

@interface HXExamErrorReportView ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *errorTypeMsg;
    IQTextView *textView;
    CGFloat textViewHeight;
}
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UIView *topView;
@property(nonatomic, strong) UILabel *titleLable;
@property(nonatomic, strong) UIViewController *parentViewController;
@property(nonatomic, strong) UIButton *cancelButton;
@property (nonatomic,strong) UIButton *sureBtn;

@end

@implementation HXExamErrorReportView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width , [UIScreen mainScreen].bounds.size.height)];
    if (self){
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.tag = HXExamErrorReportViewTag;
        
        errorTypeMsg = @[@"题目不属于当前考试科目",@"题干错误或内容缺失",@"答案错误",@"选项内容缺失",@"其他"];
        
        [self initWithView];
        
        //退出登录的通知
        [HXNotificationCenter addObserver:self selector:@selector(loginOut) name:SHOWLOGIN object:nil];
        
        //使用通知监听文字改变
        [HXNotificationCenter addObserver:self selector:@selector(textViewDidChange:) name:UITextViewTextDidChangeNotification object:nil];
        
        //注册键盘通知
//        [HXNotificationCenter addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardWillHideNotification object:nil];
//        [HXNotificationCenter addObserver:self selector:@selector(keyboardShow:)  name:UIKeyboardWillShowNotification object:nil];
    }
    return self;
}

- (void)dealloc{
    [HXNotificationCenter removeObserver:self];
}

#pragma mark - Notification
//退出登录的通知
- (void)loginOut {
    [self cancleClick];
}

//UITextViewTextDidChangeNotification  监听输入文字的个数
- (void)textViewDidChange:(NSNotification *)notification{
    
    if (textView.text.length > 100) {
        textView.text = [textView.text substringToIndex:100];
    }
}

- (void)keyboardShow:(NSNotification *)notification {
    CGSize size = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.tableView.height = kScreenHeight - kNavigationBarHeight - size.height - 20;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)keyboardHidden:(NSNotification *)notification {
    self.tableView.height = kScreenHeight - kNavigationBarHeight;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}




#pragma mark - 弹出动画
- (void)showInViewController:(UIViewController *)viewController
{
    self.parentViewController = viewController;
    
    [self showInView:viewController.tabBarController?viewController.tabBarController.view:viewController.view];
}

//添加弹出移除的动画效果
- (void)showInView:(UIView *)view
{
    //
    self.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight);
    [view addSubview:self];
    
    // 浮现
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    } completion:^(BOOL finished) {
        
    }];
}


#pragma mark - 关闭弹框
- (void)cancleClick{
    
    self.parentViewController = nil;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


#pragma mark - 点击键盘上的完成按钮
- (void)doneButtonTapped:(UIBarButtonItem *)item{
    [textView resignFirstResponder];
}

#pragma mark - 提交
- (void)commitButtonAction:(UIButton *)button {
    
    if (!self.examBasePath || !self.questionId || !self.userExamId) {
        [self showErrorWithMessage:@"参数错误，请重试！"];
        return;
    }
    
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    
    if (!indexPath) {
        [self showTostWithMessage:@"请选择反馈原因"];
        return;
    }
    
    [self showLoading];
    
    NSString *type = @"";
    if (indexPath) {
        type = [errorTypeMsg objectAtIndex:indexPath.row];
    }
    
    NSString *basePath = self.examBasePath;
    
    NSRange range = [self.examBasePath rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
        basePath = [self.examBasePath substringToIndex:range.location];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@",basePath,HXEXAM_START_JSON];
    NSDictionary *dic = @{@"userExamId":self.userExamId,@"questionId":self.questionId,@"remark":[NSString stringWithFormat:@"%@:%@",type,textView.text]};
    WeakSelf(weakSelf);
    [HXExamSessionManager postDataWithNSString:url needMd5:NO pingKey:nil withDictionary:dic success:^(NSDictionary * _Nullable dictionary) {
        //
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            [self showSuccessWithMessage:@"提交成功！"];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf cancleClick];
            });
        }else{
            NSString *errMsg = [dictionary stringValueForKey:@"message" WithHolder:@"获取数据失败,请重试!"];
            [self showErrorWithMessage:errMsg];
        }
    } failure:^(NSError * _Nullable error) {
        //
        [self showErrorWithMessage:@"请求失败，请重试！"];
    }];
    
}

#pragma mark - <UITableViewDelegate,UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return errorTypeMsg.count;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 44;
    }
    return textViewHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 46;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 10, 10, 26)];
    line.backgroundColor = [UIColor colorWithRed:0.95 green:0.81 blue:0.33 alpha:1.00];
    line.layer.cornerRadius = 5;
    [view addSubview:line];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(line.right+8, 8, 100, 30)];
    if (section == 0) {
        label.text = @"反馈原因";
    }else{
        label.text = @"问题描述";
    }
    [view addSubview:label];
    
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    NSInteger row = indexPath.row;
    
    if (indexPath.section == 0) {
        cell.textLabel.text = [errorTypeMsg objectAtIndex:row];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 0.5);
    }else{
        [cell.contentView addSubview:textView];
    }
    
    return cell;
}

- (nullable NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return indexPath;
    }else{
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}


#pragma mark - UI
- (void)initWithView{
    CGFloat width = kScreenWidth;
    CGFloat height = kScreenHeight;
    
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, kNavigationBarHeight)];
    self.topView.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
    [self addSubview:self.topView];
    
    self.titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, width, 44)];
    self.titleLable.backgroundColor = [UIColor clearColor];
    self.titleLable.text =@"错题反馈";
    self.titleLable.textColor = [UIColor whiteColor];
    self.titleLable.textAlignment = NSTextAlignmentCenter;
    self.titleLable.font = HXBoldFont(17);
    [self.topView addSubview:self.titleLable];
    
    textViewHeight = kScreenHeight - errorTypeMsg.count*44 - 180 - kScreenBottomMargin - kNavigationBarHeight;
    textViewHeight = MIN(250, textViewHeight);
    
    //文本框
    textView = [[IQTextView alloc] initWithFrame:CGRectMake(16, 0, kScreenWidth-32, textViewHeight)];
    textView.font = [UIFont systemFontOfSize:17];
    textView.placeholder = @"请输入问题描述（最多100字）";
    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"完成"
                                                                      style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTapped:)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [toolBar setItems:[NSArray arrayWithObjects:flex, barButtonDone, nil]];
    textView.inputAccessoryView = toolBar;
    
    //
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, width, height-kNavigationBarHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self addSubview:self.tableView];
    
    //返回按钮
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelButton setImage:[[UIImage imageNamed:@"navi_whiteback"] imageForCurrentTheme] forState:UIControlStateNormal];
    self.cancelButton.frame = CGRectMake(0, self.topView.height-44, 50, 44);
    [self.cancelButton addTarget:self action:@selector(cancleClick) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.cancelButton];
    
    //提交按钮
    self.sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(width/2 - 104, height - 60 - kScreenBottomMargin, 188, 40)];
    self.sureBtn.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
    [self.sureBtn setTintColor:[UIColor whiteColor]];
    [self.sureBtn setTitle:@"提交" forState:UIControlStateNormal];
    [self.sureBtn addTarget:self action:@selector(commitButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.sureBtn.userInteractionEnabled = YES;
    self.sureBtn.layer.cornerRadius = 8.f;
    
    [self addSubview:self.sureBtn];
}


@end
