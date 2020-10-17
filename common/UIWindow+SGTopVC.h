//
//  UIWindow+SGTopVC.h
//  sigmaParents
//
//  Created by 侯慧杰 on 16/8/16.
//  Copyright © 2016年 sigma5t. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (SGTopVC)

- (UIViewController *) visibleViewController;

+ (UIViewController *) getVisibleViewControllerFrom:(UIViewController *) vc;

@end
