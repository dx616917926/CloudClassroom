//
//  BJLScChatViewController.m
//  BJLiveUI
//
//  Created by xijia dai on 2019/9/17.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <SafariServices/SafariServices.h>

#import "BJLScChatViewController.h"
#import "BJLChatUploadingTask.h"
#import "BJLScChatCell.h"
#import "BJLScStickyCell.h"
#import "BJLScMessageOperatorView.h"
#import "BJLScAppearance.h"
#import "BJLScStickyMessageView.h"
#import "BJLScCommandLotteryView.h"
#import "BJLLanguageChooseView.h"
#import "BJLHeaderRefresh.h"

static const NSTimeInterval translateRequestTimeout = 5.0;

@interface BJLScChatViewController () <UIPopoverPresentationControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, readonly, weak) BJLRoom *room;
@property (nonatomic) BOOL sizeRegular;

@property (nonatomic) BJLChatStatus chatStatus;
@property (nonatomic, nullable) BJLUser *targetUser;
@property (nonatomic) BOOL onlyShowTeacherOrAssistant;

// NOTE: show sendingMessages in the second section
@property (nonatomic) NSMutableArray<id /* BJLMessage * || BJLChatUploadingTask * */> *allMessages, *currentDataSource;
@property (nonatomic) NSMutableDictionary<NSString *, NSMutableArray *> *whisperMessageDict;
// 存放私聊历史消息列表的分页页码, key 为 targetUserNumber, value 为该私聊对象的分页页码
@property (nonatomic) NSMutableDictionary<NSString *, NSNumber *> *whisperPageDict;
// key 为 targetUserNumber, value 为该私聊对象的是否有更多私聊的历史消息
@property (nonatomic) NSMutableDictionary<NSString *, NSNumber *> *whisperHasMoreDict;
@property (nonatomic) NSMutableArray<BJLMessage *> *unreadMessages, *unreadWhisperMessages, *teacherOrAssistantMessages, *imageMessages;
@property (nonatomic) NSInteger unreadMessagesCount;
@property (nonatomic) NSMutableDictionary<NSString *, UIImage *> *thumbnailForURLString;

// view
@property (nonatomic) UIView *emptyView;
@property (nonatomic, readwrite) UIView *chatStatusView;
@property (nonatomic) UILabel *chatStatusLabel;
@property (nonatomic) UIButton *unreadMessagesTipButton, *cancelChatButton, *chatInputButton, *whisperButton;
@property (nonatomic) UIView *chatInputView;
@property (nonatomic) BOOL wasAtTheBottomOfTableView;

// translation
@property (nonatomic) NSMutableDictionary<NSString *, BJLMessage *> *currentTranslateCachesDict;
@property (nonatomic) NSMutableDictionary<NSString *, NSNumber *> *translatedMessageSendTimes;
@property (nonatomic, nullable) NSTimer *sendTimeRecordTimer;
@property (nonatomic) UIViewController *optionViewController;

// 用于外部红点提示未读消息数量
@property (nonatomic) NSMutableArray<BJLMessage *> *unreadMessageArray;

// 1v1
@property (nonatomic, readonly) BOOL is1V1Class;

// 置顶消息
@property (nonatomic) BJLScStickyMessageView *stickyMessageView;
// 最多可置顶3条信息
@property (nonatomic) UILabel *maxStickyTipLabel;
@property (nonatomic) BJLConstraint *chatStatusTopConstraint;
@property (nonatomic) BJLConstraint *stickyMessageViewBottomConstraint;

@property (nonatomic, readwrite, nullable) BJLCommandLotteryBegin *commandLottery;
@property (nonatomic, nullable) BJLScCommandCountDownView *countDownView;
@property (nonatomic, nullable) BJLScCommandLotteryView *commandLotteryView;

// 引用消息折叠, 因为只有1个section, 所以key为row, 显示的行数为value
@property (nonatomic) NSMutableDictionary<NSNumber *, NSNumber *> *expandDict;

// 翻译按钮, 是否显示读取 featureConfig.enableChatTranslation
@property (nonatomic) UIButton *translatedButton;
@property (nonatomic) BJLLanguageChooseView *chooseView;
@property (nonatomic) UIViewController *chooseViewContrller;

@end

@implementation BJLScChatViewController

- (instancetype)initWithRoom:(BJLRoom *)room {
    return [self initWithRoom:room sizeRegular:NO];
}

