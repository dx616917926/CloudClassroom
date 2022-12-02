//
//  BJPChatMessageTableViewCell.h
//  BJPlaybackUI
//
//  Created by 辛亚鹏 on 2017/8/23.
//
//

#import <UIKit/UIKit.h>
#import <BJVideoPlayerCore/BJVRoom.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJPChatMessageTableViewCell: UITableViewCell

@property (nonatomic, readonly) UIImageView *imgView;
@property (nonatomic, copy, nullable) void (^updateCellConstraintsCallback)(BJPChatMessageTableViewCell *_Nullable cell);

+ (NSArray<NSString *> *)allCellIdentifiers;
+ (NSString *)cellIdentifierForMessageType:(BJVMessageType)type;
+ (CGFloat)estimatedRowHeightForMessageType:(BJVMessageType)type;

- (void)updateWithMessage:(BJVMessage *)message
              placeholder:(nullable UIImage *)placeholder
           tableViewWidth:(CGFloat)tableViewWidth
        shouldHiddenPhone:(BOOL)hidden;

@end

NS_ASSUME_NONNULL_END
