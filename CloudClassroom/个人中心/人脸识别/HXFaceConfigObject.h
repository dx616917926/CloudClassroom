//
//  HXFaceConfigObject.h
//  gaojijiao
//
//  Created by Mac on 2020/3/16.
//  Copyright © 2020 华夏大地教育网. All rights reserved.
//

#import <Foundation/Foundation.h>

//人脸识别配置参数
@interface HXFaceConfigObject : NSObject

///模块类型（1课件 2作业 3期末 0补考 4表示模拟人脸识别）
@property(nonatomic, assign) NSInteger courseType;

///是否需要人脸识别
@property(nonatomic, assign) NSInteger isFaceMatch;

///过程中是否需要监控
@property(nonatomic, assign) NSInteger isFaceMatchJK;

///0不做采集   1强制采集   2随机采集，有跳过按钮
@property(nonatomic, assign) NSInteger face_cj;

///0不做对比   1强制对比    2随机对比
@property(nonatomic, assign) NSInteger face_db;

///对比次数，只对随机对比有效 ,当课件为随机对比时，对比失败次数超过这个值，则有跳过按钮
@property(nonatomic, assign) NSInteger face_cs;

///人脸识别提示文字
@property(nonatomic, strong) NSArray<NSString *> *faceMessage;

///人脸识别的图片地址(如果为空，表示没有已审核的照片)
@property(nonatomic, strong) NSString *imageURL;

///进入模块时，弹出的课件（考试）须知地址，如果有多个，则根据数组返回的顺序弹出
@property(nonatomic, strong) NSArray<NSString *> *altertKJ;

///照片的审核状态，-1:表示没有照片      0:表示未审核     1:表示已审核 
@property(nonatomic, assign) NSInteger imageStatus;

///如果过程中需要监控，APP可以退出的次数
@property(nonatomic, assign) NSInteger quiteCount;

///APP每次退出的最长时间（秒），如果超过这个时间，则自动视为舞弊
@property(nonatomic, assign) NSInteger quiteMaxtimes;

///APP每次切出的时间超过这个数值（秒），才算切出一次
@property(nonatomic, assign) NSInteger quiteMintimes;

///当APP退出(切出)时，提示的语句
@property(nonatomic, strong) NSString *warnStr;

///过程中识别的次数
@property(nonatomic, assign) NSInteger faceTimes;

///考试（学习）过程中，如果需要人脸识别，是否开启实时监控。 1表示开启
@property(nonatomic, assign) NSInteger faceMatchByRTC;

///考试（学习）过程中，如果开启了实时监控，是否需要后置摄像头拍照
@property(nonatomic, assign) NSInteger savePhotoByBack;

///班级计划学期ID（如果是补考，传补考开课ID）
@property(nonatomic, strong)NSString *termCourseID;

@end
