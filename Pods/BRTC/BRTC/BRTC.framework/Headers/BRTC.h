/*
 * Module:   BRTC
 *
 * Function: BRTC的主要接口类
 *
 */

#import <Foundation/Foundation.h>
#import <BRTC/BRTCDef.h>
#import <BRTC/BRTCLiteAVCode.h>
#import <BRTC/BRTCDelegate.h>
#import <BRTC/BRTCStatistics.h>
#import <BRTC/BRTCDeviceManager.h>
#import <BRTC/BRTCBeautyManager.h>
#import <BRTC/BRTCAudioEffecter.h>
#import <BRTC/BRTCAudioPlayer.h>

@class BRTCParams;
@class BRTCUser;
@class BRTCStream;
@class BRTCVideoEncParam;

NS_ASSUME_NONNULL_BEGIN
@interface BRTC : NSObject

/////////////////////////////////////////////////////////////////////////////////
//
//                      SDK 基础函数
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - 基础函数

/**
 * 创建 BRTC 单例
 */
+ (instancetype)sharedInstance;

/**
 * 销毁 BRTC 单例
 */
+ (void)destroySharedIntance;

/**
 * 设置回调接口 BRTCDelegate
 * 您可以通过 BRTCDelegate 获得来自 SDK 的各种状态通知，详见 BRTCDelegate.h 中的定义
 */
@property (nonatomic, weak) id<BRTCDelegate> delegate;



/////////////////////////////////////////////////////////////////////////////////
//
//                      房间相关接口函数
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - 房间相关接口函数

/**
 * 进入房间
 *
 * 调用接口后，您会收到来自 BRTCDelegate 中的 onEnterRoom(result) 回调:
 * - 如果加入成功，result 会是一个正数（result > 0），表示加入房间的时间消耗，单位是毫秒（ms）。
 * - 如果加入失败，result 会是一个负数（result < 0），表示进房失败的错误码。
 *
 * 进房失败的错误码含义请参见[错误码]
 * @param param 进房参数，请参考 BRTCParams
 *
 * @note
 *  1. 不管进房是否成功，enterRoom 都必须与 exitRoom 配对使用，在调用 exitRoom 前再次调用 enterRoom 函数会导致不可预期的错误问题。
 */
- (void)enterRoom:(BRTCParams *_Nonnull)param;

/**
 * 离开房间
 *
 * 调用 exitRoom() 接口会执行退出房间的相关逻辑，例如释放音视频设备资源和编解码器资源等。
 * 待资源释放完毕，SDK 会通过 BRTCDelegate 中的 onExitRoom() 回调通知到您。
 *
 * 如果您要再次调用 enterRoom() 或者切换到其他的音视频 SDK，请等待 onExitRoom() 回调到来之后再执行相关操作。
 * 否则可能会遇到摄像头或麦克风（例如 iOS 里的 AudioSession）被占用等各种异常问题。
 */
- (void)exitRoom;

/**
 *  切换角色
 *
 * 调用本接口可以实现用户在“主播”和“观众”两种角色之间来回切换。
 * 由于视频直播和语音聊天室需要支持多达10万名观众同时观看，所以设定了“只有主播才能发布自己的音视频”的规则。
 * 因此，当有些观众希望发布自己的音视频流（以便能跟主播互动）时，就需要先把自己的角色切换成“主播”。
 * 您可以在进入房间时通过 {@link BRTCParams} 中的 role 字段事先确定用户的角色，也可以在进入房间后通过 switchRole 接口动态切换角色。
 * @param role 角色，默认为“主播”：
 * - {@link BRTCRoleAnchor} ：主播，可以发布自己的音视频，同一个房间里最多支持50个主播同时发布音视频。
 * - {@link BRTCRoleAudience} ：观众，不能发布自己的音视频流，只能观看房间中其他主播的音视频。如果要发布自己的音视频，需要先通过 {@link switchRole} 切换成“主播”，同一个房间内同时最多可以容纳 10 万名观众。
 */
