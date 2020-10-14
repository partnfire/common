//
//  SGNetWorkHandler.m
//  sigmaParents
//
//  Created by 侯慧杰 on 16/8/1.
//  Copyright © 2016年 sigma5t. All rights reserved.
//

#import "HJNetWorkHandler.h"
#import <CocoaSecurity/CocoaSecurity.h>
#import "NSDate+SGTimeHandle.h"
#import "NSString+Tool.h"
#import "AFNetworking.h"

#define WEAKSELF  __weak typeof(self) weakSelf = self;

@implementation HJNetWorkHandler

+ (instancetype)shareInstance {
    static HJNetWorkHandler *netWorkHandle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        netWorkHandle = [[HJNetWorkHandler alloc] init];
    });
    return netWorkHandle;
}

#pragma mark - 开始请求，回调请求成功和失败
- (void)startRequestMethod:(RequestMethod)method
                parameters:(id)parameters
                       url:(NSString *)url
                   success:(void (^)(id responseObject))success
                   failure:(void (^)(NSError *error))failure {
    AFHTTPSessionManager *managers = [AFHTTPSessionManager manager];
    managers.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    managers.requestSerializer.timeoutInterval = 30.0f;
    managers.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/javascript", @"application/x-json", @"application/x-javascript", @"multipart/form-data",@"image/jpeg", @"image/png",@"application/octet-stream", @"text/plain",nil];
    managers.requestSerializer = [AFJSONRequestSerializer serializer];
    if([[parameters allKeys] containsObject:@"telAuth"]){
        NSMutableDictionary *param = [parameters mutableCopy];
        NSString *phone = [parameters objectForKey:@"phone"];
        if (phone.length > 8) {
            phone = [phone substringWithRange:NSMakeRange(4, 5)];
            NSString *timeStamp = [NSDate dateTotimestamp:[NSDate date]];
            if (timeStamp.length > 8) {
                NSString *subtimeStamp = [timeStamp substringWithRange:NSMakeRange(3, 6)];
                NSString *miAll = [NSString stringWithFormat:@"%@%@%@",phone,@"zhikang",subtimeStamp];
                CocoaSecurityResult *md5 = [CocoaSecurity md5:miAll];
                miAll = md5.hexLower;
                
                [managers.requestSerializer setValue:miAll forHTTPHeaderField:@"a"];
                [managers.requestSerializer setValue:timeStamp forHTTPHeaderField:@"b"];
                [param removeObjectForKey:@"telAuth"];
                [param removeObjectForKey:@"phone"];
                parameters = param;
            }
        }
    }
    __weak typeof(AFHTTPSessionManager *) weakmanagers = managers;
    WEAKSELF
    switch (method) {
        //POST 方法
        case POST:{
            [managers POST:url parameters:parameters headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (success) {
                    success(responseObject);
                }
                [weakmanagers invalidateSessionCancelingTasks:YES resetSession:YES];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    NSError *e =  nil;
                    
                    if (error.code == AFNetworkErrorType_NoNetwork) {
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"网络不给力，请检查网络后再试" forKey:NSLocalizedDescriptionKey];
                        e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_NoNetwork  userInfo:userInfo];
                    } else if (error.code == AFNetworkErrorType_TimedOut){
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"网络不给力，请检查网络后再试" forKey:NSLocalizedDescriptionKey];
                        e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_TimedOut  userInfo:userInfo];
                    } else if (error.code == AFNetworkErrorType_3840Failed){
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"提交数据失败,请稍候再试" forKey:NSLocalizedDescriptionKey];
                        e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_3840Failed  userInfo:userInfo];
                    } else if (error.code == 403){
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"提交数据失败,请稍候再试" forKey:NSLocalizedDescriptionKey];
                        e = [NSError errorWithDomain:NSCocoaErrorDomain code:403 userInfo:userInfo];
                    } else {
                        NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
                        NSInteger statusCode = response.statusCode;
                        if (statusCode == 400 || statusCode == 404 ||statusCode == 500 || statusCode == 502) {
                            NSDictionary *contentDic = [NSJSONSerialization JSONObjectWithData:[error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"] options:NSJSONReadingMutableContainers error:nil];
                            NSString *reason = [NSString stringWithFormat:@"%@",[contentDic objectForKey:@"message"]];
                            if ([reason containsString:@"### Error querying database"] || [NSString isStringNull:reason] || statusCode == 404) {
                                reason = @"提交数据失败,请稍候再试";
                            }
                            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:reason forKey:NSLocalizedDescriptionKey];
                            e = [NSError errorWithDomain:NSCocoaErrorDomain code:statusCode userInfo:userInfo];
                        } else {
                            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"提交数据失败,请稍候再试" forKey:NSLocalizedDescriptionKey];
                            e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_3840Failed  userInfo:userInfo];
                        }
                    }
                    
                    failure(e);
                    [weakSelf requestFailed:error];
                } else {
                    [weakSelf requestFailed:error];
                }
                [weakmanagers invalidateSessionCancelingTasks:YES resetSession:YES];
            }];
        }
            break;
        //GET 方法
        case GET:{
            [managers GET:url parameters:parameters headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (success) {
                    success(responseObject);
                }
                [weakmanagers invalidateSessionCancelingTasks:YES resetSession:YES];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    NSError *e =  nil;
                    
                    if (error.code == AFNetworkErrorType_NoNetwork) {
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"网络不给力，请检查网络后再试" forKey:NSLocalizedDescriptionKey];
                        e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_NoNetwork  userInfo:userInfo];
                    } else if (error.code == AFNetworkErrorType_TimedOut){
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"网络不给力，请检查网络后再试" forKey:NSLocalizedDescriptionKey];
                        e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_TimedOut  userInfo:userInfo];
                    } else if (error.code == AFNetworkErrorType_3840Failed){
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"暂无数据" forKey:NSLocalizedDescriptionKey];
                        e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_3840Failed  userInfo:userInfo];
                    } else {
                        NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
                        NSInteger statusCode = response.statusCode;
                        if (statusCode == 400 || statusCode == 500) {
                            NSDictionary *contentDic = [NSJSONSerialization JSONObjectWithData:[error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"] options:NSJSONReadingMutableContainers error:nil];
                            NSString *reason = [NSString stringWithFormat:@"%@",[contentDic objectForKey:@"message"]];
                            if ([reason containsString:@"### Error querying database"] || [NSString isStringNull:reason]) {
                                reason = @"提交数据失败,请稍候再试";
                            }
                            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:reason forKey:NSLocalizedDescriptionKey];
                            e = [NSError errorWithDomain:NSCocoaErrorDomain code:statusCode userInfo:userInfo];
                        } else {
                            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"暂无数据" forKey:NSLocalizedDescriptionKey];
                            e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_3840Failed  userInfo:userInfo];
                        }
                    }
                    
                    failure(e);
                    [weakSelf requestFailed:error];
                } else {
                    [weakSelf requestFailed:error];
                }
                [weakmanagers invalidateSessionCancelingTasks:YES resetSession:YES];
            }];
        }
            break;
        //PUT 方法
        case PUT:{
            [managers PUT:url parameters:parameters headers:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (success) {
                    success(responseObject);
                }
                [weakmanagers invalidateSessionCancelingTasks:YES resetSession:YES];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    NSError *e =  nil;
                    
                    if (error.code == AFNetworkErrorType_NoNetwork) {
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"网络不给力，请检查网络后再试" forKey:NSLocalizedDescriptionKey];
                        e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_NoNetwork  userInfo:userInfo];
                    } else if (error.code == AFNetworkErrorType_TimedOut){
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"网络不给力，请检查网络后再试" forKey:NSLocalizedDescriptionKey];
                        e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_TimedOut  userInfo:userInfo];
                    } else if (error.code == AFNetworkErrorType_3840Failed){
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"提交数据失败,请稍候再试" forKey:NSLocalizedDescriptionKey];
                        e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_3840Failed  userInfo:userInfo];
                    } else {
                        NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
                        NSInteger statusCode = response.statusCode;
                        if (statusCode == 400 || statusCode == 500) {
                            NSDictionary *contentDic = [NSJSONSerialization JSONObjectWithData:[error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"] options:NSJSONReadingMutableContainers error:nil];
                            NSString *reason = [NSString stringWithFormat:@"%@",[contentDic objectForKey:@"message"]];
                            if ([reason containsString:@"### Error querying database"] || [NSString isStringNull:reason]) {
                                reason = @"提交数据失败,请稍候再试";
                            }
                            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:reason forKey:NSLocalizedDescriptionKey];
                            e = [NSError errorWithDomain:NSCocoaErrorDomain code:statusCode userInfo:userInfo];
                        } else if (statusCode == 403){
                            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"提交数据失败,请稍候再试" forKey:NSLocalizedDescriptionKey];
                            e = [NSError errorWithDomain:NSCocoaErrorDomain code:403 userInfo:userInfo];
                        } else {
                            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"提交数据失败,请稍候再试" forKey:NSLocalizedDescriptionKey];
                            e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_3840Failed  userInfo:userInfo];
                        }
                    }
                    
                    failure(e);
                    [weakSelf requestFailed:error];
                } else {
                    [weakSelf requestFailed:error];
                }
                [weakmanagers invalidateSessionCancelingTasks:YES resetSession:YES];
            }];
        }
            break;
        //DELETE 方法
        case DELETE:{
            managers.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];
            [managers DELETE:url parameters:parameters headers:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (success) {
                    success(responseObject);
                }
                [weakmanagers invalidateSessionCancelingTasks:YES resetSession:YES];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    NSError *e =  nil;
                    
                    if (error.code == AFNetworkErrorType_NoNetwork) {
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"网络不给力，请检查网络后再试" forKey:NSLocalizedDescriptionKey];
                        e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_NoNetwork  userInfo:userInfo];
                    } else if (error.code == AFNetworkErrorType_TimedOut){
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"网络不给力，请检查网络后再试" forKey:NSLocalizedDescriptionKey];
                        e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_TimedOut  userInfo:userInfo];
                    } else if (error.code == AFNetworkErrorType_3840Failed){
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"提交数据失败,请稍候再试" forKey:NSLocalizedDescriptionKey];
                        e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_3840Failed  userInfo:userInfo];
                    } else {
                        NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
                        NSInteger statusCode = response.statusCode;
                        if (statusCode == 400 || statusCode == 500) {
                            NSDictionary *contentDic = [NSJSONSerialization JSONObjectWithData:[error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"] options:NSJSONReadingMutableContainers error:nil];
                            NSString *reason = [NSString stringWithFormat:@"%@",[contentDic objectForKey:@"message"]];
                            if ([reason containsString:@"### Error querying database"] || [NSString isStringNull:reason]) {
                                reason = @"提交数据失败,请稍候再试";
                            }
                            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:reason forKey:NSLocalizedDescriptionKey];
                            e = [NSError errorWithDomain:NSCocoaErrorDomain code:[[contentDic objectForKey:@"reascodeon"] integerValue] userInfo:userInfo];
                        } else {
                            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"提交数据失败,请稍候再试" forKey:NSLocalizedDescriptionKey];
                            e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_3840Failed  userInfo:userInfo];
                        }
                    }
                    
                    failure(e);
                    [weakSelf requestFailed:error];
                } else {
                    [weakSelf requestFailed:error];
                }
                [weakmanagers invalidateSessionCancelingTasks:YES resetSession:YES];
            }];
        }
            break;
        default:
            break;
    }
}

