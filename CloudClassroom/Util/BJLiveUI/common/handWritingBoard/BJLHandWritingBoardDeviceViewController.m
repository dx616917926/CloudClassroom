//
//  BJLHandWritingBoardDeviceViewController.m
//  BJLiveUI
//
//  Created by xijia dai on 2021/5/27.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

#import "BJLHandWritingBoardDeviceViewController.h"
#import "BJLAppearance.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark -

@interface BJLHandWritingBoardDeviceInfo () <BJLYYModel>
@property (nonatomic, readwrite) NSString *identifier;
@property (nonatomic, readwrite, nullable) NSString *name;
@property (nonatomic, readwrite) NSTimeInterval lastTimestamp;
@end

@implementation BJLHandWritingBoardDeviceInfo
@end

#pragma mark -

NSString *const CBCellReuseIdentifier = @"CBCellReuseIdentifier";

@interface BJLHandWritingBoardTableViewCell: UITableViewCell

@property (nonatomic) UILabel *nameLabel, *stateLabel;
@property (nonatomic) UIImageView *stateImageView; // 已连接
@property (nonatomic) UIActivityIndicatorView *loadingIndicator; // 连接中

@end

@implementation BJLHandWritingBoardTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self makeSubviews];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.nameLabel.text = nil;
    self.stateLabel.text = nil;
    [self.loadingIndicator stopAnimating];
    self.stateImageView.hidden = YES;
}

- (void)makeSubviews {
    self.backgroundColor = BJLTheme.windowBackgroundColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    UIView *backgroundView = [UIView new];
    backgroundView.layer.cornerRadius = 4.0;
    backgroundView.layer.masksToBounds = YES;
    backgroundView.accessibilityIdentifier = @"backgroundView";
    backgroundView.backgroundColor = [BJLTheme.statusBackgroungColor colorWithAlphaComponent:0.2];
    [self.contentView addSubview:backgroundView];
    [backgroundView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(10.0, 10.0, 0.0, 10.0));
    }];
    self.nameLabel = ({
        UILabel *label = [UILabel new];
        label.accessibilityIdentifier = BJLKeypath(self, nameLabel);
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = BJLTheme.viewTextColor;
        label.font = [UIFont systemFontOfSize:14.0];
        label;
    });
    [backgroundView addSubview:self.nameLabel];
    [self.nameLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.bottom.equalTo(backgroundView);
        make.left.equalTo(backgroundView.bjl_left).offset(10.0);
        make.right.lessThanOrEqualTo(backgroundView).offset(-30.0);
    }];
    self.stateLabel = ({
        UILabel *label = [UILabel new];
        label.accessibilityIdentifier = BJLKeypath(self, stateLabel);
        label.textAlignment = NSTextAlignmentRight;
        label.textColor = BJLTheme.viewSubTextColor;
        label.font = [UIFont systemFontOfSize:12.0];
        label;
    });
    [backgroundView addSubview:self.stateLabel];
    [self.stateLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.greaterThanOrEqualTo(self.nameLabel.bjl_right);
        make.top.bottom.equalTo(backgroundView);
        make.right.equalTo(backgroundView.bjl_right).offset(-10.0);
        make.compressionResistance.hugging.required();
    }];
    self.stateImageView = ({
        UIImageView *imageView = [UIImageView new];
        imageView.hidden = YES;
        imageView.image = [UIImage bjl_imageNamed:@"bjl_bluetooth_connected"];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView;
    });
    [backgroundView addSubview:self.stateImageView];
    [self.stateImageView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.equalTo(backgroundView).offset(-6.0);
        make.centerY.equalTo(backgroundView);
        make.width.height.equalTo(@24.0);
    }];

    self.loadingIndicator = ({
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:BJLTheme.themeStyle == BJLThemeStyle_light
                                                                                                                 ? UIActivityIndicatorViewStyleGray
                                                                                                                 : UIActivityIndicatorViewStyleWhite];
        indicator.hidden = YES;
        indicator;
    });
    [backgroundView addSubview:self.loadingIndicator];
    [self.loadingIndicator bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.stateImageView);
    }];
}

