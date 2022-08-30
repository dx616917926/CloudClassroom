//
//  HXCalendarEventSource.h
//  HXXiaoGuan
//
//  Created by mac on 2021/6/1.
//

#import <Foundation/Foundation.h>
@class HXCalendarManager;
NS_ASSUME_NONNULL_BEGIN

@protocol HXCalendarEventSource <NSObject>
/**
 该日期是否有事件
 @param date  NSDate
 @return BOOL
 */
@optional
- (BOOL)calendarHaveEventWithDate:(NSDate *)date;
- (UIColor *)calendarHaveEventDotColorWithDate:(NSDate *)date;

/**
 点击 日期后的执行的操作
 @param date 选中的日期
 */
- (void)calendarDidSelectedDate:(NSDate *)date;


/**
 翻页完成后的操作

 */
- (void)calendarDidLoadPageCurrentDate:(NSDate *)date;
@end

NS_ASSUME_NONNULL_END
