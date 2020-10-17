//
//  NSString+Tool.m
//  IOSStandardDemo
//
//  Created by 于艳平 on 2018/5/14.
//  Copyright © 2018年 于艳平. All rights reserved.
//

#import "NSString+Tool.h"

@implementation NSString (Tool)
/**
 判断字符串string是否为空
 
 @param string 需要判空的字符串
 @return YES-空 NO-非空
 */
+ (BOOL)isStringNull:(NSString *)string {
    if (![string.class isEqual:[NSString class]]) {
        string = [NSString stringWithFormat:@"%@", string];
    }
    if (string && ![string isEqual:[NSNull null]] && ![string isEqualToString:@"(null)"] && ![string isEqualToString:@"<null>"] && ![string isEqualToString:@"<null>"] && ![string isEqualToString:@"null"] && string.length != 0) {
        return NO;  // 不为空
    } else {
        return YES; // 为空
    }
}

/**
 当字符串string为空时，返回nullStr
 
 @param string 需要判空的字符串
 @param nullStr 字符串string为空时，返回的值
 @return string为空返回nullStr， string不为空返回string
 */
+ (NSString *)string:(NSString *)string withNullStr:(NSString *)nullStr {
    if ([self isStringNull:string]) {
        return nullStr;
    }
    return string;
}

/**
 宽度固定，获取字符串所占高度
 
 @param value 字符串
 @param width 宽度
 @param font 字号
 @return 文字所占高度
 */
+ (float)heightForString:(NSString *)value width:(CGFloat)width font:(CGFloat)font {
    CGSize size = CGSizeMake(width, MAXFLOAT);
    CGRect rect = [value boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:font]} context:nil];
    
    return rect.size.height;
}

/**
 宽度固定，获取字符串所占高度
 
 @param value 字符串
 @param width 宽度
 @param fontObj 字体
 @return 文字所占高度
 */
+ (float)heightForString:(NSString *)value width:(CGFloat)width fontObj:(UIFont *)fontObj {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObject:fontObj forKey:NSFontAttributeName];
    CGSize size = [value boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    return size.height;
}

/**
 高度固定，获取字符串所占宽度
 
 @param value 字符串
 @param height 高度
 @param font 字号
 @return 文字所占宽度
 */
+ (float)widthForString:(NSString *)value height:(CGFloat)height fontSize:(CGFloat)font {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObject:[UIFont systemFontOfSize:font] forKey:NSFontAttributeName];
    CGSize size = [value boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    return size.width;
}

/**
 高度固定，获取字符串所占宽度
 
 @param value 字符串
 @param height 高度
 @param fontObj 字体
 @return 文字所占宽度
 */
+ (float)widthForString:(NSString *)value height:(CGFloat)height fontObj:(UIFont *)fontObj {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObject:fontObj forKey:NSFontAttributeName];
    CGSize size = [value boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    return size.width;
}

// 是否是整形
+ (BOOL)isPureInt:(NSString *)string {
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}
// 是否是浮点型
+ (BOOL)isPureFloat:(NSString *)string {
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return [scan scanFloat:&val] && [scan isAtEnd];
}

+ (NSString *)getChinesePinYin:(NSString *)chinese {
    // 转换成可变字符串
    // 传进来“于艳平”
    NSMutableString *str = [NSMutableString stringWithString:chinese];
    // 转换成带声调的拼音
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformMandarinLatin, NO);
    // 再转换成不带声调的拼音
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformStripDiacritics, NO);
    // 转换成拼音 yu yan ping
    NSMutableString *pinYin = [NSMutableString stringWithString:[str lowercaseString]];
    // 去掉空格
    NSString *result = [pinYin stringByReplacingOccurrencesOfString:@" " withString:@""];
    // 返回yuyanping
    return result;
}

+ (NSString *)getChineseFirstPinYin:(NSString *)chinese{
    // 转换成可变字符串
    // 传进来“于艳平”
    NSMutableString *str = [NSMutableString stringWithString:chinese];
    // 转换成带声调的拼音
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformMandarinLatin, NO);
    // 再转换成不带声调的拼音
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformStripDiacritics, NO);
    // 转换成大写拼音 yu yan ping
    NSMutableString *pinYin = [NSMutableString stringWithString:[str uppercaseString]];
    // 以空格为分隔符拆成数组
    NSArray *array = [pinYin componentsSeparatedByString:@" "];
    pinYin = [@"" mutableCopy];
    for (NSString *string in array) {
        // 取数组的每个元素的首字母
        [pinYin appendString:[string substringToIndex:1]];
    }
    // 返回YYP
    return pinYin;
}

+ (BOOL)isNullObject:(id)object
{
    if (object == nil || [object isEqual:[NSNull class]]) {
        return YES;
    }else if ([object isKindOfClass:[NSNull class]]){
        if ([object isEqualToString:@""]) {
            return YES;
        }else{
            return NO;
        }
    }else if ([object isKindOfClass:[NSNumber class]]){
        if ([object isEqualToNumber:@0]) {
            return YES;
        }else{
            return NO;
        }
    }
    return NO;
}

//判断是否含有表情符号 yes-有 no-没有
+ (BOOL)stringContainsEmoji:(NSString *)string {
    __block BOOL returnValue =NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        const unichar hs = [substring characterAtIndex:0];
        if (0xd800) {
            if (0xd800 <= hs && hs <= 0xdbff) {
                if (substring.length > 1) {
                    const unichar ls = [substring characterAtIndex:1];
                    const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                    if (0x1d000 <= uc && uc <= 0x1f77f) {
                        returnValue =YES;
                    }
                }
            }else if (0x2100 <= hs && hs <= 0x27ff){
                returnValue =YES;
            }else if (0x2B05 <= hs && hs <= 0x2b07) {
                returnValue =YES;
            }else if (0x2934 <= hs && hs <= 0x2935) {
                returnValue =YES;
            }else if (0x3297 <= hs && hs <= 0x3299) {
                returnValue =YES;
            }else{
                if (substring.length > 1) {
                    const unichar ls = [substring characterAtIndex:1];
                    if (ls == 0x20e3) {
                        returnValue =YES;
                    }
                }
            }
            if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50 || hs == 0xd83e) {
                returnValue =YES;
            }
            
        }
    }];
    return returnValue;
}
//是否是系统自带九宫格输入 yes-是 no-不是
+ (BOOL)isNineKeyBoard:(NSString *)string {
    NSString *other = @"➋➌➍➎➏➐➑➒";
    int len = (int)string.length;
    for(int i=0;i<len;i++){
        if(!([other rangeOfString:string].location != NSNotFound))
            return NO;
    }
    return YES;
}
//判断第三方键盘中的表情
+ (BOOL)hasEmoji:(NSString*)string {
    NSString *pattern = @"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:string];
    return isMatch;
}
//去除表情
+ (NSString *)disableEmoji:(NSString *)text {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text options:0 range:NSMakeRange(0, [text length]) withTemplate:@""];
    return modifiedString;
}

@end
