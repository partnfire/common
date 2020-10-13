//
//  HJTool.m
//  DynamicRehabilitation
//
//  Created by 于艳平 on 2017/1/18.
//  Copyright © 2017年 Knowledge Science andTechnology. All rights reserved.
//

#import "HJTool.h"
#import "AppDelegate.h"
#import <sys/utsname.h>
#import "NewVersionTipVC.h"

@implementation HJTool

+ (HJTool *) sharedInstance {
    static HJTool *shared;
    static dispatch_once_t done;
    dispatch_once(&done, ^{
        shared = [[HJTool alloc] init];
        
    });
    return shared;
}

- (NSString *)getRandomNum {
    int num = (arc4random() % 1000000);
    NSString *randomNumber = [NSString stringWithFormat:@"%.6d", num];
    return randomNumber;
}


- (NSArray *)randomArray:(int)count {
    //随机数从这里边产生
    NSMutableArray *startArray = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        [startArray addObject:@(i)];
    }
    //随机数产生结果
    NSMutableArray *resultArray = [[NSMutableArray alloc] initWithCapacity:0];
    //随机数个数
    NSInteger m = 3;
    for (int i=0; i<m; i++) {
        int t = arc4random() % startArray.count;
        resultArray[i] = startArray[t];
        startArray[t] = [startArray lastObject]; //为更好的乱序，故交换下位置
        [startArray removeLastObject];
    }
    return resultArray;
}

- (void)setHud:(NSString *)message toView:(UIView *)view {
    if ([message isEqualToString:@"请先登录"]) {
        [self setAlertController:message];
    } else {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.label.text = message;
        hud.label.numberOfLines = 0;
        hud.label.font = [UIFont systemFontOfSize:15];
        hud.bezelView.color = STRGB16Color(0x6F6F6F);
        hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        [hud showAnimated:YES];
        [hud hideAnimated:YES afterDelay:1.5];
        hud.contentColor = [UIColor whiteColor];
        hud.mode = MBProgressHUDModeText;
    }
}

- (void)setActivity:(NSString *)message {
    [SVProgressHUD setInfoImage:[UIImage sd_animatedGIFNamed:@"load"]];
    [SVProgressHUD setImageViewSize:CGSizeMake(50, 50)];
    [SVProgressHUD setMinimumDismissTimeInterval:20];
    [SVProgressHUD setBackgroundLayerColor:[UIColor clearColor]];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];//SVProgressHUDMaskTypeCustom  SVProgressHUDMaskTypeGradient
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD showInfoWithStatus:message];
}

- (void)dismissActivity {
    if ([SVProgressHUD isVisible]) {
        [[HJTool sharedInstance] dismissActivity];
    }
}

