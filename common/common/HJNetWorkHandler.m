//
//  SGNetWorkHandler.m
//  sigmaParents
//
//  Created by 侯慧杰 on 16/8/1.
//  Copyright © 2016年 sigma5t. All rights reserved.
//

#import "HJNetWorkHandler.h"
#import <CocoaSecurity/CocoaSecurity.h>


#define WEAKSELF  __weak typeof(self) weakSelf = self;

@implementation HJNetWorkHandler

// 单例
+ (instancetype)shareInstance {
    static HJNetWorkHandler *netWorkHandle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        netWorkHandle = [[HJNetWorkHandler alloc] init];
    });
    return netWorkHandle;
}

//#pragma mark - 开始请求，只回调请求成功
//- (void)startRequestMethod:(RequestMethod)method
//                parameters:(id)parameters
//                       url:(NSString *)url
//                   success:(void (^)(id responseObject))success
//{
//    [self startRequestMethod:method parameters:parameters url:url success:success failure:nil];
//}

#pragma mark - 开始请求，回调请求成功和失败
- (void)startRequestMethod:(RequestMethod)method
                parameters:(id)parameters
                       url:(NSString *)url
                   success:(void (^)(id responseObject))success
                   failure:(void (^)(NSError *error))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    manager.requestSerializer.timeoutInterval = 30.0f;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/javascript", @"application/x-json", @"application/x-javascript", @"multipart/form-data",@"image/jpeg", @"image/png",@"application/octet-stream", @"text/plain",nil];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    NSDictionary *userInfo = [KeyChainManager keyChainReadData:kUserInfo];
