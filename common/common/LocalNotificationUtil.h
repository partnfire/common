//
//  LocalNotificationUtil.h
//  facialMask
//
//  Created by partnfire_hhj on 2018/7/24.
//  Copyright © 2018年 partnfire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

@interface LocalNotificationUtil : NSObject<UNUserNotificationCenterDelegate>

typedef NS_ENUM(NSUInteger, LocalNotificationType) {
    LocalNotificationTypeSchedule, //延迟发送
    LocalNotificationTypePresent   //马上发送
};

+ (LocalNotificationUtil *) sharedInstance;

/**
 发送本地通知
 @param type 类型 
 @param info 通知展示信息
 */
- (void)sendLocalNotificationWithType: (LocalNotificationType)type andInfo:(NSDictionary *)info;

- (void)requestLocalAuthor;

@end