- (void)setAlertController:(NSString *)message {
    UIViewController *topRootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topRootViewController.presentedViewController) {
        topRootViewController = topRootViewController.presentedViewController;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:Localized(@"Hint") message:message preferredStyle:  UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:Localized(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [topRootViewController presentViewController:alert animated:true completion:^{
        
    }];
}

- (NSString*)currentVersion {
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
    return currentVersion;
}

- (void)checkVersionForUpdate {
    __weak typeof(self)weakSelf = self;
    NSString *currentVersion = [[HJTool sharedInstance] currentVersion];
    NSString *URL = [NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@",APPID];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:URL]];
    [request setHTTPMethod:@"POST"];
    NSHTTPURLResponse *urlResponse = nil;
    NSError *error = nil;
    NSData *recervedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    NSString *str = [[NSString alloc] initWithData:recervedData encoding:NSUTF8StringEncoding];
    str = [[HJTool sharedInstance] validJSONString:str];
    recervedData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:recervedData options:NSJSONReadingMutableContainers error:&error];
    if(!recervedData || error){
        return;
    }
    NSNumber* cnt = [dic objectForKey:@"resultCount"];
    //no data was obtained.
    if([cnt integerValue] < 1){
        return;
    }
    NSArray *infoArray = [dic objectForKey:@"results"];
    NSString *lastVersion = @"";
    if ([infoArray count]) {
        NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
        lastVersion = [releaseInfo objectForKey:@"version"];
        self.releaseInfo = releaseInfo;
        self.lastVersion = lastVersion;
        if ([lastVersion containsString:@"V"]) {
            lastVersion = [lastVersion stringByReplacingOccurrencesOfString:@"V" withString:@""];
        }
        weakSelf.trackViewUrl = [releaseInfo objectForKey:@"trackViewUrl"];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults synchronize];
        BOOL updateFlag = NO;
        if ([lastVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending) {
            updateFlag = YES;
        } else {
            // 不需要更新
            if ([defaults objectForKey:GetNewVersionDate]) {
                [defaults removeObjectForKey:GetNewVersionDate];
            }
        }
        
        if (updateFlag) {
            NSString *url = [NSString stringWithFormat:@"%@%@", URL_ServerAddress, URL_Version(lastVersion)];
            [[HJNetWorkHandler shareInstance] startRequestMethod:GET parameters:nil url:url success:^(id responseObjectSelf) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(![responseObjectSelf isEqual:[NSNull null]] && [[responseObjectSelf allKeys] count] > 0) {
                        NSString *foe = [NSString string:[NSString stringWithFormat:@"%@",[responseObjectSelf objectForKey:@"force"]] withNullStr:@"0"];
                        weakSelf.needFlag = foe;
                        [[AppDelegate shareAppDelegate] setNeedFlag:foe];
                        [weakSelf displayVersionUpdateBox];
                    } else {
                        weakSelf.needFlag = @"0";
                        [[AppDelegate shareAppDelegate] setNeedFlag:@"0"];
                        [weakSelf displayVersionUpdateBox];
                    }
                });
            } failure:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.needFlag = @"0";
                    [weakSelf displayVersionUpdateBox];
                });
            }];
        }
    }
}

- (void)displayVersionUpdateBox {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    NSString *currentVersionReleaseDate = [NSString stringWithFormat:@"%@",[self.releaseInfo objectForKey:@"currentVersionReleaseDate"]];
    if (![NSString isStringNull:currentVersionReleaseDate]) {
        currentVersionReleaseDate = [currentVersionReleaseDate stringByReplacingOccurrencesOfString:@"T" withString:@" "];
        currentVersionReleaseDate = [currentVersionReleaseDate stringByReplacingOccurrencesOfString:@"Z" withString:@""];
        NSDate *date = [NSDate getSGDateByString:currentVersionReleaseDate format:@"yyyy-MM-dd HH:mm:ss"];
        NSTimeZone *zone = [NSTimeZone systemTimeZone];
        //得到源日期与世界标准时间的偏移量
        NSInteger interval = [zone secondsFromGMTForDate: date];
        //返回以当前NSDate对象为基准，偏移多少秒后得到的新NSDate对象
        NSDate *localeDate = [date dateByAddingTimeInterval: interval];
        NSDate *nowDate = [NSDate getBeijingDate];
        NSInteger sec = [NSDate gapBetweenOneDate:localeDate anotherDate:nowDate];
        if (sec > 10800) {  // 检测到新版本三小时后提示更新。 10800
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *releaseInfoStr = [NSString string:[self.releaseInfo objectForKey:@"releaseNotes"] withNullStr:@""];
                NSArray *array = [NSArray array];
                if ([releaseInfoStr containsString:@";"]) {
                    array = [releaseInfoStr componentsSeparatedByString:@";"];
                }
                UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                NewVersionTipVC *vc = [board instantiateViewControllerWithIdentifier:@"NewVersionTipVC"];
                vc.array = array;
                vc.needFlag = self.needFlag;
                vc.lastVersion = self.lastVersion;
                vc.upgradeBlock = ^{
                    NSURL *url = nil;
                    if (self.trackViewUrl == nil || [self.trackViewUrl length] == 0) {
                        url = [NSURL URLWithString:@"https://itunes.apple.com"];
                    } else {
                        url = [NSURL URLWithString:self.trackViewUrl];
                    }
                    [[UIApplication sharedApplication]openURL:url];
                };
                vc.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.7];
                vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                UIViewController *topRootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                [topRootViewController presentViewController:vc animated:YES completion:nil];
            });
        }
        STLog(@"%@", localeDate);
    } else {
        NSDate *nowDate = [NSDate getBeijingDate];
        if ([defaults objectForKey:GetNewVersionDate]) {
            NSDate *date = [defaults objectForKey:GetNewVersionDate];
            NSInteger sec = [NSDate gapBetweenOneDate:date anotherDate:nowDate];
            if (sec > 10800) {  // 检测到新版本三小时后提示更新。 10800
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *releaseInfoStr = [NSString string:[self.releaseInfo objectForKey:@"releaseNotes"] withNullStr:@""];
                    NSArray *array = [NSArray array];
                    if ([releaseInfoStr containsString:@"；"]) {
                        array = [releaseInfoStr componentsSeparatedByString:@"；"];
                    }
                    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    NewVersionTipVC *vc = [board instantiateViewControllerWithIdentifier:@"NewVersionTipVC"];
                    vc.array = array;
                    vc.needFlag = self.needFlag;
                    vc.lastVersion = self.lastVersion;
                    vc.upgradeBlock = ^{
                        NSURL *url = nil;
                        if (self.trackViewUrl == nil || [self.trackViewUrl length] == 0) {
                            url = [NSURL URLWithString:@"https://itunes.apple.com"];
                        }else{
                            url = [NSURL URLWithString:self.trackViewUrl];
                        }
                        [[UIApplication sharedApplication]openURL:url];
                    };
                    vc.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.7];
                    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                    UIViewController *topRootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                    [topRootViewController presentViewController:vc animated:YES completion:nil];
                });
            }
        } else {
            [defaults setObject:nowDate forKey:GetNewVersionDate];
        }
    }
}


