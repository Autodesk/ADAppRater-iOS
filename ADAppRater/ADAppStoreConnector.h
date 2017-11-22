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

/**
 *  @brief ADAppStoreConnector uses updated store urls by default.
 *  @discussion Use this to revert to old URLs, if functionality is broken.
 *  @deprecated Use this as a toggle only. Old URLs are soon to be removed, along with this function.
 */
- (void)useOldApiFlow DEPRECATED_MSG_ATTRIBUTE("Use this as a toggle only. Old URLs are soon to be removed, along with this function.");

- (BOOL)isAppStoreAvailable;
- (void)openRatingsPageInAppStore;

@end
