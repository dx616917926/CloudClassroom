/*
 * BJYIJKMediaFramework.h
 *
 * Copyright (c) 2013 Bilibili
 * Copyright (c) 2013 Zhang Rui <bbcallen@gmail.com>
 *
 * This file is part of ijkPlayer.
 *
 * ijkPlayer is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * ijkPlayer is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with ijkPlayer; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

#import <UIKit/UIKit.h>

//! Project version number for BJYIJKMediaFramework.
FOUNDATION_EXPORT double BJYIJKMediaFrameworkVersionNumber;

//! Project version string for BJYIJKMediaFramework.
FOUNDATION_EXPORT const unsigned char BJYIJKMediaFrameworkVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <BJYIJKMediaFrameworkWithSSL/PublicHeader.h>
//#import <BJYIJKMediaFramework/BJYMediaPlayback.h>
//#import <BJYIJKMediaFramework/BJYFFOptions.h>
//#import <BJYIJKMediaFramework/BJYFFMoviePlayerController.h>
//#import <BJYIJKMediaFramework/BJYAVMoviePlayerController.h>
//#import <BJYIJKMediaFramework/BJYIJKMediaPlayer.h>
//#import <BJYIJKMediaFramework/BJYNotificationManager.h>
//#import <BJYIJKMediaFramework/BJYKVOController.h>
//#import <BJYIJKMediaFramework/BJYSDLGLViewProtocol.h>

// ijk 的 framework 在上层作为一个 module 存在的, swift编译的时候, 内部的文件引用用 import <> 的方式会被认为 module 内部引用 module 导致编译失败
#import "BJYMediaPlayback.h"
#import "BJYFFOptions.h"
#import "BJYFFMoviePlayerController.h"
#import "BJYAVMoviePlayerController.h"
#import "BJYIJKMediaPlayer.h"
#import "BJYNotificationManager.h"
#import "BJYKVOController.h"
#import "BJYSDLGLViewProtocol.h"

// backward compatible for old names
#define BJYMediaPlaybackIsPreparedToPlayDidChangeNotification BJYMPMediaPlaybackIsPreparedToPlayDidChangeNotification
#define BJYMoviePlayerLoadStateDidChangeNotification BJYMPMoviePlayerLoadStateDidChangeNotification
#define BJYMoviePlayerPlaybackDidFinishNotification BJYMPMoviePlayerPlaybackDidFinishNotification
#define BJYMoviePlayerPlaybackDidFinishReasonUserInfoKey BJYMPMoviePlayerPlaybackDidFinishReasonUserInfoKey
#define BJYMoviePlayerPlaybackStateDidChangeNotification BJYMPMoviePlayerPlaybackStateDidChangeNotification
#define BJYMoviePlayerIsAirPlayVideoActiveDidChangeNotification BJYMPMoviePlayerIsAirPlayVideoActiveDidChangeNotification
#define BJYMoviePlayerVideoDecoderOpenNotification BJYMPMoviePlayerVideoDecoderOpenNotification
#define BJYMoviePlayerFirstVideoFrameRenderedNotification BJYMPMoviePlayerFirstVideoFrameRenderedNotification
#define BJYMoviePlayerFirstAudioFrameRenderedNotification BJYMPMoviePlayerFirstAudioFrameRenderedNotification
#define BJYMoviePlayerFirstAudioFrameDecodedNotification BJYMPMoviePlayerFirstAudioFrameDecodedNotification
#define BJYMoviePlayerFirstVideoFrameDecodedNotification BJYMPMoviePlayerFirstVideoFrameDecodedNotification
#define BJYMoviePlayerOpenInputNotification BJYMPMoviePlayerOpenInputNotification
#define BJYMoviePlayerFindStreamInfoNotification BJYMPMoviePlayerFindStreamInfoNotification
#define BJYMoviePlayerComponentOpenNotification BJYMPMoviePlayerComponentOpenNotification

#define BJYMPMoviePlayerAccurateSeekCompleteNotification BJYMPMoviePlayerAccurateSeekCompleteNotification
#define BJYMoviePlayerSeekAudioStartNotification BJYMPMoviePlayerSeekAudioStartNotification
#define BJYMoviePlayerSeekVideoStartNotification BJYMPMoviePlayerSeekVideoStartNotification

