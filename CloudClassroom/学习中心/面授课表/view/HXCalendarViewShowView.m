//
//  HXCalendarViewShowView.m
//  CloudClassroom
//
//  Created by mac on 2022/9/29.
//

#import "HXCalendarViewShowView.h"
#import "MCalendarCollectionCell.h"
#import "MCalendarItem.h"
#import "CalendarConfig.h"

@interface HXCalendarViewShowView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property(nonatomic,strong) UIView *maskView;

@property(nonatomic,strong) UIView *bigBackGroundView;

@property (nonatomic, strong) UIView  *topView;
@property (nonatomic, strong) UILabel *showYearMonthDayLabel;
@property (nonatomic, strong) UIButton *preButton;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UIButton *todayButton;
@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, strong) UIView  *weekHeaderView;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property(nonatomic,strong) UIControl *dismissControl;

@property (nonatomic, strong) CalendarManager *dateManger;



@end

@implementation HXCalendarViewShowView


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        //
        [CalendarConfig sharedInstance].textColor = COLOR_WITH_ALPHA(0x333333, 1);
        [CalendarConfig sharedInstance].selectTextColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
        [CalendarConfig sharedInstance].backgroundColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
        [CalendarConfig sharedInstance].selectBackgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        
        [CalendarConfig sharedInstance].todayTextColor = COLOR_WITH_ALPHA(0xF8A528, 1);
        [CalendarConfig sharedInstance].todaySelectedTextColor =  COLOR_WITH_ALPHA(0xFFFFFF, 1);
        [CalendarConfig sharedInstance].todayBackgroundColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
        [CalendarConfig sharedInstance].todaySelectBackgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        
        [CalendarConfig sharedInstance].outBackgroundColor = UIColor.clearColor;
        [CalendarConfig sharedInstance].outSelectBackgroundColor = UIColor.clearColor;
        
        [self creatUI];
    }
    return self;
}


#pragma mark -Event
//上一个月
- (void)preMonthAction:(UIButton *)sender{
    [self setStartDate: [self.startDate preMonth]];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(preMonth:)]) {
        [self.delegate preMonth:self.startDate];
    }
}

//下一个月
- (void)nextMonthAction:(UIButton *)sender{
    [self setStartDate: [self.startDate nextMonth]];
    if (self.delegate && [self.delegate respondsToSelector:@selector(nextMonth:)]) {
        [self.delegate nextMonth:self.startDate];
    }
}
//今天
- (void)todayAction:(UIButton *)sender{
    self.selectedDate = [NSDate date];
    [self setStartDate:[NSDate date]];
    if (self.delegate && [self.delegate respondsToSelector:@selector(today:)]) {
        [self.delegate today:self.startDate];
    }
}
//确定
-(void)confirm:(UIButton *)sender{
    if (self.confirmBlock) {
        self.confirmBlock(self.selectedDate);
    }
    [self dismiss];
}


-(void)show{
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.maskView];
    self.bigBackGroundView.sd_layout.bottomSpaceToView(self, -(400+kScreenBottomMargin));
    [self.bigBackGroundView updateLayout];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.bigBackGroundView.sd_layout.bottomSpaceToView(self, 0);
        [self.bigBackGroundView updateLayout];
    } completion:^(BOOL finished) {
        [self.collectionView reloadData];
    }];
    
}

-(void)dismiss{
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.bigBackGroundView.sd_layout.bottomSpaceToView(self, -(400+kScreenBottomMargin));
        [self.bigBackGroundView updateLayout];
    } completion:^(BOOL finished) {
        [self.maskView removeFromSuperview];
    }];
    
}




#pragma mark -Setter
- (void)setStartDate:(NSDate *)startDate {
    _startDate = startDate;
    self.selectedDate = startDate;
    self.dateManger.date = startDate;
    [self.collectionView reloadData];
    self.showYearMonthDayLabel.text = [NSString stringWithFormat:@"%@年%@月%@日", @([startDate year]),@([startDate month]),@([startDate day])];
}