- (void)switchRole:(BRTCRoleType)role;

/**
 * 设置订阅模式（需要在进入房前设置才能生效）
 *
 * 您可以通过该接口在“自动订阅”和“手动订阅”两种模式下进行切换：
 * - 自动订阅：默认模式，用户在进入房间后会立刻接收到该房间中的音视频流，音频会自动播放，视频会自动开始解码（依然需要您通过 startRemoteView 接口绑定渲染控件）。
 * - 手动订阅：在用户进入房间后，需要手动调用 {@startRemoteView} 接口才能启动视频流的订阅和解码，需要手动调用 {@muteRemoteAudio} (false) 接口才能启动声音的播放。
 *
 * 在绝大多数场景下，用户进入房间后都会订阅房间中所有主播的音视频流，因此 BRTC 默认采用了自动订阅模式，以求得最佳的“秒开体验”。
 * 如果您的应用场景中每个房间同时会有很多路音视频流在发布，而每个用户只想选择性地订阅其中的 1-2 路，则推荐使用“手动订阅”模式以节省流量费用。
 * @param autoRecvAudio YES：自动订阅音频；NO：需手动调用 muteRemoteAudio(false) 订阅音频。默认值：YES。
 * @param autoRecvVideo YES：自动订阅视频；NO：需手动调用 startRemoteView 订阅视频。默认值：YES。
 * @note
 * 1. 需要在进入房间（enterRoom）前调用该接口，设置才能生效。
 * 2. 在自动订阅模式下，如果用户在进入房间后没有调用  {@startRemoteView} 订阅视频流，SDK 会自动停止订阅视频流，以便达到节省流量的目的。
 */
- (void)setDefaultStreamRecvMode:(BOOL)autoRecvAudio video:(BOOL)autoRecvVideo;


/////////////////////////////////////////////////////////////////////////////////
//
//                      视频相关接口函数
//
/////////////////////////////////////////////////////////////////////////////////

#pragma mark - 视频相关接口函数

/**
 * 开启本地视频的预览画面 (iOS 版本)
 *
 * 在 enterRoom 之前调用此函数，SDK 只会开启摄像头，并一直等到您调用 enterRoom 之后才开始推流。
 * 在 enterRoom 之后调用此函数，SDK 会开启摄像头并自动开始视频推流。
 * 当开始渲染首帧摄像头画面时，您会收到 BRTCDelegate 中的 onFirstVideoFrame(nil) 回调。
 *
 * @note 如果希望开播前预览摄像头画面并通过 BeautyManager 调节美颜参数，您可以：
 *   - 方案一：在调用 enterRoom 之前调用 startLocalPreview
 *   - 方案二：在调用 enterRoom 之后调用 startLocalPreview + muteLocalVideo(true)
 * @param frontCamera YES：前置摄像头；NO：后置摄像头。
 * @param view 承载视频画面的控件
 */
- (void)startLocalPreview:(BOOL)frontCamera view:(BRTCView *)view;

/**
 * 增加本地预览视频的渲染视图
 *
 * @note 如果没有开启本地摄像头则不会渲染
 */
- (void)addLocalPreview:(BRTCView *)view;

/**
 * 移除指定的本地预览视频的渲染视图
 */
- (void)removeLocalPreview:(BRTCView *)view;

/**
 * 停止本地视频采集及预览
 */
- (void)stopLocalPreview;

/**
 * 暂停/恢复推送本地的视频数据
 *
 * 当暂停推送本地视频后，房间里的其它成员将会收到 onUserVideoAvailable(userid, NO)回调通知
 * 当恢复推送本地视频后，房间里的其它成员将会收到 onUserVideoAvailable(userid, YES)回调通知
 * @param mute YES：暂停；NO：恢复
 */
- (void)muteLocalVideo:(BOOL)mute;

