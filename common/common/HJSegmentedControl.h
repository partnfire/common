//
//  HJSegmentedControl.h
//  DynamicRehabilitation
//  源自第三方库 DNSCastroSegmentedControl
//  Created by 侯慧杰 on 17/1/22.
//  Copyright © 2017年 Knowledge Science and Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HJSegmentedControl;

@interface HJSegmentedControl : UIControl

///An array of the choices for the user. Should be NSString/AttributedString or UIImage.
@property (nonatomic) NSArray *choices;

///The current selected index. Zero-indexed.
@property (nonatomic) NSInteger selectedSegmentIndex;

///Will set a font to be used for all labels. If nil, the default system font will be used.
@property (nonatomic) UIFont *labelFont;

///Sets the text color of labels and the tint color of UIViews. If nil, defaults to the tintColor of this view.
@property (nonatomic) UIColor *choiceColor;

/**
  没有选中时的label的字体颜色
 */
@property (nonatomic) UIColor *notChoiceLabelColor;

///The border color of the slider. If nil, defaults to the tintColor of this view.
@property (nonatomic) UIColor *selectionViewColor;

///The background color of the selection chiclet. If nil, defaults to [UIColor clearColor].
@property (nonatomic) UIColor *selectionBackgroundColor;

///The corner radius of the view. Defaults to half the height of the view, and adjusts the corner radius of the selection view accordingly.
@property (nonatomic, assign) CGFloat cornerRadius;

/**
 *  Sets the given selected index.
 *
 *  @param selectedSegmentIndex The index you wish to switch the control to
 *  @param animated      YES if you want this transition to be animated, NO if not.
 */
- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex animated:(BOOL)animated;

@end
