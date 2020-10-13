//
//  getPinYinFromChinese.m
//  Test1
//
//  Created by yyp on 16/4/25.
//  Copyright © 2016年 于艳平. All rights reserved.
//

#import "GetPinYinFromChinese.h"

@implementation GetPinYinFromChinese
+ (NSString *)getChinesePinYin:(NSString *)chinese {
    // 转换成可变字符串
    // 传进来“于艳平”
    NSMutableString *str = [NSMutableString stringWithString:chinese];
    // 转换成带声调的拼音
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformMandarinLatin, NO);
    // 再转换成不带声调的拼音
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformStripDiacritics, NO);
    // 转换成拼音 YU YAN PING
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
    // 转换成大写拼音 YU YAN PING
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
@end
