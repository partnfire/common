//
//  HeaderView.h
//  yunECloudCustomer
//
//  Created by 于艳平 on 16/10/10.
//  Copyright © 2016年 yunECloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CarouselView;
@interface HeaderView : UIView
- (instancetype)initWithFrame:(CGRect)frame
                     imageArr:(NSArray *)imageArr
                         type:(NSString *)type;
@property (nonatomic, strong) CarouselView *carouselView;
@end