- (void)upLoadImageWithImage:(id)parameters
                              url:(NSString *)url
                          success:(void (^)(id responseObject))success
                          failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *managers = [AFHTTPSessionManager manager];
    url = [NSString stringWithFormat:@"%@%@",@"",url];
    WEAKSELF
    __weak typeof(AFHTTPSessionManager *) weakmanagers = managers;
    [managers POST:url parameters:nil headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *imgData = UIImageJPEGRepresentation(parameters,0.3);
        [formData appendPartWithFileData:imgData name:@"image"
                                fileName:@"img.jpg" mimeType:@"image/jpeg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
        [weakmanagers invalidateSessionCancelingTasks:YES resetSession:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            NSError *e =  nil;
            
            if (error.code == AFNetworkErrorType_NoNetwork) {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"网络不给力，请检查网络后再试" forKey:NSLocalizedDescriptionKey];
                e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_NoNetwork  userInfo:userInfo];
            } else if (error.code == AFNetworkErrorType_TimedOut){
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"网络不给力，请检查网络后再试" forKey:NSLocalizedDescriptionKey];
                e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_TimedOut  userInfo:userInfo];
            } else if (error.code == AFNetworkErrorType_3840Failed){
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"操作报错了，我们正在紧张的编写答案。。" forKey:NSLocalizedDescriptionKey];
                e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_3840Failed  userInfo:userInfo];
            } else {
                NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
                NSInteger statusCode = response.statusCode;
                if (statusCode == 400 || statusCode == 500) {
                    NSDictionary *contentDic = [NSJSONSerialization JSONObjectWithData:[error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"] options:NSJSONReadingMutableContainers error:nil];
                    NSString *reason = [NSString stringWithFormat:@"%@",[contentDic objectForKey:@"message"]];
                    if ([reason containsString:@"### Error querying database"]) {
                        reason = @"操作报错了，我们正在紧张的编写答案。。";
                    }
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:reason forKey:NSLocalizedDescriptionKey];
                    e = [NSError errorWithDomain:NSCocoaErrorDomain code:[[contentDic objectForKey:@"reascodeon"] integerValue] userInfo:userInfo];
                } else {
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"操作报错了，我们正在紧张的编写答案。。" forKey:NSLocalizedDescriptionKey];
                    e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_3840Failed  userInfo:userInfo];
                }
                
            }
            
            failure(e);
            [weakSelf requestFailed:error];
        }else{
            [weakSelf requestFailed:error];
        }
        [weakmanagers invalidateSessionCancelingTasks:YES resetSession:YES];
    }];
}

- (void)downloadFileWithURL:(NSString*)url
                    musicId:(NSString *)musicId
                 parameters:(NSDictionary *)parameters
                  savedPath:(NSString*)savedPath
            downloadSuccess:(void (^)(NSURLResponse *response, NSURL *filePath, NSURLSessionDownloadTask *task))success
            downloadFailure:(void (^)(NSError *error))failure
           downloadProgress:(void (^)(NSProgress *downloadProgress))progress {
    
}

#pragma mark - 请求失败统一回调方法
- (void)requestFailed:(NSError *)error {
//    STLog(@"--------------\n%ld %@",(long)error.code, error.debugDescription);
    switch (error.code) {
        case AFNetworkErrorType_NoNetwork :
//            STLog(@"暂时木有网络，请检查网络。");
            break;
        case AFNetworkErrorType_TimedOut :
//            STLog(@"网络不给力，请下拉刷新或换个网络。");
            break;
        case AFNetworkErrorType_3840Failed :
//            STLog(@"操作报错了，我们正在紧张的编写答案。。");
            break;
        default:
            break;
    }
}


@end
