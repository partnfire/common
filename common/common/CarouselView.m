//
//  CarouselView.m
//  yunECloudCustomer
//
//  Created by 于艳平 on 16/10/10.
//  Copyright © 2016年 yunECloud. All rights reserved.
//

#import "CarouselView.h"


#define kCount self.imageArr.count
#define kWidth self.frame.size.width
#define kHeight self.frame.size.height

@implementation CarouselView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame
                  andImageArr:(NSMutableArray *)imageArr
                         type:(NSString *)type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageArr = imageArr;
        self.type = type;
        // 添加子视图
        [self addAllViews];
    }
    return self;
}

// 添加子视图
- (void)addAllViews {
    // 创建scrollView对象
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    // 设置属性
    self.scrollView.contentSize = CGSizeMake(kWidth * (kCount + 2), 0);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    // 添加到父视图上
    [self addSubview:self.scrollView];
    // 将最后一张图片加到第一的位置
    [self addImageView:(int)(kCount - 1)];
    self.imageView.frame = CGRectMake(0, 0, kWidth, kHeight);
    // for循环添加imageView
    for (int i = 0; i < kCount; i++) {
        [self addImageView:i];
        self.imageView.frame = CGRectMake(kWidth * (i + 1), 0, kWidth, kHeight);
    }
    // 将第一张放到最后的位置
    [self addImageView:0];
    self.imageView.frame = CGRectMake(kWidth * (kCount + 1), 0, kWidth, kHeight);
    // 设置初始偏移量
    self.scrollView.contentOffset = CGPointMake(kWidth, 0);
    
    UIImageView *pageBackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kHeight - 20, kWidth - 20, 10)];
    pageBackImageView.image = [UIImage imageNamed:@"pageControlBg"];
    [self addSubview:pageBackImageView];
    // 创建pageControl对象
    self.pageControl = [[SMPageControl alloc] initWithFrame:pageBackImageView.bounds];
    self.pageControl.pageIndicatorImage = [UIImage imageNamed:@"normalImage"];
    self.pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"selectedImage"];
    self.pageControl.alignment = SMPageControlAlignmentRight;
    // 设置小圆点个数
    self.pageControl.numberOfPages = kCount;
    [pageBackImageView addSubview:self.pageControl];
}

// 创建imageView并添加到scrollView上
- (void)addImageView:(int)index {
    self.imageView = [[UIImageView alloc] init];
    if ([self.type isEqualToString:@"setting"]) {
        self.imageView.image = [UIImage imageNamed:self.imageArr[index]];
    } else {
        NSString *picture = [NSString string:[NSString stringWithFormat:@"%@", self.imageArr[index][@"picture"]] withNullStr:@""];
        NSString *url = [NSString stringWithFormat:@"%@%@", OssUrl,picture];
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"df_banner"]];
    }
    self.imageView.tag = 1000 + index;
    self.imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTap:)];
    [self.imageView addGestureRecognizer:tap];
    [self.scrollView addSubview:self.imageView];
}

- (void)imageViewTap:(UITapGestureRecognizer *)tap {
    UIImageView *imageView = (UIImageView *)tap.view;
    if (self.imageTapBlock) {
        self.imageTapBlock((int)imageView.tag - 1000);
    }
    
}

@end
