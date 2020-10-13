//
//  CarouselView.h
//  yunECloudCustomer
//
//  Created by 于艳平 on 16/10/10.
//  Copyright © 2016年 yunECloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SMPageControl/SMPageControl.h>

@interface CarouselView : UIView
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) SMPageControl *pageControl;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSMutableArray *imageArr;
@property (nonatomic, copy) void (^imageTapBlock)(int);
- (instancetype)initWithFrame:(CGRect)frame
                  andImageArr:(NSMutableArray *)imageArr
                         type:(NSString *)type;
@end
