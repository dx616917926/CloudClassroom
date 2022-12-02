//
//   Copyright 2012 Square Inc.
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//

#import <Foundation/Foundation.h>
#import <Security/SecCertificate.h>

typedef NS_ENUM(NSInteger, BJSRReadyState) {
    SR_CONNECTING   = 0,
    SR_OPEN         = 1,
    SR_CLOSING      = 2,
    SR_CLOSED       = 3,
};

typedef enum BJSRStatusCode : NSInteger {
    // 0–999: Reserved and not used.
    BJSRStatusCodeNormal = 1000,
    BJSRStatusCodeGoingAway = 1001,
    BJSRStatusCodeProtocolError = 1002,
    BJSRStatusCodeUnhandledType = 1003,
    // 1004 reserved.
    SRStatusNoStatusReceived = 1005,
    BJSRStatusCodeAbnormal = 1006,
    BJSRStatusCodeInvalidUTF8 = 1007,
    BJSRStatusCodePolicyViolated = 1008,
    BJSRStatusCodeMessageTooBig = 1009,
    BJSRStatusCodeMissingExtension = 1010,
    BJSRStatusCodeInternalError = 1011,
    BJSRStatusCodeServiceRestart = 1012,
    BJSRStatusCodeTryAgainLater = 1013,
    // 1014: Reserved for future use by the WebSocket standard.
    BJSRStatusCodeTLSHandshake = 1015,
    // 1016–1999: Reserved for future use by the WebSocket standard.
    // 2000–2999: Reserved for use by WebSocket extensions.
    // 3000–3999: Available for use by libraries and frameworks. May not be used by applications. Available for registration at the IANA via first-come, first-serve.
    // 4000–4999: Available for use by applications.
} BJSRStatusCode;

@class BJSRWebSocket;

extern NSString *const BJSRWebSocketErrorDomain;
extern NSString *const BJSRHTTPResponseErrorKey;

#pragma mark - BJSRWebSocketDelegate

@protocol BJSRWebSocketDelegate;

#pragma mark - BJSRWebSocket

@interface BJSRWebSocket : NSObject <NSStreamDelegate>

@property (nonatomic, weak) id <BJSRWebSocketDelegate> delegate;

@property (nonatomic, readonly) BJSRReadyState readyState;
@property (nonatomic, readonly, retain) NSURL *url;


@property (nonatomic, readonly) CFHTTPMessageRef receivedHTTPHeaders;

// Optional array of cookies (NSHTTPCookie objects) to apply to the connections
@property (nonatomic, readwrite) NSArray * requestCookies;

// This returns the negotiated protocol.
// It will be nil until after the handshake completes.
@property (nonatomic, readonly, copy) NSString *protocol;

// Protocols should be an array of strings that turn into Sec-WebSocket-Protocol.
- (id)initWithURLRequest:(NSURLRequest *)request protocols:(NSArray *)protocols allowsUntrustedSSLCertificates:(BOOL)allowsUntrustedSSLCertificates;
- (id)initWithURLRequest:(NSURLRequest *)request protocols:(NSArray *)protocols;
- (id)initWithURLRequest:(NSURLRequest *)request;

// Some helper constructors.
- (id)initWithURL:(NSURL *)url protocols:(NSArray *)protocols allowsUntrustedSSLCertificates:(BOOL)allowsUntrustedSSLCertificates;
- (id)initWithURL:(NSURL *)url protocols:(NSArray *)protocols;
- (id)initWithURL:(NSURL *)url;

// Delegate queue will be dispatch_main_queue by default.
// You cannot set both OperationQueue and dispatch_queue.
- (void)setDelegateOperationQueue:(NSOperationQueue*) queue;
- (void)setDelegateDispatchQueue:(dispatch_queue_t) queue;

// By default, it will schedule itself on +[NSRunLoop SR_networkRunLoop] using defaultModes.
- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
- (void)unscheduleFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;

// BJSRWebSockets are intended for one-time-use only.  Open should be called once and only once.
- (void)open;

- (void)close;
- (void)closeWithCode:(NSInteger)code reason:(NSString *)reason;

// Send a UTF8 String or Data.
- (void)send:(id)data;

// Send Data (can be nil) in a ping message.
- (void)sendPing:(NSData *)data;

@end

#pragma mark - BJSRWebSocketDelegate

@protocol BJSRWebSocketDelegate <NSObject>

// message will either be an NSString if the server is using text
// or NSData if the server is using binary.
- (void)webSocket:(BJSRWebSocket *)webSocket didReceiveMessage:(id)message;

@optional

- (void)webSocketDidOpen:(BJSRWebSocket *)webSocket;
- (void)webSocket:(BJSRWebSocket *)webSocket didFailWithError:(NSError *)error;
- (void)webSocket:(BJSRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
- (void)webSocket:(BJSRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload;

// Return YES to convert messages sent as Text to an NSString. Return NO to skip NSData -> NSString conversion for Text messages. Defaults to YES.
- (BOOL)webSocketShouldConvertTextFrameToString:(BJSRWebSocket *)webSocket;

@end

#pragma mark - NSURLRequest (BJSRCertificateAdditions)

@interface NSURLRequest (BJSRCertificateAdditions)

@property (nonatomic, retain, readonly) NSArray *SR_SSLPinnedCertificates;

@end

#pragma mark - NSMutableURLRequest (BJSRCertificateAdditions)

@interface NSMutableURLRequest (BJSRCertificateAdditions)

@property (nonatomic, retain) NSArray *SR_SSLPinnedCertificates;

@end

#pragma mark - NSRunLoop (BJSRWebSocket)

@interface NSRunLoop (BJSRWebSocket)

+ (NSRunLoop *)SR_networkRunLoop;

@end
