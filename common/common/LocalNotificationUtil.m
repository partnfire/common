//
//  LocalNotificationUtil.m
//  facialMask
//
//  Created by partnfire_hhj on 2018/7/24.
//  Copyright © 2018年 partnfire. All rights reserved.
//

#import "LocalNotificationUtil.h"
#import "HJTool.h"
#import "AppDelegate.h"
#import "NSString+Tool.h"
#import "UIWindow+SGTopVC.h"

#define LOCAL_NOTIFY_SCHEDULE_ID @"localscheduleNotify"

@implementation LocalNotificationUtil


+ (LocalNotificationUtil *) sharedInstance {
    static LocalNotificationUtil *shared;
    static dispatch_once_t done;
    dispatch_once(&done, ^{
        shared = [[LocalNotificationUtil alloc] init];
    });
    return shared;
}

- (void)sendLocalNotificationWithType: (LocalNotificationType)type andInfo:(NSDictionary *)info {
    if (!([[info allKeys] containsObject:@"alertBody"] && (![NSString isStringNull:[info objectForKey:@"alertBody"]]))) {
        [[HJTool sharedInstance] setHud:@"请提供通知内容" toView:[self currentView]];
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[UIApplication sharedApplication] currentUserNotificationSettings].types == UIUserNotificationTypeNone) {
        NSLog(@"没有打开通知权限");
        return;
    }
    [defaults synchronize];
    if (@available(iOS 10.0, *)) {
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        if([[info allKeys] containsObject:@"title"] && (![NSString isStringNull:[info objectForKey:@"title"]])) {
            content.title = [info objectForKey:@"title"];
        }
        if([[info allKeys] containsObject:@"subtitle"] && (![NSString isStringNull:[info objectForKey:@"subtitle"]])) {
            content.subtitle = [info objectForKey:@"subtitle"];
        }
        content.body = [info objectForKey:@"alertBody"];
        content.sound = [UNNotificationSound defaultSound];
        NSInteger num = [[UIApplication sharedApplication] applicationIconBadgeNumber];
        content.badge = [NSNumber numberWithUnsignedInteger:num + 1] ;
        
        if ([[info allKeys] containsObject:@"userInfo"]) {
            NSDictionary *oUserInfo = [info objectForKey:@"userInfo"];
            NSMutableDictionary *userInfo = [oUserInfo mutableCopy];
            [userInfo addEntriesFromDictionary:@{@"id":LOCAL_NOTIFY_SCHEDULE_ID}];
            content.userInfo = userInfo;
        }

        // 声明一个时间触发器
        UNTimeIntervalNotificationTrigger *timerTrigger = nil;
        if(type == LocalNotificationTypeSchedule && [[info allKeys] containsObject:@"interval"] && (![NSString isStringNull:[info objectForKey:@"interval"]])) {
            double timerTiming = [[info objectForKey:@"interval"] doubleValue];
            if (timerTiming <= 0) {
                timerTiming = 0.1;
            }
            timerTrigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:timerTiming repeats:NO];
        } else {
            [[HJTool sharedInstance] setHud:@"请提供通知提醒周期" toView:[self currentView]];
            return;
        }
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:LOCAL_NOTIFY_SCHEDULE_ID content:content trigger:timerTrigger];
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        }];
    } else if (@available(iOS 8.0, *)) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        if([[info allKeys] containsObject:@"alertTitle"] && (![NSString isStringNull:[info objectForKey:@"alertTitle"]])) {
            if (@available(iOS 8.2, *)) {
                localNotification.alertTitle = [info objectForKey:@"alertTitle"];
            }
        }
        localNotification.alertBody = [info objectForKey:@"alertBody"];
//        if((type = LocalNotificationTypeSchedule) && [[info allKeys] containsObject:@"interval"] && (![NSString isStringNull:[info objectForKey:@"interval"]])) {
        if(type == LocalNotificationTypeSchedule) {
            if ([[info allKeys] containsObject:@"interval"]) {
                if (![NSString isStringNull:[info objectForKey:@"interval"]]) {
                    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:[[info objectForKey:@"interval"] doubleValue]];
                }
            }
        } else {
            [[HJTool sharedInstance] setHud:@"请提供通知提醒周期" toView:[self currentView]];
            return;
        }
        
        if([[info allKeys] containsObject:@"alertAction"] && (![NSString isStringNull:[info objectForKey:@"alertAction"]])) {
            localNotification.alertAction = [info objectForKey:@"alertAction"];
        }
        NSInteger num = [[UIApplication sharedApplication] applicationIconBadgeNumber];
        localNotification.applicationIconBadgeNumber = num + 1;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        if ([[info allKeys] containsObject:@"userInfo"]) {
            NSDictionary *oUserInfo = [info objectForKey:@"userInfo"];
            NSMutableDictionary *userInfo = [oUserInfo mutableCopy];
            [userInfo addEntriesFromDictionary:@{@"id":LOCAL_NOTIFY_SCHEDULE_ID}];
            localNotification.userInfo = userInfo;
        }
        if (type == LocalNotificationTypeSchedule) {
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        } else if (type == LocalNotificationTypePresent) {
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        } else {
            [[HJTool sharedInstance] setHud:@"本地通知类型错误" toView:[self currentView]];
        }
        //  iOS8.0 以后新增属性
        //  ************************************
        //  1.设置区域,进入或离开某个区域的时候触发
        //    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(40.1,106.1);
        //    ln.region = [[CLCircularRegion alloc] initWithCenter:coordinate radius:10.0 identifier:@"ab"];
        //  2.设置进入或离开某个区域只执行一次
        //    ln.regionTriggersOnce = YES;
        //  ***************************************
        
        //  iOS8.2 新增属性
        //    ln.alertTitle = @"通知标题";
        //repeatInterval
    } else {
        [[HJTool sharedInstance] setHud:@"当前iPhone系统不支持该功能，请将系统升级到8.0及以上" toView:[self currentView]];
    }
}
         
- (UIView *)currentView {
    UIViewController *rootViewController;
    if (@available(iOS 13.0, *)) {
        rootViewController = [UIApplication sharedApplication].windows[0].rootViewController;
    } else {
        rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    UIViewController *currentVC = [UIWindow getVisibleViewControllerFrom:rootViewController];
    return currentVC.view;
}

- (void)requestLocalAuthor {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:UNAuthorizationOptionBadge|UNAuthorizationOptionSound|UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                NSLog(@"注册通知成功");
            } else {
                NSLog(@"注册通知失败");
            }
        }];
    } else if (@available(iOS 8.0, *)) {
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    } else {
        
    }
}

@end
