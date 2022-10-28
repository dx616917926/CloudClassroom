//
//  HXFaceRecognitionTool.h
//  CloudClassroom
//
//  Created by mac on 2022/10/27.
//

#import <Foundation/Foundation.h>
#import "HXExamPromiseView.h"
#import "HXFaceRecognitionView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^HXFaceRecognitionToolSuccessBlock)(void);


//进入课程学习和考试前需要进行学习须知弹框、人脸识别的弹框
@interface HXFaceRecognitionTool : NSObject

@property(nonatomic, strong) HXFaceConfigObject *faceConfig;    //人脸识别和采集的相关参数

@property(nonatomic, copy) HXFaceRecognitionToolSuccessBlock successBlack; //成功回调

//弹出
- (void)showInViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
