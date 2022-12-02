//
//  HXFaceTimeTableShowView.m
//  CloudClassroom
//
//  Created by mac on 2022/9/29.
//

#import "HXFaceTimeTableShowView.h"


@interface HXFaceTimeTableShowView ()

@property(nonatomic,strong) UIView *maskView;
@property(nonatomic,strong) UIView *bigBackGroundView;
@property(nonatomic,strong) UILabel *courseNameLabel;
@property(nonatomic,strong) UILabel *courseNameContentLabel;
@property(nonatomic,strong) UILabel *timeLabel;
@property(nonatomic,strong) UILabel *timeContentLabel;
@property(nonatomic,strong) UILabel *addressLabel;
@property(nonatomic,strong) UILabel *addressContentLabel;
@property(nonatomic,strong) UILabel *teacherLabel;
@property(nonatomic,strong) UILabel *teacherContentLabel;
@property(nonatomic,strong) UILabel *statusLabel;
@property(nonatomic,strong) UILabel *statusContentLabel;
@property(nonatomic,strong) UIButton *closeButton;


@end

@implementation HXFaceTimeTableShowView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self creatUI];
    }
    return self;
}



#pragma mark -Setter
-(void)setFaceTimeCourseDetailModel:(HXFaceTimeCourseDetailModel *)faceTimeCourseDetailModel{
    _faceTimeCourseDetailModel = faceTimeCourseDetailModel;
    
    self.courseNameContentLabel.text = faceTimeCourseDetailModel.termCourseName;
    self.timeContentLabel.text = faceTimeCourseDetailModel.classTime;
    self.addressContentLabel.text = faceTimeCourseDetailModel.roomName;
    self.teacherContentLabel.text = faceTimeCourseDetailModel.teacherName;
    //课程状态 0未开始 1进行中  2已结束
    if (faceTimeCourseDetailModel.courseState==0) {
        self.statusContentLabel.text = @"未开始";
    }else if (faceTimeCourseDetailModel.courseState==1) {
        self.statusContentLabel.text = @"进行中";
    }else if (faceTimeCourseDetailModel.courseState==2) {
        self.statusContentLabel.text = @"已结束";
    }
    
}


-(void)show{
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.maskView];
}

-(void)dismiss{
    [self.maskView removeFromSuperview];
     self.maskView = nil;
}

#pragma mark -UI
-(void)creatUI{
    [self.maskView addSubview:self];
    [self addSubview:self.bigBackGroundView];
    [self.bigBackGroundView addSubview:self.courseNameLabel];
    [self.bigBackGroundView addSubview:self.courseNameContentLabel];
    [self.bigBackGroundView addSubview:self.timeLabel];
    [self.bigBackGroundView addSubview:self.timeContentLabel];
    [self.bigBackGroundView addSubview:self.addressLabel];
    [self.bigBackGroundView addSubview:self.addressContentLabel];
    [self.bigBackGroundView addSubview:self.teacherLabel];
    [self.bigBackGroundView addSubview:self.teacherContentLabel];
    [self.bigBackGroundView addSubview:self.statusLabel];
    [self.bigBackGroundView addSubview:self.statusContentLabel];
    [self addSubview:self.closeButton];
    
    self.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    
    self.bigBackGroundView.sd_layout
    .centerXEqualToView(self)
    .centerYEqualToView(self).offset(-30)
    .widthIs(275)
    .heightIs(322);
    self.bigBackGroundView.sd_cornerRadius = @16;
    
    self.closeButton.sd_layout
    .topSpaceToView(self.bigBackGroundView, 25)
    .centerXEqualToView(self)
    .widthIs(30)
    .heightEqualToWidth();
    self.closeButton.sd_cornerRadiusFromHeightRatio=@0.5;
    
    self.closeButton.imageView.sd_layout
    .centerXEqualToView(self.closeButton)
    .centerYEqualToView(self.closeButton)
    .widthIs(13)
    .heightEqualToWidth();
    
    
    self.courseNameLabel.sd_layout
    .topSpaceToView(self.bigBackGroundView, 27)
    .leftSpaceToView(self.bigBackGroundView, 12)
    .rightSpaceToView(self.bigBackGroundView, 12)
    .heightIs(15);
    
    self.courseNameContentLabel.sd_layout
    .topSpaceToView(self.courseNameLabel, 6)
    .leftEqualToView(self.courseNameLabel)
    .rightEqualToView(self.courseNameLabel)
    .heightIs(17);
    
    self.timeLabel.sd_layout
    .topSpaceToView(self.courseNameContentLabel, 20)
    .leftEqualToView(self.courseNameLabel)
    .rightEqualToView(self.courseNameLabel)
    .heightRatioToView(self.courseNameLabel, 1);
    
    self.timeContentLabel.sd_layout
    .topSpaceToView(self.timeLabel, 6)
    .leftEqualToView(self.courseNameLabel)
    .rightEqualToView(self.courseNameLabel)
    .heightRatioToView(self.courseNameContentLabel, 1);
    
    self.addressLabel.sd_layout
    .topSpaceToView(self.timeContentLabel, 20)
    .leftEqualToView(self.courseNameLabel)
    .rightEqualToView(self.courseNameLabel)
    .heightRatioToView(self.courseNameLabel, 1);
    
    self.addressContentLabel.sd_layout
    .topSpaceToView(self.addressLabel, 6)
    .leftEqualToView(self.courseNameLabel)
    .rightEqualToView(self.courseNameLabel)
    .heightRatioToView(self.courseNameContentLabel, 1);
    
    self.teacherLabel.sd_layout
    .topSpaceToView(self.addressContentLabel, 20)
    .leftEqualToView(self.courseNameLabel)
    .rightEqualToView(self.courseNameLabel)
    .heightRatioToView(self.courseNameLabel, 1);
    
    self.teacherContentLabel.sd_layout
    .topSpaceToView(self.teacherLabel, 6)
    .leftEqualToView(self.courseNameLabel)
    .rightEqualToView(self.courseNameLabel)
    .heightRatioToView(self.courseNameContentLabel, 1);
    
    self.statusLabel.sd_layout
    .topSpaceToView(self.teacherContentLabel, 20)
    .leftEqualToView(self.courseNameLabel)
    .rightEqualToView(self.courseNameLabel)
    .heightRatioToView(self.courseNameLabel, 1);
    
    self.statusContentLabel.sd_layout
    .topSpaceToView(self.statusLabel, 6)
    .leftEqualToView(self.courseNameLabel)
    .rightEqualToView(self.courseNameLabel)
    .heightRatioToView(self.courseNameContentLabel, 1);
}