/**
 * 开始拉取并显示指定用户的远端画面
 *
 * 该函数会拉取指定 userid 的视频流显示在您指定的 view 控件上，您可以通过 setRemoteRenderParams:streamType:params: 设置显示模式。
 * - 如果您提前知道房间中某个 userid 正在推流，可以直接调用 startRemoteView 显示该用户的远端画面。
 * - 如果您不知道房间中有哪些用户开启了视频，可以在 enterRoom 后等待来自 SDK 的 onUserVideoAvailable(userId, true) 回调通知。
 * 调用 startRemoteView 只是启动拉取，此时画面还需要加载，当加载完毕后会通过 onFirstVideoFrame(userId) 通知您。
 *
 * @param userId 指定远端用户的 userId
 * @param streamType 指定要观看 userId 的视频流类型：
 *   - 高清大画面：BRTCVideoStreamTypeBig
 *   - 低清小画面：BRTCVideoStreamTypeSmall
 *   - 辅流（屏幕分享）：BRTCVideoStreamTypeSub
 * @param view 承载视频画面的控件
 * @note 注意几点规则需要您关注：
 *   1. SDK 支持同时观看某 userid 的大画面和辅路，或者小画面和辅路，但不支持同时观看大画面和小画面。
 *   2. 只有当指定的 userid 通过 enableEncSmallVideoStream 开启双路编码后，才能观看该用户的小画面。
 *   3. 如果该用户的小画面不存在，则默认切换到大画面。
 */
- (void)startRemoteView:(NSString *)userId streamType:(BRTCVideoStreamType)streamType view:(BRTCView *)view;

/**
 * 更新远端视频画面的窗口 ( 大小流 )
 *
 * @param view 承载视频画面的控件
 * @param type 要设置预览窗口的流类型 ( BRTCVideoStreamTypeBig、BRTCVideoStreamTypeSub )
 * @param userId 对方的用户标识
 */
- (void)updateRemoteView:(BRTCView *)view streamType:(BRTCVideoStreamType)type forUser:(NSString *)userId;

/**
 * 增加指定 userId  和 streamType 的远端流的渲染视图
 *
 * @note 如果没有开始拉取该远端流则不会渲染
 */
- (void)addRemoteView:(NSString *)userId streamType:(BRTCVideoStreamType)streamType view:(BRTCView *)view;

/**
 * 移除指定的 userId 和 streamType 的远端流的渲染视图
 */
- (void)removeRemoteView:(NSString *)userId streamType:(BRTCVideoStreamType)streamType view:(BRTCView *)view;

/**
 * 停止显示远端视频画面，同时不再拉取该远端用户的视频数据流
 *
 * 调用此接口后，SDK 会停止接收该用户的远程视频流，同时会清理相关的视频显示资源。
 *
 * @param userId 指定远端用户的 userId
 * @param streamType 指定要停止观看的 userId 的视频流类型：
 *   - 高清大画面：BRTCVideoStreamTypeBig
 *   - 低清小画面：BRTCVideoStreamTypeSmall
 *   - 辅流（屏幕分享）：BRTCVideoStreamTypeSub

 */
- (void)stopRemoteView:(NSString *)userId streamType:(BRTCVideoStreamType)streamType;

/**
 * 停止订阅所有远端用户的视频流，并释放全部渲染资源
 *
 * 调用此接口会让 SDK 停止接收所有来自远端的视频流，并释放全部的解码和渲染资源。
 * @note 如果当前有正在显示的辅路画面（屏幕分享）也会一并被停止。
 */
- (void)stopAllRemoteView;

/**
 * 暂停/恢复接收指定的远端视频流
 *
 * 该接口仅暂停/恢复接收指定的远端用户的视频流，但并不释放显示资源，视频画面会冻屏在 mute 前的最后一帧。
 *
 * @param userId 对方的用户标识
 * @param mute  是否暂停接收
 * @note 您在 enterRoom 之前或之后调用此 API 均会进入屏蔽状态，屏蔽状态在您调用 exitRoom 之后会被重置为 false。
 */
- (void)muteRemoteVideoStream:(NSString *)userId mute:(BOOL)mute;

