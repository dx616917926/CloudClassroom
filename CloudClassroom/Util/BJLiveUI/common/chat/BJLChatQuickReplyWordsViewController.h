//
//  BJLChatQuickReplyWordsViewController.h
//  BJLiveUIBigClass
//
//  Created by HuXin on 2021/9/17.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveCore/BJLiveCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLChatQuickReplyWordsViewController: UIViewController

@property (nonatomic, copy, nullable) void (^didSelectedWordCallback)(BJLChatQuickReplyWordsViewController *vc, NSString *word);

- (instancetype)initWithRoom:(BJLRoom *)room;
@end

NS_ASSUME_NONNULL_END
