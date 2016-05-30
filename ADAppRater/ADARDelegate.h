//
//  ADARDelegate.h
//  ADAppRater
//
//  Created by Amir Shavit on 6/24/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  @brief `ADARDelegate` protocol defines methods that are called by the `ADAppRater` class in response to events in the rating prompt flow.
 *  @discussion All protocol methods are optional.
 */
@protocol ADARDelegate <NSObject>

@optional

- (void)appRaterWillPromptUserSatisfaction;
- (void)appRaterWillPromptUserRating;
- (void)appRaterWillPromptFeedbackRequest;
- (void)appRaterWillDisplayThankYouAlert;

- (void)appRaterUserDidAgreeToRateApp;
- (void)appRaterUserDidDeclineToRateApp;
- (void)appRaterUserDidRequestReminderToRateApp;

- (void)appRaterUserDidAgreeToSendFeedback;
- (void)appRaterUserDidDeclineToSendFeedback;

- (void)appRaterAppStoreDidOpen;
- (void)appRaterAppStoreCouldNotConnect:(NSError *)error;


/**
 *  Tells the delegate a message should be logged to console.
 *  @discussion Implement this method to provide a custom logging component (instead of NSLog).
 *  @discussion Optional
 *  @param message message to print out to console
 */
- (void)appRaterLogToConsole:(NSString*)message;

@end
