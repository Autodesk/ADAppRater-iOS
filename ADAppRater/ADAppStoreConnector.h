//
//  ADAppStoreConnector.h
//  ADAppRater
//
//  Created by Amir Shavit on 6/14/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADARDelegate.h"

/**
 *  @brief `ADAppStoreConnector` class is used privatly by the `ADAppRater` class, to handle communication with the App Store.
 */
@interface ADAppStoreConnector : NSObject

@property (nonatomic, weak) id<ADARDelegate> delegate;

- (void)setApplicationBundleID:(NSString *)applicationBundleID;
- (void)setAppStoreID:(NSUInteger)appStoreID;
- (void)setAppStoreCountry:(NSString *)appStoreCountry;

- (BOOL)isAppStoreAvailable;
- (void)openRatingsPageInAppStore;

@end
