//
//  BJLMediaCheckBaseView.h
//  BJLiveUIBase
//
//  Created by xijia dai on 2021/10/26.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveBase/BJLError.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLMediaDeviceCell: UITableViewCell

- (void)updateName:(NSString *)name selected:(BOOL)selected;

@end

@interface BJLMediaCheckBaseView: UIView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UIViewController *parentViewController;
@property (nonatomic) UILabel *tipLabel;
@property (nonatomic) UIButton *arrowButton;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) UILabel *checkLabel;
@property (nonatomic) UIButton *opposeButton, *confirmButton;

- (NSArray *)dataSource;
- (void)makeCheckedViewWithTitle:(NSString *)title
                  confirmMessage:(NSString *)confirmMessage
                   confirmHander:(void (^)(UIButton *button))confirmHander
                   opposeMessage:(NSString *)oppseMessage
                    opposeHander:(void (^)(UIButton *button))opposeHander
                           error:(nullable BJLError *)error;

@end

NS_ASSUME_NONNULL_END