- (instancetype)initWithRoom:(BJLRoom *)room sizeRegular:(BOOL)sizeRegular {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self->_room = room;
        self.sizeRegular = sizeRegular;
        BJLScChatCell.messageFontSize = sizeRegular ? 14.0 : 12.0;

        /*
         self.allEmoticons = ({
         NSMutableDictionary *allEmoticons = [NSMutableDictionary new];
         for (BJLEmoticon *emoticon in [BJLEmoticon allEmoticons]) {
         [allEmoticons bjl_setObject:emoticon
         forKey:emoticon.key];
         }
         allEmoticons;
         }); */

        self.allMessages = [NSMutableArray new];
        self.currentDataSource = self.allMessages;
        self.unreadMessages = [NSMutableArray new];
        self.imageMessages = [NSMutableArray new];

        self.expandDict = [NSMutableDictionary new];
        self.thumbnailForURLString = [NSMutableDictionary new];
        self.translatedMessageSendTimes = [NSMutableDictionary new];
        self.currentTranslateCachesDict = [NSMutableDictionary new];
        self.whisperPageDict = [NSMutableDictionary new];
        self.whisperHasMoreDict = [NSMutableDictionary new];

        self.unreadMessageArray = [NSMutableArray new];
        [self makeObserving];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.accessibilityIdentifier = NSStringFromClass([self class]);
    self.view.backgroundColor = BJLTheme.windowBackgroundColor;
    [self setUpSubviews];
    [self makeObservingAfterView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    self.wasAtTheBottomOfTableView = [self atTheBottomOfTableView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.tableView.scrollIndicatorInsets = bjl_set(self.tableView.scrollIndicatorInsets, {
        CGFloat adjustment = CGRectGetWidth(self.view.frame) - BJLScScrollIndicatorSize;
        set.left = -adjustment;
        set.right = adjustment;
    });

    if (self.wasAtTheBottomOfTableView && ![self atTheBottomOfTableView]) {
        [self scrollToTheEndTableView];
    }
    [self.stickyMessageView updateMaxHeight:self.view.frame.size.height];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self updateEmptyViewHidden];
    [self.tableView reloadData];
    [self loadUnreadMessages];
    [self scrollToTheEndTableView];
    [self udpateStickyMessageView];

    [self.unreadMessageArray removeAllObjects];
    if (self.newMessageCallback) {
        self.newMessageCallback(0);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self.thumbnailForURLString removeAllObjects];
}

- (void)dealloc {
    [self.sendTimeRecordTimer invalidate];
    self.sendTimeRecordTimer = nil;

    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

#pragma mark - subviews

- (void)setUpSubviews {
    BOOL iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    CGFloat margin = 5.0;
    CGFloat fontSize = self.sizeRegular ? 14.0 : 12.0;
    CGFloat largeInset = self.sizeRegular ? 12.0 : 8.0;
    CGFloat mediumInset = self.sizeRegular ? 10.0 : 5.0;
    CGFloat smallInset = self.sizeRegular ? 8.0 : 4.0;
    CGFloat cornerRadius = self.sizeRegular ? 4.0 : 2.0;

    // chatStatusView
    self.chatStatusView = ({
        UIView *view = [[UIView alloc] init];
        view.accessibilityIdentifier = BJLKeypath(self, chatStatusView);
        view.backgroundColor = BJLTheme.windowBackgroundColor;
        view.clipsToBounds = YES;
        view.layer.masksToBounds = YES;
        view;
    });
    [self.view addSubview:self.chatStatusView];
    [self.chatStatusView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        [self.chatStatusTopConstraint uninstall];
        self.chatStatusTopConstraint = make.top.equalTo(self.stickyMessageView.bjl_bottom).priorityHigh().constraint;
        make.left.right.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view);
        make.height.equalTo(@(0.0));
    }];
    // cancelChatButton
    self.cancelChatButton = ({
        UIButton *button = [[UIButton alloc] init];
        button.accessibilityIdentifier = @"cancelChatButton";
        [button bjl_setTitle:BJLLocalizedString(@"取消私聊") forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        [button bjl_setTitleColor:BJLTheme.viewSubTextColor forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        button.backgroundColor = [UIColor clearColor];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.font = [UIFont systemFontOfSize:fontSize];
        button.layer.borderColor = BJLTheme.buttonBorderColor.CGColor;
        button.layer.borderWidth = BJLScOnePixel;
        button.layer.cornerRadius = cornerRadius;
        [button addTarget:self action:@selector(cancelPrivateChat) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [self.chatStatusView addSubview:self.cancelChatButton];
    [self.cancelChatButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.right.equalTo(self.chatStatusView).offset(-margin);
        make.centerY.equalTo(self.chatStatusView);
        make.width.equalTo(@(64.0)).priorityHigh();
        make.height.equalTo(@(24.0));
    }];
    // chatStatusLabel
    self.chatStatusLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.accessibilityIdentifier = BJLKeypath(self, chatStatusLabel);
        label.font = [UIFont systemFontOfSize:fontSize];
        label.textColor = BJLTheme.viewTextColor;
        label.numberOfLines = 1;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        label;
    });
    [self.chatStatusView addSubview:self.chatStatusLabel];
    [self.chatStatusLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view).offset(margin);
        make.centerY.equalTo(self.chatStatusView);
        make.right.equalTo(self.cancelChatButton.bjl_left).offset(-margin);
    }];

    UIButton *backButton = nil;
    if (self.is1V1Class && iPhone) {
        backButton = ({
            UIButton *button = [UIButton new];
            button.accessibilityIdentifier = @"backButton";
            button.backgroundColor = [UIColor clearColor];
            [button bjl_setTitle:BJLLocalizedString(@"返回") forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
            button.titleLabel.font = [UIFont systemFontOfSize:fontSize];
            [button bjl_setTitleColor:BJLTheme.viewTextColor forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
            [button bjl_setImage:[UIImage bjl_imageNamed:@"bjl_sc_chat_back"] forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
            [button addTarget:self action:@selector(backToVideo) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
        [self.view addSubview:backButton];
        [backButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view);
            make.bottom.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view);
            make.height.equalTo(@32.0);
            make.width.equalTo(self.view).multipliedBy(1.0 / 3.0);
        }];
    }

    self.chatInputView = ({
        UIView *view = [UIView new];
        view.accessibilityIdentifier = BJLKeypath(self, chatInputView);
        view.backgroundColor = [UIColor clearColor];
        if (!self.is1V1Class || !iPhone) {
            view.layer.masksToBounds = NO;
            view.layer.shadowOpacity = 0.3;
            view.layer.shadowColor = BJLTheme.windowShadowColor.CGColor;
            view.layer.shadowOffset = CGSizeMake(0.0, -cornerRadius);
            view.layer.shadowRadius = cornerRadius;
        }
        view;
    });
    [self.view addSubview:self.chatInputView];
    [self.chatInputView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        if (self.is1V1Class && iPhone) {
            make.left.equalTo(backButton.bjl_right);
        }
        else {
            make.left.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view);
        }
        make.bottom.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view);
        make.right.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view);
        make.height.equalTo(self.sizeRegular ? @52.0 : @32.0);
    }];

    self.chatInputButton = ({
        UIButton *button = [UIButton new];
        button.accessibilityIdentifier = @"chatInputButton";
        button.layer.cornerRadius = cornerRadius;
        button.layer.masksToBounds = YES;
        if (self.sizeRegular) {
            button.backgroundColor = BJLTheme.buttonLightBackgroundColor;
        }
        else {
            button.backgroundColor = BJLTheme.windowBackgroundColor;
            button.layer.borderColor = BJLTheme.buttonBorderColor.CGColor;
            button.layer.borderWidth = 1.0;
        }
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.titleLabel.textAlignment = NSTextAlignmentLeft;
        button.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        button.titleLabel.font = [UIFont systemFontOfSize:fontSize];
        [button bjl_setTitle:BJLLocalizedString(@"输入聊天内容") forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        [button bjl_setTitleColor:BJLTheme.toolButtonTitleColor forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        button.titleEdgeInsets = UIEdgeInsetsMake(smallInset, mediumInset, smallInset, mediumInset);
        [button addTarget:self action:@selector(showChatInputView) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [self.chatInputView addSubview:self.chatInputButton];

    if (!self.room.featureConfig.enableWhisper) {
        [self.chatInputButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.equalTo(self.chatInputView).offset(largeInset);
            make.top.bottom.equalTo(self.chatInputView).inset(smallInset).priorityHigh();
            make.right.equalTo(self.chatInputView).offset(-largeInset);
        }];
    }
    else {
        [self.chatInputButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.equalTo(self.chatInputView).offset(largeInset);
            make.top.bottom.equalTo(self.chatInputView).inset(smallInset).priorityHigh();
        }];

        self.whisperButton = ({
            UIButton *button = [UIButton new];
            button.accessibilityIdentifier = @"whisperButton";
            button.layer.cornerRadius = cornerRadius;
            button.layer.masksToBounds = YES;
            if (self.sizeRegular) {
                button.backgroundColor = BJLTheme.buttonLightBackgroundColor;
            }
            else {
                button.backgroundColor = BJLTheme.windowBackgroundColor;
                button.layer.borderColor = BJLTheme.buttonBorderColor.CGColor;
                button.layer.borderWidth = 1.0;
            }
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            button.titleLabel.font = [UIFont systemFontOfSize:fontSize];
            [button bjl_setTitle:BJLLocalizedString(@"私聊") forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
            [button bjl_setTitleColor:BJLTheme.viewTextColor forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
            [button addTarget:self action:@selector(showChatInputViewWithWhisper) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
        [self.chatInputView addSubview:self.whisperButton];
        [self.whisperButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.equalTo(self.chatInputButton.bjl_right).offset(smallInset);
            make.top.bottom.equalTo(self.chatInputView).inset(smallInset).priorityHigh();
            make.right.equalTo(self.chatInputView).offset(-largeInset);
            make.width.equalTo(self.sizeRegular ? @64.0 : @48.0);
        }];
    }

    // tableView
    [self setUpTableView];
    [self.tableView bjl_removeAllConstraints];
    [self.tableView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
        make.top.equalTo(self.chatStatusView.bjl_bottom);
        make.left.right.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view);
        make.bottom.equalTo(self.chatInputView.bjl_top);
    }];

    // unreadMessage
    self.unreadMessagesTipButton = ({
        UIButton *button = [UIButton new];
        button.accessibilityIdentifier = BJLKeypath(self, unreadMessagesTipButton);
        button.hidden = YES;
        button.titleLabel.font = [UIFont systemFontOfSize:fontSize];
        [button bjl_setTitle:BJLLocalizedString(@"有新消息") forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        [button bjl_setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        button.backgroundColor = BJLTheme.brandColor;
        button.layer.cornerRadius = cornerRadius;
        button;
    });
    [self.view addSubview:self.unreadMessagesTipButton];
    [self.unreadMessagesTipButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.right.equalTo(self.tableView).offset(-BJLScScrollIndicatorSize);
        make.bottom.equalTo(self.tableView).offset(-BJLScScrollIndicatorSize);
        make.size.equal.sizeOffset(CGSizeMake(72.0, 24.0));
    }];

    bjl_weakify(self);
    [self.unreadMessagesTipButton bjl_addHandler:^(__kindof UIControl *_Nullable sender) {
        bjl_strongify(self);
        if (self.unreadMessagesCount > 0) {
            [self loadUnreadMessages];
            [self scrollToTheEndTableView];
        }
        else {
            [self updateUnreadMessagesTipWithCount:0];
        }
    }];

    // emptyView
    self.emptyView = ({
        UIView *view = [BJLHitTestView new];
        view.clipsToBounds = YES;
        view.accessibilityIdentifier = BJLKeypath(self, emptyView);
        view.backgroundColor = [UIColor clearColor];
        view;
    });
    [self.view insertSubview:self.emptyView belowSubview:self.chatStatusView];
    [self.emptyView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.view);
    }];
    UILabel *emptyLabel = ({
        UILabel *label = [UILabel new];
        label.accessibilityIdentifier = @"emptyLabel";
        label.text = BJLLocalizedString(@"无更多历史消息");
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:fontSize];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = BJLTheme.toolButtonTitleColor;
        label;
    });
    [self.emptyView addSubview:emptyLabel];
    [emptyLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(self.emptyView);
        make.left.right.equalTo(self.emptyView);
        make.top.equalTo(self.emptyView).offset(largeInset);
        make.height.equalTo(@20.0).priorityHigh();
    }];

    self.stickyMessageView = ({
        BJLScStickyMessageView *stickyMessageView = [[BJLScStickyMessageView alloc] initWithMessageList:nil room:self.room];
        stickyMessageView.hidden = YES;
        bjl_weakify(self);
        [stickyMessageView setCancelStickyCallback:^(BJLMessage *_Nonnull message) {
            bjl_strongify(self);
            if (self.room.loginUser.isTeacherOrAssistant) {
                BJLError *error = [self.room.chatVM cancelStickyMessage:message];
                if (error) {
                    [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                }
            }
        }];
        [stickyMessageView setLinkURLCallback:^BOOL(NSURL *_Nonnull url) {
            bjl_strongify(self);
            return [self openURL:url];
        }];
        [stickyMessageView setUpdateConstraintsCallback:^(BOOL showcompleteMessage) {
            bjl_strongify(self);
            if (!showcompleteMessage) {
                [self.chatStatusView bjl_updateConstraints:^(BJLConstraintMaker *make) {
                    [self.chatStatusTopConstraint uninstall];
                    self.chatStatusTopConstraint = make.top.equalTo(self.stickyMessageView.bjl_bottom).constraint;
                }];
            }
            else {
                [self.chatStatusView bjl_updateConstraints:^(BJLConstraintMaker *make) {
                    [self.chatStatusTopConstraint uninstall];
                    self.chatStatusTopConstraint = make.top.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view).constraint;
                }];
            }
        }];
        [stickyMessageView setImageSelectCallback:^(BJLMessage *_Nullable message) {
            bjl_strongify(self);
            if (message && message.type == BJLMessageType_image) {
                if (self.showImageViewCallback) self.showImageViewCallback(message, @[message], YES);
            }
        }];
        stickyMessageView;
    });

    [self.view addSubview:self.stickyMessageView];
    [self.stickyMessageView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.vertical.compressionResistance.hugging.required();
        make.top.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view);
        make.left.right.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view);
        make.bottom.lessThanOrEqualTo(self.view);
    }];

    self.maxStickyTipLabel = ({
        UILabel *label = [UILabel new];
        label.hidden = YES;
        label.text = BJLLocalizedString(@"最多可置顶3条信息");
        label.textColor = BJLTheme.buttonTextColor;
        label.font = [UIFont systemFontOfSize:fontSize];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = BJLTheme.brandColor;
        label.layer.cornerRadius = cornerRadius;
        label.layer.masksToBounds = YES;
        label;
    });
    [self.view addSubview:self.maxStickyTipLabel];
    [self.maxStickyTipLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.stickyMessageView).offset(BJLScViewSpaceS);
        make.centerX.equalTo(self.stickyMessageView);
        make.width.equalTo(@190);
        make.height.equalTo(@24);
    }];

    if (self.room.featureConfig.enableChatTranslation) {
        self.translatedButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.accessibilityIdentifier = BJLKeypath(self, translatedButton);
            [button bjl_setImage:[UIImage bjl_imageNamed:@"bjl_chat_language_choose_normal"] forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
            [button bjl_setImage:[UIImage bjl_imageNamed:@"bjl_chat_language_choose_selected"] forState:UIControlStateSelected];
            button;
        });
        [self.view insertSubview:self.translatedButton belowSubview:self.stickyMessageView];
        [self.translatedButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.right.equalTo(self.tableView).offset(-BJLScScrollIndicatorSize);
            make.bottom.equalTo(self.tableView).offset(-BJLScScrollIndicatorSize);
            make.size.equal.sizeOffset(CGSizeMake(24.0, 24.0));
        }];
        [self.translatedButton bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            [self showLanguageChooseViewContrller];
        }];
        self.chooseView = [[BJLLanguageChooseView alloc] initWithFrame:CGRectZero];
    }
}