#pragma mark -UI
-(void)creatUI{
    
    [self.maskView addSubview:self];
    [self addSubview:self.dismissControl];
    [self addSubview:self.bigBackGroundView];
    
    
    [self.bigBackGroundView addSubview:self.topView];
    [self.bigBackGroundView addSubview:self.weekHeaderView];
    [self.bigBackGroundView addSubview:self.collectionView];
    
    [self.topView addSubview:self.showYearMonthDayLabel];
    [self.topView addSubview:self.preButton];
    [self.topView addSubview:self.nextButton];
    [self.topView addSubview:self.todayButton];
    [self.topView addSubview:self.confirmButton];
    
    self.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    [self updateLayout];
    
    self.bigBackGroundView.sd_layout
    .leftEqualToView(self)
    .rightEqualToView(self)
    .bottomSpaceToView(self, 0)
    .heightIs(400+kScreenBottomMargin);
    [self.bigBackGroundView updateLayout];
    
    
    self.dismissControl.sd_layout
    .topEqualToView(self)
    .leftEqualToView(self)
    .rightEqualToView(self)
    .bottomSpaceToView(self.bigBackGroundView, 0);

    //圆角
   UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bigBackGroundView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(16 ,16)];
   CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
   maskLayer.frame =self.bigBackGroundView.bounds;
   maskLayer.path = maskPath.CGPath;
   self.bigBackGroundView.layer.mask = maskLayer;
    
    

    self.topView.sd_layout
    .topEqualToView(self.bigBackGroundView)
    .leftEqualToView(self.bigBackGroundView)
    .rightEqualToView(self.bigBackGroundView)
    .heightIs(50);
    
    self.todayButton.sd_layout
    .centerYEqualToView(self.topView)
    .leftSpaceToView(self.topView, 16)
    .widthIs(62)
    .heightIs(25);
    
    self.showYearMonthDayLabel.sd_layout
    .centerYEqualToView(self.topView)
    .centerXEqualToView(self.topView)
    .widthIs(130)
    .heightIs(21);
    
    self.preButton.sd_layout
    .centerYEqualToView(self.topView)
    .rightSpaceToView(self.showYearMonthDayLabel, 0)
    .widthIs(44)
    .heightIs(40);
    
    self.nextButton.sd_layout
    .centerYEqualToView(self.topView)
    .leftSpaceToView(self.showYearMonthDayLabel, 0)
    .widthIs(44)
    .heightIs(40);
   
    self.confirmButton.sd_layout
    .centerYEqualToView(self.topView)
    .rightEqualToView(self.topView)
    .widthIs(64)
    .heightIs(25);
    
    
    self.weekHeaderView.sd_layout
    .topSpaceToView(self.topView, 0)
    .leftEqualToView(self.bigBackGroundView)
    .rightEqualToView(self.bigBackGroundView)
    .heightIs(32);
    
    int uwidht = (float)((kScreenWidth-32)/7.0);
    NSArray *titles = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
    for (int i = 0 ; i < 7; i++) {
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = UIColor.clearColor;
        label.font = HXFont(15);
        label.text = titles[i];
        label.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        [_weekHeaderView addSubview:label];
        label.sd_layout
        .leftSpaceToView(_weekHeaderView, 16+uwidht*i)
        .centerYEqualToView(_weekHeaderView)
        .widthIs(uwidht)
        .heightRatioToView(_weekHeaderView, 1);
        
    }
    
    self.collectionView.sd_layout
    .topSpaceToView(self.weekHeaderView, 0)
    .leftEqualToView(self.bigBackGroundView)
    .rightEqualToView(self.bigBackGroundView)
    .bottomSpaceToView(self.bigBackGroundView, 0);
    
}


#pragma mark -- UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dateManger.allDates count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MCalendarCollectionCell *cell = (MCalendarCollectionCell *) [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([MCalendarCollectionCell class]) forIndexPath:indexPath];
    MCalendarItem *item = [self.dateManger.allDates objectAtIndex:indexPath.item];
    item.isToday = [item.date isSameDayAsDate:[NSDate date]];
    cell.selected = [item.date isSameDayAsDate:self.selectedDate];
    [cell doSetContentData:item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MCalendarItem *item = [self.dateManger.allDates objectAtIndex:indexPath.item];
    if (item.inMonth) {
        self.selectedDate = item.date;
        self.showYearMonthDayLabel.text = [NSString stringWithFormat:@"%@年%@月%@日", @([item.date year]),@([item.date month]),@([item.date day])];
        [collectionView reloadData];
    }
}



#pragma mark -LaztLoad
- (CalendarManager *) dateManger {
    if (!_dateManger) {
        _dateManger = [[CalendarManager alloc] init];
    }
    return _dateManger;
}

-(UIView *)maskView{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _maskView.backgroundColor = COLOR_WITH_ALPHA(0x000000, 0.5);
    }
    return _maskView;
}

