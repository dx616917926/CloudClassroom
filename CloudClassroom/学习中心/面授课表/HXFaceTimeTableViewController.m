//
//  HXFaceTimeTableViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/1.
//

#import "HXFaceTimeTableViewController.h"
#import "HXFaceTimeTableShowView.h"
#import <objc/runtime.h>

const NSString * ColorViewWithItemKey = @"ColorViewWithItemKey";

@interface HXFaceTimeTableViewController ()

@property(nonatomic,strong) UIView *topView;
@property(nonatomic,strong) UIButton *riQiBtn;

@property(nonatomic,strong) UIView *weekContainerView;

@property(nonatomic,strong) UIScrollView *mainScrollView;

@property(nonatomic,strong) UIView *columnContainerView;

@property(nonatomic,strong) UIView *columnContainerView1;

@property(nonatomic,strong) NSMutableArray *items;


@end

@implementation HXFaceTimeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.items = [NSMutableArray array];
    NSArray *courseNames = @[@"电子商务运营实务",@"英语",@"新媒体运营实务",@"中国近代史纲要",@"数学",@"新媒体运营实务",@"毛泽东思想和中国特色社会主义理论体系概论",@"中国近代史纲要"];
    NSArray *times = @[@"2022年09月26日  8:30-12:30",@"2022年10月01日  16:30-17:00",@"2022年02月10日  7:00-8:00",@"2022年12月06日  13:00-14:30",@"2022年09月26日  8:30-12:30",@"2022年10月01日  16:30-17:00",@"2022年02月10日  7:00-8:00",@"2022年12月06日  13:00-14:30"];
    NSArray *addresss = @[@"一栋教学楼 1712",@"八栋教学楼 1024",@"五栋教学楼 6666",@"九栋教学楼 0909",@"一栋教学楼 1712",@"八栋教学楼 1024",@"五栋教学楼 6666",@"九栋教学楼 0909"];
    NSArray *teachers = @[@"曹明德",@"张无忌",@"徐晓",@"韩梅梅",@"曹明德",@"张无忌",@"徐晓",@"韩梅梅"];
    NSArray *statuss = @[@"已结束",@"进行中",@"未开始",@"已结束",@"已结束",@"进行中",@"未开始",@"已结束"];
    for (int i=0; i<12; i++) {
        HXFaceTimeTableModel *model = [HXFaceTimeTableModel new];
        model.courseName = courseNames[arc4random()%7];
        model.time = times[arc4random()%7];
        model.address = addresss[arc4random()%7];
        model.teacher = teachers[arc4random()%7];
        model.status = statuss[arc4random()%7];
        [self.items addObject:model];
    }
    
    [self createUI];
}


#pragma mark - Event
-(void)selectRiQi:(UIButton *)sender{
    
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
    
    CGFloat width = kScreenWidth*1.0/8;
    
    for (int i=0; i<6; i++) {
        UIView *viewContainer =[[UIView alloc] init];
        [self.mainScrollView addSubview:viewContainer];
        viewContainer.tag = 5000+i;
        viewContainer.sd_layout
        .topEqualToView(self.columnContainerView)
        .leftSpaceToView(self.mainScrollView, width*(i+1))
        .widthRatioToView(self.columnContainerView, 1)
        .heightRatioToView(self.columnContainerView, 1);
    }
    
    NSArray *counts = @[@12,@2,@6,@8,@7,@10,@5,@4,@9];
    NSArray *colors = @[COLOR_WITH_ALPHA(0xF45E5E, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x69D360, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xF45E5E, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x69D360, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xF45E5E, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x69D360, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xF45E5E, 1),COLOR_WITH_ALPHA(0xF45E5E, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x69D360, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xF45E5E, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xF45E5E, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x69D360, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xF45E5E, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xF45E5E, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x69D360, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xF45E5E, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1)];
    
    for (int i=0; i<6; i++) {
        
        UIView *viewContainer =[self.mainScrollView viewWithTag:5000+i];
        
        for (int j=0; j<[counts[i] integerValue]; j++) {
            HXFaceTimeTableModel *item = self.items[arc4random()%7];
            UIView *view =[[UIView alloc] init];
            view.backgroundColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
            [viewContainer addSubview:view];
            view.hidden= arc4random()%2==1?YES:NO;
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
            label.text = item.courseName;
            [colorview addSubview:label];
            
            view.sd_layout
            .topSpaceToView(viewContainer, j*124)
            .leftEqualToView(viewContainer)
            .rightEqualToView(viewContainer)
            .heightIs(124);
            
            colorview.sd_layout.spaceToSuperView(UIEdgeInsetsMake(3, 3, 3, 3));
            colorview.sd_cornerRadius =@4;
            
            label.sd_layout.spaceToSuperView(UIEdgeInsetsMake(2, 5, 2, 5));
        }
    }
}

-(void)tap:(UITapGestureRecognizer *)ges{
    UIView *view = ges.view;
    HXFaceTimeTableModel *model = objc_getAssociatedObject(view, &ColorViewWithItemKey);
    HXFaceTimeTableShowView *faceTimeTableShowView =[[HXFaceTimeTableShowView alloc] init];
    faceTimeTableShowView.faceTimeTableModel = model;
    [faceTimeTableShowView show];
}

