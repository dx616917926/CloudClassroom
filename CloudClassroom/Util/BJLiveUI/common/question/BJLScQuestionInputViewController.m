//
//  BJLScQuestionInputViewController.m
//  BJLiveUI
//
//  Created by xijia dai on 2019/9/25.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import "BJLScQuestionInputViewController.h"
#import "BJLAppearance.h"

@interface BJLScQuestionInputViewController () <UITextViewDelegate>

@property (nonatomic, weak) BJLRoom *room;
@property (nonatomic, nullable) BJLQuestion *question;
@property (nonatomic) UIView *overlayView;
@property (nonatomic) UILabel *questionLabel;
@property (nonatomic) UIView *containerView;
@property (nonatomic) UITextView *textView;
@property (nonatomic) UILabel *wordCountLabel;
@property (nonatomic) UIButton *cancelButton;
@property (nonatomic) UIButton *saveButton;
@property (nonatomic) UIButton *sendQuestionButton;

@end

@implementation BJLScQuestionInputViewController

- (instancetype)initWithRoom:(BJLRoom *)room {
    if (self = [super init]) {
        self.room = room;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self makeSubviewsAndConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateConstraints];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardChangeFrameWithNotification:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardChangeFrameWithNotification:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.question = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidChangeFrameNotification
                                                  object:nil];
}

- (void)makeSubviewsAndConstraints {
    self.view.backgroundColor = BJLTheme.windowBackgroundColor;
    self.containerView = ({
        UIView *view = [UIView new];
        view.accessibilityIdentifier = BJLKeypath(self, containerView);
        view.backgroundColor = BJLTheme.windowBackgroundColor;
        view;
    });
    [self.view addSubview:self.containerView];
    [self.containerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.right.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view);
        make.bottom.equalTo(self.view).offset(0.0);
        make.height.equalTo(@120.0);
    }];

    self.questionLabel = ({
        UILabel *label = [UILabel new];
        label.backgroundColor = BJLTheme.windowBackgroundColor;
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:12.0];
        label.accessibilityIdentifier = BJLKeypath(self, questionLabel);
        label.textAlignment = NSTextAlignmentLeft;
        label;
    });
    [self.view addSubview:self.questionLabel];
    [self.questionLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.containerView.bjl_top);
        make.top.equalTo(self.view);
    }];

    UIView *questionLayer = ({
        UIView *layer = [BJLHitTestView new];
        layer.accessibilityIdentifier = @"questionLayer";
        layer.backgroundColor = BJLTheme.separateLineColor;
        layer;
    });
    [self.view addSubview:questionLayer];
    [questionLayer bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.right.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.containerView.bjl_top);
    }];

    self.textView = ({
        UITextView *textView = [UITextView new];
        textView.delegate = self;
        textView.font = [UIFont systemFontOfSize:14.0];
        textView.textColor = BJLTheme.viewTextColor;
        textView.backgroundColor = BJLTheme.windowBackgroundColor;
        textView.returnKeyType = UIReturnKeySend;
        textView;
    });
    [self.containerView addSubview:self.textView];
    [self.textView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.containerView.bjl_safeAreaLayoutGuide).insets(UIEdgeInsetsMake(0.0, 0.0, 32.0, 0.0));
    }];

    self.sendQuestionButton = [self makeButtonWithTitle:nil image:[UIImage bjl_imageNamed:@"bjl_sc_question_send"] backgroundColor:BJLTheme.brandColor action:@selector(sendQuestion)];
    self.saveButton = [self makeButtonWithTitle:BJLLocalizedString(@"保存") image:nil backgroundColor:BJLTheme.subButtonBackgroundColor action:@selector(saveReply)];
    self.cancelButton = [self makeButtonWithTitle:BJLLocalizedString(@"取消") image:nil backgroundColor:BJLTheme.subButtonBackgroundColor action:@selector(cancelReply)];

    self.wordCountLabel = ({
        UILabel *label = [UILabel new];
        label.accessibilityIdentifier = BJLKeypath(self, wordCountLabel);
        label.backgroundColor = [UIColor clearColor];
        label.textColor = BJLTheme.viewSubTextColor;
        label.textAlignment = NSTextAlignmentRight;
        label.font = [UIFont systemFontOfSize:14.0];
        label;
    });
    [self.containerView addSubview:self.wordCountLabel];
}

