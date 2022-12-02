//
//  BJRTC.m
//  BJRTCSDK
//
//  Created by Chengchao on 8/10/18.
//  Copyright © 2018 xinyapeng. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <BJRTCSDK/BJRTCSFUOptions.h>

@class BRTCSessionDescription;

@interface BJRTCSDPUtils : NSObject

// Updates the original SDP description to instead prefer the specified video
// codec. We do this by placing the specified codec at the beginning of the
// codec list if it exists in the sdp.
+ (BRTCSessionDescription *)descriptionForDescription:(BRTCSessionDescription *)description preferredVideoCodec:(BJRTCSupportedCodec)codec;
+ (BRTCSessionDescription *)simulcastDescriptionForDescription:(BRTCSessionDescription *)description;
+ (NSString *)addAudioNackToSdp:(NSString *)sdp;
+ (NSString *)changeMline:(NSString *)sdp;
@end
