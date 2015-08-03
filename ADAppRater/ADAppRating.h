//
//  ADAppRating.h
//  ADAppRating
//
//  Created by Amir Shavit on 6/10/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "ADARDelegate.h"
#import "ADARCustomViewsDelegate.h"

// Model Objects
#import "ADEventScenario.h"
#import "ADAppRatingTexts.h"

@interface ADAppRating : NSObject <MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) id<ADARDelegate> delegate;

@property (nonatomic, weak) id<ADARCustomViewsDelegate> customViewsDelegate;

/**
 *  Singlton instanciation
 */
+ (instancetype)sharedInstance;

/**
 *  Application Details - These are set automatically, but can bu overriden if needed
 */
@property (nonatomic, copy) NSString *applicationName;
@property (nonatomic, copy) NSString *applicationVersion;
@property (nonatomic, copy) NSString *applicationBundleID;

#pragma mark - Usage Configuration

/**
 *  The amount of days since the current app version was first launched to wait before prompting user to rate the app
 *  Defualt is 1.
 */
@property (nonatomic) NSInteger currentVersionDaysUntilPrompt;

/**
 *  The amount of launches of the current app version to wait before prompting user to rate the app
 *  Defualt is 3.
 */
@property (nonatomic) NSInteger currentVersionLaunchesUntilPrompt;

/**
 *  The number of days to wait to re-prompt user to rate the app, in case he asked to be reminded later.
 */
@property (nonatomic) NSInteger remindWaitPeriod;

/**
 *  Set YES if user should be prompted to rate the app for a new version, even if he already rated an older version.
 *  Defualt is NO.
 */
@property (nonatomic) BOOL promptForNewVersionIfUserRated;

/**
 *  Array of ADEventScenario Objects, each describes a scenario to prompt user rating if completed.
 *  @see ADEventScenario
 */
@property (nonatomic, strong) NSArray* eventScenariosUntilPrompt;

#pragma mark - App Usage History

@property (nonatomic, readonly) NSDate *currentVersionFirstLaunch;
@property (nonatomic, readonly) NSDate *currentVersionLastReminded;
@property (nonatomic, readonly) NSDictionary* persistEventCounters;
@property (nonatomic, readonly) NSUInteger currentVersionCountLaunches;

@property (nonatomic) BOOL ratedThisVersion;
@property (nonatomic) BOOL declinedThisVersion;
@property (nonatomic, readonly) BOOL ratedAnyVersion;
@property (nonatomic, readonly) BOOL declinedAnyVersion;

#pragma mark - Flow Methods

/**
 *  Immediately invoke the rating flow, starting with checking user satisfaction.
 *  @discussion The only condition checked is connection to app store is available
 *  @param viewController The current UIViewController that will present the prompt UI
 */
- (void)startRatingFlowFromViewController:(__weak UIViewController*)viewController;

/**
 *  Invoke the rating flow only if all configurable criterias have been met, at least one event scenario is completed (if defined any) and app store connection is available.
 *  @param viewController The current UIViewController that will present the prompt UI
 */
- (void)startRatingFlowIfCriteriaMetFromViewController:(__weak UIViewController*)viewController;

/**
 *  Check if the conditions to prompt rating are fullfiled.
 *  @return YES if the all configurable criterias have been met and at least one event scenario is completed (if defined any)
 *  @return NO otherwise
 */
- (BOOL)shouldPromptForRating;

/**
 *  Notify ADAppRating a significant event has occurred. This method can be called from anywhere in your app and increments the event count.
 This method also invokes the `startRatingFlowIfCriteriaMetFromViewController:` to check if any scenario has now been completed and present the rating flow if so.
 *  @param eventName      Name of the significant event. Should match event names configured in the eventScenariosUntilPrompt property
 *  @param viewController The current UIViewController that will present the prompt UI
 *  @see eventScenariosUntilPrompt
 */
- (void)registerEvent:(NSString*)eventName withViewController:(__weak UIViewController*)viewController;

/**
 *  Immediately prompt user to rate the app, skipping the flow of first checking user satisfaction.
 *  @discussion The only condition checked is that the device is online
 *  @param viewController The current UIViewController that will present the prompt UI
 */
- (void)promptDirectAppRatingFromViewController:(__weak UIViewController*)viewController;

#pragma mark - Developer Tools

/**
 *  @brief Enable / Disable looging to console.
 *  @discussion YES to enable printing log to console. NO to disable.
 *  @discussion Default is YES
 *  @see ADARDelegate Implement appRateLogToConsole: method to use custom logging system
 */
@property (nonatomic) BOOL enableLog;

#ifdef DEBUG

/**
 *  Preview mode is used for development process, to always return YES on shouldPromptForRating method
 *  Defualt is NO.
 */
@property (nonatomic) BOOL previewMode;

/**
 *  Reset persistent usage history. Simulate clean installation
 */
- (void)resetUsageHistory;

#endif

@end