#pragma mark -LazyLoad
-(UIView *)maskView{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _maskView.backgroundColor = COLOR_WITH_ALPHA(0x000000, 0.5);
    }
    return _maskView;
}



-(UIView *)bigBackGroundView{
    if (!_bigBackGroundView) {
        _bigBackGroundView = [[UIView alloc] init];
        _bigBackGroundView.backgroundColor = UIColor.whiteColor;
    }
    return _bigBackGroundView;
}

-(UILabel *)courseNameLabel{
    if (!_courseNameLabel) {
        _courseNameLabel = [[UILabel alloc] init];
        _courseNameLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _courseNameLabel.font = HXFont(13);
        _courseNameLabel.textAlignment = NSTextAlignmentCenter;
        _courseNameLabel.text = @"课程名称";
    }
    return _courseNameLabel;
}

-(UILabel *)courseNameContentLabel{
    if (!_courseNameContentLabel) {
        _courseNameContentLabel = [[UILabel alloc] init];
        _courseNameContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _courseNameContentLabel.font = HXFont(15);
        _courseNameContentLabel.textAlignment = NSTextAlignmentCenter;
        
    }
    return _courseNameContentLabel;
}

-(UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _timeLabel.font = HXFont(13);
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.text = @"上课时间";
    }
    return _timeLabel;
}

-(UILabel *)timeContentLabel{
    if (!_timeContentLabel) {
        _timeContentLabel = [[UILabel alloc] init];
        _timeContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _timeContentLabel.font = HXFont(15);
        _timeContentLabel.textAlignment = NSTextAlignmentCenter;
        
    }
    return _timeContentLabel;
}

-(UILabel *)addressLabel{
    if (!_addressLabel) {
        _addressLabel = [[UILabel alloc] init];
        _addressLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _addressLabel.font = HXFont(13);
        _addressLabel.textAlignment = NSTextAlignmentCenter;
        _addressLabel.text = @"上课地址";
    }
    return _addressLabel;
}

-(UILabel *)addressContentLabel{
    if (!_addressContentLabel) {
        _addressContentLabel = [[UILabel alloc] init];
        _addressContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _addressContentLabel.font = HXFont(15);
        _addressContentLabel.textAlignment = NSTextAlignmentCenter;
        
    }
    return _addressContentLabel;
}

-(UILabel *)teacherLabel{
    if (!_teacherLabel) {
        _teacherLabel = [[UILabel alloc] init];
        _teacherLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _teacherLabel.font = HXFont(13);
        _teacherLabel.textAlignment = NSTextAlignmentCenter;
        _teacherLabel.text = @"上课老师";
    }
    return _teacherLabel;
}

-(UILabel *)teacherContentLabel{
    if (!_teacherContentLabel) {
        _teacherContentLabel = [[UILabel alloc] init];
        _teacherContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _teacherContentLabel.font = HXFont(15);
        _teacherContentLabel.textAlignment = NSTextAlignmentCenter;
        
    }
    return _teacherContentLabel;
}

-(UILabel *)statusLabel{
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _statusLabel.font = HXFont(13);
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.text = @"上课状态";
    }
    return _statusLabel;
}

-(UILabel *)statusContentLabel{
    if (!_statusContentLabel) {
        _statusContentLabel = [[UILabel alloc] init];
        _statusContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _statusContentLabel.font = HXFont(15);
        _statusContentLabel.textAlignment = NSTextAlignmentCenter;
       
    }
    return _statusContentLabel;
}

-(UIButton *)closeButton{
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.backgroundColor =COLOR_WITH_ALPHA(0xFFFFFF, 0.2);
        [_closeButton setImage:[UIImage imageNamed:@"closewhite_icon"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}







@end


