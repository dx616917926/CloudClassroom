//
//  HXFaceTimeTableViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/1.
//

#import "HXFaceTimeTableViewController.h"
#import "HXCalendarViewShowView.h"
#import "HXFaceTimeTableShowView.h"
#import <objc/runtime.h>
#import "NSDate+Calendar.h"

#import "HXCourseArrangingInfoModel.h"

const NSString * ColorViewWithItemKey = @"ColorViewWithItemKey";

//单个课表高度
#define   kKeBiaoItemHeight    130
//左侧列宽度
#define   kLeftColumnWidth     _kpw(40)
//单个课表宽度
#define   kKeBiaoItemWidth    ((kScreenWidth-kLeftColumnWidth)*1.0/7)

@interface HXFaceTimeTableViewController ()

@property(nonatomic,strong) UIView *topView;
@property(nonatomic,strong) UIButton *riQiBtn;
@property(nonatomic,strong) UIButton *todayBtn;

@property(nonatomic,strong) UIView *weekContainerView;

@property(nonatomic,strong) UIScrollView *mainScrollView;

@property(nonatomic,strong) UIView *columnContainerView;

@property(nonatomic,strong) UIView *columnContainerView1;

@property(nonatomic,strong) NSMutableArray *items;

@property(nonatomic,strong) HXCalendarViewShowView *calendarView;
//选择日期
@property (nonatomic, strong) NSDate *selectedDate;

@property (nonatomic, strong) HXCourseArrangingInfoModel *courseArrangingInfoModel;

@end

@implementation HXFaceTimeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //默认当前日期
    self.selectedDate = [NSDate date];
    
    [self createUI];
    
    [self getCourseArrangingList];
}



#pragma mark - 获取面授课表数据
-(void)getCourseArrangingList{
    NSString *studentid = [HXPublicParamTool sharedInstance].student_id;
    NSString *dayTime = [self.selectedDate stringWithFormat:@"YYYY-MM-dd"];
    NSDictionary *dic =@{
        @"daytime":HXSafeString(dayTime),
        @"studentid":HXSafeString(studentid)
    };
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetCourseArrangingList needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            self.courseArrangingInfoModel = [HXCourseArrangingInfoModel mj_objectWithKeyValues:[dictionary dictionaryValueForKey:@"data"]];
            [self refreshUI];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}

#pragma mark - 刷新UI
-(void)refreshUI{
    
   
    [self.riQiBtn setTitle:self.courseArrangingInfoModel.arrangingDateName forState:UIControlStateNormal];
    
    for (int i=0; i<6; i++) {
        UIView *viewContainer =[self.mainScrollView viewWithTag:5000+i];
        [viewContainer.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //移除关联对象
            objc_removeAssociatedObjects(obj);
            [obj removeFromSuperview];
            obj = nil;
        }];
        
        [viewContainer removeFromSuperview];
        viewContainer = nil;
    }
    
    //周一到周末7列数据
    for (int i=0; i<6; i++) {
        UIView *viewContainer =[[UIView alloc] init];
        [self.mainScrollView addSubview:viewContainer];
        viewContainer.tag = 5000+i;
        viewContainer.sd_layout
        .topEqualToView(self.columnContainerView)
        .leftSpaceToView(self.mainScrollView, kKeBiaoItemWidth*i+kLeftColumnWidth)
        .widthIs(kKeBiaoItemWidth)
        .heightRatioToView(self.columnContainerView, 1);
    }
    
    //随机颜色
    NSArray *colors = @[COLOR_WITH_ALPHA(0xF45E5E, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x69D360, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xF45E5E, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x69D360, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xF45E5E, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x69D360, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xF45E5E, 1),COLOR_WITH_ALPHA(0xF45E5E, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x69D360, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xF45E5E, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xF45E5E, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x69D360, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xF45E5E, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xF45E5E, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x69D360, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xF45E5E, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1)];
    
    for (int i=0; i<self.courseArrangingInfoModel.respCourseArrangingDates.count; i++) {
        
        UIView *viewContainer =[self.mainScrollView viewWithTag:5000+i];
        
        HXCourseArrangingDateModel *courseArrangingDateModel = self.courseArrangingInfoModel.respCourseArrangingDates[i];
        
        if (courseArrangingDateModel.respCourseArranging.count>0) {
            
            for (int j=0; j<courseArrangingDateModel.respCourseArranging.count; j++) {
                
                HXFaceTimeCourseDetailModel *item = courseArrangingDateModel.respCourseArranging[j];
                
                UIView *view =[[UIView alloc] init];
                view.backgroundColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
                [viewContainer addSubview:view];
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
                [view addGestureRecognizer:tap];
                //将数据关联按钮
                objc_setAssociatedObject(view, &ColorViewWithItemKey, item, OBJC_ASSOCIATION_RETAIN);
                UIView *colorview =[[UIView alloc] init];
                colorview.backgroundColor = colors[j+i];
                [view addSubview:colorview];
                
                UILabel *label = [[UILabel alloc] init];
                label.textAlignment = NSTextAlignmentCenter;
                label.font =HXBoldFont(13);
                label.textColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
                label.numberOfLines = 0;
                label.lineBreakMode = NSLineBreakByTruncatingTail;
                label.text = item.termCourseName;
                [colorview addSubview:label];
                
                view.sd_layout
                .topSpaceToView(viewContainer, j*kKeBiaoItemHeight)
                .leftEqualToView(viewContainer)
                .rightEqualToView(viewContainer)
                .heightIs(kKeBiaoItemHeight);
                
                colorview.sd_layout.spaceToSuperView(UIEdgeInsetsMake(3, 3, 3, 3));
                colorview.sd_cornerRadius =@4;
                
                label.sd_layout.spaceToSuperView(UIEdgeInsetsMake(2, 5, 2, 5));
            }
        }
    }
}

