//
//  HXExamParaModel.h
//  CloudClassroom
//
//  Created by mac on 2022/10/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXExamParaModel : NSObject

@property(nonatomic, copy) NSString *allowCount;
///
@property(nonatomic, copy) NSString *appID;
///考试系统域名
@property(nonatomic, copy) NSString *domain;
///考试地址
@property(nonatomic, copy) NSString *examURL;
///是否可以，1是可以，0是不可以
@property(nonatomic, assign) NSInteger isCan;
///
@property(nonatomic, copy) NSString *limitedTime;
///模块代码
@property(nonatomic, copy) NSString *moduleCode;
///
@property(nonatomic, copy) NSString *pre;
///
@property(nonatomic, copy) NSString *resume;
///
@property(nonatomic, copy) NSString *syncURL;
///
@property(nonatomic, copy) NSString *userId;
///
@property(nonatomic, copy) NSString *vac;
///
@property(nonatomic, copy) NSString *vr;
///
@property(nonatomic, copy) NSString *vs;

@end

NS_ASSUME_NONNULL_END
