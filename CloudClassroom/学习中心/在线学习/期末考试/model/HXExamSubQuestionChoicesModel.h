//
//  HXExamSubQuestionChoicesModel.h
//  CloudClassroom
//
//  Created by mac on 2022/11/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXExamSubQuestionChoicesModel : NSObject

///子问题选项序号：A B C D之类
@property(nonatomic, copy) NSString *subChoice_order;
///子问题选项内容
@property(nonatomic, copy) NSString *subChoice_staticContent;

///是否选中
@property(nonatomic, assign) BOOL isSelected;

@end

NS_ASSUME_NONNULL_END