- (void)updateInputViewHidden:(BOOL)hidden {
    self.chatInputView.hidden = hidden;
    if (hidden) {
        [self.chatInputView bjl_updateConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.height.equalTo(@0.0);
        }];
    }
    else {
        [self.chatInputView bjl_updateConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.height.equalTo(@32.0);
        }];
    }
}

#pragma mark - private

- (void)updateUnreadMessagesTipWithCount:(NSInteger)unreadMessagesCount {
    ///!!!:  2020.9.29, 改为不展示具体未读消息数, unreadMessagesCount等属性暂时不删, 以免后期又改需求
    if (unreadMessagesCount > 0) {
        //        NSString *title = [NSString stringWithFormat:BJLLocalizedString(@"%td条新消息"), unreadMessagesCount];
        //        [self.unreadMessagesTipButton setTitle:title forState:UIControlStateNormal];
        self.unreadMessagesTipButton.hidden = NO;
    }
    else {
        //        [self.unreadMessagesTipButton setTitle:nil forState:UIControlStateNormal];
        self.unreadMessagesTipButton.hidden = YES;
    }
}

- (void)loadUnreadMessages {
    if (self.unreadMessages.count <= 0) {
        return;
    }
    [self.unreadMessages removeAllObjects];
    self.unreadMessagesCount = [self.unreadMessages count];
    [self updateUnreadMessagesTipWithCount:self.unreadMessagesCount];
}

- (void)updateEmptyViewHidden {
    BOOL hidden = (self.currentDataSource.count > 0);
    self.emptyView.hidden = hidden;
}

- (void)showChatInputView {
    if (self.showChatInputViewCallback) {
        self.showChatInputViewCallback(NO, self.commandLottery);
    }
}

- (void)showChatInputViewWithWhisper {
    if (self.showChatInputViewCallback) {
        self.showChatInputViewCallback(YES, self.commandLottery);
    }
}

#pragma mark - observing

- (void)makeObserving {
    bjl_weakify(self);

    [self bjl_observe:BJLMakeMethod(self.room.chatVM, receivedMessagesDidOverwrite:)
             observer:^BOOL(NSArray<BJLMessage *> *_Nullable messages) {
                 bjl_strongify(self);
                 // 因为chat server 的 socket 可能会经常断开并自动重连, 所以, 此回调可能会经常被调用
                 if (self.refreshControl.isRefreshing) {
                     [self.refreshControl endRefreshing];
                 }
                 [self clearDataSource]; // 清空群聊、私聊数据源 及 高度缓存
                 if (messages.count > 0) {
                     [self.allMessages addObjectsFromArray:messages];
                     [self updateImageMessagesWithMessages:messages];

                     [messages enumerateObjectsUsingBlock:^(BJLMessage *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                         bjl_strongify(self);
                         if (obj.fromUser.isTeacherOrAssistant) {
                             [self.teacherOrAssistantMessages bjl_addObject:obj];
                         }
                     }];
                 }

                 if (self.chatStatus == BJLChatStatus_private) {
                     [self loadWhisperHistoryList];
                 }

                 [self updateCurrentDataSource];
                 if (!self || !self.isViewLoaded || !self.view.window || self.view.hidden) {
                     return YES;
                 }
                 [self.tableView reloadData];
                 [self scrollToTheEndTableView];
                 return YES;
             }];

    [self bjl_observe:BJLMakeMethod(self.room.chatVM, didReceiveMessages:)
             observer:^BOOL(NSArray<BJLMessage *> *messages) {
                 bjl_strongify(self);

                 for (BJLMessage *message in [messages copy]) {
                     BOOL replacedTask = NO;
                     if (message.type == BJLMessageType_image
                         && [message.fromUser.number isEqualToString:self.room.loginUser.number]) {
                         for (id object in [self.currentDataSource copy]) {
                             BJLChatUploadingTask *task = bjl_as(object, BJLChatUploadingTask);
                             if (task.state == BJLUploadState_uploaded
                                 && [task.result isEqualToString:message.imageURLString]) {
                                 [self.thumbnailForURLString bjl_setObject:task.thumbnail
                                                                    forKey:message.imageURLString];
                                 [self replaceTask:task withMessage:message];
                                 replacedTask = YES;
                                 break;
                             }
                         }
                     }

                     // targetUserNumber：群聊消息中为空，私聊消息中为私聊对象的 number
                     NSString *targetUserNumber = nil;
                     NSString *toUserNumber = message.toUser.number;
                     if (toUserNumber.length > 0) {
                         NSString *fromUserNumber = message.fromUser.number;
                         targetUserNumber = [self.room.loginUser.number isEqualToString:toUserNumber] ? fromUserNumber : toUserNumber;
                     }

                     // 新增消息而非替换
                     if (!replacedTask) {
                         // 未读消息
                         BOOL shouldUpdateUnreadMessage = (self.chatStatus != BJLChatStatus_private);
                         if (self.chatStatus == BJLChatStatus_private) {
                             // 私聊状态时，收到当前私聊的消息才更新未读消息数
                             shouldUpdateUnreadMessage = [targetUserNumber isEqualToString:self.targetUser.number];
                         }

                         // 更新未读消息数
                         if (shouldUpdateUnreadMessage && ![message.fromUser isSameUser:self.room.loginUser]) {
                             [self.unreadMessageArray bjl_addObject:message];
                             [self.unreadMessages bjl_addObject:message];
                             self.unreadMessagesCount = [self.unreadMessages count];
                         }

                         // 更新来自老师/助教的消息
                         if (message.fromUser.isTeacherOrAssistant) {
                             [self.teacherOrAssistantMessages bjl_addObject:message];
                         }

                         // 添加 messgae
                         [self addMessageToCurrentDataSource:message targetUserNumber:targetUserNumber];
                     }
                 }

                 [self updateImageMessagesWithMessages:messages];

                 if (self.newMessageCallback) {
                     self.newMessageCallback([self.unreadMessageArray count]);
                 }

                 if (self.receiveNewUnreadMessageCallback) {
                     self.receiveNewUnreadMessageCallback(messages);
                 }

                 if (!self || !self.isViewLoaded || !self.view.window || self.view.hidden) {
                     return YES;
                 }
                 [self.unreadMessageArray removeAllObjects];
                 [self updateEmptyViewHidden];
                 [self.tableView reloadData];

                 // 滑动到底部
                 BOOL wasAtTheBottomOfTableView = [self atTheBottomOfTableView];
                 if ([messages.lastObject.fromUser.number isEqualToString:self.room.loginUser.number]
                     || wasAtTheBottomOfTableView) {
                     [self scrollToTheEndTableView];
                 }
                 return YES;
             }];

    [self bjl_kvo:BJLMakeProperty(self, currentDataSource)
         observer:^BOOL(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             if (!self || !self.isViewLoaded || !self.view.window || self.view.hidden) {
                 return YES;
             }
             [self updateEmptyViewHidden];
             return YES;
         }];

    [self bjl_observe:BJLMakeMethod(self.room.chatVM, didRevokeMessageWithID:isCurrentUserRevoke:)
             observer:(BJLMethodObserver) ^ BOOL(NSString * messageID, BOOL isCurrentUserRevoke) {
                 bjl_strongify(self);
                 if (self.revokeMessageCallback) {
                     self.revokeMessageCallback(messageID);
                 }
                 if (isCurrentUserRevoke) {
                     return YES;
                 }
                 else {
                     [self updateDataSourceWithRevokeMessageID:messageID];
                     if (!self || !self.isViewLoaded || !self.view.window || self.view.hidden) {
                         return YES;
                     }
                     [self.tableView reloadData];
                 }
                 return YES;
             }];

    [self bjl_observe:BJLMakeMethod(self.room.chatVM, didReceiveMessageTranslation:messageUUID:from:to:)
             observer:^BOOL(NSString *translate, NSString *messageUUID, BJLMessageLanguageType from, BJLMessageLanguageType to) {
                 bjl_strongify(self);
                 [self didReceiveMessageTranslation:translate messageUUID:messageUUID from:from to:to];
                 return YES;
             }];

    [self bjl_kvo:BJLMakeProperty(self, unreadMessagesCount)
         observer:^BOOL(NSNumber *_Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             NSInteger unreadMessagesCount = now.integerValue;
             if (unreadMessagesCount > 0 && [self atTheBottomOfTableView]) {
                 [self loadUnreadMessages];
                 [self scrollToTheEndTableView];
             }
             else {
                 [self updateUnreadMessagesTipWithCount:unreadMessagesCount];
             }
             return YES;
         }];

    if (!self.is1V1Class) {
        [self bjl_kvo:BJLMakeProperty(self.room.chatVM, stickyMessageList)
            filter:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                return value != oldValue && !!value;
            } observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                bjl_strongify(self);
                if (!self || !self.isViewLoaded || !self.view.window || self.view.hidden) {
                    return YES;
                }
                [self udpateStickyMessageView];
                return YES;
            }];
    }

    // 口令抽奖 开始
    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveBeginCommandLottery:) observer:^BOOL(BJLCommandLotteryBegin *commandLottery) {
        bjl_strongify(self);
        // 只有学生身份允许抽奖
        if (self.room.loginUser.isStudent) {
            self.commandLottery = commandLottery;
            [self makeCommandLotteryView];
        }
        return YES;
    }];

    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveLotteryResult:) observer:^BOOL(BJLLottery *lottery) {
        bjl_strongify(self);
        if (BJLLotteryType_Command == lottery.type) {
            [self removeCommandLotteryView];
            [self removeCountdownView];
        }
        return YES;
    }];

    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveHitCommandLottery:) observer:^BOOL(BJLLottery *lottery) {
        bjl_strongify(self);
        // 发送过口令之后  移除口令的弹框view
        [self removeCommandLotteryView];
        return YES;
    }];

    // 私聊的历史消息
    [self bjl_observe:BJLMakeMethod(self.room.chatVM, didReceiveWhisperMessages:targetUserNumber:hasMore:)
             observer:(BJLMethodObserver) ^ BOOL(NSArray<BJLMessage *> * messages, NSString * targetUserNumber, BOOL hasMore) {
                 bjl_strongify(self);
                 [self.refreshControl endRefreshing];
                 [self.whisperHasMoreDict bjl_setObject:@(hasMore) forKey:self.targetUser.number];
                 [self.whisperMessageDict bjl_setObject:[messages mutableCopy] forKey:targetUserNumber];

                 [self updateCurrentDataSource];
                 [self.tableView reloadData];
                 NSInteger page = [self.whisperPageDict bjl_integerForKey:targetUserNumber];
                 if (0 == page) {
                     [self scrollToTheEndTableView];
                 }
                 return YES;
             }];
}

