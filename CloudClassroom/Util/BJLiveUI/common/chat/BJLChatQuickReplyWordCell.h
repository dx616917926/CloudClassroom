//
//  BJLChatQuickReplyWordCell.h
//  BJLiveUIBigClass
//
//  Created by HuXin on 2021/9/17.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLChatQuickReplyWordCell: UICollectionViewCell
@property (nonatomic) UILabel *replyWordLabel;

- (void)updateReplyWordWithString:(NSString *)string;
@end

NS_ASSUME_NONNULL_END
