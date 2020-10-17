//
//  NSDate+SGTimeHandle.m
//  sigmaParents
//
//  Created by 于艳平 on 16/8/9.
//  Copyright © 2016年 sigma5t. All rights reserved.
//

#import "NSDate+SGTimeHandle.h"
#import "NSString+Tool.h"

@implementation NSDate (SGTimeHandle)

#pragma mark - 获取北京时间字符串
+ (NSString *)getBeijingDateString {
    NSDate *beiJingDate = [self getBeijingDate];
    return [self getStringByDate:beiJingDate format:@"YYYY-MM-dd HH:mm:ss"];
}

+ (NSString *)getBeijingDateWithFormate:(NSString *)formate {
    NSDate *beiJingDate = [self getBeijingDate];
    return [self getStringByDate:beiJingDate format:formate];
}

#pragma mark - 获取北京时间
+ (NSDate *)getBeijingDate {
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    NSInteger interval = [timeZone secondsFromGMTForDate:[NSDate date]];
    NSDate *beijingDate = [[NSDate date] dateByAddingTimeInterval:interval];
    return beijingDate;
    
}

/**
 *  根据给定的字符串返回合适的字符串
 *  如果日期是北京时间的今天，则返回“HH:mm”
 *  如果日期是北京时间的昨天，则返回“昨天 HH:mm”
 *  如果日期比北京时间的昨天还早，则将该字符串返回
 */
+ (NSString *)getSGTimeWithString:(NSString *)string {
    // 昨天
    NSDate *lastDay = [NSDate dateWithTimeInterval:-24 * 60 * 60 sinceDate:[self getBeijingDate]];
    NSString *lastString = [self getStringByDate:lastDay format:@"YYYY-MM-dd"];
    // YYYY-MM-DD HH:mm:ss
    NSArray *array;
    if (string.length > 18 && [string containsString:@" "]) {
        array = [string componentsSeparatedByString:@" "];
        
        if ([lastString compare:array[0]] == 0) {
            return [NSString stringWithFormat:@"昨天 %@",[array[1] substringToIndex:5]];
        } else if ([lastString compare:array[0]] == -1) {
            // HH:mm
            return [array[1] substringToIndex:5];
        } else {
            // YYYY-MM-DD HH:mm:ss
            return [string substringWithRange:NSMakeRange(5, 11)];
        }
        
    }
    return @"";

}

/**
 *  根据给定的日期返回合适的字符串
 *  如果日期是北京时间的今天，则返回“HH:mm”
 *  如果日期是北京时间的昨天，则返回“昨天 HH:mm”
 *  如果日期比北京时间的昨天还早，则将该字符串返回
 */
+ (NSString *)getSGTimeWithDate:(NSDate *)date {
    return [self getSGTimeWithString:[self getStringByDate:date format:@"YYYY-MM-dd HH:mm:ss"]];
}

#pragma mark - 将字符串按指定的格式转换成日期
+ (NSDate *)getSGDateByString:(NSString *)string format:(NSString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    [dateFormatter setTimeZone:zone];
    [dateFormatter setDateFormat:format];
    NSDate *date = [dateFormatter dateFromString:string];
    return date;
}

#pragma mark - 将日期按指定的格式转换成字符串
+ (NSString *)getStringByDate:(NSDate *)date format:(NSString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    [dateFormatter setTimeZone:zone];
    [dateFormatter setDateFormat:format];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}


#pragma mark - 年月日
+ (NSArray *)getArrayFromString:(NSString *)date {
    NSString *string = [self getStringByDate:[self getSGDateByString:date format:@"YYYY-MM-dd"] format:@"yyyy年 MM月dd日"];
    NSArray *array = nil;
    if ([string containsString:@" "]) {
        array = [string componentsSeparatedByString:@" "];
    }
    return array;
}


#pragma mark - 第几月第几周
/**
 {
 "year": 2016,
 "weekStartDay": "2016-06-13",
 "month": 6,
 "weekIndex": 2
 },
 */
+ (NSDictionary *)getDictFromString:(NSString *)date {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *array = [date componentsSeparatedByString:@"-"];
    if (array.count == 3) {
        [dict setObject:array[0] forKey:@"year"];
        int monthInt = [array[1] intValue];
        [dict setObject:[NSString stringWithFormat:@"%d", monthInt] forKey:@"month"];
        [dict setObject:[self getWeekTime:date] forKey:@"weekStartDay"];
        [dict setObject:[NSString stringWithFormat:@"%ld",(long)[self getIndexFromDate:date]] forKey:@"weekIndex"];
    }
    return dict;
}

