//
//  getPinYinFromChinese.h
//  Test1
//
//  Created by yyp on 16/4/25.
//  Copyright © 2016年 于艳平. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetPinYinFromChinese : NSObject
/**
 *  获取汉字字符串中各个汉字的首字母
 *
 *  @param chinese 汉字字符串
 *
 *  @return 大写首字母拼接成的字符串
 */
+ (NSString *)getChinesePinYin:(NSString *)chinese;

+ (NSString *)getChineseFirstPinYin:(NSString *)chinese;

@end
