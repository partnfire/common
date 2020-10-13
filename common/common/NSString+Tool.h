//
//  NSString+Tool.h
//  IOSStandardDemo
//
//  Created by 于艳平 on 2018/5/14.
//  Copyright © 2018年 于艳平. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Tool)

/**
 判断字符串string是否为空

 @param string 需要判空的字符串
 @return YES-空 NO-非空
 */
+ (BOOL)isStringNull:(NSString *)string;

/**
 当字符串string为空时，返回nullStr

 @param string 需要判空的字符串
 @param nullStr 字符串string为空时，返回的值
 @return string为空返回nullStr， string不为空返回string
 */
+ (NSString *)string:(NSString *)string withNullStr:(NSString *)nullStr;

/**
 宽度固定，获取字符串所占高度

 @param value 字符串
 @param width 宽度
 @param font 字号
 @return 文字所占高度
 */
+ (float)heightForString:(NSString *)value width:(CGFloat)width font:(CGFloat)font;

/**
 宽度固定，获取字符串所占高度
 
 @param value 字符串
 @param width 宽度
 @param fontObj 字体
 @return 文字所占高度
 */
+ (float)heightForString:(NSString *)value width:(CGFloat)width fontObj:(UIFont *)fontObj;

/**
 高度固定，获取字符串所占宽度
 
 @param value 字符串
 @param height 高度
 @param font 字号
 @return 文字所占宽度
 */
+ (float)widthForString:(NSString *)value height:(CGFloat)height fontSize:(CGFloat)font;

/**
 高度固定，获取字符串所占宽度
 
 @param value 字符串
 @param height 高度
 @param fontObj 字体
 @return 文字所占宽度
 */
+ (float)widthForString:(NSString *)value height:(CGFloat)height fontObj:(UIFont *)fontObj;
// 是否是整形
+ (BOOL)isPureInt:(NSString *)string;
// 是否是浮点型
+ (BOOL)isPureFloat:(NSString *)string;

/**
 *  获取汉字字符串中各个汉字的首字母
 *
 *  @param chinese 汉字字符串
 *
 *  @return 大写首字母拼接成的字符串
 */
+ (NSString *)getChinesePinYin:(NSString *)chinese;

+ (NSString *)getChineseFirstPinYin:(NSString *)chinese;


//id类型是否为空
+ (BOOL)isNullObject:(id)object;

/**
 判断是否含有表情符号 yes-有 no-没有

 @param string 字符串
 @return 判断是否含有表情符号 yes-有 no-没有
 */
+ (BOOL)stringContainsEmoji:(NSString *)string;

/**
 是否是系统自带九宫格输入 yes-是 no-不是

 @param string 字符串
 @return 是否是系统自带九宫格输入 yes-是 no-不是
 */
+ (BOOL)isNineKeyBoard:(NSString *)string;

/**
 判断第三方键盘中的表情

 @param string 字符串
 @return 判断第三方键盘中的表情
 */
+ (BOOL)hasEmoji:(NSString*)string;

/**
 去除表情

 @param text 字符串
 @return 去除表情后字符串
 */
+ (NSString *)disableEmoji:(NSString *)text;

@end
