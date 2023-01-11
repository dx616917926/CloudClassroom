//
//  HXCommonSelectModel.h
//  CloudClassroom
//
//  Created by mac on 2023/1/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXCommonSelectModel : NSObject
///政治面貌
@property(nonatomic,copy) NSString *politicalName;
///民族
@property(nonatomic,copy) NSString *nationName;
///内容
@property(nonatomic,copy) NSString *content;
///政治面貌id
@property(nonatomic,copy) NSString *politicalState_id;
///民族id
@property(nonatomic,copy) NSString *nation_id;
///ID
@property(nonatomic,copy) NSString *contentId;


//是否选中 默认否
@property(nonatomic, assign) BOOL isSelected;

@end

NS_ASSUME_NONNULL_END