- (void)updateWithDevice:(BJLHandWritingBoardDeviceInfo *)device state:(CBPeripheralState)state ignoreState:(BOOL)ignoreState {
    self.nameLabel.text = device.name;
    //    self.nameLabel.text = [self.nameLabel.text stringByAppendingString:[NSString stringWithFormat:@"-%@", device.identifier]];
    [self.loadingIndicator startAnimating];
    NSString *stateString = @"";
    switch (state) {
        case CBPeripheralStateConnected: {
            self.stateImageView.hidden = NO;
            [self.loadingIndicator stopAnimating];
            break;
        }

        case CBPeripheralStateConnecting: {
            self.stateImageView.hidden = YES;
            [self.loadingIndicator startAnimating];
            break;
        }

        default: {
            stateString = ignoreState ? nil : BJLLocalizedString(@"未连接");
            self.stateImageView.hidden = YES;
            [self.loadingIndicator stopAnimating];
            break;
        }
    }
    self.stateLabel.text = stateString;
}

@end

#pragma mark -

NSString *const BJLHandWritingBoardDeviceInfoKey = @"BJLHandWritingBoardDeviceInfoKey";
const NSInteger autoConnectTime = 10;
const NSInteger maxDeviceInfos = 5;

/** 蓝牙连接列表 */
@interface BJLHandWritingBoardDeviceViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) BJLRoom *room;

#pragma mark - device

@property (nonatomic, nullable) CBPeripheral *connetedPeripheral, *connectingPeripheral;
@property (nonatomic) NSMutableArray<BJLHandWritingBoardDeviceInfo *> *prevConnectedDeviceInfos; // 以前连接过的设备
@property (nonatomic) NSMutableArray<BJLHandWritingBoardDeviceInfo *> *availableDeviceInfos; // 连接过的设备
@property (nonatomic) NSMutableArray<BJLHandWritingBoardDeviceInfo *> *otherDeviceInfos; // 未连接过的设备
@property (nonatomic) UIView *tableViewHeaderView;

#pragma mark - auto connnect

@property (nonatomic) BOOL autoConnectDevice;
@property (nonatomic) NSInteger reconnectCount;
@property (nonatomic, nullable) void (^completion)(BOOL success);

@end

@implementation BJLHandWritingBoardDeviceViewController

+ (nullable BJLHandWritingBoardDeviceInfo *)prevConnectedWritingBoard {
    NSArray *json = [NSUserDefaults.standardUserDefaults arrayForKey:BJLHandWritingBoardDeviceInfoKey];
    NSArray<BJLHandWritingBoardDeviceInfo *> *deviceInfos = [NSArray bjlyy_modelArrayWithClass:BJLHandWritingBoardDeviceInfo.class json:json];
    return deviceInfos.firstObject;
}

