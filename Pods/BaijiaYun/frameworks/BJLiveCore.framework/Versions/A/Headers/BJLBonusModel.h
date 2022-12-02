//
//  BJLBonusModel.h
//  BJLBonusModel
//
//  Created by Ney on 7/23/21.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 积分排行类型 */
typedef NS_ENUM(NSInteger, BJLBonusListType) {
    /** 全员排行 */
    BJLBonusListTypeAll,
    /** 小组排行 */
    BJLBonusListTypeGroup,
    /** 我的排名 */
    BJLBonusListTypeMe,
    /** 我的小组排名 */
    BJLBonusListTypeMeInGroup,
};

NS_ASSUME_NONNULL_BEGIN
@interface BJLBonusListItem: NSObject
@property (nonatomic, copy, readonly) NSString *name; // 人名或者组名
@property (nonatomic, assign, readonly) CGFloat points; // 当前积分
@property (nonatomic, assign, readonly) NSInteger ranking; // 排名
@property (nonatomic, copy, readonly) NSString *color; //小组排名时存在该字段
@end

@interface BJLBonusList: NSObject
@property (nonatomic, assign, readonly) BJLBonusListType type; // 排行榜类型
@property (nonatomic, copy, readonly) NSArray<BJLBonusListItem *> *rankList; //排行榜数据
@property (nonatomic, assign, readonly) CGFloat remainPoints; // 当前剩余积分
@end

NS_ASSUME_NONNULL_END
