//
//  ADAppRater.h
//  ADAppRater
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
#import "ADAppRaterTexts.h"

/**
 *  @brief `ADAppRater` is a component intended to help you promote your apps in the App Store by targeting satisfied users and asking them to rate your app.
 *  @discussion `ADAppRater` requires no configuration and can perform as is, simply using default configuration and the application's current plist details.
 *  Configuring custom values for the parameter is optional, and recommended to do so before the app has finished launching, i.e. in the AppDelegate's `application: didFinishLaunchingWithOptions:` method.
 */
@interface ADAppRater : NSObject <MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) id<ADARDelegate> delegate;

@property (nonatomic, weak) id<ADARCustomViewsDelegate> customViewsDelegate;

///---------------------
/// @name Initialization
///---------------------

/**
 *  Singlton instanciation
 */
+ (instancetype)sharedInstance;

/**
 *  @return Version of ADAppRater component
 *  @since v1.0.3
 */
+ (NSString*)appRaterVersion;

/**
 *  @brief Application Details
 *  @discussion This is set automatically, but can be overriden if needed
 *  @since v1.0.0
 */
@property (nonatomic, copy) NSString *applicationName;

/**
 *  @brief Application Details
 *  @discussion This is set automatically, but can be overriden if needed
 *  @since v1.0.0
 */
@property (nonatomic, copy) NSString *applicationVersion;

/**
 *  @brief Application Details
 *  @discussion This is set automatically, but can be overriden if needed
 *  @since v1.0.0
 */
@property (nonatomic, copy) NSString *applicationBundleID;

#pragma mark - Usage Configuration

///---------------------
/// @name Usage Configuration
///---------------------

/**
 *  The amount of days since the current app version was first launched to wait before prompting user to rate the app
 *  Defualt is 1.
 *  @since v1.0.0
 */
@property (nonatomic) NSInteger currentVersionDaysUntilPrompt;

/**
 *  The amount of launches of the current app version to wait before prompting user to rate the app
 *  Defualt is 3.
 *  @since v1.0.0
 */
@property (nonatomic) NSInteger currentVersionLaunchesUntilPrompt;

/**
 *  The number of days to wait to re-prompt user to rate the app, in case he asked to be reminded later.
 *  @since v1.0.0
 */
@property (nonatomic) NSInteger remindWaitPeriod;

/**
 *  Set YES if user should be prompted to rate the app for a new version, even if he already rated an older version.
 *  @discussion When set to NO, the Rater does not reset the list of significant events, in order to keep progress of the event scenarios.
 *  Defualt is NO.
 *  @since v1.0.0
*/
@property (nonatomic) BOOL promptForNewVersionIfUserRated;

/**
 *  @brief Limit the frequency where the user is prompted to rate the app.
 *  @discussion In case configuration is set to prompt user for each version, limit prompt occurency in days to prvent annoying users.
 *  Default is 30 days (once a month).
 *  @since v1.0.3
 */
@property (nonatomic) NSInteger limitPromptFrequency;

/**
 *  @brief Limit the time period of which the user's prompt response is valid.
 *  @discussion In case configuration is set not to prompt user for each version, allow to re-prompt user after a certain amount time, no matter how he responded last time. This is not loose the ratings of high rater users.
 *  @discussion Default is 180 days (about 6 month). Set to 0 to disable the invalidation feature.
 *  @since v1.0.9
 */
@property (nonatomic) NSInteger invalidateLastResponsePeriod;

/**
 *  Array of ADEventScenario Objects, each describes a scenario to prompt user to rate app if completed.
 *  @see ADEventScenario
 *  @since v1.0.0
 */
@property (nonatomic, strong) NSArray* eventScenariosUntilPrompt;

#pragma mark Localization

/**
 *  @brief An object bundling all text strings that will be displayed with the default UI flow.
 *  @discussion ADAppRater is not localized and has only default English strings. 
 *  All strings used for the default UI flow are bundled in an ADAppRaterTexts class.
 *  You can either access the default instance or create a new instance and override the new one
 *  @since v1.0.2
 */
@property (nonatomic, strong) ADAppRaterTexts* localStrings;

#pragma mark - App Usage History

///---------------------
/// @name App Usage History
///---------------------

@property (nonatomic, readonly) NSDate *currentVersionFirstLaunch;

/**
 *  @brief Replaces previous `currentVersionLastReminded`.
 *  @discussion Reminder is no longer limited to a version.
 *  @since v1.0.3
 */
@property (nonatomic, readonly) NSDate *userLastRemindedToRate;

/**
 *  @since v1.0.3
 */
@property (nonatomic, readonly) NSDate *userLastPromptedToRate;
@property (nonatomic, readonly) NSDictionary* persistEventCounters;
@property (nonatomic, readonly) NSUInteger currentVersionCountLaunches;

@property (nonatomic) BOOL ratedThisVersion;
@property (nonatomic) BOOL declinedThisVersion;
@property (nonatomic, readonly) BOOL ratedAnyVersion;
@property (nonatomic, readonly) BOOL declinedAnyVersion;

#pragma mark - Flow Methods

///---------------------
/// @name Flow Methods
///---------------------

/**
 *  Immediately invoke the Rater flow, starting with checking user satisfaction.
 *  @discussion The only condition checked is connection to app store is available
 *  @param viewController The current UIViewController that will present the prompt UI
 */
- (void)startRaterFlowFromViewController:(__weak UIViewController*)viewController;

/**
 *  Invoke the Rater flow only if all configurable criterias have been met, at least one event scenario is completed (if defined any) and app store connection is available.
 *  @param viewController The current UIViewController that will present the prompt UI
 */
- (void)startRaterFlowIfCriteriaMetFromViewController:(__weak UIViewController*)viewController;

/**
 *  Check if the conditions to start Rater flow are fullfiled.
 *  @return YES if the all configurable criterias have been met and at least one event scenario is completed (if defined any)
 *  @return NO otherwise
 */
- (BOOL)shouldPromptForRating;

/**
 *  Notify ADAppRater a significant event has occurred. This method can be called from anywhere in your app and increments the event count.
 This method also invokes the `startRaterFlowIfCriteriaMetFromViewController:` to check if any scenario has now been completed and present the Rater flow if so.
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
- (void)promptDirectRatingFromViewController:(__weak UIViewController*)viewController;

/**
 * Immediately take user to the AppStore ratings page
 * @discussion No condition is checked
 */
-(void)directUserToAppStore;

#pragma mark - Developer Tools

///---------------------
/// @name Developer Tools
///---------------------

/**
 *  @brief Enable / Disable looging to console.
 *  @discussion YES to enable printing log to console. NO to disable.
 *  @discussion Default is YES
 *  @see ADARDelegate Implement appRaterLogToConsole: method to use custom logging system
 */
@property (nonatomic) BOOL enableLog;

/**
 *  @brief ADAppStoreConnector uses updated store urls by default.
 *  @discussion Use this to revert to old URLs, if functionality is broken.
 *  @deprecated Use this as a toggle only. Old URLs are soon to be removed, along with this function.
 */
- (void)useOldApiFlow DEPRECATED_MSG_ATTRIBUTE("Use this as a toggle only. Old URLs are soon to be removed, along with this function.");

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