#pragma mark - 选择时间
-(void)selectRiQi:(UIButton *)sender{
    
    self.calendarView.startDate = self.selectedDate;
    [self.calendarView show];
    WeakSelf(weakSelf);
    self.calendarView.confirmBlock = ^(NSDate *date) {
        weakSelf.selectedDate = date;
        //获取面授课表数据
        [weakSelf getCourseArrangingList];
    };
}

#pragma mark - 回到今天
-(void)backToday:(UIButton *)sender{
    
    self.selectedDate = [NSDate date];
    self.calendarView.startDate = [NSDate date];
    
    //获取面授课表数据
    [self getCourseArrangingList];
}


#pragma mark - 点击课程
-(void)tap:(UITapGestureRecognizer *)ges{
    UIView *view = ges.view;
    HXFaceTimeCourseDetailModel *faceTimeCourseDetailModel = objc_getAssociatedObject(view, &ColorViewWithItemKey);
    
    NSString *studentid = [HXPublicParamTool sharedInstance].student_id;
    NSDictionary *dic =@{
        @"id":HXSafeString(faceTimeCourseDetailModel.paiKeId),
        @"studentid":HXSafeString(studentid)
    };
    
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetCourseArrangingDetai needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            HXFaceTimeCourseDetailModel *model = [HXFaceTimeCourseDetailModel mj_objectWithKeyValues:[dictionary dictionaryValueForKey:@"data"]];
            HXFaceTimeTableShowView *faceTimeTableShowView =[[HXFaceTimeTableShowView alloc] init];
            faceTimeTableShowView.faceTimeCourseDetailModel = model;
            [faceTimeTableShowView show];
        }else{
            [self.view showErrorWithMessage:[dictionary stringValueForKey:@"message"]];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}

