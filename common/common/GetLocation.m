//
//  GetLocation.m
//  facialMask
//
//  Created by ios on 2018/11/14.
//  Copyright © 2018 partnfire. All rights reserved.
//

#import "GetLocation.h"
static GetLocation *location = nil;

@interface GetLocation ()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
/// 定位成功的回调block
@property (nonatomic, copy) void (^successBlock)(NSArray<CLLocation *> *);
/// 编码成功的回调block
@property (nonatomic, copy) void (^geocodeBlock)(NSArray *geocodeArray);
/// 定位失败的回调block
@property (nonatomic, copy) void (^failureBlock)(NSError *error);
//地理编码成功回调block
@property (nonatomic, copy) void (^geoBlock)(CLLocation *location);
@end


@implementation GetLocation

+ (instancetype)manager {
    static GetLocation *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        manager.locationManager = [[CLLocationManager alloc] init];
        manager.locationManager.delegate = manager;
        [manager.locationManager requestWhenInUseAuthorization];
    });
    return manager;
}

- (void)startLocation {
    [self startLocationWithSuccessBlock:nil failureBlock:nil geocoderBlock:nil];
}

- (void)startLocationWithSuccessBlock:(void (^)(NSArray<CLLocation *> *location))successBlock failureBlock:(void (^)(NSError *error))failureBlock {
    [self startLocationWithSuccessBlock:successBlock failureBlock:failureBlock geocoderBlock:nil];
}

- (void)startLocationWithGeocoderBlock:(void (^)(NSArray *geocoderArray))geocoderBlock {
    [self startLocationWithSuccessBlock:nil failureBlock:nil geocoderBlock:geocoderBlock];
}

- (void)startLocationWithSuccessBlock:(void (^)(NSArray<CLLocation *> *location))successBlock failureBlock:(void (^)(NSError *error))failureBlock geocoderBlock:(void (^)(NSArray *geocoderArray))geocoderBlock {
    [self.locationManager startUpdatingLocation];
    _successBlock = successBlock;
    _geocodeBlock = geocoderBlock;
    _failureBlock = failureBlock;
}

#pragma mark - CLLocationManagerDelegate

/// 地理位置发生改变时触发
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [manager stopUpdatingLocation];
    if (_successBlock) {
        _successBlock(locations);
    }
    if (_geocodeBlock && locations.count) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:[locations firstObject] completionHandler:^(NSArray *array, NSError *error) {
            self->_geocodeBlock(array);
        }];
    }
}

/// 定位失败回调方法
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"定位失败, 错误: %@",error);
    switch([error code]) {
        case kCLErrorDenied: { // 用户禁止了定位权限
            
        } break;
        default: break;
    }
    if (_failureBlock) {
        _failureBlock(error);
    }
}

- (void)startGeocodeAddressString:(NSString *)addressString withSuccessBlock:(void (^)(CLLocation *))successBlock failureBlock:(void (^)(NSError *error))failureBlock {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:addressString completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error) {
            failureBlock(error);
        } else {
            CLPlacemark *placemark = [placemarks firstObject];
            successBlock(placemark.location);
        }
    }];
}


@end
