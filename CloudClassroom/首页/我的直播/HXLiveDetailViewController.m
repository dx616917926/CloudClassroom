//
//  HXLiveDetailViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/10/18.
//

#import "HXLiveDetailViewController.h"

@interface HXLiveDetailViewController ()

@property(nonatomic,strong) UIScrollView *mainScrollView;

@property(nonatomic,strong) UIView *bigBackgroundView;
@property(nonatomic,strong) UILabel *courseNameLabel;
@property(nonatomic,strong) UILabel *numLabel;


///直播时间
@property(nonatomic,strong) UILabel *liveTimeTitleLabel;
@property(nonatomic,strong) UILabel *liveTimeContentLabel;
///直播老师
@property(nonatomic,strong) UILabel *liveTeacherTitleLabel;
@property(nonatomic,strong) UILabel *liveTeacherContentLabel;
///直播时长
@property(nonatomic,strong) UILabel *liveDurationTitleLabel;
@property(nonatomic,strong) UILabel *liveDurationContentLabel;
///回看时长
@property(nonatomic,strong) UILabel *reviewDurationTitleLabel;
@property(nonatomic,strong) UILabel *reviewDurationContentLabel;
///回看次数
@property(nonatomic,strong) UILabel *reviewNumTitleLabel;
@property(nonatomic,strong) UILabel *reviewNumContentLabel;
///直播简介
@property(nonatomic,strong) UILabel *introductionTitleLabel;
@property(nonatomic,strong) UILabel *introductionContentLabel;

@end

@implementation HXLiveDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UI
    [self createUI];
}

-(void)getBKList{
    
    [self.mainScrollView.mj_header endRefreshing];
}