/**
 * 暂停/恢复接收所有远端视频流
 *
 * 该接口仅暂停/恢复接收所有远端用户的视频流，但并不释放显示资源，视频画面会冻屏在 mute 前的最后一帧。
 *
 * @param mute 是否暂停接收
 * @note 您在 enterRoom 之前或之后调用此 API 均会进入屏蔽状态，屏蔽状态在您调用 exitRoom 之后会被重置为 false。
 */
- (void)muteAllRemoteVideoStreams:(BOOL)mute;

/**
 * 设置视频编码器相关参数，需要在推流之前设置
 *
 * 该设置决定了远端用户看到的画面质量（同时也是云端录制出的视频文件的画面质量）
 *
 * @param param 视频编码参数，详情请参考 BRTCDef.h 中的 BRTCVideoEncParam 定义
 */
- (void)setVideoEncoderParam:(BRTCVideoEncParam *_Nonnull)param;

/**
 * 设置网络流控相关参数
 *
 * 该设置决定 SDK 在各种网络环境下的调控策略（例如弱网下选择“保清晰”或“保流畅”）
 *
 * @param param 网络流控参数，详情请参考 BRTCCloudDef.h 中的 BRTCNetworkQosParam 定义
 */
- (void)setNetworkQosParam:(BRTCNetworkQosParam *)param;

/**
 *  本地图像的渲染设置
 *
 * @param params 参见 BRTCDef.h 中对 BRTCRenderParams 的定义
 */
- (void)setLocalRenderParams:(BRTCRenderParams *)params;

/**
 * 远端图像的渲染设置
 *
 * @param userId 用户 ID
 * @param type 视频线路，可以设置为主路（BRTCVideoStreamTypeBig）或者辅路（BRTCVideoStreamTypeSub）
 * @param params 参见 BRTCDef.h 中对 BRTCRenderParams 的定义
 */
- (void)setRemoteRenderParams:(NSString *)userId streamType:(BRTCVideoStreamType)type params:(BRTCRenderParams *)params;

/**
 * 设置编码器输出的画面镜像模式
 *
 * 该接口不改变本地摄像头的预览画面，但会改变另一端用户看到的（以及服务器录制的）画面效果。
 *
 * @param mirror 是否开启远端镜像，YES：开启远端画面镜像；NO：关闭远端画面镜像，默认值：NO。
 */
- (void)setVideoEncoderMirror:(BOOL)mirror;

/**
 * 开启大小画面双路编码模式
 *
 * 如果当前用户是房间中的主要角色（例如主播、老师、主持人等），并且使用 PC 或者 Mac 环境，可以开启该模式。
 * 开启该模式后，当前用户会同时输出【高清大画面】和【低清小画面】两路视频流（但只有一路音频流）。
 * 对于开启该模式的当前用户，会占用更多的网络带宽，并且会更加消耗 CPU 计算资源。
 *
 * 对于同一房间的远程观众而言：
 * - 如果下行网络很好，可以选择观看【高清大画面】
 * - 如果下行网络较差，可以选择观看【低清小画面】
 *
 * @note 双路编码开启后，会消耗更多的 CPU 和 网络带宽，所以对于 iMac、Windows 或者高性能 Pad 可以考虑开启，但请不要在手机端开启。
 *
 * @param enable 是否开启小画面编码，默认值：NO
 * @param smallVideoEncParam 小流的视频参数
 * @return 0：成功；-1：大画面已经是最低画质
 */
- (int)enableEncSmallVideoStream:(BOOL)enable withQuality:(BRTCVideoEncParam *_Nonnull)smallVideoEncParam;

/**
 * 切换指定远端用户的大小画面
 * @note
 *   1. 此功能需要该 userId 通过 enableEncSmallVideoStream 提前开启双路编码模式。
 *      如果该 userId 没有开启双路编码模式，则此操作将无任何反应。
 *   2. 在不通过此接口进行设置的情况下，startRemoteView 默认观看的画面为大画面。
 *
 * @param userId 用于指定要观看的 userId
 * @param type 视频流类型，即选择看大画面或小画面，默认为大画面
 */
