//
//  HXCalendarDayItem.h
//  HXXiaoGuan
//
//  Created by mac on 2021/6/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@import UIKit;
@interface HXCalendarDayItem : NSObject
@property (nonatomic,strong)NSDate *date;
@property (nonatomic,assign)BOOL isOtherMonth;
@property (nonatomic,assign)BOOL isSelected;
@property (nonatomic,strong)UIColor *eventDotColor;
@property (nonatomic,assign)BOOL showEventDot;
@end

NS_ASSUME_NONNULL_END