- (NSString *)validJSONString:(NSString *)json {
    NSMutableString *s = [NSMutableString stringWithString:json];
    [s replaceOccurrencesOfString:@"\\\"" withString:@"\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\\/" withString:@"/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\\n" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\\b" withString:@"\b" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\\f" withString:@"\f" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\\r" withString:@"\r" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\\t" withString:@"\t" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\n" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\r\n" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\t" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    return s;
}

- (NSString *)iphoneType {
    //需要导入头文件：#import <sys/utsname.h>
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString*platform = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if([platform isEqualToString:@"iPhone1,1"]) return@"iPhone 2G";
    
    if([platform isEqualToString:@"iPhone1,2"]) return@"iPhone 3G";
    
    if([platform isEqualToString:@"iPhone2,1"]) return@"iPhone 3GS";
    
    if([platform isEqualToString:@"iPhone3,1"]) return@"iPhone 4";
    
    if([platform isEqualToString:@"iPhone3,2"]) return@"iPhone 4";
    
    if([platform isEqualToString:@"iPhone3,3"]) return@"iPhone 4";
    
    if([platform isEqualToString:@"iPhone4,1"]) return@"iPhone 4S";
    
    if([platform isEqualToString:@"iPhone5,1"]) return@"iPhone 5";
    
    if([platform isEqualToString:@"iPhone5,2"]) return@"iPhone 5";
    
    if([platform isEqualToString:@"iPhone5,3"]) return@"iPhone 5c";
    
    if([platform isEqualToString:@"iPhone5,4"]) return@"iPhone 5c";
    
    if([platform isEqualToString:@"iPhone6,1"]) return@"iPhone 5s";
    
    if([platform isEqualToString:@"iPhone6,2"]) return@"iPhone 5s";
    
    if([platform isEqualToString:@"iPhone7,1"]) return@"iPhone 6 Plus";
    
    if([platform isEqualToString:@"iPhone7,2"]) return@"iPhone 6";
    
    if([platform isEqualToString:@"iPhone8,1"]) return@"iPhone 6s";
    
    if([platform isEqualToString:@"iPhone8,2"]) return@"iPhone 6s Plus";
    
    if([platform isEqualToString:@"iPhone8,4"]) return@"iPhone SE";
    
    if([platform isEqualToString:@"iPhone9,1"]) return@"iPhone 7";
    
    if([platform isEqualToString:@"iPhone9,2"]) return@"iPhone 7 Plus";
    
    if([platform isEqualToString:@"iPhone10,1"]) return@"iPhone 8";
    
    if([platform isEqualToString:@"iPhone10,4"]) return@"iPhone 8";
    
    if([platform isEqualToString:@"iPhone10,2"]) return@"iPhone 8 Plus";
    
    if([platform isEqualToString:@"iPhone10,5"]) return@"iPhone 8 Plus";
    
    if([platform isEqualToString:@"iPhone10,3"]) return@"iPhone X";
    
    if([platform isEqualToString:@"iPhone10,6"]) return@"iPhone X";
    
    if([platform isEqualToString:@"iPod1,1"]) return@"iPod Touch 1G";
    
    if([platform isEqualToString:@"iPod2,1"]) return@"iPod Touch 2G";
    
    if([platform isEqualToString:@"iPod3,1"]) return@"iPod Touch 3G";
    
    if([platform isEqualToString:@"iPod4,1"]) return@"iPod Touch 4G";
    
    if([platform isEqualToString:@"iPod5,1"]) return@"iPod Touch 5G";
    
    if([platform isEqualToString:@"iPad1,1"]) return@"iPad 1G";
    
    if([platform isEqualToString:@"iPad2,1"]) return@"iPad 2";
    
    if([platform isEqualToString:@"iPad2,2"]) return@"iPad 2";
    
    if([platform isEqualToString:@"iPad2,3"]) return@"iPad 2";
    
    if([platform isEqualToString:@"iPad2,4"]) return@"iPad 2";
    
    if([platform isEqualToString:@"iPad2,5"]) return@"iPad Mini 1G";
    
    if([platform isEqualToString:@"iPad2,6"]) return@"iPad Mini 1G";
    
    if([platform isEqualToString:@"iPad2,7"]) return@"iPad Mini 1G";
    
    if([platform isEqualToString:@"iPad3,1"]) return@"iPad 3";
    
    if([platform isEqualToString:@"iPad3,2"]) return@"iPad 3";
    
    if([platform isEqualToString:@"iPad3,3"]) return@"iPad 3";
    
    if([platform isEqualToString:@"iPad3,4"]) return@"iPad 4";
    
    if([platform isEqualToString:@"iPad3,5"]) return@"iPad 4";
    
    if([platform isEqualToString:@"iPad3,6"]) return@"iPad 4";
    
    if([platform isEqualToString:@"iPad4,1"]) return@"iPad Air";
    
    if([platform isEqualToString:@"iPad4,2"]) return@"iPad Air";
    
    if([platform isEqualToString:@"iPad4,3"]) return@"iPad Air";
    
    if([platform isEqualToString:@"iPad4,4"]) return@"iPad Mini 2G";
    
    if([platform isEqualToString:@"iPad4,5"]) return@"iPad Mini 2G";
    
    if([platform isEqualToString:@"iPad4,6"]) return@"iPad Mini 2G";
    
    if([platform isEqualToString:@"iPad4,7"]) return@"iPad Mini 3";
    
    if([platform isEqualToString:@"iPad4,8"]) return@"iPad Mini 3";
    
    if([platform isEqualToString:@"iPad4,9"]) return@"iPad Mini 3";
    
    if([platform isEqualToString:@"iPad5,1"]) return@"iPad Mini 4";
    
    if([platform isEqualToString:@"iPad5,2"]) return@"iPad Mini 4";
    
    if([platform isEqualToString:@"iPad5,3"]) return@"iPad Air 2";
    
    if([platform isEqualToString:@"iPad5,4"]) return@"iPad Air 2";
    
    if([platform isEqualToString:@"iPad6,3"]) return@"iPad Pro 9.7";
    
    if([platform isEqualToString:@"iPad6,4"]) return@"iPad Pro 9.7";
    
    if([platform isEqualToString:@"iPad6,7"]) return@"iPad Pro 12.9";
    
    if([platform isEqualToString:@"iPad6,8"]) return@"iPad Pro 12.9";
    
    if([platform isEqualToString:@"i386"]) return@"iPhone Simulator";
    
    if([platform isEqualToString:@"x86_64"]) return@"iPhone Simulator";
    
    return platform;
    
}

#pragma mark----网络检测
- (void)netWorkState:(netStateBlock)block {
    // 打开网络监测
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    // 判断当前是wifi状态、3g、4g还是网络不可用状态
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi: {
               // wifi
                block(@"wifi");
                [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN: {
                // 移动网络
                block(@"mobile");
                [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
                break;
            }
            default:
                block(@"");
                [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
                break;
        }
    }];
}

- (UIViewController *)currentVc {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [UIWindow getVisibleViewControllerFrom:rootViewController];
    return currentVC;
}

- (NSString *)convertToJsonData:(NSDictionary *)dict {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}

@end