- (void)setRemoteVideoStreamType:(NSString *)userId type:(BRTCVideoStreamType)type;

/**
*  视频画面截图
*
* 截取本地、远程主路和远端辅流的视频画面，并通过 UIImage(iOS) 或 NSImage(macOS) 对象返回给您。
*
* @param userId 用户 ID，nil 表示截取本地视频画面。
* @param type 视频流类型，支持主路画面（BRTCVideoStreamTypeBig，一般用于摄像头）和 辅路画面（BRTCVideoStreamTypeSub，一般用于屏幕分享）。
* @prara sourceType 截图画面来源，支持视频流（BRTCSnapshotSourceTypeStream）和视频渲染画面（BRTCSnapshotSourceTypeView）
* @param completionBlock 画面截取后的回调。
*
* @note 设置 userId = nil，代表截取当前用户的本地画面，目前本地画面仅支持截取主路画面（BRTCVideoStreamTypeBig）。
*/
- (void)snapshotVideo:(NSString *)userId
                 type:(BRTCVideoStreamType)type
           sourceType:(BRTCSnapshotSourceType)sourceType
      completionBlock:(void (^)(UIImage *image))completionBlock;



/////////////////////////////////////////////////////////////////////////////////
//
//                      音频相关接口
//
/////////////////////////////////////////////////////////////////////////////////

#pragma mark 音频相关接口
/**
 *  开启本地音频的采集和上行
 *
 * SDK 默认不采集声音，您需要调用该函数启动麦克风采集，并将音频数据传输给房间里的其他用户。
 *
 * @param quality 声音音质
 * - {@link BRTCDef#BRTCAudioQualityDefault}，默认：采样率：48k；单声道；音频裸码率：50kbps；SDK 默认的音频质量，如无特殊需求推荐选择之。
 *
 * @note 该函数会检查麦克风的使用权限，如果当前 App 没有麦克风权限，SDK 会向用户申请开启。
 */
- (void)startLocalAudio:(BRTCAudioQuality)quality;

/**
 * 关闭本地音频的采集和上行
 *
 * 当关闭本地音频的采集和上行，房间里的其它成员会收到 onUserAudioAvailable(NO) 回调通知。
 */
- (void)stopLocalAudio;

/**
 * 静音/取消静音本地的音频
 *
 * 当静音本地音频后，房间里的其它成员会收到 onUserAudioAvailable(userId, NO) 回调通知。
 * 当取消静音本地音频后，房间里的其它成员会收到 onUserAudioAvailable(userId, YES) 回调通知。
 *
 * 与 stopLocalAudio 不同之处在于，muteLocalAudio:YES 并不会停止发送音视频数据，而是继续发送码率极低的静音包。
 * 由于 MP4 等视频文件格式，对于音频的连续性是要求很高的，使用 stopLocalAudio 会导致录制出的 MP4 不易播放。
 * 因此在对录制质量要求很高的场景中，建议选择 muteLocalAudio，从而录制出兼容性更好的 MP4 文件。
 *
 * @param mute YES：静音；NO：取消静音
 */
- (void)muteLocalAudio:(BOOL)mute;

/**
 * 静音/取消静音指定的远端用户的声音
 *
 * @param userId 对方的用户 ID
 * @param mute YES：静音；NO：取消静音
 *
 * @note 静音时会停止接收该用户的远端音频流并停止播放，取消静音时会自动拉取该用户的远端音频流并进行播放。
 *       您在 enterRoom 之前或之后调用此 API 均会进入屏蔽状态，屏蔽状态在您调用 exitRoom 之后会被重置为 false。
 */
- (void)muteRemoteAudio:(NSString *)userId mute:(BOOL)mute;

/**
 * 静音/取消静音所有用户的声音
 *
 * @param mute YES：静音；NO：取消静音
 *
 * @note 静音时会停止接收所有用户的远端音频流并停止播放，取消静音时会自动拉取所有用户的远端音频流并进行播放。
 *       您在 enterRoom 之前或之后调用此 API 均会进入屏蔽状态，屏蔽状态在您调用 exitRoom 之后会被重置为 false。
 */
