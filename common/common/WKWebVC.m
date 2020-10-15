//
//  WKWebVC.m
//  facialMask
//
//  Created by partnfire_hhj on 2018/11/11.
//  Copyright © 2018 partnfire. All rights reserved.
//

#import "WKWebVC.h"
#import <WebKit/WebKit.h>
#import "UIImage+ChangeSize.h"
#import "WebViewJavascriptBridge.h"
#import "WKWebViewJavascriptBridge.h"
#import "UIImage+ChangeSize.h"
#import "HJWebVC.h"
#import "BaseNavigationController.h"

@interface WKWebVC ()<UIActionSheetDelegate,WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (strong, nonatomic) WKWebView *wkWebView;
@property (assign, nonatomic) NSUInteger loadCount;
@property (strong, nonatomic) UIProgressView *progressView;
@property (nonatomic, strong) NSString *titleStr;
@property WKWebViewJavascriptBridge *bridge;

@property (nonatomic, assign) BOOL isPresent;

@end

@implementation WKWebVC

+ (void)showWithContro:(UIViewController *)contro withUrlStr:(NSString *)urlStr withTitle:(NSString *)title {
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    WKWebVC *webContro = [WKWebVC new];
    webContro.homeUrl = [NSURL URLWithString:urlStr];
    webContro.navigationItem.title = title;
    webContro.hidesBottomBarWhenPushed = YES;
    webContro.view.backgroundColor = [UIColor whiteColor];
    [contro.navigationController pushViewController:webContro animated:YES];
}

+ (void)showWithContro:(UIViewController *)contro withUrlStr:(NSString *)urlStr withTitle:(NSString *)title withType:(NSString *)type {
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    WKWebVC *webContro = [WKWebVC new];
    webContro.homeUrl = [NSURL URLWithString:urlStr];
    webContro.type = type;
    webContro.navigationItem.title = title;
    webContro.hidesBottomBarWhenPushed = YES;
    webContro.view.backgroundColor = [UIColor whiteColor];
    [contro.navigationController pushViewController:webContro animated:YES];
}

+ (void)showWithContro:(UIViewController *)contro withUrlStr:(NSString *)urlStr withTitle:(NSString *)title withModule:(NSString *)module withInfo:(NSDictionary *)info {
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    WKWebVC *webContro = [WKWebVC new];
    webContro.homeUrl = [NSURL URLWithString:urlStr];
    webContro.module = module;
    webContro.webInfo = info;
    webContro.navigationItem.title = title;
    webContro.hidesBottomBarWhenPushed = YES;
    webContro.view.backgroundColor = [UIColor whiteColor];
    [contro.navigationController pushViewController:webContro animated:YES];
}

//** 传入控制器、url、标题 */
+ (void)presentWithContro:(UIViewController *)contro withUrlStr:(NSString *)urlStr withTitle:(NSString *)title {
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    WKWebVC *webContro = [WKWebVC new];
    webContro.homeUrl = [NSURL URLWithString:urlStr];
    webContro.hidesBottomBarWhenPushed = YES;
    webContro.isPresent = YES;
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:webContro];
    webContro.title = title;
    [contro presentViewController:nav animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadUI]; //加载ui
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)bleDidDisConnect:(NSNotification *)notification {
    if ([self.navigationItem.rightBarButtonItems count] == 1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.rightBarButtonItem = nil;
        });
    }
}

