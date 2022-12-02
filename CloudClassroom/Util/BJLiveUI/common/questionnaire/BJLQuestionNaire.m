//
//  BJLQuestionNaire.m
//  Alamofire
//
//  Created by lwl on 2021/10/21.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import "BJLQuestionNaire.h"

#import <WebKit/WebKit.h>

NSString *CloseWebviewMessageHander = @"close";
NSString *OpenNewWebviewMessageHander = @"openURL";

@interface BJLQuestionNaire () <WKScriptMessageHandler, WKNavigationDelegate>

@property (nonatomic, copy) NSURL *url;
@property (nonatomic, readwrite) WKWebView *webView;
@property (nonatomic) BJLProgressHUD *webViewHud;
@property (nonatomic) UIView *loadingView;
@property (nonatomic) UIButton *closeButton;

@end

@implementation BJLQuestionNaire

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loadingView = [UIView new];
    self.loadingView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.loadingView];
    [self.loadingView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.center.equalTo(self.view);
        make.top.equalTo(self.view).offset(90);
        make.width.equalTo(self.loadingView.bjl_height);
    }];

    self.view.backgroundColor = [UIColor bjl_colorWithHexString:@"#007dff"];
    self.closeButton = [UIButton new];
    [self.closeButton bjl_setImage:[UIImage imageNamed:@"webview_back_blue"] forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
    bjl_weakify(self);
    [self.closeButton bjl_addHandler:^(UIButton *_Nonnull button) {
        bjl_strongify(self);
        [self goback];
    }];

    [self.view addSubview:self.closeButton];

    [self.closeButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.view).inset(10);
        make.left.equalTo(self.view).inset(20);
        make.width.height.equalTo(@24);
    }];

    [self loadWebView];
}

- (void)loadWebView {
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    if (!request) {
        [self didFailLoading];
        return;
    }
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds
                                      configuration:[self defaultConfiguration] ?: [WKWebViewConfiguration new]];
    self.webView.navigationDelegate = self;
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:CloseWebviewMessageHander];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:OpenNewWebviewMessageHander];
    self.webView.opaque = NO;
    self.webView.scrollView.bounces = NO;
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.scrollView.backgroundColor = [UIColor clearColor];
    if (@available(iOS 11.0, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.view.contentMode = UIViewContentModeScaleAspectFit;
    self.webView.contentMode = UIViewContentModeScaleAspectFit;

    [self.view addSubview:self.webView];
    [self.webView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equal.to(self.view);
    }];
    [self.webView loadRequest:request];
    self.webViewHud = [BJLProgressHUD bjl_showHUDForLoadingWithSuperview:self.loadingView animated:YES];
    self.closeButton.hidden = NO;
}

- (WKWebViewConfiguration *)defaultConfiguration {
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    config.userContentController = [WKUserContentController new];
    config.allowsInlineMediaPlayback = YES;
    config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    return config;
}

- (void)goback {
    [self.webView stopLoading];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:CloseWebviewMessageHander];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:OpenNewWebviewMessageHander];
    [self bjl_removeFromParentViewControllerAndSuperiew];
    if (self.closeWebViewCallback) {
        self.closeWebViewCallback();
    }
}

#pragma mark -WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (message.name == CloseWebviewMessageHander) {
        if ([message.body isKindOfClass:NSDictionary.class]) {
            NSDictionary *body = message.body;
            BOOL submit = [body bjl_boolForKey:@"isSubmit" defaultValue:NO];

            if (submit) {
                [self bjl_removeFromParentViewControllerAndSuperiew];
                if (self.questionUrlSubmitCallback) {
                    self.questionUrlSubmitCallback();
                }
            }
            else {
                [self goback];
            }
        }
    }
}

#pragma mark -WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self didFinishLoading];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self didStartLoading];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self didFailLoading];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        NSURL *url = navigationAction.request.URL;
        if (!url) {
            return;
        }
        [[BJLURLActionManager globalActionManager] performChainingActionWithURL:url userInfo:self completion:nil];
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self didFailLoading];
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    [self didFailLoading];
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *_Nullable))completionHandler {
    NSInteger disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *credential;
    if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
        disposition = NSURLSessionAuthChallengeUseCredential;
        credential = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
    }
    else {
        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    }
    completionHandler(disposition, credential);
}

#pragma mark -loading state

- (void)webViewLoadTimeout {
    [self didFailLoading];
}

- (void)didStartLoading {
}

- (void)didFailLoading {
    self.webViewHud.hidden = YES;
}

- (void)didFinishLoading {
    self.closeButton.hidden = YES;
    self.webViewHud.hidden = YES;
}
@end
