//
//  ADAppStoreConnector.h
//  ADAppRating Demo
//
//  Created by Amir Shavit on 6/14/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADARDelegate.h"

@interface ADAppStoreConnector : NSObject

@property (nonatomic, weak) id<ADARDelegate> delegate;

- (void)setApplicationBundleID:(NSString *)applicationBundleID;
- (void)setAppStoreID:(NSUInteger)appStoreID;

- (BOOL)isAppStoreAvailable;
- (void)openRatingsPageInAppStore;

@end