- (instancetype)initWithRoom:(BJLRoom *)room {
    if (self = [super init]) {
        self.room = room;
        self.availableDeviceInfos = [NSMutableArray new];
        self.otherDeviceInfos = [NSMutableArray new];
        self.prevConnectedDeviceInfos = [NSMutableArray new];
        [self generatePrevConnectedDeviceInfos];
        [self makeObserving];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.completion = nil;
    [self.availableDeviceInfos removeAllObjects];
    [self.otherDeviceInfos removeAllObjects];
    [self reloadTableView];
    [self.room.drawingVM scanHandWritingBoard];
}

- (void)makeSubviews {
    self.view.backgroundColor = BJLTheme.windowBackgroundColor;
    UIView *topBar = [UIView new];
    [self.view addSubview:topBar];
    [topBar bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(@32.0);
    }];

    UILabel *titleLabel = ({
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = BJLTheme.viewTextColor;
        label.font = [UIFont systemFontOfSize:14.0];
        label.text = BJLLocalizedString(@"蓝牙设备");
        label;
    });
    [topBar addSubview:titleLabel];
    [titleLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(topBar).offset(10.0);
        make.top.bottom.equalTo(topBar);
    }];

    UIButton *closeButton = ({
        UIButton *button = [UIButton new];
        [button setImage:[UIImage bjl_imageNamed:@"window_close_gray"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [topBar addSubview:closeButton];
    [closeButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.equalTo(topBar).offset(-10.0);
        make.top.bottom.equalTo(topBar);
        make.width.equalTo(topBar.bjl_height);
    }];

    UIView *topGapLine = [UIView bjl_createSeparateLine];
    [self.view addSubview:topGapLine];
    [topGapLine bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.bottom.left.right.equalTo(topBar);
        make.height.equalTo(@(BJLScOnePixel));
    }];

    [self.tableView removeFromSuperview];
    self.tableView.rowHeight = 46.0;
    self.tableView.backgroundColor = BJLTheme.windowBackgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[BJLHandWritingBoardTableViewCell class] forCellReuseIdentifier:CBCellReuseIdentifier];
    [self.view addSubview:self.tableView];
    [self.tableView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(topBar.bjl_bottom);
        make.bottom.left.right.equalTo(self.view);
    }];

    self.tableViewHeaderView = [self makeHeaderView];
}

- (void)makeObserving {
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self.room.drawingVM, availableHandWritingBoards)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             [self.availableDeviceInfos removeAllObjects];
             [self.otherDeviceInfos removeAllObjects];
             // 连接中和已连接的设备蓝牙搜索不会回调
             if (self.connetedPeripheral) {
                 BJLHandWritingBoardDeviceInfo *info = [self deviceInfoWithPeripheral:self.connetedPeripheral];
                 if (![self.availableDeviceInfos containsObject:info]) {
                     [self.availableDeviceInfos bjl_addObject:info];
                 }
             }
             if (self.connectingPeripheral) {
                 BJLHandWritingBoardDeviceInfo *info = [self deviceInfoWithPeripheral:self.connectingPeripheral];
                 if (![self.availableDeviceInfos containsObject:info]) {
                     [self.availableDeviceInfos bjl_addObject:info];
                 }
             }
             NSArray<CBPeripheral *> *allDevices = [self.room.drawingVM.availableHandWritingBoards mutableCopy];
             for (CBPeripheral *device in allDevices) {
                 BJLHandWritingBoardDeviceInfo *info = [self deviceInfoWithPeripheral:device];
                 if ([self.prevConnectedDeviceInfos containsObject:info]) {
                     if (![self.availableDeviceInfos containsObject:info]) {
                         [self.availableDeviceInfos bjl_addObject:info];
                     }
                 }
                 else {
                     [self.otherDeviceInfos bjl_addObject:info];
                 }
             }
             [self sortDevices];
             if (self.autoConnectDevice) {
                 [self connectHandWritingBoardWaitingForScanFinish:YES];
             }
             [self reloadTableView];
             return YES;
         }];
    [self bjl_kvo:BJLMakeProperty(self.room.drawingVM, connectedHandWritingBoard)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             if (self.connectingPeripheral) {
                 self.connectingPeripheral = nil;
             }
             self.connetedPeripheral = self.room.drawingVM.connectedHandWritingBoard;
             // 连接完成
             if (self.connetedPeripheral) {
                 // 添加为记录的设备
                 [self updatePrevConnectedDeviceInfosWithDeviceInfo:[self deviceInfoWithPeripheral:self.connetedPeripheral] remove:NO];
                 // 重置自动重连次数
                 self.reconnectCount = 0;
                 // 回调自动连接的 block
                 if (self.completion) {
                     self.completion(YES);
                     self.completion = nil;
                 }
             }
             [self reloadTableView];
             return YES;
         }];
    [self bjl_kvo:BJLMakeProperty(self.room.drawingVM, scanfindSameDevice)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             if (self.autoConnectDevice && self.room.drawingVM.scanfindSameDevice) {
                 [self connectHandWritingBoardWaitingForScanFinish:NO];
             }
             return YES;
         }];
    [self bjl_observe:BJLMakeMethod(self.room.drawingVM, handWritingBoardDidConnectFailed:)
             observer:^BOOL(CBPeripheral *peripheral) {
                 bjl_strongify(self);
                 // 连接过程中连接失败
                 if (self.connectingPeripheral) {
                     if (self.connectFailedCallback) {
                         self.connectFailedCallback();
                     }
                     self.connectingPeripheral = nil;
                     // 连接失败，清空回调 block
                     [self.room.drawingVM stopScanHandWritingBoard];
                     self.completion = nil;
                     [self reloadTableView];
                 }
                 // 连接完成后断开
                 else if (self.connetedPeripheral) {
                     [self tryToReconnectWithCurrentDevice];
                 }
                 return YES;
             }];
    [self bjl_kvo:BJLMakeProperty(self.room.drawingVM, connectedDeviceSleep)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             // 设备休眠
             if (self.room.drawingVM.connectedDeviceSleep && self.dormantCallback) {
                 self.dormantCallback();
             }
             return YES;
         }];
}

