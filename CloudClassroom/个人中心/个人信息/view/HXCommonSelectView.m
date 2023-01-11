//
//  HXCommonSelectView.m
//  CloudClassroom
//
//  Created by mac on 2023/1/11.
//

#import "HXCommonSelectView.h"
#import "HXCommonSelectCell.h"



@interface HXCommonSelectView ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UIView *maskView;
@property(nonatomic,strong) UIView *bigBackGroundView;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UIView *lineView;
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) UIControl *dismissControl;

//记录初始选择
@property(nonatomic,assign) NSInteger selectIndex;
@property(nonatomic,assign) BOOL isRefresh;
@property(nonatomic,strong) HXCommonSelectModel *selecModel;

@end

@implementation HXCommonSelectView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self creatUI];
    }
    return self;
}


#pragma mark - Setter
-(void)setDataArray:(NSArray<HXCommonSelectModel *> *)dataArray{
    _dataArray = dataArray;
    self.selectIndex = 0;
    [dataArray enumerateObjectsUsingBlock:^(HXCommonSelectModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HXCommonSelectModel *model = obj;
        if (model.isSelected) {
            self.selecModel = model;
            self.selectIndex = idx;
            *stop = YES;
            return;
        }
    }];
}

-(void)setTitle:(NSString *)title{
    _title = title;
    self.titleLabel.text = title;
}


-(void)show{
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.maskView];
   
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.bigBackGroundView.sd_layout.bottomSpaceToView(self.maskView, 0);
        [self.bigBackGroundView updateLayout];
    } completion:^(BOOL finished) {
        
    }];
    [self.tableView reloadData];
    
    ///滑动到选择的项中间
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

-(void)dismiss{
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.bigBackGroundView.sd_layout.bottomSpaceToView(self.maskView, -256-kScreenBottomMargin);
        [self.bigBackGroundView updateLayout];
    } completion:^(BOOL finished) {
        if (self.seletConfirmBlock) {
            self.seletConfirmBlock(self.isRefresh,self.selecModel,self.selectIndex);
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
    [self.bigBackGroundView addSubview:self.lineView];
    [self.bigBackGroundView addSubview:self.tableView];
    
    
    self.bigBackGroundView.sd_layout
    .leftEqualToView(self.maskView)
    .rightEqualToView(self.maskView)
    .bottomSpaceToView(self.maskView, -265-kScreenBottomMargin)
    .heightIs(265+kScreenBottomMargin);
    [self.bigBackGroundView updateLayout];
    
    
    self.dismissControl.sd_layout
    .topEqualToView(self.maskView)
    .leftEqualToView(self.maskView)
    .rightEqualToView(self.maskView)
    .bottomSpaceToView(self.bigBackGroundView, 0);
   
    
    //圆角
   UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bigBackGroundView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10 ,10)];
   CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
   maskLayer.frame =self.bigBackGroundView.bounds;
   maskLayer.path = maskPath.CGPath;
   self.bigBackGroundView.layer.mask = maskLayer;
    
    self.titleLabel.sd_layout
    .topEqualToView(self.bigBackGroundView)
    .leftEqualToView(self.bigBackGroundView)
    .rightEqualToView(self.bigBackGroundView)
    .heightIs(56);
    
    self.lineView.sd_layout
    .topSpaceToView(self.titleLabel, 0)
    .leftEqualToView(self.bigBackGroundView)
    .rightEqualToView(self.bigBackGroundView)
    .heightIs(0.5);
    
    self.tableView.sd_layout
    .topSpaceToView(self.lineView, 0)
    .leftEqualToView(self.bigBackGroundView)
    .rightEqualToView(self.bigBackGroundView)
    .bottomSpaceToView(self.bigBackGroundView, kScreenBottomMargin);
    
}



#pragma mark - <UITableViewDelegate,UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *commonSelectCellIdentifier = @"HXCommonSelectCellIdentifier";
    HXCommonSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:commonSelectCellIdentifier];
    if (!cell) {
        cell = [[HXCommonSelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonSelectCellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ///重置选择
    [self.dataArray enumerateObjectsUsingBlock:^(HXCommonSelectModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HXCommonSelectModel *model = obj;
        if (indexPath.row == idx) {
            self.selectIndex = idx;
            model.isSelected = YES;
            self.selecModel = model;
        }else{
            model.isSelected = NO;
        }
    }];
    self.isRefresh = (self.selectIndex == indexPath.row);
    [self dismiss];
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

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _titleLabel.font = HXBoldFont(15);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        
    }
    return _titleLabel;
}

-(UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = COLOR_WITH_ALPHA(0xD3D3D3, 1);
    }
    return _lineView;
}


@end