- (void)makeObservingAfterView {
    bjl_weakify(self);
    [self bjl_kvoMerge:@[BJLMakeProperty(self.room.chatVM, forbidAll),
        BJLMakeProperty(self.room.chatVM, forbidMyGroup),
        BJLMakeProperty(self.room.chatVM, forbidMe)]
              observer:^(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                  bjl_strongify(self);
                  if (self.room.loginUser.isTeacherOrAssistant) {
                      return;
                  }
                  BOOL forbid = self.room.chatVM.forbidAll || self.room.chatVM.forbidMyGroup || self.room.chatVM.forbidMe;
                  BOOL secretForbid = self.room.featureConfig.useSecretMsgSendForbid;

                  NSString *title = (forbid && !secretForbid) ? BJLLocalizedString(@"老师已开启禁言") : BJLLocalizedString(@"输入聊天内容");
                  [self.chatInputButton bjl_setTitle:title forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];

                  BOOL whisperForbid = self.room.chatVM.forbidMe || self.room.chatVM.forbidMyGroup
                                       || (self.room.chatVM.forbidAll && !self.room.featureConfig.enableWhisperToTeacherWhenForbidAll);
                  UIColor *titleColor = whisperForbid ? BJLTheme.subButtonTextColor : BJLTheme.viewTextColor;
                  [self.whisperButton bjl_setTitleColor:titleColor forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
              }];
}

- (void)updateImageMessagesWithMessages:(NSArray<BJLMessage *> *)messages {
    for (BJLMessage *message in [messages copy]) {
        if (message.type == BJLMessageType_image) {
            [self.imageMessages bjl_addObject:message];
        }
    }
}

#pragma mark - messageTranslate
- (NSString *)keyForMessgaetranslation:(BJLMessage *)message {
    //    使用消息ID-发送方ID-翻译发送时间戳 做为区分message的唯一字符串
    NSTimeInterval currentTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSString *currentTimeString = [NSString stringWithFormat:@"%f", currentTimeInterval];

    NSString *key = [NSString stringWithFormat:@"%@-%@-%@", message.ID, message.fromUser.ID, currentTimeString];
    return key;
}

- (void)showOperatorViewWithMessage:(BJLMessage *)message
                              point:(CGPoint)point
                              image:(UIImage *)image {
    bjl_weakify(self);
    // 群聊下，点击老师/助教消息可以弹出”只看老师/助教“选项
    BOOL needShowOnlyTeacherOrAssistant = self.chatStatus == BJLChatStatus_default && message.fromUser.isTeacherOrAssistant && !self.onlyShowTeacherOrAssistant;
    BJLRecallType recallType = BJLRecallTypeNone;
    if ([message.fromUser.number isEqualToString:self.room.loginUser.number]) {
        recallType = BJLRecallTypeNormal;
    }
    else if (self.room.loginUser.isTeacherOrAssistant) {
        recallType = BJLRecallTypeDelete;
    }

    NSInteger optionCount = 1;
    optionCount += (recallType == BJLRecallTypeNone) ? 0 : 1;
    optionCount += needShowOnlyTeacherOrAssistant ? 1 : 0;
    CGFloat height = 20.0 + optionCount * BJLScMessageOperatorButtonSize;
    CGFloat width = needShowOnlyTeacherOrAssistant ? 120.0 : 80.0f;

    self.optionViewController = ({
        UIViewController *viewController = [[UIViewController alloc] init];
        viewController.view.backgroundColor = [UIColor clearColor];
        viewController.modalPresentationStyle = UIModalPresentationPopover;
        viewController.preferredContentSize = CGSizeMake(width, height);
        viewController.popoverPresentationController.backgroundColor = BJLTheme.toolboxBackgroundColor;
        viewController.popoverPresentationController.delegate = self;
        viewController.popoverPresentationController.sourceView = self.view;
        viewController.popoverPresentationController.sourceRect = CGRectMake(point.x, point.y, 1.0, 1.0);
        viewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown;
        viewController;
    });

    // 当前是老师或者助教 && 当前不是1v1的课程
    BOOL isSticky = NO;
    for (BJLMessage *msg in self.room.chatVM.stickyMessageList) {
        if ([msg.ID isEqualToString:message.ID]) {
            isSticky = YES;
            break;
        }
    }
    BOOL canStickyMessage = self.room.loginUser.isTeacherOrAssistant && !self.is1V1Class;
    BJLScMessageOperatorView *optionView = [[BJLScMessageOperatorView alloc] initWithNeedShowOnlyTeacherOrAssistant:needShowOnlyTeacherOrAssistant recallType:recallType canStickyMessage:canStickyMessage isSticky:isSticky];
    [optionView updateButtonConstraints];
    [optionView setOnClikCopyCallback:^(BOOL on) {
        bjl_strongify(self);
        switch (message.type) {
            case BJLMessageType_text: {
                if (message.text.length) {
                    [[UIPasteboard generalPasteboard] setString:message.text];
                }
                break;
            }

            case BJLMessageType_image: {
                if (message.imageURLString) {
                    [[UIPasteboard generalPasteboard] setString:[NSString stringWithFormat:@"[img:%@]", message.imageURLString]];
                }
                break;
            }

            case BJLMessageType_emoticon: {
                [[UIPasteboard generalPasteboard] setString:[NSString stringWithFormat:@"[%@]", message.emoticon.name]];
                break;
            }
            default:
                break;
        }
        [self hideOptionViewController];
    }];

    [optionView setOnlyShowTeacherORAssistantMessageCallback:^(BOOL on) {
        bjl_strongify(self);
        [self hideOptionViewController];
        BOOL needShowOnlyTeacherOrAssistant = self.chatStatus == BJLChatStatus_default && message.fromUser.isTeacherOrAssistant;
        if (message && needShowOnlyTeacherOrAssistant) {
            [self startOnlyShowTeacherOrAsisstantMessgae:YES];
        }
    }];

    [optionView setRecallMessageCallback:^(BOOL on) {
        bjl_strongify(self);
        [self hideOptionViewController];
        BJLError *error = [self.room.chatVM revokeMessage:message];
        if (error) {
            [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
        }
        else {
            error = [self.room.chatVM cancelStickyMessage:message];
            if (error) {
                [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
            }
            else {
                [self updateDataSourceWithRevokeMessageID:message.ID];
                [self.tableView reloadData];
            }
        }
    }];

    [optionView setStickyMessageCallback:^(BOOL on) {
        bjl_strongify(self);
        [self hideOptionViewController];
        if (on) {
            if (self.room.chatVM.stickyMessageList.count >= 3) {
                self.maxStickyTipLabel.hidden = NO;
                self.maxStickyTipLabel.alpha = 1.0;
                [UIView animateWithDuration:0.5 delay:2.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
                    self.maxStickyTipLabel.alpha = 0.01;
                } completion:^(BOOL finished) {
                    self.maxStickyTipLabel.hidden = YES;
                }];
            }
            else {
                BJLError *error = [self.room.chatVM sendStickyMessage:message];
                if (error) {
                    [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                }
            }
        }
        else {
            BJLError *error = [self.room.chatVM cancelStickyMessage:message];
            if (error) {
                [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
            }
        }
    }];

    [self.optionViewController.view addSubview:optionView];
    [optionView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.optionViewController.view.bjl_safeAreaLayoutGuide ?: self.optionViewController.view).inset(1.0);
    }];
    if (self.presentedViewController) {
        [self.presentedViewController bjl_dismissAnimated:YES completion:nil];
    }
    [self presentViewController:self.optionViewController animated:YES completion:nil];
}

- (void)hideOptionViewController {
    [self.optionViewController bjl_dismissAnimated:YES completion:nil];
}

- (void)showLanguageChooseViewContrller {
    self.chooseViewContrller = ({
        UIViewController *viewController = [[UIViewController alloc] init];
        viewController.view.backgroundColor = [UIColor clearColor];
        viewController.modalPresentationStyle = UIModalPresentationPopover;
        viewController.preferredContentSize = self.chooseView.expectSize;
        viewController.popoverPresentationController.backgroundColor = BJLTheme.toolboxBackgroundColor;
        viewController.popoverPresentationController.delegate = self;
        viewController.popoverPresentationController.sourceView = self.translatedButton;
        viewController.popoverPresentationController.sourceRect = CGRectMake(0, 0, 1.0, 1.0);
        viewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown;
        viewController;
    });

    [self.chooseViewContrller.view addSubview:self.chooseView];
    [self.chooseView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.chooseViewContrller.view.bjl_safeAreaLayoutGuide ?: self.chooseViewContrller.view).inset(1.0);
    }];
    if (self.presentedViewController) {
        [self.presentedViewController bjl_dismissAnimated:YES completion:nil];
    }
    [self presentViewController:self.chooseViewContrller animated:YES completion:nil];
    self.translatedButton.selected = YES;
}