#pragma mark - auto connect

- (void)autoConnectIfFindPrevConnectedDevice:(void (^__nullable)(BOOL success))completion {
    if (!self.prevConnectedDeviceInfos.count) {
        if (completion) {
            completion(NO);
        }
    }
    [self.room.drawingVM scanHandWritingBoard];
    self.completion = completion;
    self.autoConnectDevice = YES;
    // 连接超时，回调自动连接的 block
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(autoConnectTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.autoConnectDevice = NO;
        if (self.completion) {
            self.completion(NO);
            self.completion = nil;
        }
    });
}

// waitingForScanFinish 为 YES 时，仅连接最近一次连接的手写板，为 NO 时，只要连接过的手写板就去自动连接
- (BOOL)connectHandWritingBoardWaitingForScanFinish:(BOOL)waitingForScanFinish {
    if (!self.availableDeviceInfos.count) {
        return NO;
    }
    self.autoConnectDevice = NO;
    BJLHandWritingBoardDeviceInfo *deviceInfo = self.availableDeviceInfos.firstObject;
    [self.availableDeviceInfos bjl_removeObject:deviceInfo];
    if (waitingForScanFinish) {
        if ([deviceInfo.identifier isEqualToString:self.prevConnectedDeviceInfos.firstObject.identifier]) {
            [self connectWithDeviceInfo:deviceInfo];
        }
    }
    else {
        [self connectWithDeviceInfo:deviceInfo];
    }
    return YES;
}

#pragma mark - reconnnect

- (void)tryToReconnectWithCurrentDevice {
    if (self.reconnectCount > 10) {
        if (self.connectFailedCallback) {
            self.connectFailedCallback();
        }
        self.reconnectCount = 0;
        return;
    }
    self.reconnectCount++;
    [self.room.drawingVM connectHandWritingBoard:self.connetedPeripheral];
}

#pragma mark - device info

- (void)generatePrevConnectedDeviceInfos {
    NSArray *json = [NSUserDefaults.standardUserDefaults arrayForKey:BJLHandWritingBoardDeviceInfoKey];
    NSArray<BJLHandWritingBoardDeviceInfo *> *deviceInfos = [NSArray bjlyy_modelArrayWithClass:BJLHandWritingBoardDeviceInfo.class json:json];
    if (deviceInfos) {
        self.prevConnectedDeviceInfos = [deviceInfos mutableCopy];
    }
}

