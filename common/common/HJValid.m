//
//  HJValid.m
//  DynamicRehabilitation
//
//  Created by ctsi_houhuijie on 16/4/27.
//  Copyright © 2016年 Dev..l. All rights reserved.
//

#import "HJValid.h"
#import <CommonCrypto/CommonDigest.h>

@implementation HJValid

//+ (BOOL)validateMobile:(NSString *)mobileNum{
//    /**
//     * 手机号码
//     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,183,184,187,188
//     * 联通：130,131,132,152,155,156,185,186
//     * 电信：133,1349,153,180,189
//     */
//
//    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[0245-9])\\d{8}$";
//    /**
//     10         * 中国移动：China Mobile
//     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,183,187,188
//     12         */
//    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[23478])\\d)\\d{7}$";
//    /**
//     15         * 中国联通：China Unicom
//     16         * 130,131,132,152,155,156,185,186
//     17         */
//    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
//    /**
//     20         * 中国电信：China Telecom
//     21         * 133,1349,153,180-189，170-179
//     22         */
//    NSString * CT = @"^1((33|53|7[0-9]|8[0-9])[0-9]|349)\\d{7}$";
//    /**
//     25         * 大陆地区固话及小灵通
//     26         * 区号：010,020,021,022,023,024,025,027,028,029
//     27         * 号码：七位或八位
//     28         */
//    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
//
//    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
//    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
//    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
//    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
//
//    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
//        || ([regextestcm evaluateWithObject:mobileNum] == YES)
//        || ([regextestct evaluateWithObject:mobileNum] == YES)
//        || ([regextestcu evaluateWithObject:mobileNum] == YES)){
//        return YES;
//    }else{
//        return NO;
//    }
//}

+ (BOOL)validateMobile:(NSString *)mobileNum{
    if (mobileNum.length == 11 && [self isPureInt:mobileNum]) {
        return YES;
    } else {
        return NO;
    }
}

//判断是否为整形
+ (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

//判断是否为浮点形
+ (BOOL)isPureFloat:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}

+ (BOOL)isNumber:(NSString*)string{
    if( ![self isPureInt:string] || ![self isPureFloat:string]){
        return NO;
    }else{
        return YES;
    }
}


+ (BOOL)validPassWorld:(NSString *)passworld{
    BOOL result = false;
    if ([passworld length] >= 6 && [passworld length] <= 16){
        // 判断长度大于8位后再接着判断是否同时包含数字和字符
        //        ^[a-zA-Z]\w{5,17}$  ^\d{m,n}$  ^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{8,16}$
        //        NSString * regex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,14}$";
        //        NSString *regex = @"/^(?!^[0-9]+$)(?!^[A-z]+$)(?!^[^A-z0-9]+$)^.{6,14}$/";
        //        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        //        result = [pred evaluateWithObject:passworld];
        result = true;
    }
    return result;
}

+ (NSString *)calculateFileMd5WithFilePath:(NSString *)filePath {
    //生成文件的MD5   校验的是压缩包的MD5  判断下载是否正确
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if( handle == nil ) {
        NSLog(@"文件出错");
    }
    
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    BOOL done = NO;
    while(!done)
    {
        NSData* fileData = [handle readDataOfLength: 256 ];
        CC_MD5_Update(&md5, [fileData bytes], (CC_LONG)[fileData length]);
        if( [fileData length] == 0 ) done = YES;
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString *fileMD5 = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                         digest[0], digest[1],
                         digest[2], digest[3],
                         digest[4], digest[5],
                         digest[6], digest[7],
                         digest[8], digest[9],
                         digest[10], digest[11],
                         digest[12], digest[13],
                         digest[14], digest[15]];
    NSLog(@"生成的文件MD5为:%@",fileMD5);
    return fileMD5;
}


@end
