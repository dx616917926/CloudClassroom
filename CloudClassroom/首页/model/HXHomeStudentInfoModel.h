//
//  HXHomeStudentInfoModel.h
//  CloudClassroom
//
//  Created by mac on 2022/10/8.
//  获取首页信息模型

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXHomeStudentInfoModel : NSObject

//姓名
@property(nonatomic, copy) NSString *name;
//身份证
@property(nonatomic, copy) NSString *personId;
//学校id
@property(nonatomic, copy) NSString *subSchool_id;
//学校名称
@property(nonatomic, copy) NSString *subSchoolName;
//头像地址
@property(nonatomic, copy) NSString *imgUrl;
//班级ID
@property(nonatomic, copy) NSString *class_id;
//专业ID
@property(nonatomic, copy) NSString *major_id;
//专业名称
@property(nonatomic, copy) NSString *majorlongName;
//年级
@property(nonatomic, copy) NSString *enterDate;
//本期合格课程
@property(nonatomic, copy) NSString *termQuaCourseCount;
//累计合格课程
@property(nonatomic, copy) NSString *totalQuaCourseCount;

@end

NS_ASSUME_NONNULL_END