- (void)updateConstraints {
    NSArray<UIView *> *array = @[self.sendQuestionButton, self.saveButton, self.cancelButton];
    for (UIView *view in array) {
        if (view && [view respondsToSelector:@selector(removeFromSuperview)]) {
            [view removeFromSuperview];
        }
    }

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 8.0;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    NSTextAttachment *textAttachment = [NSTextAttachment new];
    textAttachment.image = [UIImage bjl_imageNamed:@"bjl_sc_pencil"];
    textAttachment.bounds = CGRectMake(0, -2.0, 16.0, 16.0);

    NSMutableAttributedString *placeholder = [NSMutableAttributedString new];
    [placeholder appendAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
    [placeholder appendAttributedString:[[NSAttributedString alloc] initWithString:self.question ? BJLLocalizedString(@"请输入回复") : BJLLocalizedString(@" 请输入提问内容") attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0], NSForegroundColorAttributeName: BJLTheme.viewSubTextColor, NSParagraphStyleAttributeName: paragraphStyle}]];

    if (self.question.content.length) {
        NSMutableAttributedString *question = [NSMutableAttributedString new];
        [question appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:BJLLocalizedString(@"%@："), self.question.fromUser.displayName] attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:12.0], NSForegroundColorAttributeName: BJLTheme.viewTextColor}]];
        [question appendAttributedString:[[NSAttributedString alloc] initWithString:self.question.content attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.0], NSForegroundColorAttributeName: BJLTheme.viewSubTextColor}]];
        self.questionLabel.attributedText = question;
    }
    else {
        self.questionLabel.attributedText = nil;
    }
    self.wordCountLabel.text = [NSString stringWithFormat:@"%lu/%ld", (unsigned long)self.textView.text.length, (long)BJLTextMaxLength_question];
    self.textView.bjl_attributedPlaceholder = placeholder;

    if (self.question) {
        [self remakeConstraintsWithViews:array];
        [self.wordCountLabel bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.right.equalTo(array.lastObject.bjl_left).offset(-13.0);
            make.top.bottom.equalTo(array.lastObject);
        }];
        [self.questionLabel bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.right.equalTo(self.view).inset(8.0);
            make.bottom.equalTo(self.containerView.bjl_top).offset(-8.0);
            make.top.equalTo(self.view).offset(8.0);
        }];
    }
    else {
        array = @[self.sendQuestionButton];
        [self remakeConstraintsWithViews:array];
        [self.wordCountLabel bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.right.equalTo(array.lastObject.bjl_left).offset(-13.0);
            make.top.bottom.equalTo(array.lastObject);
        }];
        [self.questionLabel bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.containerView.bjl_top);
            make.top.equalTo(self.view);
        }];
    }
}

#pragma mark -

- (void)updateWithQuestion:(BJLQuestion *)question {
    self.question = question;
}

- (void)sendQuestion {
    if (self.sendQuestionCallback) {
        self.sendQuestionCallback(self.textView.text);
        self.textView.text = nil;
        self.question = nil;
    }
}

- (void)saveReply {
    if (self.question.state & BJLQuestionPublished) {
        [self sendQuestion];
    }
    else if (self.saveReplyCallback) {
        self.saveReplyCallback(self.question, self.textView.text);
        self.textView.text = nil;
        self.question = nil;
    }
}

- (void)cancelReply {
    if (self.cancelCallback) {
        self.cancelCallback();
        self.textView.text = nil;
        self.question = nil;
    }
}

#pragma mark - keyboard

- (void)keyboardChangeFrameWithNotification:(NSNotification *)notification {
    BOOL isPortrait = UIScreen.mainScreen.bounds.size.height > UIScreen.mainScreen.bounds.size.width;

    NSDictionary *userInfo = notification.userInfo;
    if (!userInfo || isPortrait) {
        return;
    }

    CGRect keyboardFrame = bjl_as(userInfo[UIKeyboardFrameEndUserInfoKey], NSValue).CGRectValue;

    CGFloat offset = (CGRectGetMinY(keyboardFrame) >= CGRectGetHeight([UIScreen mainScreen].bounds)
                          ? 0.0
                          : -CGRectGetHeight(keyboardFrame));
    [self.containerView bjl_updateConstraints:^(BJLConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(offset);
    }];
}

#pragma mark - text view delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self sendQuestion];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    dispatch_async(dispatch_get_main_queue(), ^{
        // max length
        if (textView.text.length > BJLTextMaxLength_question) {
            UITextRange *markedTextRange = textView.markedTextRange;
            if (!markedTextRange || markedTextRange.isEmpty) {
                textView.text = [textView.text substringToIndex:BJLTextMaxLength_question];
                [textView.undoManager removeAllActions];
            }
        }
        self.wordCountLabel.text = [NSString stringWithFormat:@"%lu/%ld", (unsigned long)self.textView.text.length, (long)BJLTextMaxLength_question];
    });
}

#pragma mark - wheel

- (UIButton *)makeButtonWithTitle:(nullable NSString *)title image:(nullable UIImage *)image backgroundColor:(UIColor *)color action:(SEL)selector {
    UIButton *button = [UIButton new];
    [button.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    button.backgroundColor = color;
    button.layer.cornerRadius = 12.0;
    button.layer.masksToBounds = YES;
    if (image) {
        [button bjl_setImage:image forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
    }
    if (title) {
        [button bjl_setTitleColor:BJLTheme.subButtonTextColor forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        [button bjl_setTitle:title forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
    }
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)remakeConstraintsWithViews:(NSArray<UIView *> *)views {
    UIView *last = nil;
    for (UIView *view in views) {
        [self.containerView addSubview:view];
        [view bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            if (last) {
                make.top.bottom.equalTo(last);
                make.right.equalTo(last.bjl_left).offset(-8.0);
            }
            else {
                make.right.equalTo(self.containerView).offset(-12.0);
                make.bottom.equalTo(self.containerView).offset(-8.0);
                make.height.equalTo(@24.0);
            }
            make.width.equalTo(@55.0);
        }];
        last = view;
    }
}

@end