#pragma - 获取给定日期的周一
+ (NSString *)getWeekTime:(NSString *)date {
    NSDate *nowDate = [self getSGDateByString:date format:@"YYYY-MM-dd"];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitDay fromDate:nowDate];
    // 获取今天是周几
    NSInteger weekDay = [comp weekday];
    // 获取几天是几号
    NSInteger day = [comp day];
    
    // 计算当前日期和本周的星期一和星期天相差天数
    long firstDiff;
    //    weekDay = 1;
    if (weekDay == 1)
    {
        firstDiff = -6;
    }
    else
    {
        firstDiff = [calendar firstWeekday] - weekDay + 1;
    }
    
    // 在当前日期(去掉时分秒)基础上加上差的天数
    NSDateComponents *firstDayComp = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay  fromDate:nowDate];
    [firstDayComp setDay:day + firstDiff];
    NSDate *firstDayOfWeek = [calendar dateFromComponents:firstDayComp];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *firstDay = [formatter stringFromDate:firstDayOfWeek];
    return firstDay;
    
}

#pragma mark - 获取给定日期是当月第几周
+ (NSInteger)getIndexFromDate:(NSString *)string {
    NSDate * date = [self getSGDateByString:string format:@"YYYY-MM-dd"];
    NSCalendar*calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps;
    // 周几和星期几获得
    comps =[calendar components:(NSCalendarUnitWeekday | NSCalendarUnitWeekday |NSCalendarUnitWeekdayOrdinal) fromDate:date];
    NSInteger weekdayOrdinal = [comps weekdayOrdinal]; // 这个月的第几周
    return weekdayOrdinal;

}


#pragma mark - 时间戳转换成时间
+ (NSDate *)timestampToDate:(NSString *)timestamp {
    NSString * timeStampString = timestamp;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeStampString doubleValue] / 1000];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    return localeDate;
}

#pragma mark - 时间戳转换成时间字符串
+ (NSString *)timestampToFormatString:(NSString *)timestamp andFormat:(NSString *)format {
    NSString * timeStampString = timestamp;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeStampString doubleValue] / 1000];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    NSString *formatStr = [self getStringByDate:localeDate format:format];
    return formatStr;
}

#pragma mark - 两个日期的时间差(秒)
+ (NSInteger)gapBetweenOneDate:(NSDate *)date1 anotherDate:(NSDate *)date2 {
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    unsigned int unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    NSDateComponents *d = [cal components:unitFlags fromDate:date1 toDate:date2 options:0];
    
    NSInteger sec = [d hour] * 3600 + [d minute] * 60 + [d second];
    return sec;

}

#pragma mark - 时间转换成时间戳
+ (NSString *)dateTotimestamp:(NSDate *)date {
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    NSString *timeStamp = [NSString stringWithFormat:@"%.0f", timeInterval * 1000];
    return timeStamp;
//    return [NSString stringWithFormat:@"%f", [date timeIntervalSince1970] * 1000];
}

#pragma mark - 计算年龄
+ (NSInteger)getAge:(NSString *)date {
    NSInteger age;
    if (![NSString isStringNull:date] && date.length > 18) {
        NSDate *birDate = [NSDate getSGDateByString:date format:@"YYYY-MM-dd HH:mm:ss"];
        
        NSTimeInterval dateDiff = [birDate timeIntervalSinceNow];
        
        age= fabs(trunc(dateDiff/(60*60*24))/365);
        
        return age;
    }
    return 0;
}

#pragma mark - 给定日期+n天
+ (NSDate *)dateAddUpNDays:(int)days withDate:(NSDate *)date {
    NSDate *newDate = [date dateByAddingTimeInterval:60 * 60 * 24 * days];
    return newDate;
}