- (void)hideLanguageChooseViewContrller {
    self.translatedButton.selected = NO;
}

- (void)startSendTimeRecording:(BJLMessage *)message messageUUID:(NSString *)messageUUID {
    if (!self.sendTimeRecordTimer || !self.sendTimeRecordTimer.isValid) {
        bjl_weakify(self);
        self.sendTimeRecordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer *_Nonnull timer) {
            bjl_strongify(self);
            if (!self) {
                [timer invalidate];
                return;
            }
            [self checkcRequestTimeOutMessage];
        }];
    }

    if (message && messageUUID) {
        [self recordSendTime:message messageUUID:messageUUID];
    }
}

//记录发送翻译信令的message 发送时间
- (void)recordSendTime:(BJLMessage *)message messageUUID:(NSString *)messageUUID {
    if (!message) {
        return;
    }

    NSTimeInterval currentTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSNumber *currentTime = [NSNumber numberWithDouble:currentTimeInterval];

    [self.translatedMessageSendTimes bjl_setObject:currentTime forKey:messageUUID];
}

//轮循检查请求超时的message
- (void)checkcRequestTimeOutMessage {
    bjl_weakify(self);
    NSArray *messageSendTimeKeys = [self.currentTranslateCachesDict allKeys];
    [messageSendTimeKeys enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        bjl_strongify(self);
        NSNumber *sendTime = [self.translatedMessageSendTimes bjl_numberForKey:obj defaultValue:@(-1)];

        if (![sendTime isEqualToNumber:@(-1)]) {
            NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
            NSTimeInterval sentSeconds = round(currentTime - sendTime.doubleValue);

            //已经请求的时间大于 translateRequestTimeout ,则视为请求超时
            if (sentSeconds > translateRequestTimeout) {
                [self.currentTranslateCachesDict bjl_removeObjectForKey:obj];
                [self.translatedMessageSendTimes removeObjectForKey:obj];

                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showTranslationFailedMessage];
                });
            }
        }
    }];
}

- (void)didReceiveMessageTranslation:(NSString *)translate messageUUID:(NSString *)messageUUID from:(BJLMessageLanguageType)from to:(BJLMessageLanguageType)to {
    if (!messageUUID)
        return;

    __block BJLMessage *cacheMessage = nil;
    bjl_weakify(self);
    NSArray *messageSendTimeKeys = [self.currentTranslateCachesDict allKeys];
    [messageSendTimeKeys enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        bjl_strongify(self);
        if (obj && [obj isEqualToString:messageUUID]) {
            cacheMessage = [self.currentTranslateCachesDict bjl_objectForKey:obj class:[BJLMessage class]];
            *stop = YES;
        }
    }];

    if (!cacheMessage) {
        return;
    }

    [self.currentTranslateCachesDict bjl_removeObjectForKey:messageUUID];
    [self.translatedMessageSendTimes removeObjectForKey:messageUUID];

    if (!translate.length) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showTranslationFailedMessage];
        });
        return;
    }
    [cacheMessage updateTranslationString:translate from:from to:to];

    NSUInteger index = [self.currentDataSource indexOfObject:cacheMessage];
    if (index == NSNotFound || self.currentDataSource.count <= 0) {
        return;
    }

    [self.tableView bjl_clearHeightCaches];
    [self.tableView reloadData];
}

- (void)showTranslationFailedMessage {
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *language = [languages objectAtIndex:0];
    if ([language hasPrefix:@"zh-Hans"]) {
        [self showProgressHUDWithText:BJLLocalizedString(@"翻译失败")];
    }
    else {
        [self showProgressHUDWithText:@"Translate Fail!"];
    }
}

- (BOOL)shouldTranslateToEn:(BJLMessage *)message {
    if (!message || !message.text.length)
        return NO;

    NSString *text = message.text;

    //判断是否包含中文汉子
    for (int i = 0; i < [text length]; i++) {
        unichar ch = [text characterAtIndex:i];
        if (0x4E00 <= ch && ch <= 0x9FA5) {
            return YES;
        }
    }
    //判断是否为纯数字,是则翻译为英文
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([pred evaluateWithObject:text]) {
        return YES;
    }

    return NO;
}

#pragma mark - public

- (void)refreshMessages {
    [self loadUnreadMessages];
    [self scrollToTheEndTableView];
}

- (void)sendImageFile:(ICLImageFile *)file image:(nullable UIImage *)image {
    [self loadUnreadMessages];

    BJLChatUploadingTask *task = [BJLChatUploadingTask uploadingTaskWithImageFile:file room:self.room];
    [self addTaskToCurrentDataSource:task];

    [self startObservingUploadingTask:task];
    [task upload];
}

- (void)startObservingUploadingTask:(BJLChatUploadingTask *)task {
    bjl_weakify(self, task);

    [self bjl_kvo:BJLMakeProperty(task, state)
         observer:^BOOL(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self, task);
             [self updateCellWithUploadingTask:task];
             if (task.state == BJLUploadState_uploaded) {
                 [self sendMessageWithUploadingTask:task];
             }
             return YES;
         }];

    [self bjl_kvo:BJLMakeProperty(task, progress)
         observer:^BOOL(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self, task);
             [self updateCellWithUploadingTask:task];
             return YES;
         }];
}

- (void)updateCellWithUploadingTask:(BJLChatUploadingTask *)task {
    NSUInteger index = [self.currentDataSource indexOfObject:task];
    if (index == NSNotFound || self.currentDataSource.count <= 0) {
        return;
    }
    [self.tableView reloadData];
}

