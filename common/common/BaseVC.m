//
//  BaseVC.m
//  facialMask
//  为了可以滑动返回，所有二级及下级页面都需集成BaseVC
//  Created by partnfire_hhj on 2018/8/11.
//  Copyright © 2018年 partnfire. All rights reserved.
//

#import "BaseVC.h"

@interface BaseVC ()<UIGestureRecognizerDelegate>

@end

@implementation BaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
//    [AppDelegate shareAppDelegate].allowRotation = YES;
//    [self orientationToPortrait:UIInterfaceOrientationPortrait];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:0];
        if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
            self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
        }
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    dispatch_async(dispatch_get_main_queue(), ^{
        //        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        //            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        //        }
    });
}

- (void)orientationToPortrait:(UIInterfaceOrientation)orientation {
    SEL selector = NSSelectorFromString(@"setOrientation:");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:[UIDevice currentDevice]];
    int val = orientation;
    [invocation setArgument:&val atIndex:2];
    [invocation invoke];
}


#pragma 滑动返回需要
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if(self.navigationController.childViewControllers.count == 1) {
        return NO;
    }
    if (self.navigationController.viewControllers.count < 2 || self.navigationController.visibleViewController == [self.navigationController.viewControllers objectAtIndex:0] )  {
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        if (gestureRecognizer.state != UIGestureRecognizerStatePossible) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