#pragma mark - 获取本周全部日期
+ (NSArray *)weekDayWithDate:(NSDate *)date {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitDay fromDate:date];
    // 获取今天是周几
    NSInteger weekDay = [comp weekday];
    // 获取几天是几号
    NSInteger day = [comp day];
    
    // 计算当前日期和本周的星期一和星期天相差天数
    long firstDiff,lastDiff;
    //    weekDay = 1;
    if (weekDay == 1)
    {
        firstDiff = -6;
        lastDiff = 0;
    }
    else
    {
        firstDiff = [calendar firstWeekday] - weekDay + 1;
        lastDiff = 8 - weekDay;
    }
    //  NSLog(@"firstDiff: %ld   lastDiff: %ld",firstDiff,lastDiff);
    
    // 在当前日期(去掉时分秒)基础上加上差的天数
    NSDateComponents *firstDayComp = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay  fromDate:date];
    [firstDayComp setDay:day + firstDiff];
    NSDate *firstDayOfWeek = [calendar dateFromComponents:firstDayComp];
    
    NSDateComponents *lastDayComp = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay   fromDate:date];
    [lastDayComp setDay:day + lastDiff];
    NSDate *lastDayOfWeek = [calendar dateFromComponents:lastDayComp];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd"];
    NSString *firstDay = [formatter stringFromDate:firstDayOfWeek];
    NSString *lastDay = [formatter stringFromDate:lastDayOfWeek];
    
    int firstValue = firstDay.intValue;
    int lastValue = lastDay.intValue;
    
    NSMutableArray *dateArr = [[NSMutableArray alloc]init];
    
    if (firstValue < lastValue) {
        for (int j = 0; j<7; j++) {
            NSString *obj = [NSString stringWithFormat:@"%d",firstValue+j];
            [dateArr addObject:obj];
        }
    }
    else if (firstValue > lastValue)
    {
        for (int j = 0; j < 7-lastValue; j++) {
            NSString *obj = [NSString stringWithFormat:@"%d",firstValue+j];
            [dateArr addObject:obj];
            
        }
        for (int z = 0; z<lastValue; z++) {
            if (z == 0) { // 如果是1日，显示月份
                NSDateFormatter *format = [[NSDateFormatter alloc] init];
                [format setDateFormat:@"M月"];
                NSString *month = [format stringFromDate:lastDayOfWeek];
                [dateArr addObject:month];
            } else {
                NSString *obj = [NSString stringWithFormat:@"%d",z+1];
                [dateArr addObject:obj];
            }
            
        }
    }
    
    NSLog(@"dateArr = %@", dateArr);
    return dateArr;
}

#pragma mark - 获取本周全部日期(NSDate)
+ (NSArray *)weekDayDateWithDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitDay fromDate:date];
    // 获取今天是周几
    NSInteger weekDay = [comp weekday];
    // 获取几天是几号
    NSInteger day = [comp day];
    
    // 计算当前日期和本周的星期一和星期天相差天数
    long firstDiff,lastDiff;
    //    weekDay = 1;
    if (weekDay == 1)
    {
        firstDiff = -6;
        lastDiff = 0;
    }
    else
    {
        firstDiff = [calendar firstWeekday] - weekDay + 1;
        lastDiff = 8 - weekDay;
    }
    
    // 在当前日期(去掉时分秒)基础上加上差的天数
    NSDateComponents *firstDayComp = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay  fromDate:date];
    [firstDayComp setDay:day + firstDiff];
    NSDate *firstDayOfWeek = [calendar dateFromComponents:firstDayComp];
    
    NSDateComponents *lastDayComp = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay   fromDate:date];
    [lastDayComp setDay:day + lastDiff];
    NSDate *lastDayOfWeek = [calendar dateFromComponents:lastDayComp];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd"];
    NSString *firstDay = [formatter stringFromDate:firstDayOfWeek];
    NSString *lastDay = [formatter stringFromDate:lastDayOfWeek];
    
    int firstValue = firstDay.intValue;
    int lastValue = lastDay.intValue;
    
    NSMutableArray *dateArr = [[NSMutableArray alloc]init];
    
    if (firstValue < lastValue) {
        for (int j = 0; j<7; j++) {
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"yyyy-MM-"];
            NSString *dateStr = [format stringFromDate:firstDayOfWeek];
            
            NSString *obj = [NSString stringWithFormat:@"%d",firstValue+j];
            obj = obj.length == 1 ? [NSString stringWithFormat:@"0%@", obj] : obj;
            [dateArr addObject:[NSString stringWithFormat:@"%@%@", dateStr, obj]];
        }
    }
    else if (firstValue > lastValue)
    {
        for (int j = 0; j < 7-lastValue; j++) {
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"yyyy-MM-"];
            NSString *dateStr = [format stringFromDate:firstDayOfWeek];
            
            NSString *obj = [NSString stringWithFormat:@"%d",firstValue+j];
            obj = obj.length == 1 ? [NSString stringWithFormat:@"0%@", obj] : obj;
            [dateArr addObject:[NSString stringWithFormat:@"%@%@", dateStr, obj]];
            
        }
        for (int z = 0; z<lastValue; z++) {
            
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"yyyy-MM-"];
            NSString *dateStr = [format stringFromDate:lastDayOfWeek];
            NSString *obj = [NSString stringWithFormat:@"%d",z+1];
            obj = obj.length == 1 ? [NSString stringWithFormat:@"0%@", obj] : obj;
            [dateArr addObject:[NSString stringWithFormat:@"%@%@", dateStr, obj]];
            
            
        }
    }
    
    NSLog(@"dateArr = %@", dateArr);
    return dateArr;

}

@end
