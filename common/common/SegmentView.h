//
//  SegmentView.h
//  yunECloudCustomer
//
//  Created by 于艳平 on 16/10/17.
//  Copyright © 2016年 yunECloud. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TouchLabelIndexBlock)(void);

@protocol TouchLabelDelegate <NSObject>

- (void)touchLabelWithIndex:(NSInteger)index;

@end

@interface SegmentView : UIView
/**
 *  标题数组
 */
@property ( nonatomic, strong) NSArray *titleArray;

/**
 *  标题颜色
 */
@property ( nonatomic, strong) UIColor *titleColor;

/**
 *  标题被选中的颜色
 */
@property ( nonatomic, strong) UIColor *titleSelectedColor;

/**
 *  滚动条
 */
@property ( nonatomic, strong) UIView *scrollLine;

/**
 *  滚动条颜色
 */
@property ( nonatomic, strong) UIColor *scrollLineColor;

/**
 *  分割线颜色
 */
@property ( nonatomic, strong) UIColor *separateColor;

/**
 *  分割线
 */
@property ( nonatomic, strong) UIView *separateLine;

/**
 *  滚动条高度
 */
@property ( nonatomic, assign) float scrollLineHeight;
/**
 *  滚动条宽度
 */
@property ( nonatomic, assign) float scrollLineWidth;
/**
 *  分割线高度
 */
@property ( nonatomic, assign) float separateHeight;

/**
 *  标题字体大小
 */
@property ( nonatomic, assign) CGFloat titleFont;

@property (nonatomic, assign) NSInteger selectedIndex;
/// 不可点击
@property (nonatomic, assign) BOOL disable;

// 滚动条的图片名称，nil--无图片
@property (nonatomic, strong) NSString *imageName;

@property ( nonatomic, weak) id<TouchLabelDelegate>touchDelegate;

//根据titleArray配置label
- (void)configSubLabel;

//选中指定位置label
- (void)selectLabelWithIndex:(NSInteger)index;
- (instancetype)initWithFrame:(CGRect)frame disable:(BOOL)disable;

@end

