//
//  BaseNavigationController.m
//  yunECloudCustomer
//
//  Created by 于艳平 on 2016/12/28.
//  Copyright © 2016年 yunECloud. All rights reserved.
//

#import "BaseNavigationController.h"
#import "AppDelegate.h"
#import "UIImage+ChangeSize.h"
#import "NSDate+SGTimeHandle.h"
#define iOS10 ([[UIDevice currentDevice].systemVersion intValue]>=10?YES:NO)

@interface BaseNavigationController ()<UINavigationControllerDelegate>

@property (nonatomic, strong) UIViewController *viewcontroller;
@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
}

- (void)backItemAction:(UIBarButtonItem *)sender {
    [self popViewControllerAnimated:YES];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navBack"] style:UIBarButtonItemStylePlain target:self action:@selector(backItemAction:)];
    [backItem setTintColor:[UIColor blackColor]];
    viewController.navigationItem.leftBarButtonItem = backItem;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 是否支持自动转屏
- (BOOL)shouldAutorotate {
    return [self.visibleViewController shouldAutorotate];
}

// 支持哪些屏幕方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.visibleViewController supportedInterfaceOrientations];
}

// 默认的屏幕方向（当前ViewController必须是通过模态出来的UIViewController（模态带导航的无效）方式展现出来的，才会调用这个方法）
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.visibleViewController preferredInterfaceOrientationForPresentation];
}

@end
