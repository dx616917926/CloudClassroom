//
//  BJLScUserCell.h
//  BJLiveUI
//
//  Created by xijia dai on 2019/9/23.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveCore/BJLiveCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLScUserCell: UITableViewCell

@property (nonatomic, readonly) UIImageView *avatarImageView;
@property (nonatomic, readonly) UIButton *likeButton;

@property (nonatomic, strong) void (^likeEventHandlerBlock)(BJLScUserCell *cell, UIButton *likeButton);

- (void)updateWithUser:(BJLUser *)user
              roleName:(nullable NSString *)roleName
             isSubCell:(BOOL)isSubCell
             likeCount:(NSInteger)likeCount
        hideLikeButton:(BOOL)hideLikeButton;

@end

NS_ASSUME_NONNULL_END
