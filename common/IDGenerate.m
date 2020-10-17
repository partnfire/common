//
//  IDGenerate.m
//  facialMask
//
//  Created by partnfire_hhj on 2018/7/31.
//  Copyright © 2018年 partnfire. All rights reserved.
//

#import "IDGenerate.h"

@implementation IDGenerate


/**
 生成36位uuid
 @return uuid
 */
+ (NSString *)nextUuid {
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [uuid lowercaseString];
}

@end
