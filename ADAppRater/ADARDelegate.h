//
//  ADARDelegate.h
//  ADAppRating Demo
//
//  Created by Amir Shavit on 6/24/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ADARDelegate <NSObject>

@optional

- (void)appRateWillPromptUserSatisfaction;
- (void)appRateWillPromptUserRating;
- (void)appRateWillPromptFeedbackRequest;
- (void)appRateWillDisplayThankYouAlert;

- (void)appRateUserDidAgreeToRateApp;
- (void)appRateUserDidDeclineToRateApp;
- (void)appRateUserDidRequestReminderToRateApp;

- (void)appRateUserDidAgreeToSendFeedback;
- (void)appRateUserDidDeclineToSendFeedback;

- (void)appRateAppStoreDidOpen;
- (void)appRateAppStoreCouldNotConnect:(NSError *)error;


/**
 *  Tells the delegate a message should be logged to console.
 *  @discussion Implement this method to provide a custom logging component (instead of NSLog).
 *  @discussion Optional
 *  @param message message to print out to console
 */
- (void)appRateLogToConsole:(NSString*)message;

@end
