//
//  HJCustomTextField.m
//  DynamicRehabilitation
//
//  Created by ctsi_houhuijie on 16/4/26.
//  Copyright © 2016年 Dev..l. All rights reserved.
//

#import "HJCustomTextField.h"

@implementation HJCustomTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    [super awakeFromNib];
    // 设置光标的颜色
    self.tintColor = _cursorColor;
}

-(void)drawPlaceholderInRect:(CGRect)rect{
//    _placeholderColor = STRGB16Color(0x999999);
    [_placeholderColor setFill];
    
    CGRect placeholderRect = CGRectMake(rect.origin.x + 3, (rect.size.height- self.font.pointSize - 3)/2, rect.size.width, self.font.pointSize + 3);//设置距离

    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    style.alignment = self.textAlignment;
    NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:style,NSParagraphStyleAttributeName, self.font, NSFontAttributeName, _placeholderColor, NSForegroundColorAttributeName, nil];
    
    [self.placeholder drawInRect:placeholderRect withAttributes:attr];
}

@end
