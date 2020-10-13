//
//  UIImage+ChangeSize.m
//  yunECloudCustomer
//
//  Created by 于艳平 on 16/10/10.
//  Copyright © 2016年 yunECloud. All rights reserved.
//

#import "UIImage+ChangeSize.h"

@implementation UIImage (ChangeSize)

+(UIImage*)OriginImage:(UIImage *)image scaleToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);  //size 为CGSize类型，即你所需要的图片尺寸
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;   //返回的就是已经改变的图片
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    if (!color || size.width <= 0 || size.height <= 0) return nil;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//设置图片透明度

+ (UIImage *)imageByApplyingAlpha:(CGFloat)alpha image:(UIImage*)image {
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextSetAlpha(ctx, alpha);
    
    CGContextDrawImage(ctx, area, image.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}
+ (UIImage *)getImageViewWithView:(UIView *)view {
//    UIGraphicsBeginImageContext(view.frame.size);
//    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
//    UIImage *image =  UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)getImageViewWithScrollView:(UIScrollView *)scroll {
    UIImage *image;
    // 开启图形上下文
    UIGraphicsBeginImageContextWithOptions(scroll.contentSize, YES, [UIScreen mainScreen].scale);
    CGPoint savedContentOffset = scroll.contentOffset;
    CGRect savedFrame = scroll.frame;
    scroll.contentOffset = CGPointZero;
    scroll.frame = CGRectMake(0, 0, scroll.contentSize.width, scroll.contentSize.height);
    [scroll.layer renderInContext: UIGraphicsGetCurrentContext()];
    //因为 renderInContext 渲染时会导致内存急剧上升,可能会造成crash, 所以要清除 layer 绘制过后产生的缓存
    scroll.layer.contents = nil; //释放缓存
    image = UIGraphicsGetImageFromCurrentImageContext(); //从图形上下文获取图片
    UIGraphicsEndImageContext();
    scroll.contentOffset= savedContentOffset;
    scroll.frame= savedFrame;
    return image;
}


@end
