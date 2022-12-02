//
//  BJLScWarmingUpView.m
//  BJLiveUI
//
//  Created by 辛亚鹏 on 2021/7/20.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <BJYIJKMediaFramework/BJYIJKMediaFramework.h>
#import <AVFoundation/AVFoundation.h>
#import <BJLiveBase/BJLiveBase.h>

#import "BJLScWarmingUpView.h"
#import "BJLScMediaControlView.h"

@interface BJLScWarmingUpView ()

@property (nonatomic, weak) BJLRoom *room;
@property (nonatomic) NSArray *list;
@property (nonatomic) BOOL isLoop;
@property (nonatomic) BJLScMediaControlView *controlView;
@property (nonatomic, nullable) UIView *playerView;

@end

@implementation BJLScWarmingUpView

- (void)dealloc {
    [self.room.playingVM stopVodPlayer];
    [self.playerView removeFromSuperview];
    self.playerView = nil;
}

- (instancetype)initWithList:(NSArray *)list isLoop:(BOOL)isLoop room:(BJLRoom *)room {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.room = room;
        self.list = list;
        self.isLoop = isLoop;

        NSError *error;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback mode:AVAudioSessionModeDefault options:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];

        [self setupView];
        [self makePlayerCallback];
        [self playWithURLString:list.firstObject];
    }
    return self;
}

#pragma mark -

- (void)setupView {
    self.controlView = [[BJLScMediaControlView alloc] initWithFrame:CGRectZero];
    [self addSubview:self.controlView];
    [self.controlView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.bottom.left.right.equalTo(self);
    }];

    bjl_weakify(self);
    [self.controlView setPlayCallback:^(BOOL shouldPlay) {
        bjl_strongify(self);
        if (shouldPlay) {
            [self.room.playingVM vodVideoPlay];
        }
        else {
            [self.room.playingVM vodVideoPause];
        }
    }];
    [self.controlView setScaleCallback:^(BOOL shoudFullScreen) {
        bjl_strongify(self);
        if (self.scaleCallback) {
            self.scaleCallback(shoudFullScreen);
        }
    }];
    [self.controlView setMediaSeekCallback:^(NSTimeInterval toTime) {
        bjl_strongify(self);
        [self.room.playingVM seekVodPlayerToTime:toTime];
    }];
}

- (void)updateView:(BOOL)isFullScreen {
    [self.controlView updateScaleButtonSelected:isFullScreen];
}

#pragma mark - player

- (void)playWithURLString:(NSString *)URLString {
    self.playerView = [self.room.playingVM vodPlayerViewWithURLString:URLString];
    [self insertSubview:self.playerView atIndex:0];
    [self.playerView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self);
    }];
    [self.room.playingVM vodVideoPlay];
    [self.controlView updatePlayButtonSelected:NO];
}

- (void)makePlayerCallback {
    bjl_weakify(self);
    [self.room.playingVM setVodVideoPlayDidFinishCallback:^(NSString *_Nonnull urlString) {
        bjl_strongify(self);
        [self.controlView updatePlayButtonSelected:YES];
        [self playerReachEndWithItemUrl:[NSURL URLWithString:urlString]];
    }];

    [self bjl_kvo:BJLMakeProperty(self.room.playingVM, vodPlayerCurrentTime) observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
        bjl_strongify(self);
        [self.controlView updateCurrentTime:self.room.playingVM.vodPlayerCurrentTime duration:self.room.playingVM.vodPlayerDuration];
        return YES;
    }];
}

- (void)playerReachEndWithItemUrl:(NSURL *)url {
    NSString *videoUrlString = url.absoluteString;
    // 如果列表中最后一个视频结束了, 再判断是否循环播放, 如果是, 则继续播放列表第一个视频
    if ([videoUrlString isEqualToString:self.list.lastObject]) {
        if (self.isLoop) {
            [self playWithURLString:self.list.firstObject];
        }
        else {
            // 如果是最后一个, 且不是循环播放
            [self.room.playingVM seekVodPlayerToTime:0];
            [self.controlView updateCurrentTime:0 duration:self.room.playingVM.vodPlayerDuration];
        }
    }
    else {
        // 当前结束的视频, 不是列表中最后一个, 则播放下一个视频
        NSInteger index = [self.list indexOfObject:videoUrlString];
        if (self.list.count > (index + 1)) {
            [self playWithURLString:self.list[index + 1]];
        }
    }
}

@end