- (void)sendMessageWithUploadingTask:(BJLChatUploadingTask *)task {
    BJLUser *targetUser = (self.chatStatus == BJLChatStatus_private) ? self.targetUser : nil;
    NSDictionary *data = [BJLMessage messageDataWithImageURLString:task.result imageSize:task.imageSize];
    BJLError *error = [self.room.chatVM sendMessageData:data toUser:targetUser];
    if (error) {
        task.error = error;
        [self updateCellWithUploadingTask:task];
        [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
    }
}

- (void)backToVideo {
    if (self.backToVideoCallback) {
        self.backToVideoCallback();
    }
}

- (void)addSecretForbidMessage:(NSString *)messageString targetUser:(nullable BJLUser *)targetUser {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic bjl_setObject:[self.room.loginUser bjlyy_modelToJSONObject] forKey:@"from"];
    [dic bjl_setObject:messageString ?: @"" forKey:@"content"];
    [dic bjl_setObject:@([NSDate timeIntervalSinceReferenceDate]) forKey:@"time"];

    if (targetUser) {
        [dic bjl_setObject:[targetUser bjlyy_modelToJSONObject] forKey:@"to_user"];
    }
    BJLMessage *message = [BJLMessage bjlyy_modelWithDictionary:dic];
    [self addMessageToCurrentDataSource:message targetUserNumber:targetUser.number];

    if (!self || !self.isViewLoaded || !self.view.window || self.view.hidden) {
        return;
    }
    [self.unreadMessageArray removeAllObjects];
    [self updateEmptyViewHidden];
    [self.tableView reloadData];

    // 滑动到底部
    [self scrollToTheEndTableView];
}

#pragma mark - chatStatus

- (void)updateChatStatus:(BJLChatStatus)chatStatus withTargetUser:(nullable BJLUser *)targetUser {
    //    不管是切换到公聊or私聊，切换后， 都要清空只看老师/助教状态
    self.onlyShowTeacherOrAssistant = NO;

    self.chatStatus = chatStatus;
    self.targetUser = (chatStatus == BJLChatStatus_private) ? targetUser : nil;

    CGFloat statusViewHeight = 0.0;
    if (chatStatus == BJLChatStatus_private) {
        self.currentDataSource = [self.whisperMessageDict bjl_objectForKey:self.targetUser.number class:[NSMutableArray class]];
        NSString *tipLabel = BJLLocalizedString(@"私聊:");
        NSString *displayName = targetUser.displayName ?: @"---";
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", tipLabel, displayName]];
        [attributedString addAttribute:NSForegroundColorAttributeName value:BJLTheme.viewTextColor range:NSMakeRange(0, tipLabel.length)];
        [attributedString addAttribute:NSForegroundColorAttributeName value:BJLTheme.brandColor range:NSMakeRange(tipLabel.length, displayName.length)];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, tipLabel.length + displayName.length)];

        self.chatStatusLabel.attributedText = attributedString;
        statusViewHeight = 32.0;
        [self.cancelChatButton setTitle:BJLLocalizedString(@"取消私聊") forState:UIControlStateNormal];
        // 进入私聊时,请求历史消息
        [self loadWhisperHistoryList];

        // 私聊时才添加下拉控件
        if (!self.refreshControl) {
            self.refreshControl = [[BJLHeaderRefresh alloc] initWithTargrt:self action:@selector(loadWhisperHistoryList)];
            self.refreshControl.backgroundColor = [UIColor clearColor];
        }
    }
    else {
        [self showProgressHUDWithText:BJLLocalizedString(@"私聊已取消")];
        // 公聊时移除下拉控件
        if (self.refreshControl) {
            [self.refreshControl removeFromSuperview];
            self.refreshControl = nil;
        }
    }
    [self.chatStatusView bjl_updateConstraints:^(BJLConstraintMaker *make) {
        make.height.equalTo(@(statusViewHeight));
    }];

    [self updateCurrentDataSource];
    [self.tableView reloadData];
    [self scrollToTheEndTableView];
}

- (void)startPrivateChatWithTargetUser:(BJLUser *)targetUser {
    [self updateChatStatus:BJLChatStatus_private withTargetUser:targetUser];
    if (self.changeChatStatusCallback) {
        self.changeChatStatusCallback(BJLChatStatus_private, targetUser);
    }
}

- (void)cancelPrivateChat {
    if (self.chatStatus == BJLChatStatus_default) {
        // 取消只看老师/助教
        [self startOnlyShowTeacherOrAsisstantMessgae:NO];
    }
    else {
        // 取消私聊
        [self updateChatStatus:BJLChatStatus_default withTargetUser:nil];
    }

    if (self.changeChatStatusCallback) {
        self.changeChatStatusCallback(BJLChatStatus_default, nil);
    }
}

- (void)startOnlyShowTeacherOrAsisstantMessgae:(BOOL)show {
    self.onlyShowTeacherOrAssistant = show;
    CGFloat statusViewHeight = 0.0;
    if (self.chatStatus == BJLChatStatus_default && show) {
        self.currentDataSource = [self.whisperMessageDict bjl_objectForKey:self.targetUser.number class:[NSMutableArray class]];
        self.chatStatusLabel.text = [NSString stringWithFormat:BJLLocalizedString(@"已开启只看老师/助教")];
        statusViewHeight = 36.0;
        [self.cancelChatButton setTitle:BJLLocalizedString(@"取消") forState:UIControlStateNormal];
    }

    [self.chatStatusView bjl_updateConstraints:^(BJLConstraintMaker *make) {
        make.height.equalTo(@(statusViewHeight));
    }];

    [self updateCurrentDataSource];
    [self.tableView reloadData];
    [self scrollToTheEndTableView];
}

#pragma mark - dataSource

// 整体更新数据源
- (void)updateCurrentDataSource {
    // !!!: 私聊消息在不同的聊天状态下样式不同，在切换前需要清除高度缓存
    [self.tableView bjl_clearHeightCaches];

    // 切换数据源时清空
    if (self.chatStatus == BJLChatStatus_private) {
        self.currentDataSource = [self.whisperMessageDict bjl_objectForKey:self.targetUser.number class:[NSMutableArray class]] ?: [NSMutableArray array];
        [self.whisperMessageDict bjl_setObject:self.currentDataSource
                                        forKey:self.targetUser.number];
    }
    else {
        if (self.onlyShowTeacherOrAssistant) {
            self.currentDataSource = (NSMutableArray<id> *)self.teacherOrAssistantMessages;
        }
        else {
            self.currentDataSource = self.allMessages;
        }
    }
}

// 清空数据源
- (void)clearDataSource {
    [self.unreadMessages removeAllObjects];
    [self.imageMessages removeAllObjects];
    self.unreadMessagesCount = [self.unreadMessages count];
    [self.allMessages removeAllObjects];
    [self.whisperMessageDict removeAllObjects];
    [self.teacherOrAssistantMessages removeAllObjects];
    [self.tableView bjl_clearHeightCaches]; //清除高度缓存

    [self.whisperPageDict removeAllObjects];
    [self.whisperHasMoreDict removeAllObjects];
}

- (void)updateDataSourceWithRevokeMessageID:(NSString *)messageID {
    BJLMessage *targetMessage = nil;
    for (BJLMessage *message in [self.allMessages copy]) {
        if ([message isKindOfClass:[BJLMessage class]] && message && [message.ID isEqualToString:messageID]) {
            [self.allMessages bjl_removeObject:message];
            targetMessage = message;
            break;
        }
    }
    [self.teacherOrAssistantMessages bjl_removeObject:targetMessage];
    NSMutableArray<BJLMessage *> *whisperMessage = [[self.whisperMessageDict bjl_arrayForKey:targetMessage.toUser.number] mutableCopy];
    [whisperMessage bjl_removeObject:targetMessage];
    [self.whisperMessageDict bjl_setObject:whisperMessage forKey:targetMessage.toUser.number];
    [self updateCurrentDataSource];
}

// 增量更新 task
- (void)addTaskToCurrentDataSource:(BJLChatUploadingTask *)task {
    if (!task || ![task isKindOfClass:[BJLChatUploadingTask class]]) {
        return;
    }

    [self.currentDataSource bjl_addObject:task];

    if (self.chatStatus == BJLChatStatus_private) {
        [self.allMessages bjl_addObject:task];
    }
    [self.tableView reloadData];
    [self scrollToTheEndTableView];
}

// message 替换 task
- (void)replaceTask:(BJLChatUploadingTask *)task withMessage:(BJLMessage *)message {
    NSInteger index = [self.currentDataSource indexOfObject:task];
    [self.currentDataSource bjl_replaceObjectAtIndex:index withObject:message];
    if (self.chatStatus == BJLChatStatus_private) {
        // !!!: 私聊状态下，allMessages 也需要更新
        NSInteger indexInAll = [self.allMessages indexOfObject:task];
        [self.allMessages bjl_replaceObjectAtIndex:indexInAll withObject:message];
    }
    [self.tableView reloadData];
}