#pragma mark - UI
-(void)createUI{
    self.sc_navigationBar.title = @"直播详情";
   
    [self.view addSubview:self.mainScrollView];
    [self.mainScrollView addSubview:self.bigBackgroundView];
    [self.bigBackgroundView addSubview:self.courseNameLabel];
    [self.bigBackgroundView addSubview:self.numLabel];
    [self.bigBackgroundView addSubview:self.liveTimeTitleLabel];
    [self.bigBackgroundView addSubview:self.liveTimeContentLabel];
    [self.bigBackgroundView addSubview:self.liveTeacherTitleLabel];
    [self.bigBackgroundView addSubview:self.liveTeacherContentLabel];
    [self.bigBackgroundView addSubview:self.liveDurationTitleLabel];
    [self.bigBackgroundView addSubview:self.liveDurationContentLabel];
    [self.bigBackgroundView addSubview:self.reviewDurationTitleLabel];
    [self.bigBackgroundView addSubview:self.reviewDurationContentLabel];
    [self.bigBackgroundView addSubview:self.reviewNumTitleLabel];
    [self.bigBackgroundView addSubview:self.reviewNumContentLabel];
    [self.bigBackgroundView addSubview:self.introductionTitleLabel];
    [self.bigBackgroundView addSubview:self.introductionContentLabel];
    
    self.mainScrollView.sd_layout
    .topSpaceToView(self.view, kNavigationBarHeight)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .bottomEqualToView(self.view);
    
    self.bigBackgroundView.sd_layout
    .topSpaceToView(self.mainScrollView, 16)
    .leftSpaceToView(self.mainScrollView, 12)
    .rightSpaceToView(self.mainScrollView, 12);
    self.bigBackgroundView.sd_cornerRadius=@2;
    
    self.courseNameLabel.sd_layout
    .topSpaceToView(self.bigBackgroundView, 22)
    .leftSpaceToView(self.bigBackgroundView, 20)
    .rightSpaceToView(self.bigBackgroundView, 20)
    .heightIs(23);
    
    self.numLabel.sd_layout
    .topSpaceToView(self.courseNameLabel, 0)
    .leftEqualToView(self.courseNameLabel)
    .rightEqualToView(self.courseNameLabel)
    .heightIs(17);
    
    self.liveTimeTitleLabel.sd_layout
    .topSpaceToView(self.numLabel, 21)
    .leftEqualToView(self.courseNameLabel)
    .widthIs((kScreenWidth-40)*0.5)
    .heightIs(20);
    
    self.liveTimeContentLabel.sd_layout
    .topSpaceToView(self.liveTimeTitleLabel, 6)
    .leftEqualToView(self.courseNameLabel)
    .rightEqualToView(self.courseNameLabel)
    .heightIs(21);
    
    
    self.liveTeacherTitleLabel.sd_layout
    .topSpaceToView(self.liveTimeContentLabel, 20)
    .leftEqualToView(self.courseNameLabel)
    .widthIs((kScreenWidth-40)*0.6)
    .heightRatioToView(self.liveTimeTitleLabel, 1);
    
    self.liveTeacherContentLabel.sd_layout
    .topSpaceToView(self.liveTeacherTitleLabel, 6)
    .leftEqualToView(self.liveTeacherTitleLabel)
    .rightEqualToView(self.liveTeacherTitleLabel)
    .heightRatioToView(self.liveTimeContentLabel, 1);
    
    
    self.liveDurationTitleLabel.sd_layout
    .centerYEqualToView(self.liveTeacherTitleLabel)
    .leftSpaceToView(self.liveTeacherTitleLabel, 10)
    .rightEqualToView(self.courseNameLabel)
    .heightRatioToView(self.liveTimeTitleLabel, 1);
    
    self.liveDurationContentLabel.sd_layout
    .centerYEqualToView(self.liveTeacherContentLabel)
    .leftEqualToView(self.liveDurationTitleLabel)
    .rightEqualToView(self.liveDurationTitleLabel)
    .heightRatioToView(self.liveTimeContentLabel, 1);
    
    self.reviewDurationTitleLabel.sd_layout
    .topSpaceToView(self.liveTeacherContentLabel, 20)
    .leftEqualToView(self.liveTeacherTitleLabel)
    .rightEqualToView(self.liveTeacherTitleLabel)
    .heightRatioToView(self.liveTimeTitleLabel, 1);
    
    self.reviewDurationContentLabel.sd_layout
    .topSpaceToView(self.reviewDurationTitleLabel, 6)
    .leftEqualToView(self.liveTeacherTitleLabel)
    .rightEqualToView(self.liveTeacherTitleLabel)
    .heightRatioToView(self.liveTimeContentLabel, 1);
    
    
    self.reviewNumTitleLabel.sd_layout
    .centerYEqualToView(self.reviewDurationTitleLabel)
    .leftEqualToView(self.liveDurationTitleLabel)
    .rightEqualToView(self.liveDurationTitleLabel)
    .heightRatioToView(self.liveTimeTitleLabel, 1);
    
    self.reviewNumContentLabel.sd_layout
    .centerYEqualToView(self.reviewDurationContentLabel)
    .leftEqualToView(self.liveDurationTitleLabel)
    .rightEqualToView(self.liveDurationTitleLabel)
    .heightRatioToView(self.liveTimeContentLabel, 1);
    
    self.introductionTitleLabel.sd_layout
    .topSpaceToView(self.reviewDurationContentLabel, 20)
    .leftEqualToView(self.courseNameLabel)
    .rightEqualToView(self.courseNameLabel)
    .heightRatioToView(self.liveTimeTitleLabel, 1);
    
    self.introductionContentLabel.sd_layout
    .topSpaceToView(self.introductionTitleLabel, 6)
    .leftEqualToView(self.courseNameLabel)
    .rightEqualToView(self.courseNameLabel)
    .autoHeightRatio(0);
    
    
    [self.bigBackgroundView setupAutoHeightWithBottomView:self.introductionContentLabel bottomMargin:20];
    
    [self.mainScrollView setupAutoContentSizeWithBottomView:self.bigBackgroundView bottomMargin:100];
    
    self.noDataTipView.tipTitle = @"暂无直播详情～";
    self.noDataTipView.frame = self.mainScrollView.frame;
    
    // 刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getBKList)];
    header.automaticallyChangeAlpha = YES;
    self.mainScrollView.mj_header = header;
 
}

