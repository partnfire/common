//
//  HJTool.h
//  DynamicRehabilitation
//
//  Created by 于艳平 on 2017/1/18.
//  Copyright © 2017年 Knowledge Science andTechnology. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^netStateBlock)(NSString *netState);

@interface HJTool : NSObject

+ (HJTool *)sharedInstance;

- (NSString *)getRandomNum;

- (NSArray *)randomArray:(int)count;

- (NSString *)currentVersion;

//是否需要强制升级
@property (nonatomic, strong) NSString *needFlag;
//App新版本信息
@property (nonatomic, strong) NSDictionary *releaseInfo;
//
@property (nonatomic, strong) NSString *lastVersion;
//本来想删除掉的，但是：当强制升级时，需要在进入前台的时候展示升级提示框，所以还得留着
@property (nonatomic, strong) NSString *trackViewUrl;

- (void)checkVersionForUpdate;

- (void)displayVersionUpdateBox;

- (NSString *)validJSONString:(NSString *)json;

- (void)setHud:(NSString *)message toView:(UIView *)view;

- (void)setActivity:(NSString *)message;

- (void)dismissActivity;

- (void)setAlertController:(NSString *)message;

/**
 获取机型
 @return 本机机型
 */
- (NSString *)iphoneType;

/**
 *  网络监测
 *  @param block 判断结果回调
 */
- (void)netWorkState:(netStateBlock)block;

- (UIViewController *)currentVc;

/**
 NSDictionary转json字符串

 @param dict NSDictionary
 @return json字符串
 */
- (NSString *)convertToJsonData:(NSDictionary *)dict;

@end
