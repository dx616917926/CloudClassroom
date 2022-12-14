//
//  HXCalendarManager.m
//  HXXiaoGuan
//
//  Created by mac on 2021/6/1.
//

#import "HXCalendarManager.h"


@implementation HXCalendarManager
- (void)setCalenderScrollView:(HXCalendarScrollView *)calenderScrollView{
    _calenderScrollView = calenderScrollView;
    calenderScrollView.calendarView.eventSource = self.eventSource;

}
- (void)setEventSource:(id<HXCalendarEventSource>)eventSource{
    _eventSource = eventSource;
    self.calenderScrollView.calendarView.eventSource = self.eventSource;
   
}

- (void)goBackToday{
    self.calenderScrollView.calendarView.currentDate = [NSDate date];
    [self.calenderScrollView.calendarView reloadAppearance];
}
/// 重新加载外观和数据
- (void)reloadAppearanceAndData{
    [self.weekDayView reloadAppearance];
    [self.calenderScrollView.calendarView reloadAppearance];
}

- (void)showSingleWeek{
    [self.calenderScrollView scrollToSingleWeek];
}
- (void)showAllWeek{
    [self.calenderScrollView scrollToAllWeek];
}

///  前一页。上个月
- (void)loadPreviousPage{
    [self.calenderScrollView.calendarView loadPreviousPage];
}
///   下一页 下一个月

- (void)loadNextPage{
    [self.calenderScrollView.calendarView loadNextPage];
}
- (NSDate *)currentSelectedDate{
    return self.calenderScrollView.calendarView.currentDate;
}
@end