- (UIControl *)dismissControl{
    if (!_dismissControl) {
        _dismissControl = [[UIControl alloc] init];
        _dismissControl.backgroundColor = UIColor.clearColor;
        [_dismissControl addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dismissControl;
}

-(UIView *)bigBackGroundView{
    if (!_bigBackGroundView) {
        _bigBackGroundView = [[UIView alloc] init];
        _bigBackGroundView.backgroundColor = UIColor.whiteColor;
    }
    return _bigBackGroundView;
}

-(UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = COLOR_WITH_ALPHA(0xF4F6FA, 1);
    }
    return _topView;
}

- (UILabel *)showYearMonthDayLabel {
    if (!_showYearMonthDayLabel) {
        _showYearMonthDayLabel = [[UILabel alloc] init];
        _showYearMonthDayLabel.textAlignment = NSTextAlignmentCenter;
        _showYearMonthDayLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _showYearMonthDayLabel.font = HXBoldFont(15);
    }
    return _showYearMonthDayLabel;
}

- (UIButton *)todayButton {
    if (!_todayButton) {
        _todayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_todayButton addTarget:self action:@selector(todayAction:) forControlEvents:UIControlEventTouchUpInside];
        _todayButton.backgroundColor = COLOR_WITH_ALPHA(0xF4F6FA, 1);
        _todayButton.layer.borderColor = COLOR_WITH_ALPHA(0xF8A528, 1).CGColor;
        _todayButton.layer.cornerRadius = 2.0f;
        _todayButton.layer.borderWidth = .5f;
        _todayButton.titleLabel.font = HXFont(13);
        [_todayButton setTitle:@"回到今天" forState:UIControlStateNormal];
        [_todayButton setTitleColor:COLOR_WITH_ALPHA(0xF8A528, 1) forState:UIControlStateNormal];
    }
    return _todayButton;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.titleLabel.font = HXBoldFont(15);
        [_confirmButton setTitle:@"确认" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:COLOR_WITH_ALPHA(0x2E5BFD, 1) forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

- (UIButton *)preButton {
    if (!_preButton) {
        _preButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_preButton setImage:[UIImage imageNamed:@"Calendar.bundle/left_normal"] forState:UIControlStateNormal];
        [_preButton setImage:[UIImage imageNamed:@"Calendar.bundle/left_select"] forState:UIControlStateSelected];
        [_preButton setImage:[UIImage imageNamed:@"Calendar.bundle/left_select"] forState:UIControlStateHighlighted];
        _preButton.imageEdgeInsets = UIEdgeInsetsMake(8, 12, 8, 12);
        [_preButton addTarget:self action:@selector(preMonthAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _preButton;
}


- (UIButton *)nextButton {
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextButton setImage:[UIImage imageNamed:@"Calendar.bundle/right_normal"] forState:UIControlStateNormal];
        [_nextButton setImage:[UIImage imageNamed:@"Calendar.bundle/right_select"] forState:UIControlStateSelected];
        [_nextButton setImage:[UIImage imageNamed:@"Calendar.bundle/right_select"] forState:UIControlStateHighlighted];
        _nextButton.imageEdgeInsets = UIEdgeInsetsMake(8, 12, 8, 12);
        [_nextButton addTarget:self action:@selector(nextMonthAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
}

- (UIView *)weekHeaderView {
    if (!_weekHeaderView) {
        _weekHeaderView = [[UIView alloc] init];
        _weekHeaderView.backgroundColor = [UIColor clearColor];
    }
    return _weekHeaderView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumLineSpacing = 1.0f;
        _flowLayout.minimumInteritemSpacing = 1.0f;
        int uwidht = (int)((kScreenWidth-8-32)/7);
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 16, 0, 16);
        _flowLayout.itemSize = CGSizeMake(uwidht, uwidht);
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return _flowLayout;
}


- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = UIColor.whiteColor;
        _collectionView.scrollEnabled = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerClass:[MCalendarCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([MCalendarCollectionCell class])];
    }
    return _collectionView;
}

#pragma mark --配置手势
- (void)configGustures{
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swapGestureRecognizer:)];
    recognizer.direction =  UISwipeGestureRecognizerDirectionLeft;
    [self.collectionView addGestureRecognizer:recognizer];
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swapGestureRecognizer:)];
    recognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.collectionView addGestureRecognizer:recognizer];
}

- (void)swapGestureRecognizer:(UISwipeGestureRecognizer *) recognizer {
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        [self preMonthAction:nil];
    } else {
        [self nextMonthAction:nil];
    }
}

@end

