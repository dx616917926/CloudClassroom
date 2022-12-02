//
//  BJLRouteTableViewCell.h
//  BJLiveUIBigClass
//
//  Created by HuXin on 2021/11/30.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLCDNListCell: UITableViewCell
@property (nonatomic) UIImageView *selectedImageView;

- (void)updateRouteLabel:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