- (void)muteAllRemoteAudio:(BOOL)mute;

/**
 * 设置 SDK 采集音量。
 *
 * @param volume 音量大小，100为原始音量，范围是：[0 ~ 150]，默认值为100
 *
 * @note  如果要将 volume 设置为大于100的数值，需要进行特殊配置，请联系技术支持。
 */
- (void)setAudioCaptureVolume:(NSInteger)volume;

/**
 * 获取 SDK 采集音量
 */
- (NSInteger)getAudioCaptureVolume;

/**
 * 设置 SDK 播放音量。
 *
 * @param volume 音量大小，100为原始音量，范围是：[0 ~ 150]，默认值为100
 *
 * @note
 *  1. 该函数会控制最终交给系统播放的声音音量，会影响录制本地音频文件的音量大小，但不会影响耳返的音量。<br>
 *  2. 如果要将 volume 设置为大于100的数值，需要进行特殊配置，请联系技术支持。
 */
- (void)setAudioPlayoutVolume:(NSInteger)volume;

/**
 * 获取 SDK 播放音量
 */
- (NSInteger)getAudioPlayoutVolume;

/**
 * 启用音量大小提示
 *
 * 开启此功能后，SDK 会在 onUserVoiceVolume() 中反馈对每一路声音音量大小值的评估。
 * 如需打开此功能，请在 startLocalAudio() 之前调用。
 *
 * @note Demo 中有一个音量大小的提示条，就是基于这个接口实现的。
 * @param interval 设置 onUserVoiceVolume 回调的触发间隔，单位为ms，最小间隔为100ms，如果小于等于0则会关闭回调，建议设置为300ms；
 */
- (void)enableAudioVolumeEvaluation:(NSUInteger)interval;


/////////////////////////////////////////////////////////////////////////////////
//
//                      设备管理相关接口
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - 设备管理相关接口

/**
 * 获取设备管理类 BRTCDeviceManager
 */
- (BRTCDeviceManager *)getDeviceManager;



/////////////////////////////////////////////////////////////////////////////////
//
//                      美颜特效和图像水印
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - 美颜特效和变脸特效
/**
 *  获取美颜管理对象
 *
 * 通过美颜管理，您可以使用以下功能：
 * - 设置"美颜风格"、“美白”、“红润”、“大眼”、“瘦脸”、“V脸”、“下巴”、“短脸”、“小鼻”、“亮眼”、“白牙”、“祛眼袋”、“祛皱纹”、“祛法令纹”等美容效果。
 * - 调整“发际线”、“眼间距”、“眼角”、“嘴形”、“鼻翼”、“鼻子位置”、“嘴唇厚度”、“脸型”
 * - 设置人脸挂件（素材）等动态效果
 * - 添加美妆
 * - 进行手势识别
 */
- (BRTCBeautyManager *)getBeautyManager;

/**
 *  添加水印
 *
 * 水印的位置是通过 rect 参数来指定的，rect 是一个四元组参数，其格式为 (x，y，width，height)
 * - x：水印的坐标，取值范围为0 - 1的浮点数。
 * - y：水印的坐标，取值范围为0 - 1的浮点数。
 * - width：水印的宽度，取值范围为0 - 1的浮点数。
 * - height：是不用设置的，SDK 内部会根据水印图片的宽高比自动计算一个合适的高度。
 *
 * 参数设置举例：
 * 如果当前视频的编码分辨率是 540 × 960，且 rect 参数被您设置为（0.1，0.1，0.2，0.0），
 * 那么水印的左上坐标点就是（540 × 0.1，960 × 0.1）即（54，96），水印的宽度是 540 × 0.2 = 108px，水印的高度会根据水印图片的宽高比由 SDK 自动算出。
 *
 * @param image 水印图片，**必须使用透明底色的 png 格式**
 * @param streamType 指定给哪一路画面设置水印，详情请参考{@link BRTCVideoStreamType}。
 * @param rect 水印相对于编码分辨率的归一化坐标，x，y，width，height 取值范围0 - 1。
 * @note 如果您要给主画面（一般为摄像头）和辅路画面（一般用作屏幕分享）同时设置水印，需要调用该接口两次，并设定不同的 streamType。
 */
