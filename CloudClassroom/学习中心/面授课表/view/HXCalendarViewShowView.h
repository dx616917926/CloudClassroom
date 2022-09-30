//
//  HXCalendarViewShowView.h
//  CloudClassroom
//
//  Created by mac on 2022/9/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HXCalendarViewShowViewDelegate <NSObject>

- (void) preMonth:(NSDate *) date;

- (void) nextMonth:(NSDate *) date;

- (void) today:(NSDate *) date;

@end

@interface HXCalendarViewShowView : UIView
//开始日期
@property (nonatomic, strong) NSDate *startDate;
//选择日期
@property (nonatomic, strong) NSDate *selectedDate;

@property (nonatomic, weak) id<HXCalendarViewShowViewDelegate> delegate;

@property (nonatomic, copy) void (^confirmBlock)(NSDate *date);

-(void)show;

//配置手势
- (void)configGustures;

@end

NS_ASSUME_NONNULL_END
