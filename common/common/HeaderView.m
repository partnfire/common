//
//  HeaderView.m
//  yunECloudCustomer
//
//  Created by 于艳平 on 16/10/10.
//  Copyright © 2016年 yunECloud. All rights reserved.
//

#import "HeaderView.h"
#import "CarouselView.h"

@implementation HeaderView


- (instancetype)initWithFrame:(CGRect)frame
                     imageArr:(NSArray *)imageArr
                         type:(NSString *)type
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addAllViews:imageArr type:type];
    }
    return self;
}

- (void)addAllViews:(NSArray *)imageArrs type:(NSString *)type {

    // 创建SPView对象
    self.carouselView = [[CarouselView alloc] initWithFrame:self.bounds andImageArr:[imageArrs mutableCopy] type:type];
    [self addSubview:self.carouselView];
}

@end
