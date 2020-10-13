//
//  SegmentView.m
//  yunECloudCustomer
//
//  Created by 于艳平 on 16/10/17.
//  Copyright © 2016年 yunECloud. All rights reserved.
//

#import "SegmentView.h"

#define ItemWidth self.frame.size.width/_titleArray.count
#define ItemHeight self.frame.size.height
#define NavBarColor [UIColor colorWithRed:234/255.0f green:114/255.0f blue:60/255.0f alpha:1]

@implementation SegmentView

#pragma mark getter方法 懒加载
- (UIColor *)titleColor{
    if (!_titleColor) {
        _titleColor = STRGB16Color(0x888888);
    }
    return _titleColor;
}

- (CGFloat)titleFont{
    if (!_titleFont) {
        _titleFont = 16.0;
    }
    return _titleFont;
}

- (UIColor *)titleSelectedColor{
    if (!_titleSelectedColor) {
        _titleSelectedColor = MainStyleColor;
    }
    return _titleSelectedColor;
}

- (UIColor *)separateColor{
    if (!_separateColor) {
        _separateColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
    }
    return _separateColor;
}

- (UIColor *)scrollLineColor{
    if (!_scrollLineColor) {
        _scrollLineColor = MainStyleColor;
    }
    return _scrollLineColor;
}

- (float)scrollLineHeight{
    if (!_scrollLineHeight) {
        _scrollLineHeight = 3.0;
    }
    return _scrollLineHeight;
}

- (float)separateHeight{
    if (!_separateHeight) {
        _separateHeight = 0.5;
    }
    return _separateHeight;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addPropertyObserver];
        [self configSubLabel];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame disable:(BOOL)disable {
    self = [super initWithFrame:frame];
    if (self) {
        self.disable = disable;
        [self addPropertyObserver];
        [self configSubLabel];
    }
    return self;

}