- (void)updatePrevConnectedDeviceInfosWithDeviceInfo:(BJLHandWritingBoardDeviceInfo *)deviceInfo remove:(BOOL)remove {
    for (BJLHandWritingBoardDeviceInfo *info in [self.prevConnectedDeviceInfos copy]) {
        if ([deviceInfo.identifier isEqualToString:info.identifier]) {
            [self.prevConnectedDeviceInfos bjl_removeObject:info];
            break;
        }
    }
    if (!remove && deviceInfo) {
        deviceInfo.lastTimestamp = BJLTimeIntervalSince1970();
        [self.prevConnectedDeviceInfos bjl_insertObject:deviceInfo atIndex:0];
    }
    while (self.prevConnectedDeviceInfos.count > 5) {
        [self.prevConnectedDeviceInfos removeLastObject];
    }
    if (self.prevConnectedDeviceInfos.count) {
        NSArray *json = [self.prevConnectedDeviceInfos bjlyy_modelToJSONObject];
        [NSUserDefaults.standardUserDefaults setObject:json forKey:BJLHandWritingBoardDeviceInfoKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:BJLHandWritingBoardDeviceInfoKey];
    }
}

- (void)disConnectCurrentConnectedDevice {
    [self updatePrevConnectedDeviceInfosWithDeviceInfo:[self deviceInfoWithPeripheral:self.connetedPeripheral] remove:YES];
    [self.room.drawingVM disconnectHandWritingBoard];
}

- (void)sortDevices {
    [self.availableDeviceInfos sortUsingComparator:^NSComparisonResult(BJLHandWritingBoardDeviceInfo *_Nonnull obj1, BJLHandWritingBoardDeviceInfo *_Nonnull obj2) {
        return obj1.lastTimestamp > obj2.lastTimestamp ? NSOrderedAscending : NSOrderedDescending;
    }];
    [self.otherDeviceInfos sortUsingComparator:^NSComparisonResult(BJLHandWritingBoardDeviceInfo *_Nonnull obj1, BJLHandWritingBoardDeviceInfo *_Nonnull obj2) {
        switch ([obj1.identifier compare:obj2.identifier]) {
            case NSOrderedDescending:
                return NSOrderedDescending;
            default:
                return NSOrderedAscending;
        }
    }];
}

#pragma mark - internal

- (void)reloadTableView {
    if (!self || !self.isViewLoaded || !self.view.window || self.view.hidden) {
        return;
    }
    bjl_dispatch_on_main_queue(^{
        [self.tableView reloadData];
    });
}

- (void)close {
    [self.room.drawingVM stopScanHandWritingBoard];
    [self bjl_removeFromParentViewControllerAndSuperiew];
}

- (void)connectWithDeviceInfo:(BJLHandWritingBoardDeviceInfo *)deviceInfo {
    [self.availableDeviceInfos bjl_insertObject:deviceInfo atIndex:0];
    self.connectingPeripheral = [self peripheralWithDeviceInfo:deviceInfo];
    [self.room.drawingVM connectHandWritingBoard:self.connectingPeripheral];
}

#pragma mark - data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    if (section == 0) {
        count = self.availableDeviceInfos.count;
    }
    else if (section == 1) {
        count = self.otherDeviceInfos.count;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BJLHandWritingBoardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CBCellReuseIdentifier forIndexPath:indexPath];
    BJLHandWritingBoardDeviceInfo *deviceInfo = nil;
    if (indexPath.section == 0) {
        deviceInfo = [self.availableDeviceInfos bjl_objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 1) {
        deviceInfo = [self.otherDeviceInfos bjl_objectAtIndex:indexPath.row];
    }
    CBPeripheral *peripheral = [self peripheralWithDeviceInfo:deviceInfo];
    if (!peripheral) {
        if ([deviceInfo.identifier isEqualToString:self.connetedPeripheral.identifier.UUIDString]) {
            peripheral = self.connetedPeripheral;
        }
        if ([deviceInfo.identifier isEqualToString:self.connectingPeripheral.identifier.UUIDString]) {
            peripheral = self.connectingPeripheral;
        }
    }
    [cell updateWithDevice:deviceInfo state:peripheral.state ignoreState:(indexPath.section == 1)];
    return cell;
}

