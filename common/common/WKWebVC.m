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
#import "BLEService_V2.h"
#import "WorkingStateVC.h"
#import "WorkingVC.h"
#import "BluetoothUtil.h"
#import "HJWebVC.h"

@interface WKWebVC ()<UIWebViewDelegate,UIActionSheetDelegate,WKNavigationDelegate, WorkingStateDelegate, WKUIDelegate>

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
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    WKWebVC *webContro = [WKWebVC new];
    webContro.homeUrl = [NSURL URLWithString:urlStr];
    webContro.navigationItem.title = title;
    webContro.hidesBottomBarWhenPushed = YES;
    webContro.view.backgroundColor = [UIColor whiteColor];
    [contro.navigationController pushViewController:webContro animated:YES];
}

+ (void)showWithContro:(UIViewController *)contro withUrlStr:(NSString *)urlStr withTitle:(NSString *)title withType:(NSString *)type {
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    WKWebVC *webContro = [WKWebVC new];
    webContro.homeUrl = [NSURL URLWithString:urlStr];
    webContro.type = type;
    webContro.navigationItem.title = title;
    webContro.hidesBottomBarWhenPushed = YES;
    webContro.view.backgroundColor = [UIColor whiteColor];
    [contro.navigationController pushViewController:webContro animated:YES];
}

+ (void)showWithContro:(UIViewController *)contro withUrlStr:(NSString *)urlStr withTitle:(NSString *)title withModule:(NSString *)module withInfo:(NSDictionary *)info {
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bleDidDisConnect:) name:BLEUtilDisConnectNotification object:nil];
    [self loadUI]; //加载ui
    [self videoPlayerFinishedToShowStatusBar];
}

- (void)videoPlayerFinishedToShowStatusBar {
    if (@available(iOS 12.0, *)) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidRotate) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(videoDidRotate) name:UIWindowDidBecomeHiddenNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(beginFullScreen:) name:UIWindowDidBecomeVisibleNotification object:nil];
    }
}

- (BOOL)prefersStatusBarHidden {
    return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
}

- (void)videoDidRotate {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsStatusBarAppearanceUpdate];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        self.navigationController.navigationBar.frame = CGRectMake(0, kStatusBarHeight, kScreenSizeWidth, 44);//矫正导航栏移位
    });
}

- (void)windowDidBecomeHidden:(NSNotification *)noti {
    UIWindow *win = (UIWindow *)noti.object;
    if(win){
        UIViewController *rootVC = win.rootViewController;
        NSArray<__kindof UIViewController *> *vcs = rootVC.childViewControllers;
        if([vcs.firstObject isKindOfClass:NSClassFromString(@"AVPlayerViewController")]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
            });
        }
    }
}

- (void)beginFullScreen:(NSNotification *)noti {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    });
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:0];
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navBack"] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnPressed:)];
        [backItem setTintColor:STRGB16Color(0x453015)];
        self.navigationItem.leftBarButtonItem = backItem;
        
        if (![NSString isStringNull:self.module]) {
            if ([self.module isEqualToString:@"aimeishuo"]) {
                UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"believe_share_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(shareAction:)];
                [shareItem setTintColor:STRGB16Color(0x666666)];
                self.navigationItem.rightBarButtonItem = shareItem;
            }
        } else {
            NSString *title = self.navigationItem.title;
            if ([title isEqualToString:Localized(@"Product")]) {
                self.navigationItem.rightBarButtonItem = nil;
                BOOL result = [[BLEService_V2 sharedInstance] isWorkingAndConnectedDevice];
                if (result) {
                    UIButton *deviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    [deviceBtn setFrame:CGRectMake(0, 0, 23, 23)];
                    UIImage *deviceButtonImage = [UIImage sd_animatedGIFNamed:@"deviceWorking"];
                    if (@available(iOS 11.0, *)) {
                        [deviceBtn.widthAnchor constraintEqualToConstant:23].active = YES;
                        [deviceBtn.heightAnchor constraintEqualToConstant:23].active = YES;
                        [deviceBtn setImage:deviceButtonImage forState:UIControlStateNormal];
                        [deviceBtn setImage:deviceButtonImage forState:UIControlStateHighlighted];
                        [deviceBtn sizeToFit];
                    } else {
                        // Fallback on earlier versions
                        CGFloat btnSelImageW = deviceButtonImage.size.width * 0.5;
                        CGFloat btnSelImageH = deviceButtonImage.size.height * 0.5;
                        UIImage *newBtnSelImage = [deviceButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(btnSelImageH, btnSelImageW, btnSelImageH, btnSelImageW) resizingMode:UIImageResizingModeStretch];
                        [deviceBtn setImage:newBtnSelImage forState:UIControlStateNormal];
                        [deviceBtn setImage:newBtnSelImage forState:UIControlStateHighlighted];
                    }
                    [deviceBtn addTarget:self action:@selector(deviceAction:) forControlEvents:UIControlEventTouchUpInside];
                    UIBarButtonItem *deviceButtonItem = [[UIBarButtonItem alloc] initWithCustomView:deviceBtn];
                    self.navigationItem.rightBarButtonItem = deviceButtonItem;
                }
            }
        }
    });
}