#pragma mark - Lazyload
-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] init];
        _mainScrollView.backgroundColor = UIColor.clearColor;
        _mainScrollView.bounces = YES;
        _mainScrollView.showsVerticalScrollIndicator = NO;
        self.extendedLayoutIncludesOpaqueBars = YES;
        if (@available(iOS 11.0, *)) {
            _mainScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _mainScrollView;
}

-(UIView *)bigBackgroundView{
    if (!_bigBackgroundView) {
        _bigBackgroundView = [[UIView alloc] init];
        _bigBackgroundView.backgroundColor = [UIColor whiteColor];
        _bigBackgroundView.clipsToBounds = YES;
    }
    return _bigBackgroundView;
}

- (UILabel *)courseNameLabel{
    if (!_courseNameLabel) {
        _courseNameLabel = [[UILabel alloc] init];
        _courseNameLabel.textAlignment = NSTextAlignmentCenter;
        _courseNameLabel.font = HXBoldFont(16);
        _courseNameLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _courseNameLabel.text = @"广告策划与创意";
    }
    return _courseNameLabel;
}

- (UILabel *)numLabel{
    if (!_numLabel) {
        _numLabel = [[UILabel alloc] init];
        _numLabel.textAlignment = NSTextAlignmentCenter;
        _numLabel.font = HXFont(12);
        _numLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _numLabel.text = @"（第3次）";
    }
    return _numLabel;
}



- (UILabel *)liveTimeTitleLabel{
    if (!_liveTimeTitleLabel) {
        _liveTimeTitleLabel = [[UILabel alloc] init];
        _liveTimeTitleLabel.textAlignment = NSTextAlignmentLeft;
        _liveTimeTitleLabel.font = HXFont(14);
        _liveTimeTitleLabel.textColor = COLOR_WITH_ALPHA(0xBDBDBD, 1);
        _liveTimeTitleLabel.text = @"直播时间";
    }
    return _liveTimeTitleLabel;
}

- (UILabel *)liveTimeContentLabel{
    if (!_liveTimeContentLabel) {
        _liveTimeContentLabel = [[UILabel alloc] init];
        _liveTimeContentLabel.textAlignment = NSTextAlignmentLeft;
        _liveTimeContentLabel.font = HXFont(15);
        _liveTimeContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _liveTimeContentLabel.text = @"2022.07.07 19:00-20:00";
    }
    return _liveTimeContentLabel;
}

- (UILabel *)liveTeacherTitleLabel{
    if (!_liveTeacherTitleLabel) {
        _liveTeacherTitleLabel = [[UILabel alloc] init];
        _liveTeacherTitleLabel.textAlignment = NSTextAlignmentLeft;
        _liveTeacherTitleLabel.font = HXFont(14);
        _liveTeacherTitleLabel.textColor = COLOR_WITH_ALPHA(0xBDBDBD, 1);
        _liveTeacherTitleLabel.text = @"直播老师";
    }
    return _liveTeacherTitleLabel;
}

- (UILabel *)liveTeacherContentLabel{
    if (!_liveTeacherContentLabel) {
        _liveTeacherContentLabel = [[UILabel alloc] init];
        _liveTeacherContentLabel.textAlignment = NSTextAlignmentLeft;
        _liveTeacherContentLabel.font = HXFont(15);
        _liveTeacherContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _liveTeacherContentLabel.text = @"张小小";
    }
    return _liveTeacherContentLabel;
}

