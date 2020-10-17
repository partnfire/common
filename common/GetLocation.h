//
//  GetLocation.h
//  facialMask
//
//  Created by ios on 2018/11/14.
//  Copyright © 2018 partnfire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface GetLocation : NSObject

+ (instancetype)manager;

- (void)startLocation;

- (void)startLocationWithSuccessBlock:(void (^)(NSArray<CLLocation *> *location))successBlock failureBlock:(void (^)(NSError *error))failureBlock;

- (void)startLocationWithGeocoderBlock:(void (^)(NSArray *geocoderArray))geocoderBlock;

- (void)startLocationWithSuccessBlock:(void (^)(NSArray<CLLocation *> *location))successBlock failureBlock:(void (^)(NSError *error))failureBlock geocoderBlock:(void (^)(NSArray *geocoderArray))geocoderBlock;

- (void)startGeocodeAddressString:(NSString *)addressString withSuccessBlock:(void (^)(CLLocation *))successBlock failureBlock:(void (^)(NSError *error))failureBlock;

@end