- (void)loadUI {
    self.view.backgroundColor = [UIColor whiteColor];
    //scrollview
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - (44 + 22))];
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 100);
    scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.backgroundColor = [UIColor redColor];
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    // 进度条
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0.1, self.view.frame.size.width, 2)];
    progressView.trackTintColor = [UIColor whiteColor];
    [self.scrollView addSubview:progressView];
    self.progressView = progressView;
    
    // 网页
    WKPreferences *pref = [[WKPreferences alloc] init];
    [pref setJavaScriptEnabled:YES]; // 设置成NO的时候比较狠,团火web端团队现行框架全部挂
    [pref setJavaScriptCanOpenWindowsAutomatically:NO];
    
    WKWebViewConfiguration *conf = [[WKWebViewConfiguration alloc] init];
    [conf setPreferences:pref];
    [conf setAllowsInlineMediaPlayback:YES];
    
    WKWebView *wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 2.1, self.view.frame.size.width, CGRectGetHeight(scrollView.frame) - 2.1) configuration:conf];
    wkWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    wkWebView.backgroundColor = [UIColor whiteColor];
    wkWebView.scrollView.backgroundColor = [UIColor whiteColor];
    wkWebView.scrollView.bounces = NO;
    wkWebView.navigationDelegate = self;
    wkWebView.UIDelegate = self;
    [self.scrollView insertSubview:wkWebView belowSubview:progressView];
    [wkWebView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    
    [wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    NSString *homeUrlStr = self.homeUrl.absoluteString;
    if ([self.homeUrl.absoluteString hasPrefix:@"xxx-"]) {
        homeUrlStr = [self.homeUrl.absoluteString stringByReplacingOccurrencesOfString:@"xxx-" withString:@""];
    }
    NSURL *tempUrl = [NSURL URLWithString:homeUrlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:tempUrl
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:15.0];
    [wkWebView loadRequest:request];
    self.wkWebView = wkWebView;
    
    self.bridge = [WKWebViewJavascriptBridge bridgeForWebView:self.wkWebView];
    [self.bridge setWebViewDelegate:self];
}

#pragma mark - 返回按钮事件
// 返回按钮点击
- (void)backBtnPressed:(id)sender {
    if (self.isPresent) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - wkWebView代理
// 如果不添加这个，那么wkwebview跳转不了AppStore
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    WebViewJavascriptBridgeBase *base = [[WebViewJavascriptBridgeBase alloc] init];
    if ([base isWebViewJavascriptBridgeURL:navigationAction.request.URL]) {
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

// 计算wkWebView进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.wkWebView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1) {
            self.progressView.hidden = YES;
            [self.progressView setProgress:0 animated:NO];
        }else {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newprogress animated:YES];
        }
    } else if (object == self.wkWebView.scrollView && [keyPath isEqualToString:@"contentSize"]) {
        CGSize fittingSize = [self.wkWebView sizeThatFits:CGSizeZero];
        CGFloat documentHeight = fittingSize.height;
        self.scrollView.contentSize  = CGSizeMake(self.view.frame.size.width, documentHeight + (44 + 22));
        self.wkWebView.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, documentHeight);
    } else {
        
    }
}

// 记得取消监听
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.wkWebView.scrollView removeObserver:self forKeyPath:@"contentSize"];
}

#pragma mark - webView代理
// 计算webView进度条
- (void)setLoadCount:(NSUInteger)loadCount {
    _loadCount = loadCount;
    if (loadCount == 0) {
        self.progressView.hidden = YES;
        [self.progressView setProgress:0 animated:NO];
    }else {
        self.progressView.hidden = NO;
        CGFloat oldP = self.progressView.progress;
        CGFloat newP = (1.0 - oldP) / (loadCount + 1) + oldP;
        if (newP > 0.95) {
            newP = 0.95;
        }
        [self.progressView setProgress:newP animated:YES];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
//    __weak typeof(self)weakself = self;
//    [webView evaluateJavaScript:@"document.body.scrollHeight;" completionHandler:^(id result, NSError * error) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            CGFloat documentHeight = [result floatValue];
//            weakself.scrollView.contentSize  = CGSizeMake(weakself.view.frame.size.width, documentHeight + (44 + kStatusBarHeight));
//            weakself.wkWebView.frame = CGRectMake(weakself.view.bounds.origin.x, weakself.view.bounds.origin.y, weakself.view.bounds.size.width, documentHeight);
//        });
//    }];
}

-(void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,card);
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"message:%@",message);
    completionHandler();

}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    //    DLOG(@"msg = %@ frmae = %@",message,frame);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
