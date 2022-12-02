//
//  BJLStudyRoomQuestion.h
//  BJLiveCore
//
//  Created by Ney on 3/3/21.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, BJLStudyRoomQuestionReplyType) {
    BJLStudyRoomQuestionReplyByText = 1,
    BJLStudyRoomQuestionReplyBy1v1 = 2,
};

NS_ASSUME_NONNULL_BEGIN

@interface BJLStudyRoomQuestion: NSObject <NSCopying>
@property (nonatomic, copy, readonly) NSString *roomID;
@property (nonatomic, copy, readonly) NSString *studentNumber;

@property (nonatomic, copy, readonly) NSString *questionText;
@property (nonatomic, copy, readonly) NSArray<NSString *> *questionImages;

@property (nonatomic, copy, readonly) NSString *questionDate;
@end

@interface BJLStudyRoomQuestionAndAnswer: BJLStudyRoomQuestion <NSCopying>
@property (nonatomic, copy, readonly) NSString *assistantNumber;
@property (nonatomic, copy, readonly) NSString *assistantName;

@property (nonatomic, copy, readonly) NSString *answerText;
@property (nonatomic, copy, readonly) NSArray<NSString *> *answerImages;
@end

@interface BJLStudyRoomQuestionReplyNotification: NSObject <NSCopying>
@property (nonatomic, assign, readonly) BJLStudyRoomQuestionReplyType replyType;
@property (nonatomic, copy, readonly) NSString *enterRoomCode;
@end
NS_ASSUME_NONNULL_END
