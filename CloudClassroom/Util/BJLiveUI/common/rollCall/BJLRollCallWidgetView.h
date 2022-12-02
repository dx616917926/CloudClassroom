//
//  BJLRollCallWidgetView.m
//  BJLiveUI
//
//  Created by Ney on 1/12/21.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BJLiveCore/BJLRollCallResult.h>

@interface BJLRollCallStartView: UIView
@property (nonatomic, readonly) NSInteger time;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIStackView *timeOptionsStackView;
@property (nonatomic, strong) UIButton *startRollCallButton;
@end

@interface BJLRollCallCountdownTimerView: UIView
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;

- (void)updateTime:(NSInteger)time;
@end

@interface BJLRollCallResultItemCell: UITableViewCell
@property (nonatomic, strong) UILabel *nameLabel;
- (void)updateData:(BJLRollCallResultItem *)data;
@end

@interface BJLRollCallResultView: UIView <UITableViewDataSource>
@property (nonatomic, strong) CAShapeLayer *ackListTabMaskLayer;
@property (nonatomic, strong) CAShapeLayer *ackListTabBorderLayer;
@property (nonatomic, strong) UIButton *ackListTabButton;

@property (nonatomic, strong) CAShapeLayer *nackListTabMaskLayer;
@property (nonatomic, strong) CAShapeLayer *nackListTabBorderLayer;
@property (nonatomic, strong) UIButton *nackListTabButton;

@property (nonatomic, strong) UITableView *ackListTableView;
@property (nonatomic, strong) UITableView *nackListTableView;

@property (nonatomic, strong) UIImageView *emptyDataImageView;
@property (nonatomic, strong) UILabel *emptyDataLabel;

@property (nonatomic, strong) UIButton *rollCallAgainButton;

@property (nonatomic, strong) BJLRollCallResult *result;

- (void)updateRollCallResult:(BJLRollCallResult *)result;
- (void)updateCooldownRemainTime:(NSInteger)cooldownRemainTime;
@end
