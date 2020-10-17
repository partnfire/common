//
//  NSDate+SGTimeHandle.h
//  sigmaParents
//
//  Created by 于艳平 on 16/8/9.
//  Copyright © 2016年 sigma5t. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (SGTimeHandle)

#pragma mark - 获取北京时间字符串
+ (NSString *)getBeijingDateString;

#pragma mark - 获取北京时间字符串
+ (NSString *)getBeijingDateWithFormate:(NSString *)formate;

#pragma mark - 获取北京时间
+ (NSDate *)getBeijingDate;

/**
 *  根据给定的字符串返回合适的字符串
 *  如果日期是北京时间的今天，则返回“HH:mm”
 *  如果日期是北京时间的昨天，则返回“昨天 HH:mm”
 *  如果日期比北京时间的昨天还早，则将该字符串返回
 */
+ (NSString *)getSGTimeWithString:(NSString *)string;

/**
 *  根据给定的日期返回合适的字符串
 *  如果日期是北京时间的今天，则返回“HH:mm”
 *  如果日期是北京时间的昨天，则返回“昨天 HH:mm”
 *  如果日期比北京时间的昨天还早，则将该字符串返回
 */
+ (NSString *)getSGTimeWithDate:(NSDate *)date;

#pragma mark - 将字符串按指定的格式转换成日期
+ (NSDate *)getSGDateByString:(NSString *)string format:(NSString *)format;

#pragma mark - 将日期按指定的格式转换成字符串
+ (NSString *)getStringByDate:(NSDate *)date format:(NSString *)format;

#pragma mark - 年月日
+ (NSArray *)getArrayFromString:(NSString *)date;

#pragma mark - 第几月第几周
/**
 {
 "year": 2016,
 "weekStartDay": "2016-06-13",
 "month": 6,
 "weekIndex": 2
 },
 */
+ (NSDictionary *)getDictFromString:(NSString *)date;

#pragma - 获取给定日期的周一
+ (NSString *)getWeekTime:(NSString *)date;

#pragma mark - 获取给定日期是当月第几周
+ (NSInteger)getIndexFromDate:(NSString *)string;

#pragma mark - 时间戳转换成时间
+ (NSDate *)timestampToDate:(NSString *)timestamp;

#pragma mark - 时间戳转换成时间字符串
+ (NSString *)timestampToFormatString:(NSString *)timestamp andFormat:(NSString *)format;

#pragma mark - 两个日期的时间差
+ (NSInteger)gapBetweenOneDate:(NSDate *)date1 anotherDate:(NSDate *)date2;

#pragma mark - 时间转换成时间戳
+ (NSString *)dateTotimestamp:(NSDate *)date;

#pragma mark - 计算年龄
+ (NSInteger)getAge:(NSString *)date;

#pragma mark - 给定日期+n天
+ (NSDate *)dateAddUpNDays:(int)days withDate:(NSDate *)date;

#pragma mark - 获取本周全部日期(NSString)
+ (NSArray *)weekDayWithDate:(NSDate *)date;

#pragma mark - 获取本周全部日期(NSDate)
+ (NSArray *)weekDayDateWithDate:(NSDate *)date;
@end
