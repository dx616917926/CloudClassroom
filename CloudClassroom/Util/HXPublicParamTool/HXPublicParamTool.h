//
//  HXPublicParamTool.h
//  HXCloudClass
//
//  Created by Mac on 2020/7/22.
//  Copyright © 2020 华夏大地教育网. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HXSchoolModel.h"

@interface HXPublicParamTool : NSObject

+ (instancetype)sharedInstance;

///是否登录成功
@property(nonatomic,assign) BOOL isLogin;

///第一次返回JWT的Token
@property (nonatomic, strong) NSString *token;
///学生ID
@property (nonatomic, strong) NSString *student_id;
///姓名
@property (nonatomic, strong) NSString *name;
///身份证
@property (nonatomic, strong) NSString *personId;
///专业ID
@property (nonatomic, strong) NSString *major_id;
///考籍号
@property (nonatomic, strong) NSString *examineeNo;
///学号
@property (nonatomic, strong) NSString *studentNo;
///班级ID
@property (nonatomic, strong) NSString *class_id;
///年级
@property (nonatomic, strong) NSString *enterDate;
///站点
@property (nonatomic, strong) NSString *subSchool_id;
///学生状态
@property (nonatomic, strong) NSString *studentState_id;
///数据库GUID
@property (nonatomic, strong) NSString *uuid;
///学校域名
@property (nonatomic,strong) NSString *schoolDomainURL;
///当前学期
@property (nonatomic,strong) NSString *currentSemesterid;
//当前学校
@property (nonatomic, strong) HXSchoolModel *currentSchoolModel;

//退出登录
- (void)logOut;

@end
