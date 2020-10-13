//
//  WKWebVC.h
//  facialMask
//
//  Created by partnfire_hhj on 2018/11/11.
//  Copyright © 2018 partnfire. All rights reserved.
//

#import "BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface WKWebVC : BaseVC

@property (strong, nonatomic) NSURL *homeUrl;

@property (strong, nonatomic) NSString *type;
//功能、模块
@property (strong, nonatomic) NSString *module;
//信息
@property (strong, nonatomic) NSDictionary *webInfo;

/** 传入控制器、url、标题 */
+ (void)showWithContro:(UIViewController *)contro withUrlStr:(NSString *)urlStr withTitle:(NSString *)title;

+ (void)showWithContro:(UIViewController *)contro withUrlStr:(NSString *)urlStr withTitle:(NSString *)title withType:(NSString *)type;

+ (void)presentWithContro:(UIViewController *)contro withUrlStr:(NSString *)urlStr withTitle:(NSString *)title;

+ (void)showWithContro:(UIViewController *)contro withUrlStr:(NSString *)urlStr withTitle:(NSString *)title withModule:(NSString *)module withInfo:(NSDictionary *)info;

- (void)loadUI;

@end

NS_ASSUME_NONNULL_END
