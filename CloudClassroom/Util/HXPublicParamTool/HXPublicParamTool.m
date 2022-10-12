//
//  HXPublicParamTool.m
//  HXCloudClass
//
//  Created by Mac on 2020/7/22.
//  Copyright © 2020 华夏大地教育网. All rights reserved.
//

#import "HXPublicParamTool.h"

@interface HXPublicParamTool()

@property (nonatomic,strong)NSUserDefaults * userDefault;

@end


@implementation HXPublicParamTool

@synthesize isLogin = _isLogin , currentSchoolModel = _currentSchoolModel , token = _token , student_id = _student_id , name = _name,
personId = _personId ,major_id = _major_id , examineeNo = _examineeNo , studentNo = _studentNo , class_id = _class_id ,enterDate = _enterDate , subSchool_id = _subSchool_id , studentState_id = _studentState_id , uuid = _uuid ,schoolDomainURL = _schoolDomainURL, currentSemesterid = _currentSemesterid;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static HXPublicParamTool *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}


+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}


#pragma mark - Setter/Getter
- (NSUserDefaults *)userDefault{
    if (!_userDefault) {
        _userDefault = [NSUserDefaults standardUserDefaults];
    }
    return _userDefault;
}

-(void)setCurrentSchoolModel:(HXSchoolModel *)currentSchoolModel{
    _currentSchoolModel = currentSchoolModel;
    [self.userDefault setObject:[NSKeyedArchiver archivedDataWithRootObject:currentSchoolModel] forKey:@"currentSchoolModel"];
}

-(HXSchoolModel *)currentSchoolModel{
    if (!_currentSchoolModel) {
        _currentSchoolModel = [NSKeyedUnarchiver unarchiveObjectWithData:[HXUserDefaults objectForKey:@"currentSchoolModel"]];
    }
    return _currentSchoolModel;
}

- (BOOL)isLogin{
    if (!_isLogin) {
        _isLogin = [self.userDefault boolForKey:@"islogin"];
    }
    return _isLogin;
}
- (void)setIsLogin:(BOOL)isLogin{
    _isLogin = isLogin;
    [self.userDefault setBool:isLogin forKey:@"islogin"];
}

-(void)setToken:(NSString *)token{
    _token = token;
    [self.userDefault setObject:token forKey:@"token"];
}

-(NSString *)token{
    if (!_token) {
        _token = [self.userDefault objectForKey:@"token"];
    }
    return _token;
}

-(void)setStudent_id:(NSString *)student_id{
    _student_id = student_id;
    [self.userDefault setObject:student_id forKey:@"student_id"];
}

-(NSString *)student_id{
    if (!_student_id) {
        _student_id = [self.userDefault objectForKey:@"student_id"];
    }
    return _student_id;
}


-(void)setName:(NSString *)name{
    _name = name;
    [self.userDefault setObject:name forKey:@"name"];
}

-(NSString *)name{
    if (!_name) {
        _name = [self.userDefault objectForKey:@"name"];
    }
    return _name;
}

-(void)setPersonId:(NSString *)personId{
    _personId = personId;
    [self.userDefault setObject:personId forKey:@"personId"];
}

- (NSString *)personId{
    if (!_personId) {
        _personId = [self.userDefault objectForKey:@"personId"];
    }
    return _personId;
}

-(void)setMajor_id:(NSString *)major_id{
    _major_id = major_id;
    [self.userDefault setObject:major_id forKey:@"major_id"];
}

- (NSString *)major_id{
    if (!_major_id) {
        _major_id = [self.userDefault objectForKey:@"major_id"];
    }
    return _major_id;
}

- (void)setExamineeNo:(NSString *)examineeNo{
    _examineeNo = examineeNo;
    [self.userDefault setObject:examineeNo forKey:@"examineeNo"];
}

-(NSString *)examineeNo{
    if (!_examineeNo) {
        _examineeNo = [self.userDefault objectForKey:@"examineeNo"];
    }
    return _examineeNo;
}

- (void)setStudentNo:(NSString *)studentNo{
    _studentNo = studentNo;
    [self.userDefault setObject:studentNo forKey:@"studentNo"];
}

-(NSString *)studentNo{
    if (!_studentNo) {
        _studentNo = [self.userDefault objectForKey:@"studentNo"];
    }
    return _studentNo;
}

- (void)setClass_id:(NSString *)class_id{
    _class_id = class_id;
    [self.userDefault setObject:class_id forKey:@"class_id"];
}

-(NSString *)class_id{
    if (!_class_id) {
        _class_id = [self.userDefault objectForKey:@"class_id"];
    }
    return _class_id;
}

- (void)setEnterDate:(NSString *)enterDate{
    _enterDate = enterDate;
    [self.userDefault setObject:enterDate forKey:@"enterDate"];
}

-(NSString *)enterDate{
    if (!_enterDate) {
        _enterDate = [self.userDefault objectForKey:@"enterDate"];
    }
    return _enterDate;
}

- (void)setSubSchool_id:(NSString *)subSchool_id{
    _subSchool_id = subSchool_id;
    [self.userDefault setObject:subSchool_id forKey:@"subSchool_id"];
}

-(NSString *)subSchool_id{
    if (!_subSchool_id) {
        _subSchool_id = [self.userDefault objectForKey:@"subSchool_id"];
    }
    return _subSchool_id;
}

- (void)setStudentState_id:(NSString *)studentState_id{
    _studentState_id = studentState_id;
    [self.userDefault setObject:studentState_id forKey:@"studentState_id"];
}

-(NSString *)studentState_id{
    if (!_studentState_id) {
        _studentState_id = [self.userDefault objectForKey:@"studentState_id"];
    }
    return _studentState_id;
}

- (void)setUuid:(NSString *)uuid{
    _uuid = uuid;
    [self.userDefault setObject:uuid forKey:@"uuid"];
}

-(NSString *)uuid{
    if (!_uuid) {
        _uuid = [self.userDefault objectForKey:@"uuid"];
    }
    return _uuid;
}

- (void)setCurrentSemesterid:(NSString *)currentSemesterid{
    _currentSemesterid = currentSemesterid;
    [self.userDefault setObject:_currentSemesterid forKey:@"currentSemesterid"];
}

-(NSString *)currentSemesterid{
    if (!_currentSemesterid) {
        _currentSemesterid = [self.userDefault objectForKey:@"currentSemesterid"];
    }
    return _currentSemesterid;
}

- (void)setSchoolDomainURL:(NSString *)schoolDomainURL{
    _schoolDomainURL = schoolDomainURL;
    [self.userDefault setObject:schoolDomainURL forKey:@"schoolDomainURL"];
}

-(NSString *)schoolDomainURL{
    if (!_schoolDomainURL) {
        _schoolDomainURL = [self.userDefault objectForKey:@"schoolDomainURL"];
    }
    return _schoolDomainURL;
}


- (void)logOut {
    
    //清除内存中数据
    self.isLogin = NO;
    self.token = nil;
    self.student_id = nil;
    self.name = nil;
    self.personId = nil;
    self.major_id = nil;
    self.examineeNo = nil;
    self.studentNo = nil;
    self.class_id = nil;
    self.enterDate = nil;
    self.subSchool_id = nil;
    self.studentState_id = nil;
    self.uuid = nil;
    self.currentSemesterid = nil;
    //清除沙盒中数据
    [self.userDefault synchronize];
    

}

@end