- (void)addPropertyObserver{
    [self addObserver:self forKeyPath:@"titleColor" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [self addObserver:self forKeyPath:@"titleSelectedColor" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [self addObserver:self forKeyPath:@"titleFont" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [self addObserver:self forKeyPath:@"scrollLineColor" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [self addObserver:self forKeyPath:@"separateColor" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [self addObserver:self forKeyPath:@"scrollLineHeight" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
     [self addObserver:self forKeyPath:@"scrollLineWidth" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [self addObserver:self forKeyPath:@"separateHeight" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [self addObserver:self forKeyPath:@"titleArray" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [self addObserver:self forKeyPath:@"haveRightLine" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [self addObserver:self forKeyPath:@"imageName" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)dealloc{
    [self removeObserver:self forKeyPath:@"titleColor"];
    [self removeObserver:self forKeyPath:@"titleSelectedColor"];
    [self removeObserver:self forKeyPath:@"titleFont"];
    [self removeObserver:self forKeyPath:@"separateColor"];
    [self removeObserver:self forKeyPath:@"scrollLineColor"];
    [self removeObserver:self forKeyPath:@"scrollLineHeight"];
    [self removeObserver:self forKeyPath:@"scrollLineWidth"];
    [self removeObserver:self forKeyPath:@"separateHeight"];
    [self removeObserver:self forKeyPath:@"titleArray"];
    [self removeObserver:self forKeyPath:@"haveRightLine"];
    [self removeObserver:self forKeyPath:@"imageName"];
}

//根据titleArray配置label
- (void)configSubLabel{
    //移除所有子视图
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (self.titleArray.count != 0 && !self.scrollLineWidth) {
        self.scrollLineWidth = ItemWidth;
    }
    for (int i = 0;  i < self.titleArray.count; i++) {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(i * ItemWidth, 0, ItemWidth, ItemHeight)];
        titleLabel.text = [self.titleArray objectAtIndex:i];
        titleLabel.textColor =  self.titleColor;
        titleLabel.font = [UIFont systemFontOfSize:self.titleFont];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.tag = 100+i;
        if (!self.disable) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchLabelWithGesture:)];
            tap.numberOfTapsRequired = 1;
            titleLabel.userInteractionEnabled = YES;
            [titleLabel addGestureRecognizer:tap];
        }
       
        
        [self addSubview:titleLabel];
    }
    
    [self selectLabelWithIndex:self.selectedIndex];
    
    //分割线
    _separateLine = [[UIView alloc]initWithFrame:CGRectMake(0, ItemHeight - _separateHeight, self.frame.size.width, self.separateHeight)];
    [_separateLine setBackgroundColor:self.separateColor];
    
    //滚动条
    if (self.selectedIndex != 0) {
        _scrollLine = [[UIView alloc]initWithFrame:CGRectMake((ItemWidth) * self.selectedIndex + ((ItemWidth) - self.scrollLineWidth) * 0.5, ItemHeight - self.scrollLineHeight, self.scrollLineWidth, self.scrollLineHeight)];
    } else {
        _scrollLine = [[UIView alloc]initWithFrame:CGRectMake(0, ItemHeight - self.scrollLineHeight, self.scrollLineWidth, self.scrollLineHeight)];
    }
    
   
    [_scrollLine setBackgroundColor:self.scrollLineColor];
    
    [self addSubview:_separateLine];
    [self addSubview:_scrollLine];
}

//点击第几个label触发回调
- (void)touchLabelWithGesture:(UITapGestureRecognizer *)tap{
  
    UILabel *label = (UILabel *)tap.view;
    NSInteger index = label.tag - 100;
    
    [self selectLabelWithIndex:index];
    
}

//选中指定位置label
- (void)selectLabelWithIndex:(NSInteger)index{

    UILabel *selectedLabel = [self viewWithTag:index+100];
    for (int i = 0; i < self.titleArray.count; i++) {
        UILabel *label = [self viewWithTag:100+i];
        if ([label isEqual:selectedLabel]) {
            label.textColor = self.titleSelectedColor;
        }else{
            label.textColor = self.titleColor;
        }
    }
   
    CGRect scrollLineFrame = _scrollLine.frame;
    scrollLineFrame.origin.x =  (ItemWidth) * index + ((ItemWidth) - (self.scrollLineWidth)) * 0.5;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        [weakSelf.scrollLine setFrame:scrollLineFrame];
    }];
    if ([self.touchDelegate respondsToSelector:@selector(touchLabelWithIndex:)]) {
        [self.touchDelegate touchLabelWithIndex:index];
    }
    
}

- (void)changeTitleColorWithColor:(UIColor *)color{
    for (int i = 0; i < _titleArray.count; i ++) {
        UILabel *label = [self viewWithTag:100+i];
        label.textColor = color;
    }
}

- (void)changeTitleLabelFontWithFont:(CGFloat)font{
    for (int i = 0; i < _titleArray.count; i ++) {
        UILabel *label = [self viewWithTag:100+i];
        label.font = [UIFont systemFontOfSize:font];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"titleColor"]) {
        
        [self changeTitleColorWithColor:_titleColor];
        
    }else if ([keyPath isEqualToString:@"titleSelectedColor"]){
        
        NSInteger index = _scrollLine.frame.origin.x/ItemWidth;
        UILabel *label = [self viewWithTag:index + 100];
        label.textColor = _titleSelectedColor;
        
    }else if ([keyPath isEqualToString:@"titleFont"]){
        
        [self changeTitleLabelFontWithFont:_titleFont];
        
    }else if ([keyPath isEqualToString:@"scrollLineColor"]){
        
        [_scrollLine setBackgroundColor:_scrollLineColor];
        
    }else if ([keyPath isEqualToString:@"separateColor"]){
        
        [_separateLine setBackgroundColor:_separateColor];
        
    }else if ([keyPath isEqualToString:@"scrollLineHeight"]){
        
        CGRect scrollLineFrame = _scrollLine.frame;
        scrollLineFrame.origin.y = ItemHeight - _scrollLineHeight;
        scrollLineFrame.size.height = _scrollLineHeight;
        [_scrollLine setFrame:scrollLineFrame];
        
    }else if ([keyPath isEqualToString:@"scrollLineWidth"]){
        
        CGRect scrollLineFrame = _scrollLine.frame;
        scrollLineFrame.origin.x = (ItemWidth) * self.selectedIndex + ((ItemWidth) - self.scrollLineWidth) * 0.5;
        scrollLineFrame.size.width = _scrollLineWidth;
        [_scrollLine setFrame:scrollLineFrame];
        
    } else if ([keyPath isEqualToString:@"separateHeight"]){
        
        CGRect separateLineFrame = _separateLine.frame;
        separateLineFrame.size.height = _separateHeight;
        separateLineFrame.origin.y = ItemHeight - _separateHeight;
        [_separateLine setFrame:separateLineFrame];
        
    }else if ([keyPath isEqualToString:@"titleArray"]){
        
        [self configSubLabel];
        
    }else if ([keyPath isEqualToString:@"haveRightLine"]){
        
        [self configSubLabel];
        
    }else if ([keyPath isEqualToString:@"imageName"]){
    
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:_scrollLine.bounds];
        imageView.image = [UIImage imageNamed:_imageName];
        [_scrollLine addSubview:imageView];
        _scrollLine.backgroundColor = [UIColor whiteColor];
        
    }
}


@end