- (void)setWatermark:(BRTCImage *)image streamType:(BRTCVideoStreamType)streamType rect:(CGRect)rect;

- (BRTCAudioEffecter *)getAudioEffecter;


/////////////////////////////////////////////////////////////////////////////////
//
//                      屏幕分享相关接口
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - 屏幕分享相关接口
/**
 * 开始应用内的屏幕分享（该接口仅支持 iOS 13.0 及以上的 iPhone 和 iPad）
 *
 * iPhone 屏幕分享的推荐配置参数：
 * - 分辨率(videoResolution): 1280 x 720
 * - 帧率(videoFps): 10 FPS
 * - 码率(videoBitrate): 1600 kbps
 * - 分辨率自适应(enableAdjustRes): NO
 *
 * @param encParams 设置屏幕分享时的编码参数，推荐采用上述推荐配置，如果您指定 config 为 nil，则使用您调用 startScreenCapture 之前的编码参数设置。
 */
- (void)startScreenCaptureInApp:(BRTCVideoEncParam *)encParams API_AVAILABLE(ios(13.0));

/**
 * 开始全系统的屏幕分享（该接口支持 iOS 11.0 及以上的 iPhone 和 iPad）
 *
 * 该接口支持共享整个 iOS 系统的屏幕。
 * 但是实现复杂度要比 startScreenCaptureInApp 略繁琐一些，需要参考文档为 App 实现一个 Replaykit 扩展模块。
 *
 *
 * iPhone 屏幕分享的推荐配置参数：
 * - 分辨率(videoResolution): 1280 x 720
 * - 帧率(videoFps): 10 FPS
 * - 码率(videoBitrate): 1600 kbps
 * - 分辨率自适应(enableAdjustRes): NO
 *
 * @param encParams 设置屏幕分享时的编码参数，推荐采用上述推荐配置，如果您指定 config 为 nil，则使用您调用 startScreenCapture 之前的编码参数设置。
 * @param appGroup 主 App 与 Broadcast 共享的 Application Group Identifier，可以指定为 nil，但按照文档设置会使功能更加可靠。
 */
- (void)startScreenCaptureByReplaykit:(BRTCVideoEncParam *)encParams appGroup:(NSString *)appGroup API_AVAILABLE(ios(11.0));

/**
 *  停止屏幕采集
 *
 * @return 0：成功；<0：失败
 */
- (int)stopScreenCapture API_AVAILABLE(ios(11.0));

/**
 *  暂停屏幕分享
 *
 * @return 0：成功；<0：失败
 */
- (int)pauseScreenCapture API_AVAILABLE(ios(11.0));

/**
 * 8.6 恢复屏幕分享
 *
 * @return 0：成功；<0：失败
 */
- (int)resumeScreenCapture API_AVAILABLE(ios(11.0));




/////////////////////////////////////////////////////////////////////////////////
//
//                      自定义采集和渲染
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - 自定义采集和渲染





