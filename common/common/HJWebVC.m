//
//  HJWebVC.m
//  DynamicRehabilitation
//
//  Created by 侯慧杰 on 17/1/10.
//  Copyright © 2017年 Dev..l. All rights reserved.
//

#import "HJWebVC.h"
#import <WebKit/WebKit.h>
#import "UIImage+ChangeSize.h"
#import "WebViewJavascriptBridge.h"
#import "WKWebViewJavascriptBridge.h"
#import "UIImage+ChangeSize.h"


@interface HJWebVC ()<UIActionSheetDelegate,WKNavigationDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (strong, nonatomic) WKWebView *wkWebView;
@property (assign, nonatomic) NSUInteger loadCount;
@property (strong, nonatomic) UIProgressView *progressView;
@property (nonatomic, strong) NSString *titleStr;
@property WKWebViewJavascriptBridge *bridge;

@end

@implementation HJWebVC

//** 传入控制器、url、标题 */
+ (void)showWithContro:(UIViewController *)contro withUrlStr:(NSString *)urlStr withTitle:(NSString *)title {
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    HJWebVC *webContro = [HJWebVC new];
    webContro.homeUrl = [NSURL URLWithString:urlStr];
    webContro.navigationItem.title = title;
    webContro.hidesBottomBarWhenPushed = YES;
    [contro.navigationController pushViewController:webContro animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    [self loadUI]; //加载ui
    [self configBackItem]; //加载返回按钮
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)loadUI {
    //scrollview
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - (44 + 22))];
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 100);
    scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.backgroundColor = [UIColor redColor];
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    // 进度条
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0.1, self.view.frame.size.width, 2)];
    progressView.tintColor = [UIColor orangeColor];
    progressView.trackTintColor = [UIColor whiteColor];
    [self.scrollView addSubview:progressView];
    self.progressView = progressView;
    
    // 网页
    WKPreferences *pref = [[WKPreferences alloc] init];
    [pref setJavaScriptEnabled:YES]; // 设置成NO的时候比较狠,团火web端团队现行框架全部挂
    [pref setJavaScriptCanOpenWindowsAutomatically:NO];
    
    WKWebViewConfiguration *conf = [[WKWebViewConfiguration alloc] init];
    [conf setPreferences:pref];
    
    WKWebView *wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 2.1, self.view.frame.size.width, CGRectGetHeight(scrollView.frame) - 2.1) configuration:conf];
    wkWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    wkWebView.backgroundColor = [UIColor whiteColor];
    wkWebView.navigationDelegate = self;
    wkWebView.scrollView.backgroundColor = [UIColor whiteColor];
    [self.scrollView insertSubview:wkWebView belowSubview:progressView];
    
    [wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:_homeUrl];
    [wkWebView loadRequest:request];
    self.wkWebView = wkWebView;
    
//    self.bridge = [WKWebViewJavascriptBridge bridgeForWebView:self.wkWebView];
//    [self.bridge setWebViewDelegate:self];
//    __weak __typeof(self) weakSelf = self;
//    [self.bridge registerHandler:@"ZkShare" handler:^(id data, WVJBResponseCallback responseCallback) {
//    }];
}

- (void)configBackItem {
    // 导航栏的返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"navBack"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"navBack"] forState:UIControlStateHighlighted];
    [backButton sizeToFit];
    [backButton addTarget:self action:@selector(backBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
}

#pragma mark - 返回按钮事件
// 返回按钮点击
- (void)backBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
    }
}

// 记得取消监听
- (void)dealloc {
    [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
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

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    __weak typeof(self)weakself = self;
    [webView evaluateJavaScript:@"document.body.scrollHeight;" completionHandler:^(id result, NSError * error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat documentHeight = [result floatValue];
            weakself.scrollView.contentSize  = CGSizeMake(weakself.view.frame.size.width, documentHeight + (44 + 22));
            weakself.wkWebView.frame = CGRectMake(weakself.view.bounds.origin.x, weakself.view.bounds.origin.y, weakself.view.bounds.size.width, documentHeight);
        });
    }];
}

-(void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,card);
    }
}

@end
