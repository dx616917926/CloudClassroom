#ifndef __BRTCLITEAVCODE_H__
#define __BRTCLITEAVCODE_H__

/////////////////////////////////////////////////////////////////////////////////
//
//                     错误码
//
/////////////////////////////////////////////////////////////////////////////////

typedef enum BRTCLiteAVError
{
    /////////////////////////////////////////////////////////////////////////////////
    //
    //       基础错误码
    //
    /////////////////////////////////////////////////////////////////////////////////
    BRTC_ERR_NULL                                        = 0,        ///< 无错误
    BRTC_ERR_UNKNOWN                                     = -1,       ///< 未知错误
    /////////////////////////////////////////////////////////////////////////////////
    //
    //       进房（enterRoom）相关错误码
    //       NOTE: 通过回调函数 BRTCDelegate##onEnterRoom() 和 BRTCDelegate##OnError() 通知
    //
    /////////////////////////////////////////////////////////////////////////////////
    BRTC_ERR_ROOM_ENTER_FAIL                             = -3301,    ///< 进入房间失败
    BRTC_ERR_ENTER_ROOM_PARAM_NULL                       = -3316,    ///< 进房参数为空，请检查 enterRoom: 接口调用是否传入有效的 param
    BRTC_ERR_SDK_APPID_INVALID                           = -3317,    ///< 进房参数 sdkAppId 错误
    BRTC_ERR_ROOM_ID_INVALID                             = -3318,    ///< 进房参数 roomId 错误
    BRTC_ERR_USER_ID_INVALID                             = -3319,    ///< 进房参数 userID 不正确
    BRTC_ERR_USER_SIG_INVALID                            = -3320,    ///< 进房参数 userSig 不正确
    BRTC_ERR_ROOM_REQUEST_ENTER_ROOM_TIMEOUT             = -3308,    ///< 请求进房超时，请检查网络
    BRTC_ERR_ROOM_RECONNECT_FAILED                       = -3309,    ///< 尝试与服务器重连次数超过了最大值
    BRTC_ERR_SERVER_INFO_SERVICE_SUSPENDED               = -100013,  ///< 服务不可用。请检查：套餐包剩余分钟数是否大于0，BRTC账号是否欠费

    /////////////////////////////////////////////////////////////////////////////////
    //
    //       设备（摄像头、麦克风、扬声器）相关错误码
    //       NOTE: 通过回调函数 BRTCDelegate##OnError() 通知
    //
    /////////////////////////////////////////////////////////////////////////////////
    BRTC_ERR_CAMERA_START_FAIL                           = -1301,    ///< 打开摄像头失败，例如在 Windows 或 Mac 设备，摄像头的配置程序（驱动程序）异常，禁用后重新启用设备，或者重启机器，或者更新配置程序
    BRTC_ERR_CAMERA_NOT_AUTHORIZED                       = -1314,    ///< 摄像头设备未授权，通常在移动设备出现，可能是权限被用户拒绝了
    BRTC_ERR_CAMERA_SET_PARAM_FAIL                       = -1315,    ///< 摄像头参数设置出错（参数不支持或其它）
    BRTC_ERR_CAMERA_OCCUPY                               = -1316,    ///< 摄像头正在被占用中，可尝试打开其他摄像头
    BRTC_ERR_MIC_START_FAIL                              = -1302,    ///< 打开麦克风失败，例如在 Windows 或 Mac 设备，麦克风的配置程序（驱动程序）异常，禁用后重新启用设备，或者重启机器，或者更新配置程序
    BRTC_ERR_MIC_NOT_AUTHORIZED                          = -1317,    ///< 麦克风设备未授权，通常在移动设备出现，可能是权限被用户拒绝了
    BRTC_ERR_MIC_SET_PARAM_FAIL                          = -1318,    ///< 麦克风设置参数失败
    BRTC_ERR_MIC_OCCUPY                                  = -1319,    ///< 麦克风正在被占用中，例如移动设备正在通话时，打开麦克风会失败
    BRTC_ERR_MIC_STOP_FAIL                               = -1320,    ///< 停止麦克风失败
    BRTC_ERR_SPEAKER_START_FAIL                          = -1321,    ///< 打开扬声器失败，例如在 Windows 或 Mac 设备，扬声器的配置程序（驱动程序）异常，禁用后重新启用设备，或者重启机器，或者更新配置程序
    BRTC_ERR_SPEAKER_SET_PARAM_FAIL                      = -1322,    ///< 扬声器设置参数失败
    BRTC_ERR_SPEAKER_STOP_FAIL                           = -1323,    ///< 停止扬声器失败


    /////////////////////////////////////////////////////////////////////////////////
    //
    //       屏幕分享相关错误码
    //       NOTE: 通过回调函数 BRTCDelegate##OnError() 通知
    //
    /////////////////////////////////////////////////////////////////////////////////
    BRTC_ERR_SCREEN_CAPTURE_START_FAIL                   = -1308,   ///< 开始录屏失败，如果在移动设备出现，可能是权限被用户拒绝了，如果在 Windows 或 Mac 系统的设备出现，请检查录屏接口的参数是否符合要求
    BRTC_ERR_SCREEN_CAPTURE_UNSURPORT                    = -1309,    ///< 录屏失败，在 Android 平台，需要5.0以上的系统，在 iOS 平台，需要11.0以上的系统
    BRTC_ERR_SCREEN_CAPTURE_STOPPED                      = -7001,    ///< 录屏被系统中止

    /////////////////////////////////////////////////////////////////////////////////
    //
    //       客户无需关心的内部错误码
    //
    /////////////////////////////////////////////////////////////////////////////////
    BRTC_ERROR_INVALID_USER_TOKEN                        = -2001,
    BRTC_ERR_QUERY_PUBLIC_IP_SERVICE                     = -2004,    ///< 访问 vt 返回的用于查询本机 IP 的 URL 访问错误
    BRTC_ERR_QUERY_PUBLIC_IP_SERVICE_RET_FAIL            = -2005,    ///< 访问 vt 返回的用于查询本机 IP 的 URL 访问返回内容格式不对
    BRTC_ERROR_FAILED_CREATE_ADAPTER                     = -2011,
    BRTC_ERROR_FAILED_REQUEST_IP                         = -2021,    ///< 请求本地外网IP失败

} BRTCLiteAVError;

#endif
