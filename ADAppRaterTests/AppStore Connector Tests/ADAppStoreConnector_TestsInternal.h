//
//  ADAppStoreConnector_TestsInternal.h
//  ADAppRater Demo
//
//  Created by Amir Shavit on 6/24/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import "ADAppStoreConnector.h"

@interface ADAppStoreConnector ()

@property (nonatomic, readonly) NSUInteger appStoreID;
@property (nonatomic, readonly) NSUInteger appStoreGenreID;
@property (nonatomic, readonly) NSString *applicationBundleID;
@property (nonatomic, readonly) NSString *appStoreCountry;
@property (nonatomic, readonly) NSURL *ratingsURL;

- (void)checkForConnectivityInBackground;
- (NSInteger)checkForConnectivity:(NSError **)error;

@end
