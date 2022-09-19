//
//  HXFaceConfigObject.h
//  gaojijiao
//
//  Created by Mac on 2020/3/16.
//  Copyright © 2020 华夏大地教育网. All rights reserved.
//

#import <Foundation/Foundation.h>

//人脸识别配置参数
@interface HXFaceConfigObject : NSObject<NSCopying>

@property(nonatomic, strong) NSArray *AltertBK;      //补考时弹出的考试须知地址
@property(nonatomic, strong) NSArray *AltertKJ;       //课件时弹出的学习须知地址
@property(nonatomic, strong) NSArray *AltertZY;       //作业时弹出的考试须知地址
@property(nonatomic, strong) NSArray *AltertKS;       //期末考试时弹出的考试须知地址

@property(nonatomic, strong) NSArray *FaceMessage;    //人人脸识别提示文字

@property(nonatomic, assign) BOOL IsKJFaceMatch;      //课件是否需要人脸识别
@property(nonatomic, assign) BOOL IsQMFaceMatch;      //期末考试是否需要人脸识别
@property(nonatomic, assign) BOOL IsZYFaceMatch;      //作业是否需要人脸识别
@property(nonatomic, assign) BOOL IsBKFaceMatch;      //补考是否需要人脸识别

@property(nonatomic, assign) BOOL IsKJFaceMatchJK;    //课件如果开启了人脸识别，是否需要监控。
@property(nonatomic, assign) BOOL IsQMFaceMatchJK;    //期末如果开启了人脸识别，是否需要监控。
@property(nonatomic, assign) BOOL IsZYFaceMatchJK;    //作业如果开启了人脸识别，是否需要监控。
@property(nonatomic, assign) BOOL IsBKFaceMatchJK;    //补考如果开启了人脸识别，是否需要监控。

@property(nonatomic, strong) NSString *KJFaceCjOrDb;  //课件时 1表示采集  2表示对比
@property(nonatomic, strong) NSString *ZYFaceCjOrDb;  //作业时 1表示采集  2表示对比
@property(nonatomic, strong) NSString *QMFaceCjOrDb;  //期末时 1表示采集  2表示对比
@property(nonatomic, strong) NSString *BKFaceCjOrDb;  //补考时 1表示采集  2表示对比

@property(nonatomic, strong) NSString *imageURL;      //人脸识别的图片地址   如果为空，表示没有已审核的照片或者未上传照片
@property(nonatomic, strong) NSString *imageStatus;   //照片状态  0表示未审核   1表示已审核   -1表示没有上传照片

@property(nonatomic, strong) NSString *modelID;       //课程ID 后加的参数

@property(nonatomic, assign) NSInteger QuitCount;     //APP可以退出的次数
@property(nonatomic, assign) NSInteger QuitTime;      //APP每次退出的最长时间（秒），如果超过这个时间，则自动视为舞弊
@property(nonatomic, assign) NSInteger QuitMinTime;   //APP每次退出的最短时间（秒），如果没超过这个时间，则不计算次数
@property(nonatomic, strong) NSString *WarnStr;       //退出APP时候的提示
@property(nonatomic, assign) NSInteger BKFaceMatchTimes;   //考试途中需要进行人脸识别的次数

@property(nonatomic, assign) BOOL IsUsingRTC;         //是否开启实时监控，考试过程中如果开启人脸识别，默认还是走之前的弹出对比。如果开启了实时监控，则使用实时监控
@property(nonatomic, assign) BOOL IsSavePhotoByBack;  //如果开启实时监控，是否开启后置摄像头拍照

//自定义字段
@property(nonatomic, assign) NSInteger faceType;    //来源 不传默认为0。补考考试人脸识别使用默认值0；正常考试人脸识别使用参数如下（1表示课件学习 2表示平时作业 3表示期末考试）；模拟人脸识别传递4；
@property(nonatomic, assign, readonly) BOOL IsFaceMatch;      //根据来源判断是否需要人脸识别。
@property(nonatomic, assign, readonly) BOOL IsFaceMatchJK;    //根据来源判断是否需要监控。
@property(nonatomic, assign, readonly) BOOL faceCj;           //人脸拍照
@property(nonatomic, strong, readonly) NSArray *Altert;       //考试须知地址

@end