// 增量更新 messages
- (void)addMessageToCurrentDataSource:(BJLMessage *)message targetUserNumber:(nullable NSString *)targetUserNumber {
    [self.allMessages bjl_addObject:message];
    if (targetUserNumber.length > 0) {
        // 私聊消息
        NSMutableArray *whisperMessages = [self.whisperMessageDict bjl_objectForKey:targetUserNumber class:[NSMutableArray class]] ?: [NSMutableArray array];
        [whisperMessages bjl_addObject:message];
        [self.whisperMessageDict bjl_setObject:whisperMessages
                                        forKey:targetUserNumber];
    }
}

- (void)loadWhisperHistoryList {
    NSUInteger page = 0;

    // hasMore字典, 如果 whisperHasMoreDict 有当前私聊对象 并且 没有更多数据
    if ([self.whisperHasMoreDict.allKeys containsObject:self.targetUser.number]
        && ![self.whisperHasMoreDict bjl_boolForKey:self.targetUser.number]) {
        [self.refreshControl endRefreshing];
        //        [self showProgressHUDWithText:BJLLocalizedString(@"没有更多历史消息了")];
        return;
    }
    // page字典
    if ([self.whisperPageDict.allKeys containsObject:self.targetUser.number]) {
        page = [self.whisperPageDict bjl_integerForKey:self.targetUser.number] + 1;
    }
    [self.whisperPageDict bjl_setObject:@(page) forKey:self.targetUser.number];
    BJLError *error = [self.room.chatVM loadWhisperMessagesWithTargetUser:self.targetUser page:page];
    if (error) {
        [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
    }
}

#pragma mark - <UIContentContainer>

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    NSLog(@"%@ willTransitionToSizeClasses: %td-%td",
        NSStringFromClass([self class]),
        newCollection.horizontalSizeClass,
        newCollection.verticalSizeClass);

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        [self.tableView reloadData]; // 更改聊天背景色
    } completion:nil];
}

#pragma mark - tableView

- (void)setUpTableView {
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;

    self.tableView.allowsSelection = YES;

    for (NSString *cellIdentifier in [BJLScChatCell allCellIdentifiers]) {
        [self.tableView registerClass:[BJLScChatCell class]
               forCellReuseIdentifier:cellIdentifier];
    }

    self.tableView.contentInset = bjl_set(self.tableView.contentInset, {
        set.top = /* set.bottom = */ BJLScViewSpaceS;
    });
    self.tableView.scrollIndicatorInsets = bjl_set(self.tableView.contentInset, {
        set.top = /* set.bottom = */ BJLScViewSpaceS;
    });

    self.tableView.estimatedRowHeight = 44;

    if (@available(iOS 11.0, *)) {
        self.tableView.insetsContentViewsToSafeArea = NO;
    }
}

- (void)scrollToTheEndTableView {
    NSInteger section = 0;
    NSInteger numberOfRows = [self.tableView numberOfRowsInSection:section];
    if (numberOfRows <= 0) {
        return;
    }

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:numberOfRows - 1
                                                inSection:section];
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:NO];
}

- (BOOL)atTheTopOfTableView {
    CGFloat contentOffsetY = self.tableView.contentOffset.y;
    CGFloat top = self.tableView.contentInset.top;
    CGFloat topOffset = contentOffsetY + top;
    return topOffset >= 0.0 + BJLScViewSpaceS;
}

- (BOOL)atTheBottomOfTableView {
    CGFloat contentOffsetY = self.tableView.contentOffset.y;
    CGFloat bottom = self.tableView.contentInset.bottom;
    CGFloat viewHeight = CGRectGetHeight(self.tableView.frame);
    CGFloat contentHeight = self.tableView.contentSize.height;
    CGFloat bottomOffset = contentOffsetY + viewHeight - bottom - contentHeight;
    return bottomOffset >= 0.0 - BJLScViewSpaceS;
}

- (NSString *)keyWithIndexPath:(NSIndexPath *)indexPath message:(BJLMessage *)message taskMessage:(BJLChatUploadingTask *)task {
    NSString *key = @"";
    if (message) {
        key = [NSString stringWithFormat:@"%@-%@-%f", message.ID, message.fromUser.ID, message.timeInterval];
    }
    else if (task) {
        key = [NSString stringWithFormat:@"task:%@", task.imageFile.filePath];
    }
    return key;
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BJLMessage *message = bjl_as([self.currentDataSource bjl_objectAtIndex:indexPath.row], BJLMessage);
    BJLChatUploadingTask *task = bjl_as([self.currentDataSource bjl_objectAtIndex:indexPath.row], BJLChatUploadingTask);
    if (message) {
        NSString *cellIdentifier = [BJLScChatCell cellIdentifierForMessageType:message.type
                                                                hasTranslation:(!!message.translation.length)];
        BJLScChatCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                              forIndexPath:indexPath];

        BOOL isSender = self.room.loginUser.ID.length && [self.room.loginUser.ID isEqualToString:message.fromUser.ID];
        BJLUserGroup *groupInfo = nil;
        for (BJLUserGroup *group in self.room.onlineUsersVM.groupList) {
            if (message.fromUser.groupID == group.groupID) {
                groupInfo = group;
                break;
            }
        }
        [cell updatReferenceLabelLineNumber:[[self.expandDict objectForKey:@(indexPath.row)] integerValue]];
        [cell updateWithMessage:message
                    fromLoginUser:[message.fromUser.number isEqualToString:self.room.loginUser.number]
                     customString:[self customStringWithRole:message.fromUser.role]
                       chatStatus:self.chatStatus
                         isSender:isSender
                shouldHiddenPhone:[self shouldHiddenPhoneInMessage:message]
            enableChatTranslation:self.room.featureConfig.enableChatTranslation
              shouldShowGroupInfo:[self shouldShowGroupInfoWithMessage:message]
                        groupInfo:groupInfo
                        cellWidth:self.tableView.bounds.size.width];
        bjl_weakify(self);
        cell.linkURLCallback = cell.linkURLCallback ?: ^BOOL(BJLScChatCell *_Nullable cell, NSURL *_Nonnull url) {
            bjl_strongify(self);
            return [self openURL:url];
        };

        // 聊天菜单
        cell.longPressCallback = cell.longPressCallback ?: ^(BJLMessage *message, UIImage *_Nullable image, CGPoint pointInCell) {
            bjl_strongify(self);
            if (message) {
                [self showOperatorViewWithMessage:message
                                            point:[self.view convertPoint:pointInCell fromView:cell]
                                            image:image];
            }
        };

        [cell setUserSelectCallback:^(BJLScChatCell *_Nullable cell) {
            bjl_strongify(self);
            if (self.chatStatus == BJLChatStatus_private) {
                return;
            }

            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            BJLMessage *message = bjl_as([self.currentDataSource bjl_objectAtIndex:indexPath.row], BJLMessage);
            BJLUser *user = message.fromUser;
            CGPoint point = [self.view convertPoint:cell.iconImageView.center fromView:cell.iconImageView.superview];
            if (self.userSelectCallback) {
                self.userSelectCallback(user, point);
            }
        }];

        [cell setImageSelectCallback:^(BJLScChatCell *_Nullable cell) {
            bjl_strongify(self);
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            BJLMessage *message = bjl_as([self.currentDataSource bjl_objectAtIndex:indexPath.row], BJLMessage);
            if (message && message.type == BJLMessageType_image) {
                if (self.showImageViewCallback) self.showImageViewCallback(message, self.imageMessages, NO);
            }
        }];

        [cell setReloadCellCallback:^(BJLScChatCell *_Nullable cell, NSInteger line) {
            bjl_strongify(self);
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            if (indexPath) {
                [self.expandDict setObject:@(line) forKey:@(indexPath.row)];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }];
        [cell setTranslateCallback:^(BJLMessage *_Nonnull message, BOOL showingTranslate) {
            bjl_strongify(self);
            if (showingTranslate) {
                if (message.toType == self.chooseView.type) {
                    [message updateTranslationString:nil from:BJLMessageLanguageType_NONE to:BJLMessageLanguageType_NONE];
                    [self.tableView bjl_clearHeightCaches];
                    [self.tableView reloadData];
                    return;
                }
            }
            // 如果修改了目标翻译语言类型, 则会再请求翻译
            if (message && message.type == BJLMessageType_text && message.text.length) {
                NSString *messageUUID = [self keyForMessgaetranslation:message];
                [self startSendTimeRecording:message messageUUID:messageUUID];
                [self.currentTranslateCachesDict bjl_setObject:message forKey:messageUUID];
                BJLError *error = [self.room.chatVM translateMessage:message
                                                         messageUUID:messageUUID
                                                  targetLanguageType:self.chooseView.type];
                if (error) {
                    [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                }
            }
        }];
        return cell;
    }
    else { // if task
        NSString *cellIdentifier = [BJLScChatCell cellIdentifierForUploadingImage];
        BJLScChatCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                              forIndexPath:indexPath];
        if (task) {
            [cell updateWithUploadingTask:task
                               chatStatus:self.chatStatus
                                 fromUser:self.room.loginUser];
        }
        bjl_weakify(self);
        cell.retryUploadingCallback = cell.retryUploadingCallback ?: ^(BJLScChatCell *_Nullable cell) {
            bjl_strongify(self);
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            BJLChatUploadingTask *uploadingTask = bjl_as([self.currentDataSource bjl_objectAtIndex:indexPath.row], BJLChatUploadingTask);
            if (uploadingTask.error) {
                if (!uploadingTask.result) {
                    [uploadingTask upload];
                }
                else {
                    [self sendMessageWithUploadingTask:uploadingTask];
                }
            }
        };
        return cell;
    }
}