/////////////////////////////////////////////////////////////////////////////////
//
//                      自定义消息发送
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - 自定义消息发送
/**
 *  发送自定义消息给房间内所有用户
 *
 * 该接口可以借助音视频数据通道向当前房间里的其他用户广播您自定义的数据，但因为复用了音视频数据通道，
 * 请务必严格控制自定义消息的发送频率和消息体的大小，否则会影响音视频数据的质量控制逻辑，造成不确定性的问题。
 *
 * @param cmdID 消息 ID，取值范围为1 - 10
 * @param data 待发送的消息，最大支持 1KB（1000 字节）的数据大小
 * @param reliable 是否可靠发送，可靠发送的代价是会引入一定的延时，因为接收端要暂存一段时间的数据来等待重传
 * @param ordered 是否要求有序，即是否要求接收端接收的数据顺序和发送端发送的顺序一致，这会带来一定的接收延时，因为在接收端需要暂存并排序这些消息。
 * @return YES：消息已经发出；NO：消息发送失败。
 *
 * @note 本接口有以下限制：
 *       - 发送消息到房间内所有用户（暂时不支持 Web/小程序端），每秒最多能发送30条消息。
 *       - 每个包最大为 1KB，超过则很有可能会被中间路由器或者服务器丢弃。
 *       - 每个客户端每秒最多能发送总计 8KB 数据。
 *       - 将 reliable 和 ordered 同时设置为 YES 或 NO，暂不支持交叉设置。
 *       - 强烈建议不同类型的消息使用不同的 cmdID，这样可以在要求有序的情况下减小消息时延。
 */
- (BOOL)sendCustomCmdMsg:(NSInteger)cmdID data:(NSData *)data reliable:(BOOL)reliable ordered:(BOOL)ordered;

/**
 * 将小数据量的自定义数据嵌入视频帧中
 *
 * sendSEIMsg 是将数据直接塞入视频数据头中。因此，即使视频帧被旁路到了直播 CDN 上，
 * 这些数据也会一直存在。由于需要把数据嵌入视频帧中，建议尽量控制数据大小，推荐使用几个字节大小的数据。
 *
 * 最常见的用法是把自定义的时间戳（timstamp）用 sendSEIMsg 嵌入视频帧中，实现消息和画面的完美对齐。
 *
 * @param data 待发送的数据，最大支持 1KB（1000字节）的数据大小
 * @param repeatCount 发送数据次数
 * @return YES：消息已通过限制，等待后续视频帧发送；NO：消息被限制发送
 *
 * @note 本接口有以下限制：
 *       - 数据在接口调用完后不会被即时发送出去，而是从下一帧视频帧开始带在视频帧中发送。
 *       - 发送消息到房间内所有用户，每秒最多能发送 30 条消息（与 sendCustomCmdMsg 共享限制）。
 *       - 每个包最大为 1KB，若发送大量数据，会导致视频码率增大，可能导致视频画质下降甚至卡顿（与 sendCustomCmdMsg 共享限制）。
 *       - 每个客户端每秒最多能发送总计8KB数据（与 sendCustomCmdMsg 共享限制）。
 *       - 若指定多次发送（repeatCount > 1），则数据会被带在后续的连续 repeatCount 个视频帧中发送出去，同样会导致视频码率增大。
 *       - 如果 repeatCount > 1，多次发送，接收消息 onRecvSEIMsg 回调也可能会收到多次相同的消息，需要去重。
 */
- (BOOL)sendSEIMsg:(NSData *)data repeatCount:(int)repeatCount;



/////////////////////////////////////////////////////////////////////////////////
//
//                      Log 相关接口函数
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - Log 相关接口函数
/**
 * 获取 SDK 版本信息
 */
+ (NSString *)getSDKVersion;

/**
 * 设置 Log 输出级别
 */
+ (void)setLogLevel:(BRTCLogLevel)level;

/**
 * 启用或禁用控制台日志打印
 *
 * @param enabled 指定是否启用，默认为禁止状态
 */
+ (void)setConsoleEnabled:(BOOL)enabled;

/**
 * 修改日志保存路径
 *
 * @note 日志文件默认保存在 sandbox Library/Caches 下，如需修改，必须在所有方法前调用。
 * @param path 存储日志路径
 */
+ (void)setLogDirPath:(NSString *__nullable)path;

/**
 * 设置日志回调
 */
+ (void)setLogDelegate:(id<BRTCLogDelegate> __nullable)logDelegate;

/**
 *  调用实验性 API 接口
 *
 * @note 该接口用于调用一些实验性功能
 * @param jsonStr 接口及参数描述的 JSON 字符串
 */
- (void)callExperimentalAPI:(NSString *)jsonStr;

@end

NS_ASSUME_NONNULL_END