//    if (![NSString isStringNull:[userInfo objectForKey:@"authToken"]]) {
//        [manager.requestSerializer setValue:[userInfo objectForKey:@"authToken"] forHTTPHeaderField:@"authCode"];
//    }
    if([[parameters allKeys] containsObject:@"telAuth"]){
        NSMutableDictionary *param = [parameters mutableCopy];
        NSString *phone = [parameters objectForKey:@"phone"];
        if (phone.length > 8) {
            phone = [phone substringWithRange:NSMakeRange(4, 5)];
            NSString *timeStamp = [NSDate dateTotimestamp:[NSDate date]];
            if (timeStamp.length > 8) {
                NSString *subtimeStamp = [timeStamp substringWithRange:NSMakeRange(3, 6)];
                NSString *miAll = [NSString stringWithFormat:@"%@%@%@",phone,kMessage,subtimeStamp];
                CocoaSecurityResult *md5 = [CocoaSecurity md5:miAll];
                miAll = md5.hexLower;
                
                [manager.requestSerializer setValue:miAll forHTTPHeaderField:@"a"];
                [manager.requestSerializer setValue:timeStamp forHTTPHeaderField:@"b"];
                [param removeObjectForKey:@"telAuth"];
                [param removeObjectForKey:@"phone"];
                parameters = param;
            }
        }
    }
    __weak typeof(manager) weakManager = manager;
    WEAKSELF
    switch (method) {
        //POST 方法
        case POST:{
            [manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (success) {
                    success(responseObject);
                }
                [weakManager invalidateSessionCancelingTasks:YES];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    NSError *e =  nil;
                    
                    if (error.code == AFNetworkErrorType_NoNetwork) {
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:Localized(@"CheckNetwork1") forKey:NSLocalizedDescriptionKey];
                        e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_NoNetwork  userInfo:userInfo];
                    } else if (error.code == AFNetworkErrorType_TimedOut){
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:Localized(@"CheckNetwork") forKey:NSLocalizedDescriptionKey];
                        e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_TimedOut  userInfo:userInfo];
                    } else if (error.code == AFNetworkErrorType_3840Failed){
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:Localized(@"ErrorTryAgain") forKey:NSLocalizedDescriptionKey];
                        e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_3840Failed  userInfo:userInfo];
                    } else if (error.code == 403){
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:Localized(@"ErrorTryAgain") forKey:NSLocalizedDescriptionKey];
                        e = [NSError errorWithDomain:NSCocoaErrorDomain code:403 userInfo:userInfo];
                    } else {
                        NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
                        NSInteger statusCode = response.statusCode;
                        if (statusCode == 400 || statusCode == 404 ||statusCode == 500 || statusCode == 502) {
                            NSDictionary *contentDic = [NSJSONSerialization JSONObjectWithData:[error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"] options:NSJSONReadingMutableContainers error:nil];
                            NSString *reason = [NSString stringWithFormat:@"%@",[contentDic objectForKey:@"message"]];
                            if ([reason containsString:@"### Error querying database"] || [NSString isStringNull:reason] || statusCode == 404) {
                                reason = Localized(@"ErrorTryAgain");
                            }
                            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:reason forKey:NSLocalizedDescriptionKey];
                            e = [NSError errorWithDomain:NSCocoaErrorDomain code:statusCode userInfo:userInfo];
                        } else {
                            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:Localized(@"ErrorTryAgain") forKey:NSLocalizedDescriptionKey];
                            e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_3840Failed  userInfo:userInfo];
                        }
                    }
                    
                    failure(e);
                    [weakSelf requestFailed:error];
                } else {
                    [weakSelf requestFailed:error];
                }
                [weakManager invalidateSessionCancelingTasks:YES];
            }];
        }
            break;
        //GET 方法
        case GET:{
            [manager GET:url parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (success) {
                    success(responseObject);
                }
                [weakManager invalidateSessionCancelingTasks:YES];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    NSError *e =  nil;
                    
                    if (error.code == AFNetworkErrorType_NoNetwork) {
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:Localized(@"CheckNetwork1") forKey:NSLocalizedDescriptionKey];
                        e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_NoNetwork  userInfo:userInfo];
                    } else if (error.code == AFNetworkErrorType_TimedOut){
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:Localized(@"CheckNetwork") forKey:NSLocalizedDescriptionKey];
                        e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_TimedOut  userInfo:userInfo];
                    } else if (error.code == AFNetworkErrorType_3840Failed){
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:Localized(@"NoData") forKey:NSLocalizedDescriptionKey];
                        e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_3840Failed  userInfo:userInfo];
                    } else {
                        NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
                        NSInteger statusCode = response.statusCode;
                        if (statusCode == 400 || statusCode == 500) {
                            NSDictionary *contentDic = [NSJSONSerialization JSONObjectWithData:[error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"] options:NSJSONReadingMutableContainers error:nil];
                            NSString *reason = [NSString stringWithFormat:@"%@",[contentDic objectForKey:@"message"]];
                            if ([reason containsString:@"### Error querying database"] || [NSString isStringNull:reason]) {
                                reason = Localized(@"ErrorTryAgain");
                            }
                            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:reason forKey:NSLocalizedDescriptionKey];
                            e = [NSError errorWithDomain:NSCocoaErrorDomain code:statusCode userInfo:userInfo];
                        } else {
                            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:Localized(@"NoData") forKey:NSLocalizedDescriptionKey];
                            e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_3840Failed  userInfo:userInfo];
                        }
                    }
                    
                    failure(e);
                    [weakSelf requestFailed:error];
                } else {
                    [weakSelf requestFailed:error];
                }
                [weakManager invalidateSessionCancelingTasks:YES];
            }];
        }
            break;
        //PUT 方法
        case PUT:{
            [manager PUT:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (success) {
                    success(responseObject);
                }
                [weakManager invalidateSessionCancelingTasks:YES];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    NSError *e =  nil;
                    
                    if (error.code == AFNetworkErrorType_NoNetwork) {
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:Localized(@"CheckNetwork1") forKey:NSLocalizedDescriptionKey];
                        e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_NoNetwork  userInfo:userInfo];
                    } else if (error.code == AFNetworkErrorType_TimedOut){
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:Localized(@"CheckNetwork") forKey:NSLocalizedDescriptionKey];
                        e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_TimedOut  userInfo:userInfo];
                    } else if (error.code == AFNetworkErrorType_3840Failed){
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:Localized(@"ErrorTryAgain") forKey:NSLocalizedDescriptionKey];
                        e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_3840Failed  userInfo:userInfo];
                    } else {
                        NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
                        NSInteger statusCode = response.statusCode;
                        if (statusCode == 400 || statusCode == 500) {
                            NSDictionary *contentDic = [NSJSONSerialization JSONObjectWithData:[error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"] options:NSJSONReadingMutableContainers error:nil];
                            NSString *reason = [NSString stringWithFormat:@"%@",[contentDic objectForKey:@"message"]];
                            if ([reason containsString:@"### Error querying database"] || [NSString isStringNull:reason]) {
                                reason = Localized(@"ErrorTryAgain");
                            }
                            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:reason forKey:NSLocalizedDescriptionKey];
                            e = [NSError errorWithDomain:NSCocoaErrorDomain code:statusCode userInfo:userInfo];
                        } else if (statusCode == 403){
                            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:Localized(@"ErrorTryAgain") forKey:NSLocalizedDescriptionKey];
                            e = [NSError errorWithDomain:NSCocoaErrorDomain code:403 userInfo:userInfo];
                        } else {
                            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:Localized(@"ErrorTryAgain") forKey:NSLocalizedDescriptionKey];
                            e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_3840Failed  userInfo:userInfo];
                        }
                    }
                    
                    failure(e);
                    [weakSelf requestFailed:error];
                } else {
                    [weakSelf requestFailed:error];
                }
                [weakManager invalidateSessionCancelingTasks:YES];
            }];
        }
            break;
        //DELETE 方法
        case DELETE:{
            manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];
            [manager DELETE:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (success) {
                    success(responseObject);
                }
                [weakManager invalidateSessionCancelingTasks:YES];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    NSError *e =  nil;
                    
                    if (error.code == AFNetworkErrorType_NoNetwork) {
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:Localized(@"CheckNetwork1") forKey:NSLocalizedDescriptionKey];
                        e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_NoNetwork  userInfo:userInfo];
                    } else if (error.code == AFNetworkErrorType_TimedOut){
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:Localized(@"CheckNetwork") forKey:NSLocalizedDescriptionKey];
                        e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_TimedOut  userInfo:userInfo];
                    } else if (error.code == AFNetworkErrorType_3840Failed){
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:Localized(@"ErrorTryAgain") forKey:NSLocalizedDescriptionKey];
                        e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_3840Failed  userInfo:userInfo];
                    } else {
                        NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
                        NSInteger statusCode = response.statusCode;
                        if (statusCode == 400 || statusCode == 500) {
                            NSDictionary *contentDic = [NSJSONSerialization JSONObjectWithData:[error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"] options:NSJSONReadingMutableContainers error:nil];
                            NSString *reason = [NSString stringWithFormat:@"%@",[contentDic objectForKey:@"message"]];
                            if ([reason containsString:@"### Error querying database"] || [NSString isStringNull:reason]) {
                                reason = Localized(@"ErrorTryAgain");
                            }
                            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:reason forKey:NSLocalizedDescriptionKey];
                            e = [NSError errorWithDomain:NSCocoaErrorDomain code:[[contentDic objectForKey:@"reascodeon"] integerValue] userInfo:userInfo];
                        } else {
                            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:Localized(@"ErrorTryAgain") forKey:NSLocalizedDescriptionKey];
                            e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_3840Failed  userInfo:userInfo];
                        }
                    }
                    
                    failure(e);
                    [weakSelf requestFailed:error];
                } else {
                    [weakSelf requestFailed:error];
                }
                [weakManager invalidateSessionCancelingTasks:YES];
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
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    url = [NSString stringWithFormat:@"%@%@",URL_ServerAddress,url];
    WEAKSELF
    __weak typeof(manager) weakManager = manager;
    [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *imgData = UIImageJPEGRepresentation(parameters,0.3);
        [formData appendPartWithFileData:imgData name:@"image"
                                fileName:@"img.jpg" mimeType:@"image/jpeg"];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
        [weakManager invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            NSError *e =  nil;
            
            if (error.code == AFNetworkErrorType_NoNetwork) {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:Localized(@"CheckNetwork1") forKey:NSLocalizedDescriptionKey];
                e = [NSError errorWithDomain:NSCocoaErrorDomain code:AFNetworkErrorType_NoNetwork  userInfo:userInfo];
            } else if (error.code == AFNetworkErrorType_TimedOut){
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:Localized(@"CheckNetwork") forKey:NSLocalizedDescriptionKey];
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
        [weakManager invalidateSessionCancelingTasks:YES];
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
