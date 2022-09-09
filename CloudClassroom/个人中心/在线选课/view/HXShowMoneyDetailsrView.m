//
//  HXShowMoneyDetailsrView.m
//  CloudClassroom
//
//  Created by mac on 2022/9/8.
//

#import "HXShowMoneyDetailsrView.h"
#import "HXShowMajorCell.h"

@interface HXShowMoneyDetailsrView ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UIView *maskView;
@property(nonatomic,strong) UIView *bigBackGroundView;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) UIControl *dismissControl;

//记录初始选择
@property(nonatomic,assign) NSInteger selectIndex;
@property(nonatomic,assign) BOOL isRefresh;
@property(nonatomic,strong) HXMajorModel *selectMajorModel;

@end

@implementation HXShowMoneyDetailsrView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self creatUI];
    }
    return self;
}


#pragma mark - Setter
-(void)setDataArray:(NSArray *)dataArray{
    _dataArray = dataArray;
    [dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HXMajorModel *model = obj;
        if (model.isSelected) {
            self.selectIndex = idx;
            self.selectMajorModel = model;
            *stop = YES;
            return;
        }
    }];
}


#pragma mark - Public Method
-(void)show{
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.maskView];
   
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.bigBackGroundView.sd_layout.bottomSpaceToView(self.maskView, 0);
        [self.bigBackGroundView updateLayout];
    } completion:^(BOOL finished) {
        self.isShow = YES;
        if (self.callBack) {
            self.callBack();
        }
    }];
    [self.tableView reloadData];
    
    ///滑动到选择的项中间
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

-(void)dismiss{
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.bigBackGroundView.sd_layout.bottomSpaceToView(self.maskView, -423);
        [self.bigBackGroundView updateLayout];
    } completion:^(BOOL finished) {
        self.isShow = NO;
        if (self.callBack) {
            self.callBack();
        }
        [self removeFromSuperview];
        [self.maskView removeFromSuperview];
    }];
    
}

-(void)creatUI{
    [self addSubview:self.maskView];
    [self.maskView addSubview:self.bigBackGroundView];
    [self.maskView addSubview:self.dismissControl];
    [self.bigBackGroundView addSubview:self.titleLabel];
    [self.bigBackGroundView addSubview:self.tableView];
    
    
   
    self.bigBackGroundView.sd_layout
    .leftEqualToView(self.maskView)
    .rightEqualToView(self.maskView)
    .bottomSpaceToView(self.maskView, -423)
    .heightIs(423);
    [self.bigBackGroundView updateLayout];
    [self.bigBackGroundView updateLayout];
    
    
    self.dismissControl.sd_layout
    .topEqualToView(self.maskView)
    .leftEqualToView(self.maskView)
    .rightEqualToView(self.maskView)
    .bottomSpaceToView(self.bigBackGroundView, 0);
   
    
    //圆角
   UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bigBackGroundView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(16 ,16)];
   CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
   maskLayer.frame =self.bigBackGroundView.bounds;
   maskLayer.path = maskPath.CGPath;
   self.bigBackGroundView.layer.mask = maskLayer;
    
    self.titleLabel.sd_layout
    .topSpaceToView(self.bigBackGroundView, 20)
    .leftSpaceToView(self.bigBackGroundView, 16)
    .rightSpaceToView(self.bigBackGroundView, 16)
    .heightIs(21);
    
    
    
    self.tableView.sd_layout
    .topSpaceToView(self.titleLabel, 20)
    .leftEqualToView(self.bigBackGroundView)
    .rightEqualToView(self.bigBackGroundView)
    .bottomSpaceToView(self.bigBackGroundView, 0);
    
    
   

}



#pragma mark - <UITableViewDelegate,UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *showMajorCellIdentifier = @"HXShowMajorCellIdentifier";
    HXShowMajorCell *cell = [tableView dequeueReusableCellWithIdentifier:showMajorCellIdentifier];
    if (!cell) {
        cell = [[HXShowMajorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:showMajorCellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.bounces = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            _tableView.estimatedRowHeight = 0;
        }
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.scrollIndicatorInsets = _tableView.contentInset;
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
    
}
-(UIView *)maskView{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-80)];
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



-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _titleLabel.font = HXBoldFont(15);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"金额明细";
    }
    return _titleLabel;
}

@end

