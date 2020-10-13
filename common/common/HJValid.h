//
//  HJValid.h
//  DynamicRehabilitation
//
//  Created by ctsi_houhuijie on 16/4/27.
//  Copyright © 2016年 Dev..l. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HJValid : NSObject

//验证手机号
+ (BOOL)validateMobile:(NSString *)mobileNum;

//验证是否是纯数字
+ (BOOL)isNumber:(NSString*)string;

//验证密码规则
+ (BOOL)validPassWorld:(NSString *)passworld;

//校验文件md5以验证文件完整性
+ (NSString *)calculateFileMd5WithFilePath:(NSString *)filePath;



@end
