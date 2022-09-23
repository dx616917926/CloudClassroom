//
//  HXSchoolModel.h
//  CloudClassroom
//
//  Created by mac on 2022/9/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXSchoolModel : NSObject<NSCoding>

@property (nonatomic,copy) NSString *schoolDomainURL;//学校域名
@property (nonatomic,copy) NSString *schoolName_En;//英文名
@property (nonatomic,copy) NSString *schoolName_Cn;//中文名
@property (nonatomic,copy) NSString *schoolLogoUrl;//学校logo图片
@property (nonatomic,copy) NSString *schoolBgUrl;//学校图片

@end

NS_ASSUME_NONNULL_END