#pragma mark - UI
-(void)createUI{
    [self.view addSubview:self.topView];
    [self.topView addSubview:self.riQiBtn];
    [self.view addSubview:self.mainScrollView];
    [self.view addSubview:self.weekContainerView];
    
    [self.mainScrollView addSubview:self.columnContainerView];
    
    
    
    self.topView.sd_layout
    .topSpaceToView(self.view, 0)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .heightIs(44);
    
    self.riQiBtn.sd_layout
    .centerXEqualToView(self.topView)
    .centerYEqualToView(self.topView)
    .heightIs(28);
    self.riQiBtn.sd_cornerRadius=@2;
    
    self.riQiBtn.titleLabel.sd_layout
    .centerYEqualToView(self.riQiBtn)
    .leftSpaceToView(self.riQiBtn, 8)
    .heightIs(18);
    [self.riQiBtn.titleLabel setSingleLineAutoResizeWithMaxWidth:160];
    
    self.riQiBtn.imageView.sd_layout
    .centerYEqualToView(self.riQiBtn)
    .leftSpaceToView(self.riQiBtn.titleLabel, 8)
    .widthIs(13)
    .heightIs(13);
    
    [self.riQiBtn setupAutoWidthWithRightView:self.riQiBtn.imageView rightMargin:6];
    
    NSArray *weeks = @[@" ",@"一",@"二",@"三",@"四",@"五",@"六",@"日"];
    
    self.weekContainerView.sd_layout
    .topSpaceToView(self.topView, 0)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .heightIs(40);
    
    CGFloat width = kScreenWidth*1.0/8;
    
    for (int i=0; i<weeks.count; i++) {
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.font =HXBoldFont(14);
        label.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        label.text = weeks[i];
        [self.weekContainerView addSubview:label];
        
        label.sd_layout
        .centerYEqualToView(self.weekContainerView)
        .leftSpaceToView(self.weekContainerView, i*width)
        .widthIs(width)
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
    .widthIs(width);
    
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
        .topSpaceToView(self.columnContainerView, i*124)
        .leftEqualToView(self.columnContainerView)
        .rightEqualToView(self.columnContainerView)
        .heightIs(124);
        lastView = label;
    }
    [self.columnContainerView setupAutoHeightWithBottomView:lastView bottomMargin:0];
    
    
    for (int i=0; i<weeks.count; i++) {
        UIView *viewContainer =[[UIView alloc] init];
        [self.mainScrollView addSubview:viewContainer];
        viewContainer.tag = 5000+i;
        viewContainer.sd_layout
        .topEqualToView(self.columnContainerView)
        .leftSpaceToView(self.mainScrollView, width*(i+1))
        .widthRatioToView(self.columnContainerView, 1)
        .heightRatioToView(self.columnContainerView, 1);
    }
    
    NSArray *counts = @[@12,@2,@6,@8,@7,@10,@5,@4,@9];
    NSArray *colors = @[COLOR_WITH_ALPHA(0xF45E5E, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x69D360, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xF45E5E, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x69D360, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xF45E5E, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x69D360, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xF45E5E, 1),COLOR_WITH_ALPHA(0xF45E5E, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x69D360, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xF45E5E, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xF45E5E, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x69D360, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xF45E5E, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xF45E5E, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x69D360, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1),COLOR_WITH_ALPHA(0xF45E5E, 1),COLOR_WITH_ALPHA(0xFFAF38, 1),COLOR_WITH_ALPHA(0x39A0FF, 1),COLOR_WITH_ALPHA(0xBD5CF9, 1)];
    
    for (int i=0; i<weeks.count; i++) {
        
        UIView *viewContainer =[self.mainScrollView viewWithTag:5000+i];
        
        for (int j=0; j<[counts[i] integerValue]; j++) {
            HXFaceTimeTableModel *item = self.items[j];
            UIView *view =[[UIView alloc] init];
            view.backgroundColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
            [viewContainer addSubview:view];
            view.hidden= arc4random()%2==1?YES:NO;
            
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
            label.text = item.courseName;
            [colorview addSubview:label];
            
            view.sd_layout
            .topSpaceToView(viewContainer, j*124)
            .leftEqualToView(viewContainer)
            .rightEqualToView(viewContainer)
            .heightIs(124);
            
            colorview.sd_layout.spaceToSuperView(UIEdgeInsetsMake(3, 3, 3, 3));
            colorview.sd_cornerRadius =@4;
            
            label.sd_layout.spaceToSuperView(UIEdgeInsetsMake(2, 5, 2, 5));
        }
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
        [_riQiBtn setTitle:@"9月28日 周三 第4周" forState:UIControlStateNormal];
        [_riQiBtn setImage:[UIImage imageNamed:@"set_arrow"] forState:UIControlStateNormal];
        [_riQiBtn addTarget:self action:@selector(selectRiQi:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _riQiBtn;
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


@end
