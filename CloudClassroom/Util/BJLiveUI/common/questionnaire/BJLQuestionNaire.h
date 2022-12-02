//
//  BJLQuestionNaire.h
//  Alamofire
//
//  Created by lwl on 2021/10/21.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveBase/BJLiveBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLQuestionNaire: UIViewController

- (instancetype)initWithURL:(NSURL *)url;
@property (nonatomic) void (^questionUrlSubmitCallback)(void);
@property (nonatomic) void (^closeWebViewCallback)(void);

@end

NS_ASSUME_NONNULL_END
