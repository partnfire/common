//
//  HJWebVC.h
//  DynamicRehabilitation
//
//  Created by 侯慧杰 on 17/1/10.
//  Copyright © 2017年 Dev..l. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HJWebVC : UIViewController

@property (strong, nonatomic) NSURL *homeUrl;

/** 传入控制器、url、标题 */
+ (void)showWithContro:(UIViewController *)contro withUrlStr:(NSString *)urlStr withTitle:(NSString *)title;

- (void)loadUI;

@end