#pragma mark - delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    BJLHandWritingBoardDeviceInfo *deviceInfo = nil;
    if (indexPath.section == 0) {
        deviceInfo = [self.availableDeviceInfos bjl_objectAtIndex:indexPath.row];
        [self.availableDeviceInfos bjl_removeObject:deviceInfo];
    }
    else if (indexPath.section == 1) {
        deviceInfo = [self.otherDeviceInfos bjl_objectAtIndex:indexPath.row];
        [self.otherDeviceInfos bjl_removeObject:deviceInfo];
    }
    [self connectWithDeviceInfo:deviceInfo];
    [self reloadTableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section != 1) {
        return 0.0;
    }
    return 28.0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return self.tableViewHeaderView;
    }
    return nil;
}

- (UIView *)makeHeaderView {
    UIView *headerView = [UIView new];
    UILabel *label = ({
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = BJLTheme.viewSubTextColor;
        label.font = [UIFont systemFontOfSize:12.0];
        label.text = BJLLocalizedString(@"其他设备");
        label;
    });
    [headerView addSubview:label];
    [label bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.bottom.equalTo(headerView);
        make.left.top.equalTo(headerView).offset(10.0);
    }];
    UIActivityIndicatorView *indicatorView = ({
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:BJLTheme.themeStyle == BJLThemeStyle_light
                                                                                                                 ? UIActivityIndicatorViewStyleGray
                                                                                                                 : UIActivityIndicatorViewStyleWhite];
        [indicator startAnimating];
        indicator.hidesWhenStopped = NO;
        indicator;
    });
    [headerView addSubview:indicatorView];
    [indicatorView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(label.bjl_right).offset(4.0);
        make.top.bottom.equalTo(label);
        make.width.equalTo(indicatorView.bjl_height);
    }];
    return headerView;
}

#pragma mark -

- (nullable BJLHandWritingBoardDeviceInfo *)devices:(NSArray<BJLHandWritingBoardDeviceInfo *> *)devices containPeripheral:(CBPeripheral *)peripheral {
    BJLHandWritingBoardDeviceInfo *target = nil;
    for (BJLHandWritingBoardDeviceInfo *device in devices) {
        if ([peripheral.identifier.UUIDString isEqualToString:device.identifier]) {
            target = device;
            break;
        }
    }
    return target;
}

- (BJLHandWritingBoardDeviceInfo *)deviceInfoWithPeripheral:(CBPeripheral *)peripheral {
    BJLHandWritingBoardDeviceInfo *deviceInfo = nil;
    BOOL findPrevInfo = NO;
    for (BJLHandWritingBoardDeviceInfo *info in [self.prevConnectedDeviceInfos copy]) {
        if ([info.identifier isEqualToString:peripheral.identifier.UUIDString]) {
            deviceInfo = info;
            // 更新设备名字
            deviceInfo.name = peripheral.name;
            findPrevInfo = YES;
            break;
        }
    }
    if (!findPrevInfo) {
        deviceInfo = [BJLHandWritingBoardDeviceInfo new];
        deviceInfo.name = peripheral.name;
        deviceInfo.identifier = peripheral.identifier.UUIDString;
    }
    return deviceInfo;
}

- (nullable CBPeripheral *)peripheralWithDeviceInfo:(BJLHandWritingBoardDeviceInfo *)deviceInfo {
    for (CBPeripheral *peripheral in [self.room.drawingVM.availableHandWritingBoards copy]) {
        if ([peripheral.identifier.UUIDString isEqualToString:deviceInfo.identifier]) {
            return peripheral;
        }
    }
    return nil;
}

@end

NS_ASSUME_NONNULL_END