- (void)helpAction:(UIBarButtonItem *)sender {
    NSString *url = [NSString stringWithFormat:@"%@/pfimm-skin/skinManagerHelp",URL_FileServer];
    [WKWebVC showWithContro:self withUrlStr:url withTitle:@"肌肤管理小助手"];
}

- (void)shareAction:(UIBarButtonItem *)sender {
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)deviceAction:(UIBarButtonItem *)sender {
    WorkingStateVC *wsvc = (WorkingStateVC *)[[UIStoryboard storyboardWithName:@"Setting" bundle:nil] instantiateViewControllerWithIdentifier:@"WorkingStateVC"];
    wsvc.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
    wsvc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    wsvc.delegate = self;
    [self presentViewController:wsvc animated:YES completion:^{
        
    }];
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
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - (44 + kStatusBarHeight))];
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 100);
    scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.backgroundColor = [UIColor redColor];
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    // 进度条
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0.1, kScreenSizeWidth, 2)];
    progressView.tintColor = MainStyleColor;
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
    
    WKWebView *wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 2.1, kScreenSizeWidth, CGRectGetHeight(scrollView.frame) - 2.1) configuration:conf];
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
    
    __weak typeof(self)weakself = self;
  

    //用户没有选择过肌肤类型，h5展示选择肌肤类型   type:select(没有的时候选择)  change(更换肌肤类型)
    [self.bridge registerHandler:@"homeToSelectSkinType" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *type = [NSString string:[NSString stringWithFormat:@"%@",[data objectForKey:@"type"]] withNullStr:@"change"];
        if ([type isEqualToString:@"select"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakself.title = @"选择肌肤类型";
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *homeUrl = [NSString string:[NSString stringWithFormat:@"%@%@",URL_FileServer,[data objectForKey:@"url"]] withNullStr:@""];
                [HJWebVC showWithContro:weakself withUrlStr:homeUrl withTitle:@"选择肌肤类型"];
            });
        }
    }];

    //通用
    [self.bridge registerHandler:@"generalBridge" handler:^(id data, WVJBResponseCallback responseCallback) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *homeUrl = [NSString string:[NSString stringWithFormat:@"%@%@",URL_FileServer,[data objectForKey:@"url"]] withNullStr:@""];
            NSString *title = [NSString string:[NSString stringWithFormat:@"%@",[data objectForKey:@"title"]] withNullStr:@""];
            if([NSString isStringNull:[data objectForKey:@"type"]]) {
                [HJWebVC showWithContro:weakself withUrlStr:homeUrl withTitle:title];
            } else {
                [HJWebVC showWithContro:weakself withUrlStr:homeUrl withTitle:title];
            }
        });
    }];
}

#pragma mark - 返回按钮事件
// 返回按钮点击
- (void)backBtnPressed:(id)sender {
    if (self.isPresent) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        NSString *title = self.navigationItem.title;
        if ([title isEqualToString:Localized(@"Product")]) {
            BOOL result = [[BLEService_V2 sharedInstance] isWorking];
            if (result) {
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIViewController *rootVC = [board instantiateViewControllerWithIdentifier:@"RootVC_V3"];
                UIWindow *window = UIApplication.sharedApplication.delegate.window;
                window.rootViewController = rootVC;
                [UIView transitionWithView:window duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
                }];
            }
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
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
        self.scrollView.contentSize  = CGSizeMake(self.view.frame.size.width, documentHeight + (44 + kStatusBarHeight));
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

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.loadCount ++;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.loadCount --;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    self.loadCount --;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
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
    STLog(@"message:%@",message);
    completionHandler();

}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    //    DLOG(@"msg = %@ frmae = %@",message,frame);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:Localized(@"Hint") message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:Localized(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:Localized(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:Localized(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 点击“控制设备”
- (void)workingToControlDevice {
    WorkingVC *workingVC = (WorkingVC *)[[UIStoryboard storyboardWithName:@"Music" bundle:nil] instantiateViewControllerWithIdentifier:@"WorkingVC"];
    workingVC.hidesBottomBarWhenPushed = YES;
    workingVC.backType = @"back";
    [self.navigationController pushViewController:workingVC animated:YES];
}

@end
