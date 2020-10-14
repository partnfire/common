//
//  SGNetWorkHandler.h
//  sigmaParents
//
//  Created by 侯慧杰 on 16/8/1.
//  Copyright © 2016年 sigma5t. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HJNetWorkHandler : NSObject

//请求方式
typedef NS_ENUM(NSUInteger, RequestMethod) {
    POST = 0,
    GET,
    PUT,
    DELETE
};

//错误状态码 iOS-sdk里面的 NSURLError.h 文件
typedef NS_ENUM (NSInteger, AFNetworkErrorType) {
    AFNetworkErrorType_TimedOut = NSURLErrorTimedOut,                               //-1001 请求超时
    AFNetworkErrorType_UnURL = NSURLErrorUnsupportedURL,                            //-1002 不支持的url
    AFNetworkErrorType_NoNetwork = NSURLErrorNotConnectedToInternet,                //-1009 断网
    AFNetworkErrorType_404Failed = NSURLErrorBadServerResponse,                     //-1011 404错误
    AFNetworkErrorType_3840Failed = 3840,                                           //请求或返回不是纯Json格式
};

//声明单例方法
+ (instancetype)shareInstance;


/**
 *  AFNetworking请求方法 [AFHTTPClient shareInstance]
 *
 *  @param method     请求方式 POST / GET
 *  @param parameters 请求参数 --支持NSArray, NSDictionary, NSSet这三种数据结构
 *  @param url        请求url字符串
 *  @param success    请求成功回调block
 */
//- (void)startRequestMethod:(RequestMethod)method
//                parameters:(id)parameters
//                       url:(NSString *)url
//                   success:(void (^)(id responseObject))success;

/**
 *  AFNetworking请求方法 [AFHTTPClient shareInstance]
 *
 *  @param method     请求方式 POST / GET
 *  @param parameters 请求参数 --支持NSArray, NSDictionary, NSSet这三种数据结构
 *  @param url        请求url字符串
 *  @param success    请求成功回调block
 *  @param failure    请求失败回调block
 */
- (void)startRequestMethod:(RequestMethod)method
                parameters:(id)parameters
                       url:(NSString *)url
                   success:(void (^)(id responseObject))success
                   failure:(void (^)(NSError *error))failure;

/**
 *  AFNetworking上传图片方法 [AFHTTPClient shareInstance]
 *
 *  @param parameters 请求参数 --支持NSArray, NSDictionary, NSSet这三种数据结构
 *  @param url        请求url字符串
 *  @param success    请求成功回调block
 *  @param failure    请求失败回调block
 */
- (void)upLoadImageWithImage:(id)parameters
                       url:(NSString *)url
                   success:(void (^)(id responseObject))success
                   failure:(void (^)(NSError *error))failure;

/**
 *  AFNetworking下载文件方法 [AFHTTPClient shareInstance]
 *
 *  @param parameters 请求参数 --支持NSArray, NSDictionary, NSSet这三种数据结构
 *  @param url        请求url字符串
 *  @param savedPath  下载文件保存地址
 *  @param success    请求成功回调block
 *  @param failure    请求失败回调block
 *  @param progress   下载进度block
 */
- (void)downloadFileWithURL:(NSString*)url
                    musicId:(NSString *)musicId
                 parameters:(NSDictionary *)parameters
                  savedPath:(NSString*)savedPath
            downloadSuccess:(void (^)(NSURLResponse *response, NSURL *filePath, NSURLSessionDownloadTask *task))success
            downloadFailure:(void (^)(NSError *error))failure
           downloadProgress:(void (^)(NSProgress *downloadProgress))progress;

@end