- (BOOL)shouldHiddenPhoneInMessage:(BJLMessage *)message {
    if ([message.fromUser.number isEqualToString:self.room.loginUser.number]) { return NO; }
    if (!self.room.featureConfig.enableStudentHiddenPhoneNumberMessage) { return NO; }
    if (message.fromUser.isStudent && self.room.loginUser.isStudent) { return YES; }
    return NO;
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BJLMessage *message = bjl_as([self.currentDataSource bjl_objectAtIndex:indexPath.row], BJLMessage);
    BJLChatUploadingTask *task = bjl_as([self.currentDataSource bjl_objectAtIndex:indexPath.row], BJLChatUploadingTask);

    NSString *key = [self keyWithIndexPath:indexPath message:message taskMessage:task];
    NSString *identifier;
    void (^configuration)(BJLScChatCell *cell); //用于计算 cell 高度的设置
    if (message) {
        identifier = [BJLScChatCell cellIdentifierForMessageType:message.type
                                                  hasTranslation:(!!message.translation.length)];
        bjl_weakify(self);
        configuration = ^(BJLScChatCell *cell) {
            bjl_strongify(self);
            cell.bjl_autoSizing = YES;
            BOOL isSender = self.room.loginUser.ID.length && [self.room.loginUser.ID isEqualToString:message.fromUser.ID];
            BJLUserGroup *groupInfo = nil;
            for (BJLUserGroup *group in self.room.onlineUsersVM.groupList) {
                if (message.fromUser.groupID == group.groupID) {
                    groupInfo = group;
                    break;
                }
            }
            [cell updateWithMessage:message
                        fromLoginUser:[message.fromUser.number isEqualToString:self.room.loginUser.number]
                         customString:[self customStringWithRole:message.fromUser.role]
                           chatStatus:self.chatStatus
                             isSender:isSender
                    shouldHiddenPhone:[self shouldHiddenPhoneInMessage:message]
                enableChatTranslation:self.room.featureConfig.enableChatTranslation
                  shouldShowGroupInfo:[self shouldShowGroupInfoWithMessage:message]
                            groupInfo:groupInfo
                            cellWidth:self.tableView.bounds.size.width];
        };
        if (message.reference) {
            return UITableViewAutomaticDimension;
        }
    }
    else if (task) {
        identifier = [BJLScChatCell cellIdentifierForUploadingImage];
        bjl_weakify(self);
        configuration = ^(BJLScChatCell *cell) {
            bjl_strongify(self);
            cell.bjl_autoSizing = YES;
            [cell updateWithUploadingTask:task
                               chatStatus:self.chatStatus
                                 fromUser:self.room.loginUser];
        };
    }
    return [tableView bjl_cellHeightWithKey:key identifier:identifier configuration:configuration];
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!scrollView.dragging && !scrollView.decelerating) {
        return;
    }
    if (self.unreadMessagesCount
        && [self atTheBottomOfTableView]) {
        [self loadUnreadMessages];
        // NO [self scrollToTheEndOf...];
    }
}

#pragma mark - <UIPopoverPresentationControllerDelegate>

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection {
    return UIModalPresentationNone;
}

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    [self hideLanguageChooseViewContrller];
}

#pragma mark - command Lottery
- (void)makeCommandLotteryView {
    // 倒计时
    if (self.countDownView) {
        [self.countDownView removeFromSuperview];
        self.countDownView = nil;
    }
    self.countDownView = [[BJLScCommandCountDownView alloc] initWithDuration:self.commandLottery.duration];
    [self.view addSubview:self.countDownView];
    [self.countDownView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.tableView);
        make.bottom.equalTo(self.tableView).offset(-5);
        make.height.width.equalTo(@44);
    }];

    if (self.commandLotteryView) {
        [self.commandLotteryView removeFromSuperview];
        self.commandLotteryView = nil;
    }
    self.commandLotteryView = [[BJLScCommandLotteryView alloc] initWithCommand:self.commandLottery.command];
    [self.view addSubview:self.commandLotteryView];
    [self.commandLotteryView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.countDownView.bjl_right).offset(5);
        make.bottom.equalTo(self.chatInputView.bjl_top).offset(-2);
        make.size.equal.sizeOffset(self.commandLotteryView.expectSize);
    }];

    bjl_weakify(self);
    UITapGestureRecognizer *tap = [UITapGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer *_Nullable gesture) {
        bjl_strongify(self);
        [self removeCommandLotteryView];
        [self.chatInputButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        if (self.tapCommandLotteryCallback) {
            self.tapCommandLotteryCallback(self.commandLottery);
        }
    }];
    [self.commandLotteryView addGestureRecognizer:tap];

    [self.countDownView setCountOverCallback:^{
        bjl_strongify(self);
        [self removeCommandLotteryView];
        [self removeCountdownView];
    }];
}

- (void)removeCommandLotteryView {
    [self.commandLotteryView removeFromSuperview];
    self.commandLotteryView = nil;
}

- (void)removeCountdownView {
    [self.countDownView destory];
    [self.countDownView removeFromSuperview];
    self.countDownView = nil;
    self.commandLottery = nil;
}

#pragma mark - sticky

- (BOOL)openURL:(NSURL *)url {
    BOOL shouldOpen = NO;
    NSString *scheme = url.scheme.lowercaseString;
    if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
        SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:url];
        if (self.presentedViewController) {
            [self.presentedViewController bjl_dismissAnimated:YES completion:nil];
        }
        [self bjl_presentFullScreenViewController:safari animated:YES completion:nil];
    }
    else if ([scheme hasPrefix:@"bjhl"]) {
        shouldOpen = YES;
    }
    else {
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:BJLLocalizedString(@"不支持打开此链接")
                             message:nil
                      preferredStyle:UIAlertControllerStyleAlert];
        [alert bjl_addActionWithTitle:BJLLocalizedString(@"知道了")
                                style:UIAlertActionStyleCancel
                              handler:nil];
        if (self.presentedViewController) {
            [self.presentedViewController bjl_dismissAnimated:YES completion:nil];
        }
        [self presentViewController:alert animated:YES completion:nil];
    }
    return shouldOpen;
}

- (void)udpateStickyMessageView {
    NSArray<BJLMessage *> *stickyMessageList = self.room.chatVM.stickyMessageList;
    self.stickyMessageView.hidden = stickyMessageList.count > 0 ? NO : YES;

    // 缩略展示置顶消息
    if (stickyMessageList.count > 0) {
        [self.chatStatusView bjl_updateConstraints:^(BJLConstraintMaker *make) {
            [self.chatStatusTopConstraint uninstall];
            self.chatStatusTopConstraint = make.top.equalTo(self.stickyMessageView.bjl_bottom).constraint;
        }];
        [self.stickyMessageView updateStickyMessageList:stickyMessageList];
    }
    else {
        // 无置顶消息
        [self.chatStatusView bjl_updateConstraints:^(BJLConstraintMaker *make) {
            [self.chatStatusTopConstraint uninstall];
            self.chatStatusTopConstraint = make.top.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view).constraint;
        }];
        self.stickyMessageView.showCompleteMessage = NO;
    }
}

#pragma mark - getters

- (BOOL)is1V1Class {
    return self.room.roomInfo.roomType == BJLRoomType_1v1Class;
}

- (NSMutableDictionary<NSString *, NSMutableArray *> *)whisperMessageDict {
    if (!_whisperMessageDict) {
        _whisperMessageDict = [[NSMutableDictionary alloc] init];
    }
    return _whisperMessageDict;
}

- (NSMutableArray<BJLMessage *> *)teacherOrAssistantMessages {
    if (!_teacherOrAssistantMessages) {
        _teacherOrAssistantMessages = [NSMutableArray new];
    }
    return _teacherOrAssistantMessages;
}

- (nullable NSString *)customStringWithRole:(BJLUserRole)role {
    switch (role) {
        case BJLUserRole_teacher:
            return self.room.featureConfig.teacherLabel ?: BJLLocalizedString(@"老师");

        case BJLUserRole_assistant:
            return self.room.featureConfig.assistantLabel ?: BJLLocalizedString(@"助教");

        default:
            return nil;
    }
}

- (BOOL)shouldShowGroupInfoWithMessage:(BJLMessage *)message {
    BJLUserGroup *groupInfo = nil;
    for (BJLUserGroup *group in self.room.onlineUsersVM.groupList) {
        if (message.fromUser.groupID == group.groupID) {
            groupInfo = group;
            break;
        }
    }
    BOOL shouldShowGroupInfo = self.room.featureConfig.enableShowMessageGroupInfo
                               && self.room.loginUser.isTeacherOrAssistant
                               && (message.fromUser.isStudent || (message.fromUser.isTeacherOrAssistant && !message.fromUser.noGroup))
                               && groupInfo;
    return shouldShowGroupInfo;
}

@end
