//
//  RollCall.m
//  BJLiveUIBase
//
//  Created by 凡义 on 2022/4/21.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import <BJLiveCore/BJLUser.h>
#import "BJLUser+RollCall.h"

@implementation BJLUser (RollCall)

- (BOOL)canLaunchRollCallWithRoom:(BJLRoom *)room {
    if (!self.isTeacherOrAssistant) { return NO; }

    if (room.roomInfo.newRoomGroupType == BJLRoomNewGroupType_group) {
        BOOL enableGroupAssistant = room.featureConfig.enableGroupAssistantSignIn;
        if (self.groupID == 0 && !enableGroupAssistant) { return YES; }
        if (self.groupID != 0 && enableGroupAssistant) { return YES; }
    }
    else {
        return self.isTeacherOrAssistant && self.groupID == 0;
    }
    return NO;
}

@end