- (UILabel *)liveDurationTitleLabel{
    if (!_liveDurationTitleLabel) {
        _liveDurationTitleLabel = [[UILabel alloc] init];
        _liveDurationTitleLabel.textAlignment = NSTextAlignmentLeft;
        _liveDurationTitleLabel.font = HXFont(14);
        _liveDurationTitleLabel.textColor = COLOR_WITH_ALPHA(0xBDBDBD, 1);
        _liveDurationTitleLabel.text = @"直播时长";
    }
    return _liveDurationTitleLabel;
}

- (UILabel *)liveDurationContentLabel{
    if (!_liveDurationContentLabel) {
        _liveDurationContentLabel = [[UILabel alloc] init];
        _liveDurationContentLabel.textAlignment = NSTextAlignmentLeft;
        _liveDurationContentLabel.font = HXFont(15);
        _liveDurationContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _liveDurationContentLabel.text = @"20/50";
    }
    return _liveDurationContentLabel;
}

- (UILabel *)reviewDurationTitleLabel{
    if (!_reviewDurationTitleLabel) {
        _reviewDurationTitleLabel = [[UILabel alloc] init];
        _reviewDurationTitleLabel.textAlignment = NSTextAlignmentLeft;
        _reviewDurationTitleLabel.font = HXFont(14);
        _reviewDurationTitleLabel.textColor = COLOR_WITH_ALPHA(0xBDBDBD, 1);
        _reviewDurationTitleLabel.text = @"回看时长";
    }
    return _reviewDurationTitleLabel;
}

- (UILabel *)reviewDurationContentLabel{
    if (!_reviewDurationContentLabel) {
        _reviewDurationContentLabel = [[UILabel alloc] init];
        _reviewDurationContentLabel.textAlignment = NSTextAlignmentLeft;
        _reviewDurationContentLabel.font = HXFont(15);
        _reviewDurationContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _reviewDurationContentLabel.text = @"200/50";
    }
    return _reviewDurationContentLabel;
}

- (UILabel *)reviewNumTitleLabel{
    if (!_reviewNumTitleLabel) {
        _reviewNumTitleLabel = [[UILabel alloc] init];
        _reviewNumTitleLabel.textAlignment = NSTextAlignmentLeft;
        _reviewNumTitleLabel.font = HXFont(14);
        _reviewNumTitleLabel.textColor = COLOR_WITH_ALPHA(0xBDBDBD, 1);
        _reviewNumTitleLabel.text = @"回看次数";
    }
    return _reviewNumTitleLabel;
}

- (UILabel *)reviewNumContentLabel{
    if (!_reviewNumContentLabel) {
        _reviewNumContentLabel = [[UILabel alloc] init];
        _reviewNumContentLabel.textAlignment = NSTextAlignmentLeft;
        _reviewNumContentLabel.font = HXFont(15);
        _reviewNumContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _reviewNumContentLabel.text = @"3";
    }
    return _reviewNumContentLabel;
}

- (UILabel *)introductionTitleLabel{
    if (!_introductionTitleLabel) {
        _introductionTitleLabel = [[UILabel alloc] init];
        _introductionTitleLabel.textAlignment = NSTextAlignmentLeft;
        _introductionTitleLabel.font = HXFont(14);
        _introductionTitleLabel.textColor = COLOR_WITH_ALPHA(0xBDBDBD, 1);
        _introductionTitleLabel.text = @"直播简介";
    }
    return _introductionTitleLabel;
}

- (UILabel *)introductionContentLabel{
    if (!_introductionContentLabel) {
        _introductionContentLabel = [[UILabel alloc] init];
        _introductionContentLabel.textAlignment = NSTextAlignmentLeft;
        _introductionContentLabel.font = HXFont(15);
        _introductionContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _introductionContentLabel.numberOfLines=0;
        _introductionContentLabel.text = @"这里是直播简介这里是直播简介这里是直播简介这里是直,播简介这里是直播简介这里是直播简介这里是直播简介这里是直播简介这里是直播简介这里是直播简介.";
    }
    return _introductionContentLabel;
}


@end
