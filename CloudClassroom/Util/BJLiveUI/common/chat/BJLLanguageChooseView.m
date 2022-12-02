//
//  BJLLanguageChooseView.m
//  BJLiveUI
//
//  Created by 辛亚鹏 on 2021/7/23.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import "BJLLanguageChooseView.h"
#import "BJLTheme.h"
#import "BJLAppearance.h"

#pragma mark - model

@interface BJLLanguageModel: NSObject

// 匹配首选的系统语言, 默认简体中文
@property (nonatomic) BJLMessageLanguageType type;
@property (nonatomic) NSString *languageString;

+ (instancetype)languageWithString:(NSString *)string type:(BJLMessageLanguageType)type;

@end

@implementation BJLLanguageModel

+ (instancetype)languageWithString:(NSString *)string type:(BJLMessageLanguageType)type {
    BJLLanguageModel *model = [BJLLanguageModel new];
    model.languageString = string;
    model.type = type;
    return model;
}

@end

#pragma mark - cell

@interface BJLLanguageCell: UITableViewCell

@property (nonatomic) UIImageView *selectImageView;
@property (nonatomic) UILabel *languageLabel;
@property (nonatomic) BJLLanguageModel *model;

- (void)updateWithModel:(BJLLanguageModel *)model selected:(BOOL)selected;

@end

@implementation BJLLanguageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self makeSubview];
    }
    return self;
}

- (void)updateWithModel:(BJLLanguageModel *)model selected:(BOOL)selected {
    self.model = model;
    self.languageLabel.text = model.languageString;
    self.selectImageView.hidden = !selected;
    self.languageLabel.textColor = selected ? BJLTheme.brandColor : BJLTheme.viewTextColor;
}

- (void)makeSubview {
    self.selectImageView = [[UIImageView alloc] initWithImage:[UIImage bjl_imageNamed:@"bjl_chat_language_selected"]];
    self.selectImageView.hidden = YES;
    [self.contentView addSubview:self.selectImageView];

    self.languageLabel = ({
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = BJLTheme.viewTextColor;
        label;
    });
    [self.contentView addSubview:self.languageLabel];

    [self.selectImageView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.height.width.equalTo(@12);
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(8.0);
    }];

    [self.languageLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.selectImageView.bjl_right).offset(6.0);
        make.right.lessThanOrEqualTo(self.contentView);
    }];
}

@end

#pragma mark - BJLLanguageChooseView

@interface BJLLanguageChooseView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UITableView *tableView;
@property (nonatomic, readwrite) BJLMessageLanguageType type;
@property (nonatomic) NSArray<BJLLanguageModel *> *languageList;

@end

@implementation BJLLanguageChooseView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 设置里面的语言列表
        NSArray *languageList = [NSLocale preferredLanguages];
        // 当前设置的首选语言
        NSString *languageCode = [languageList firstObject];
        NSString *countryCode = [NSString stringWithFormat:@"-%@", [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]];
        if (languageCode) {
            languageCode = [languageCode stringByReplacingOccurrencesOfString:countryCode withString:@""];
        }
        self.type = [self languageTypeWithCode:languageCode];
        [self makeDataSource];
        [self makeSubview];
    }
    return self;
}

- (CGSize)expectSize {
    return CGSizeMake(100, self.languageList.count * 32);
}

- (void)makeDataSource {
    // !!!: languages 和 typs 里面预设顺序的需要一一对应
    NSArray *languages = @[BJLLocalizedString(@"高棉语"), BJLLocalizedString(@"英语"), BJLLocalizedString(@"日语"), BJLLocalizedString(@"越南语"), BJLLocalizedString(@"印尼语"), BJLLocalizedString(@"中文(简体)"), BJLLocalizedString(@"中文(繁体)")];
    NSArray *typs = @[@(BJLMessageLanguageType_HKM), @(BJLMessageLanguageType_EN), @(BJLMessageLanguageType_JP), @(BJLMessageLanguageType_VIE), @(BJLMessageLanguageType_ID), @(BJLMessageLanguageType_ZH), @(BJLMessageLanguageType_CHT)];
    NSMutableArray *arrM = [NSMutableArray array];
    for (int i = 0; i < typs.count; i++) {
        NSString *string = languages[i];
        BJLMessageLanguageType type = [typs[i] bjl_integerValue];
        BJLLanguageModel *model = [BJLLanguageModel languageWithString:string type:type];
        [arrM addObject:model];
    }
    self.languageList = [arrM copy];
}

- (void)makeSubview {
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.accessibilityIdentifier = BJLKeypath(self, tableView);
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.rowHeight = 32;
        tableView.showsVerticalScrollIndicator = NO;
        tableView.scrollEnabled = NO;
        tableView.backgroundColor = BJLTheme.toolboxBackgroundColor;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[BJLLanguageCell class] forCellReuseIdentifier:@"BJLLanguageCell"];
        tableView;
    });
    [self addSubview:self.tableView];
    [self.tableView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self);
    }];
}

#pragma mark -

- (BJLMessageLanguageType)languageTypeWithCode:(NSString *)code {
    if ([code isEqualToString:@"zh-Hans"]) {
        return BJLMessageLanguageType_ZH;
    }
    else if ([code isEqualToString:@"zh-Hant"]) {
        return BJLMessageLanguageType_CHT;
    }
    else if ([code isEqualToString:@"ja"]) {
        return BJLMessageLanguageType_JP;
    }
    else if ([code isEqualToString:@"id"]) {
        return BJLMessageLanguageType_ID;
    }
    else if ([code isEqualToString:@"vi"]) {
        return BJLMessageLanguageType_VIE;
    }
    else if ([code isEqualToString:@"en"]) {
        return BJLMessageLanguageType_EN;
    }
    else if ([code isEqualToString:@"hkm"]) {
        return BJLMessageLanguageType_HKM;
    }
    // 如果没有匹配到则返回简体中文
    return BJLMessageLanguageType_ZH;
}

#pragma mark -

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.languageList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BJLLanguageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BJLLanguageCell"];
    BJLLanguageModel *model = self.languageList[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell updateWithModel:model selected:(model.type == self.type)];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BJLLanguageCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    self.type = cell.model.type;
    [tableView reloadData];
}

@end
