//
//  BJLQuestionAnswerSheetUserDetailTableViewCell.h
//  BJLiveUI
//
//  Created by fanyi on 2019/6/4.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <BJLiveCore/BJLAnswerSheet.h>
#import <BJLiveCore/BJLRoom.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLQuestionAnswerSheetUserDetailTableViewCell: UITableViewCell

- (void)updateWithUserDetailModel:(nullable BJLAnswerSheetUserDetail *)userDetail
                      hasSubmited:(BOOL)hasSubmited
                         userInfo:(nullable BJLUser *)userInfo
                        groupInfo:(nullable BJLUserGroup *)groupInfo
                             room:(nullable BJLRoom *)room;

@end

NS_ASSUME_NONNULL_END
