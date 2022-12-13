//
//  HXDegreeEnglishShowView.h
//  CloudClassroom
//
//  Created by mac on 2022/9/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    FeiBenKeShengType,//非本科生
    WeiKaiFangBaoMingType,//未开放报名
    WeiManZuTiaoJianType,//未满足学位申请的条件
} DegreeEnglishType;

@interface HXDegreeEnglishShowView : UIView

@property(nonatomic,assign) DegreeEnglishType type;

-(void)show;

@end

NS_ASSUME_NONNULL_END