#pragma mark - UI
-(void)createUI{
    
    [self.view addSubview:self.topView];
    [self.topView addSubview:self.riQiBtn];
    [self.topView addSubview:self.todayBtn];
    [self.view addSubview:self.mainScrollView];
    [self.view addSubview:self.weekContainerView];
    
    [self.mainScrollView addSubview:self.columnContainerView];
    
    self.topView.sd_layout
    .topSpaceToView(self.view, 0)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .heightIs(44);
    
    self.riQiBtn.sd_layout
    .leftSpaceToView(self.topView, 16)
    .centerYEqualToView(self.topView)
    .widthIs(_kpw(220))
    .heightIs(32);
    self.riQiBtn.sd_cornerRadius=@2;
    
    self.riQiBtn.imageView.sd_layout
    .centerYEqualToView(self.riQiBtn)
    .rightSpaceToView(self.riQiBtn, 6)
    .widthIs(13)
    .heightIs(13);
    
    self.riQiBtn.titleLabel.sd_layout
    .centerYEqualToView(self.riQiBtn)
    .leftSpaceToView(self.riQiBtn, 6)
    .rightSpaceToView(self.riQiBtn.imageView, 12)
    .heightIs(18);
    
    
    self.todayBtn.sd_layout
    .rightSpaceToView(self.topView, 16)
    .centerYEqualToView(self.topView)
    .widthIs(_kpw(114))
    .heightIs(32);
    self.todayBtn.sd_cornerRadius=@2;
    
   
    
    NSArray *weeks = @[@"一",@"二",@"三",@"四",@"五",@"六",@"日"];
    
    self.weekContainerView.sd_layout
    .topSpaceToView(self.topView, 0)
    .leftSpaceToView(self.view, kLeftColumnWidth)
    .rightEqualToView(self.view)
    .heightIs(40);
    
    
    for (int i=0; i<weeks.count; i++) {
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.font =HXBoldFont(14);
        label.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        label.text = weeks[i];
        [self.weekContainerView addSubview:label];
        
        label.sd_layout
        .centerYEqualToView(self.weekContainerView)
        .leftSpaceToView(self.weekContainerView, i*kKeBiaoItemWidth)
        .widthIs(kKeBiaoItemWidth)
        .heightRatioToView(self.weekContainerView, 1);
    }
    
    self.mainScrollView.sd_layout
    .topSpaceToView(self.weekContainerView, 0)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .bottomEqualToView(self.view);
    
    self.columnContainerView.sd_layout
    .topEqualToView(self.mainScrollView)
    .leftEqualToView(self.mainScrollView)
    .widthIs(kLeftColumnWidth);
    
    //12节课
    NSArray *columns = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12"];
    UIView *lastView;
    for (int i=0; i<columns.count; i++) {
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.font =HXBoldFont(14);
        label.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        label.text = columns[i];
        [self.columnContainerView addSubview:label];
        
        label.sd_layout
        .topSpaceToView(self.columnContainerView, i*kKeBiaoItemHeight)
        .leftEqualToView(self.columnContainerView)
        .rightEqualToView(self.columnContainerView)
        .heightIs(kKeBiaoItemHeight);
        lastView = label;
    }
    [self.columnContainerView setupAutoHeightWithBottomView:lastView bottomMargin:0];
    
    //周一到周末
    for (int i=0; i<weeks.count; i++) {
        UIView *viewContainer =[[UIView alloc] init];
        [self.mainScrollView addSubview:viewContainer];
        viewContainer.tag = 5000+i;
        viewContainer.sd_layout
        .topEqualToView(self.columnContainerView)
        .leftSpaceToView(self.mainScrollView, kKeBiaoItemWidth*i+kLeftColumnWidth)
        .widthIs(kKeBiaoItemWidth)
        .heightRatioToView(self.columnContainerView, 1);
    }
    
    
    
    [self.mainScrollView setupAutoContentSizeWithBottomView:self.columnContainerView bottomMargin:0];
}

#pragma mark -LazyLoad

-(UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = UIColor.whiteColor;
    }
    return _topView;
}


- (UIButton *)riQiBtn{
    if (!_riQiBtn) {
        _riQiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _riQiBtn.backgroundColor = COLOR_WITH_ALPHA(0xF4F6FA, 1);
        _riQiBtn.titleLabel.font = HXFont(13);
        [_riQiBtn setTitleColor:COLOR_WITH_ALPHA(0x333333, 1) forState:UIControlStateNormal];
        [_riQiBtn setImage:[UIImage imageNamed:@"set_arrow"] forState:UIControlStateNormal];
        [_riQiBtn addTarget:self action:@selector(selectRiQi:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _riQiBtn;
}

- (UIButton *)todayBtn{
    if (!_todayBtn) {
        _todayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _todayBtn.backgroundColor = COLOR_WITH_ALPHA(0xF4F6FA, 1);
        _todayBtn.titleLabel.font = HXFont(13);
        [_todayBtn setTitleColor:COLOR_WITH_ALPHA(0x333333, 1) forState:UIControlStateNormal];
        [_todayBtn setTitle:@"回到今天" forState:UIControlStateNormal];
        [_todayBtn addTarget:self action:@selector(backToday:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _todayBtn;
}

-(UIView *)weekContainerView{
    if (!_weekContainerView) {
        _weekContainerView = [[UIView alloc] init];
        _weekContainerView.backgroundColor = VCBackgroundColor;
    }
    return _weekContainerView;
}

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] init];
        _mainScrollView.backgroundColor = UIColor.whiteColor;
        _mainScrollView.bounces = NO;
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

-(UIView *)columnContainerView{
    if (!_columnContainerView) {
        _columnContainerView = [[UIView alloc] init];
        _columnContainerView.backgroundColor = VCBackgroundColor;
    }
    return _columnContainerView;
}

-(HXCalendarViewShowView *)calendarView{
    if (!_calendarView) {
        _calendarView = [[HXCalendarViewShowView alloc] init];
    }
    return _calendarView;
}

@end
