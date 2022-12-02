//
//  RTCatError.h
//  RTCatSDK
//
//  Created by cong chen on 10/20/16.
//  Copyright © 2016 cong chen. All rights reserved.
//

#ifndef BJRTCError_h
#define BJRTCError_h

/**
 *  RTCat Error
 */
typedef NS_ENUM(NSInteger, BJRTCError) {
    /// 未知错误
    BJRTCError_Unknown = 0,
    ///
    BJRTCError_RequestTimeout = 3,
    ///
    BJRTCError_NotAvailableCode = 101,
    ///
    BJRTCError_NotExistCode = 102,
    ///
    BJRTCError_AlreadyExistCode = 103,
    ///
    BJRTCError_NotReadyCode = 104,
    ///
    BJRTCError_InvalidRequestCode = 105,
    ///
    BJRTCError_NotAllowedCode = 106,
    ///
    BJRTCError_TokenInvalidCode = 107,
    ///
    BJRTCError_InternalErrorCode = 3000,
    ///
    BJRTCError_RootDownCode = 3001,
    ///
    BJRTCError_RouterDownCode = 3002,
    ///
    BJRTCError_CaptureErrorCode = 4000,
    /// publish 内部错误
    BJRTCError_PublishInternalError,
    /// subscibe 内部错误
    BJRTCError_SubscribeInternalError,
};

FOUNDATION_EXPORT NSString *const BJRTC_ERROR_DOMAIN_SESSION;
FOUNDATION_EXPORT NSString *const BJRTC_ERROR_DOMAIN_PUBLISH;
FOUNDATION_EXPORT NSString *const BJRTC_ERROR_DOMAIN_SUBSCRIBE;

FOUNDATION_EXPORT NSString *const BJRTC_ERROR_UNKNOWN_DESP;
FOUNDATION_EXPORT NSString *const BJRTC_ERROR_SESSION_INVALID_DESP;
FOUNDATION_EXPORT NSString *const BJRTC_ERROR_SESSION_TOKEN_USED_DESP;
FOUNDATION_EXPORT NSString *const BJRTC_ERROR_SESSION_TYPE_MISMATCH_DESP;
FOUNDATION_EXPORT NSString *const BJRTC_ERROR_SESSION_TYPE_SUPPORTLESS_DESP;

FOUNDATION_EXPORT NSString *const BJRTC_ERROR_PUBLISH_INTERNAL_ERROR_DESP;
FOUNDATION_EXPORT NSString *const BJRTC_ERROR_SUBSCRIBE_INTERNAL_ERROR_DESP;


#endif /* BJRTCError_h */

