//
//  HXPublicParamTool.h
//  HXCloudClass
//
//  Created by Mac on 2020/7/22.
//  Copyright © 2020 华夏大地教育网. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HXPublicParamTool : NSObject

+ (instancetype)sharedInstance;


//是否登录成功
@property(nonatomic,assign) BOOL isLogin;
//是否是运行过
@property(nonatomic,assign) BOOL isLaunch;

//userId
@property (nonatomic, strong) NSString *userId;
//token
@property (nonatomic, strong) NSString *accessToken;


///1 学历     2 非学历
@property(nonatomic,assign) NSInteger type;

///是否有查看财务权限1有0无
@property(nonatomic, assign) NSInteger isCwSelRole;

///是否有录入财务权限1有0无
@property(nonatomic, assign) NSInteger isXJSaveRole;

///是否有续缴查看权限1有0无
@property(nonatomic, assign) NSInteger isXJSelRole;

///是否有续缴录入权限1有0无
@property(nonatomic, assign) NSInteger isCwSaveRole;

/******** 机构信息 **********/
// 合作机构Id
@property (nonatomic, strong) NSString *partnerId;
// 合作机构主页地址
@property (nonatomic, strong) NSString *homeUrl;
// 合作机构Logo
@property (nonatomic, strong) NSString *logoUrl;
// 合作机构名称
@property (nonatomic, strong) NSString *partnerName;
// 合作机code值
@property (nonatomic, strong) NSString *code;


/******** 登录返回信息 **********/
//currentYear
@property (nonatomic, strong) NSString *currentYear;

//accountantNoDate
@property (nonatomic, strong) NSString *accountantNoDate;
//skillGrade
@property (nonatomic, strong) NSString *skillGrade;
//userCode
@property (nonatomic, strong) NSString *userCode;
//mobilePhone
@property (nonatomic, strong) NSString *mobilePhone;
//email
@property (nonatomic, strong) NSString *email;

//用户名
@property (nonatomic, strong) NSString *username;
//头像
@property (nonatomic, strong) NSString *avatarImageUrl;
//微博用户头像
@property (nonatomic, strong) NSString *avatar_hd;
//积分
@property (nonatomic, strong) NSString *nowIntegral;
//等级
@property (nonatomic, strong) NSString *level;
//等级名称
@property (nonatomic, strong) NSString *levelName;
//个人成长值
@property (nonatomic, strong) NSString *growthValue;

//保存年份列表
@property (nonatomic, strong) NSArray *yearArray;

#pragma mark - 新增字段
//token
@property (nonatomic, strong) NSString *token;
//隐私协议url
@property (nonatomic, strong) NSString *privacyUrl;

@property (nonatomic, strong) NSString *jiGouLogoUrl;

//退出登录
- (void)logOut;

@end
