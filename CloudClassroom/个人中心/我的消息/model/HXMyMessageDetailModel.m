//
//  HXMyMessageDetailModel.m
//  CloudClassroom
//
//  Created by mac on 2022/11/25.
//

#import "HXMyMessageDetailModel.h"

@implementation HXMyMessageDetailModel

+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"respMessageAttaches" : @"HXMessageAttachmentModel"
             };
}

@end
