//
//  UIImage+ChangeSize.h
//  yunECloudCustomer
//
//  Created by 于艳平 on 16/10/10.
//  Copyright © 2016年 yunECloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ChangeSize)
+(UIImage*)OriginImage:(UIImage *)image scaleToSize:(CGSize)size;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)imageByApplyingAlpha:(CGFloat)alpha image:(UIImage*)image;
+ (UIImage *)getImageViewWithView:(UIView *)view;
+ (UIImage *)getImageViewWithScrollView:(UIScrollView *)scroll;
@end
