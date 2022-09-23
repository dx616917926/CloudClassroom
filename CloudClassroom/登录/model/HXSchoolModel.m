//
//  HXSchoolModel.m
//  CloudClassroom
//
//  Created by mac on 2022/9/22.
//

#import "HXSchoolModel.h"

@implementation HXSchoolModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"schoolDomainURL":@"url",
             @"schoolName_En":@"ename",
             @"schoolName_Cn":@"cname"};
}

- (NSString *)schoolLogoUrl{
    return @"https://demo.edu-edu.com.cn/login/images/qrcode/demo_logo.png";
//    return [NSString stringWithFormat:@"%@/login/images/qrcode/%@_logo.png",_schoolDomainURL,_schoolName_En];
}

-(NSString *)schoolBgUrl{
    return @"https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fpic1.win4000.com%2Fwallpaper%2F2%2F51a4675984d4f.jpg%3Fdown&refer=http%3A%2F%2Fpic1.win4000.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1666430870&t=fc9a811a834e2e7c3c04f85acc4878b6";
}

#pragma mark - <NSCoding>归档和解档

- (void)encodeWithCoder:(NSCoder *)coder {
    unsigned int numberOfIvars = 0;
    //成员变量
    Ivar *ivars = class_copyIvarList([self class], &numberOfIvars);
    
    for (const Ivar *p = ivars; p < ivars + numberOfIvars; p++) {
        Ivar const ivar = *p;
        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        [coder encodeObject:[self valueForKey:key] forKey:key];
    }
    free(ivars);
}
 
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        unsigned int numberOfIvars = 0;
        //成员变量
        Ivar *ivars = class_copyIvarList([self class], &numberOfIvars);
        
        for (const Ivar *p = ivars; p < ivars + numberOfIvars; p++) {
            Ivar const ivar = *p;
            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
            [self setValue:[coder decodeObjectForKey:key] forKey:key];
        }
        free(ivars);
    }
    return self;
}

@end
