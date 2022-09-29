//
//  HXFaceTimeTableModel.h
//  CloudClassroom
//
//  Created by mac on 2022/9/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXFaceTimeTableModel : NSObject

@property(nonatomic,strong) NSString *courseName;
@property(nonatomic,strong) NSString *time;
@property(nonatomic,strong) NSString *address;
@property(nonatomic,strong) NSString *teacher;
@property(nonatomic,strong) NSString *status;

@end

NS_ASSUME_NONNULL_END
