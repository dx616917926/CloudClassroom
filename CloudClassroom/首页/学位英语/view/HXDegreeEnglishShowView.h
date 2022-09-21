//
//  HXDegreeEnglishShowView.h
//  CloudClassroom
//
//  Created by mac on 2022/9/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    FeiBenKeShengType,
    WeiKaiFangBaoMingType,
    WeiManZuTiaoJianType,
} DegreeEnglishType;

@interface HXDegreeEnglishShowView : UIView

@property(nonatomic,assign) DegreeEnglishType type;

-(void)show;

@end

NS_ASSUME_NONNULL_END
