//
//  HXFaceConfigObject.m
//  gaojijiao
//
//  Created by Mac on 2020/3/16.
//  Copyright © 2020 华夏大地教育网. All rights reserved.
//

#import "HXFaceConfigObject.h"

@implementation HXFaceConfigObject

- (NSArray *)Altert
{
    switch (self.faceType) {
        case 1:
            return self.AltertKJ;
            break;
        case 2:
            return self.AltertZY;
            break;
        case 3:
            return self.AltertKS;
            break;
        default:
            return self.AltertBK;
            break;
    }
    return nil;
}

- (BOOL)faceCj
{
    switch (self.faceType) {
        case 1:
            return [self.KJFaceCjOrDb isEqualToString:@"1"];
            break;
        case 2:
            return [self.ZYFaceCjOrDb isEqualToString:@"1"];
            break;
        case 3:
            return [self.QMFaceCjOrDb isEqualToString:@"1"];
            break;
        default:
            return [self.BKFaceCjOrDb isEqualToString:@"1"];
            break;
    }
    return NO;
}

- (BOOL)IsFaceMatch
{
    switch (self.faceType) {
        case 1:
            return self.IsKJFaceMatch;
            break;
        case 2:
            return self.IsZYFaceMatch;
            break;
        case 3:
            return self.IsQMFaceMatch;
            break;
        default:
            return self.IsBKFaceMatch;
            break;
    }
    return NO;
}

- (BOOL)IsFaceMatchJK
{
    switch (self.faceType) {
        case 1:
            return self.IsKJFaceMatchJK;
            break;
        case 2:
            return self.IsZYFaceMatchJK;
            break;
        case 3:
            return self.IsQMFaceMatchJK;
            break;
        default:
            return self.IsBKFaceMatchJK;
            break;
    }
    return NO;
}

- (id)copyWithZone:(NSZone *)zone
{
    id copyObject = [[[self class] allocWithZone:zone] init];
    
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i++)
    {
        NSString *key = [[NSString stringWithUTF8String:ivar_getName(ivars[i])] substringFromIndex:1];
        [copyObject setValue:[self valueForKey:key] forKey:key];
    }
    return copyObject;
}

@end
