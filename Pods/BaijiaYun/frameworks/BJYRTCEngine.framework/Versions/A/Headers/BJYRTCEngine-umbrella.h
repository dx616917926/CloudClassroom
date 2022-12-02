#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "BJYPlayerView.h"
#import "BJYRoomOptions.h"
#import "BJYRTCAdapter.h"
#import "BJYRTCEngine.h"
#import "BJYRTCEngineDefines.h"
#import "BJYRTCEngineDelegate.h"
#import "BJYRTCKeys.h"
#import "BJYRTCLog.h"
#import "BJYRTCMessage.h"
#import "BJYRTMPMediaView.h"
#import "BJYAudioMixerManager.h"

FOUNDATION_EXPORT double BJYRTCEngineVersionNumber;
FOUNDATION_EXPORT const unsigned char BJYRTCEngineVersionString[];

