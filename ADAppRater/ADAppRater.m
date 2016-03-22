//
//  ADAppRater.m
//  ADAppRater
//
//  Created by Amir Shavit on 6/10/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import "ADAppRater.h"
#import "ADAppStoreConnector.h"
#import "ADAlertViewRatingDelegate.h"

static NSString *const kADAppRaterLastVersionUsedKey = @"AD_AppRaterLastVersionUsed";
static NSString *const kADAppRaterVersionFirstUsedKey = @"AD_AppRaterVersionFirstUsed";
static NSString *const kADAppRaterVersionLaunchCountKey = @"AD_AppRaterVersionLaunchCount";
static NSString *const kADAppRaterVersionEventCountKey = @"AD_AppRaterVersionEventCount";
static NSString *const kADAppRaterLastRatedVersionKey = @"AD_AppRaterLastRatedVersion";
static NSString *const kADAppRaterLastDeclinedVersionKey = @"AD_AppRaterLastDeclinedVersion";
static NSString *const kADAppRaterLastPromptedKey = @"AD_AppRaterLastPromptedDate";
static NSString *const kADAppRaterLastRemindedKey = @"AD_AppRaterLastReminded";

#define SECONDS_IN_A_DAY 86400.0

@interface ADAppRater ()

@property (nonatomic, strong) NSUserDefaults* userDefaults;

@property (nonatomic, strong) UIAlertController* currentAlert;
@property (nonatomic, strong) ADAppStoreConnector* appStoreConnector;
@property (nonatomic, strong) ADAlertViewRatingDelegate* olderIosStyleDelegate;

// Extend Capabilities of public read only properties
@property (nonatomic, strong) NSDate *currentVersionFirstLaunch;
@property (nonatomic, strong) NSDate *userLastRemindedToRate;
@property (nonatomic, strong) NSDate *userLastPromptedToRate;
@property (nonatomic, strong) NSDictionary* persistEventCounters;
@property (nonatomic) NSUInteger currentVersionCountLaunches;

// Temp dictionary to hold old events found when version is updated - Hold to be saved again in session if needed
@property (nonatomic, strong) NSDictionary* tempOldVersionEventCounters;

@end

@implementation ADAppRater

static ADAppRater* sharedAppRater;
static dispatch_once_t once_token = 0;

// Singleton
+ (instancetype)sharedInstance
{
    // Only once
    dispatch_once(&once_token,
                  ^{
                      if (sharedAppRater == nil)
                      {
                          sharedAppRater = [ADAppRater new];
                      }
                  });
    
    return sharedAppRater;
}

- (instancetype)init
{
    return [self initWithUserDefaults:[NSUserDefaults standardUserDefaults]
                    appStoreConnector:nil];
}

/**
 *  Pass param objects as property to allow unit testing and mocking
 */
- (instancetype)initWithUserDefaults:(NSUserDefaults*)userDefaults appStoreConnector:(ADAppStoreConnector*)storeConnector
{
    self = [super init];
    if (self)
    {
        self.userDefaults = userDefaults;
        self.appStoreConnector = storeConnector;
        
        // Application version
        self.applicationVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        if ([self.applicationVersion length] == 0)
        {
            self.applicationVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
        }
        
        // Localised application name
        self.applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        if ([self.applicationName length] == 0)
        {
            self.applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
        }
        
        // Bundle Id
        self.applicationBundleID = [[NSBundle mainBundle] bundleIdentifier];
        
        [self setDefaultConfiguration];
        
        // Init default texts
        self.localStrings = [[ADAppRaterTexts alloc] initWithApplicationName:self.applicationName];

        // Check if this is a new version
        NSString *lastUsedVersion = [self.userDefaults objectForKey:kADAppRaterLastVersionUsedKey];
        if (!self.currentVersionFirstLaunch || ![lastUsedVersion isEqualToString:self.applicationVersion])
        {
            // Reset
            [self initCurrentVersionHistoryForceReset:NO];
            
            /// TODO: Inform about app update
//            [self.delegate appRateDidDetectAppUpdate];
//            [[NSNotificationCenter defaultCenter] postNotificationName:kADAppRaterDidDetectAppUpdate object:nil];
        }
        
        // Increment app launch
        self.currentVersionCountLaunches++;
    }
    return self;
}

#pragma mark Private Instanciation

- (void)setDefaultConfiguration
{
    self.currentVersionDaysUntilPrompt = 1;
    self.currentVersionLaunchesUntilPrompt = 3;
    self.remindWaitPeriod = 5;
    self.promptForNewVersionIfUserRated = NO;
    self.limitPromptFrequency = 30;
    self.enableLog = NO;

#ifdef DEBUG
    self.previewMode = NO;
#endif
}

- (void)initCurrentVersionHistoryForceReset:(BOOL)shouldForceReset
{
    // Copy events
    if (!shouldForceReset)
    {
        self.tempOldVersionEventCounters = [NSDictionary dictionaryWithDictionary:self.persistEventCounters];
    }
    
    [self.userDefaults setObject:self.applicationVersion forKey:kADAppRaterLastVersionUsedKey];
    [self.userDefaults setObject:[NSDate date] forKey:kADAppRaterVersionFirstUsedKey];
    [self.userDefaults setInteger:0 forKey:kADAppRaterVersionLaunchCountKey];
    
    // Reset reminders
    [self resetUserLastRemindedDate];
    
    [self.userDefaults removeObjectForKey:kADAppRaterVersionEventCountKey];
    
    [self.userDefaults synchronize];
}

#pragma mark - Setters

- (void)setPromptForNewVersionIfUserRated:(BOOL)promptForNewVersionIfUserRated
{
    _promptForNewVersionIfUserRated = promptForNewVersionIfUserRated;
    
    // Restore events from previous versions if applicable
    if (promptForNewVersionIfUserRated)
    {
        self.tempOldVersionEventCounters = nil;
    }
    else if (self.tempOldVersionEventCounters)
    {
        // Restore old events to continue count
        NSDictionary* merged = [self mergeEvents:self.persistEventCounters withEvents:self.tempOldVersionEventCounters];
        
        // Save back and reset
        self.persistEventCounters = merged;
        self.tempOldVersionEventCounters = nil;
    }
}

#pragma mark Getters

// Push applicationName to update strings too
-(void)setApplicationName:(NSString *)applicationName
{
    _applicationName = applicationName;
    self.localStrings.applicationName = applicationName;
}

- (NSDate *)currentVersionFirstLaunch
{
    return [self.userDefaults objectForKey:kADAppRaterVersionFirstUsedKey];
}

- (void)setCurrentVersionFirstLaunch:(NSDate *)date
{
    [self.userDefaults setObject:date forKey:kADAppRaterVersionFirstUsedKey];
    [self.userDefaults synchronize];
}

- (NSUInteger)currentVersionCountLaunches
{
    return [self.userDefaults integerForKey:kADAppRaterVersionLaunchCountKey];
}

- (void)setCurrentVersionCountLaunches:(NSUInteger)count
{
    [self.userDefaults setInteger:(NSInteger)count forKey:kADAppRaterVersionLaunchCountKey];
    [self.userDefaults synchronize];
}

- (NSDate *)userLastPromptedToRate
{
    return [self.userDefaults objectForKey:kADAppRaterLastPromptedKey];
}

- (void)setUserLastPromptedToRate:(NSDate *)date
{
    [self.userDefaults setObject:date forKey:kADAppRaterLastPromptedKey];
    [self.userDefaults synchronize];
}

- (NSDate *)userLastRemindedToRate
{
    return [self.userDefaults objectForKey:kADAppRaterLastRemindedKey];
}

- (void)setUserLastRemindedToRate:(NSDate *)date
{
    [self.userDefaults setObject:date forKey:kADAppRaterLastRemindedKey];
    [self.userDefaults synchronize];
}

- (NSDictionary *)persistEventCounters
{
    NSDictionary* dict = [self.userDefaults dictionaryForKey:kADAppRaterVersionEventCountKey];
    return (dict ? dict : [NSDictionary dictionary]);
}

- (void)setPersistEventCounters:(NSDictionary *)dict
{
    [self.userDefaults setObject:dict forKey:kADAppRaterVersionEventCountKey];
    [self.userDefaults synchronize];
}

- (BOOL)declinedThisVersion
{
    return [[self.userDefaults objectForKey:kADAppRaterLastDeclinedVersionKey]
            isEqualToString:self.applicationVersion];
}

- (void)setDeclinedThisVersion:(BOOL)declined
{
    [self.userDefaults setObject:(declined ? self.applicationVersion: nil)
                                              forKey:kADAppRaterLastDeclinedVersionKey];
    [self.userDefaults synchronize];
}

- (BOOL)declinedAnyVersion
{
    return [(NSString *)[self.userDefaults objectForKey:kADAppRaterLastDeclinedVersionKey] length] != 0;
}

- (BOOL)ratedThisVersion
{
    return [[self.userDefaults objectForKey:kADAppRaterLastRatedVersionKey]
            isEqualToString:self.applicationVersion];
}

- (void)setRatedThisVersion:(BOOL)rated
{
    [self.userDefaults setObject:(rated ? self.applicationVersion: nil)
                                              forKey:kADAppRaterLastRatedVersionKey];
    [self.userDefaults synchronize];
}

- (BOOL)ratedAnyVersion
{
    return [(NSString *)[self.userDefaults objectForKey:kADAppRaterLastRatedVersionKey] length] != 0;
}

#pragma mark Private Getters

- (ADAppStoreConnector *)appStoreConnector
{
    if (_appStoreConnector == nil)
    {
        _appStoreConnector = [ADAppStoreConnector new];
        _appStoreConnector.delegate = self.delegate;
        [_appStoreConnector setApplicationBundleID:self.applicationBundleID];        
    }
    return _appStoreConnector;
}

- (ADAlertViewRatingDelegate *)olderIosStyleDelegate
{
    if (_olderIosStyleDelegate == nil)
    {
        _olderIosStyleDelegate = [ADAlertViewRatingDelegate new];
    }
    return _olderIosStyleDelegate;
}

#pragma mark - Public Methods

- (void)startRaterFlowFromViewController:(__weak UIViewController*)viewController
{
    // First check if we're online
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        BOOL isOnline = [self.appStoreConnector isAppStoreAvailable];
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self startRaterFlowFromViewController:viewController online:isOnline];
        });
    });
}

- (void)startRaterFlowIfCriteriaMetFromViewController:(__weak UIViewController*)viewController
{
    if ([self shouldPromptForRating])
    {
        [self startRaterFlowFromViewController:viewController];
    }
}

- (void)registerEvent:(NSString*)eventName withViewController:(__weak UIViewController*)viewController
{
    [self registerEvent:eventName];
    [self startRaterFlowIfCriteriaMetFromViewController:viewController];
}

- (BOOL)shouldPromptForRating
{
#ifdef DEBUG
    // Preview mode?
    if (self.previewMode)
    {
        [ADAppRater AR_logConsole:@"Preview mode is enabled - make sure you disable this for release"];
        return YES;
    }
#endif
    
    // Check if we've rated this version
    if (self.ratedThisVersion)
    {
        [ADAppRater AR_logConsole:@"Did not start Rater because the user has already rated this version"];
        return NO;
    }
    
    // Check if we've rated any version
    else if (self.ratedAnyVersion && !self.promptForNewVersionIfUserRated)
    {
        [ADAppRater AR_logConsole:@"Did not start Rater because the user has already rated this app, and promptForNewVersionIfUserRated is disabled"];
        return NO;
    }
    
    // Check if we've declined to rate the app
    else if (self.declinedThisVersion ||
             (self.declinedAnyVersion && !self.promptForNewVersionIfUserRated))
    {
        [ADAppRater AR_logConsole:@"Did not start Rater because the user has declined to rate the app"];
        return NO;
    }
    
    // Check if user asked for a reminder
    else if (self.userLastRemindedToRate)
    {
        // Check if reminder period has passed or not
        NSDateComponents* delta = [[NSCalendar currentCalendar] components:NSCalendarUnitDay
                                                                  fromDate:self.userLastRemindedToRate
                                                                    toDate:[NSDate date]
                                                                   options:NSCalendarWrapComponents];
        
        if (delta.day >= self.remindWaitPeriod)
        {
            [ADAppRater AR_logConsole:@"Prompt without further conditions since the user asked to be remenided"];
            return YES;
        }
        else
        {
            [ADAppRater AR_logConsole:[NSString stringWithFormat:@"Did not start Rater because the user last asked to be reminded less than %i days ago",
                                       (int)self.remindWaitPeriod]];
            return NO;
        }
    }
    
    // Check if user should be prompted for each version, but with a rate limit
    else if (self.promptForNewVersionIfUserRated)
    {
        // Check if minimum frequency has passed yet
        NSDateComponents* delta = [[NSCalendar currentCalendar] components:NSCalendarUnitDay
                                                                 fromDate:self.userLastPromptedToRate
                                                                   toDate:[NSDate date]
                                                                  options:NSCalendarWrapComponents];
        if (delta.day < self.limitPromptFrequency)
        {
            [ADAppRater AR_logConsole:@"Did not start Rater because the user has declined to rate the app"];
            return NO;
        }
    }
    
    // Check how long we've been using this version
    else if ([[NSDate date] timeIntervalSinceDate:self.currentVersionFirstLaunch] < self.currentVersionDaysUntilPrompt * SECONDS_IN_A_DAY)
    {
        [ADAppRater AR_logConsole:[NSString stringWithFormat:@"Did not start Rater because the app was first used less than %d days ago", (int)self.currentVersionDaysUntilPrompt]];
        return NO;
    }
    
    // Check how many times we've used current version
    else if (self.currentVersionCountLaunches < self.currentVersionLaunchesUntilPrompt)
    {
        [ADAppRater AR_logConsole:[NSString stringWithFormat:@"Did not start Rater because the app has only been used %d times", (int)self.currentVersionCountLaunches]];
        return NO;
    }
    
    // Check if any scenario of significant events is completed
    else if (self.eventScenariosUntilPrompt.count > 0)
    {
        // Retrieve event dict
        NSDictionary* eventList = self.persistEventCounters;
        if (eventList.count == 0)
        {
            [ADAppRater AR_logConsole:@"No events have been logged yet"];
            return NO;
        }
        
        // Itterate over scenarios
        for (ADEventScenario* currScenario in self.eventScenariosUntilPrompt)
        {
            if ([self isScenarioComplete:currScenario eventList:eventList])
            {
                [ADAppRater AR_logConsole:@"Found a complete scenario! Lets start Rater!"];
                return YES;
            }
        }
        
        [ADAppRater AR_logConsole:[NSString stringWithFormat:@"None of the %d scenarios has been completed yet",
                                    (int)self.eventScenariosUntilPrompt.count]];
        return NO;
    }
    
    
    [ADAppRater AR_logConsole:@"All Crtieria met! Lets start Rater!"];
    return YES;
}

- (void)promptDirectRatingFromViewController:(UIViewController *__weak)viewController
{
    // First check if we're online
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       BOOL isOnline = [self.appStoreConnector isAppStoreAvailable];;
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          [self promptDirectRatingFromViewController:viewController online:isOnline];
                                      });
                   });
}

#ifdef DEBUG
- (void)resetUsageHistory
{
    [self initCurrentVersionHistoryForceReset:YES];
    
    [self.userDefaults removeObjectForKey:kADAppRaterLastDeclinedVersionKey];
    [self.userDefaults removeObjectForKey:kADAppRaterLastRatedVersionKey];
    [self.userDefaults synchronize];
}
#endif

#pragma mark - Display Alert

- (void)promptUserSatisfationAlertFromViewController:(__weak UIViewController*)viewController
{
    [self delegateSafeCall:@selector(appRaterWillPromptUserSatisfaction)];
    
    __weak ADAppRater* welf = self;
    ADAppRaterCustomViewBlock userSatisfiedBlock = ^()
    {
        [welf promptAppRatingAlertFromViewController:viewController];
    };

    ADAppRaterCustomViewBlock userNotSatisfiedBlock = ^()
    {
        welf.declinedThisVersion = YES;
        [welf promptFeedbackRequestAlertFromViewController:viewController];
    };

    if ([self.customViewsDelegate respondsToSelector:@selector(promptUserSatisfationAlertFromViewController:userSatisfiedBlock:userNotSatisfiedBlock:)])
    {
        [self.customViewsDelegate promptUserSatisfationAlertFromViewController:viewController
                                                       userSatisfiedBlock:userSatisfiedBlock
                                                       userNotSatisfiedBlock:userNotSatisfiedBlock];
    }
    else
    {
        if ([UIAlertController class])
        {
            UIAlertController* userSatisfationAlert = [UIAlertController
                                                       alertControllerWithTitle:self.localStrings.userSatisfactionAlertTitle
                                                       message:self.localStrings.userSatisfactionAlertMessage
                                                       preferredStyle:UIAlertControllerStyleAlert];
            [userSatisfationAlert addAction:[UIAlertAction
                                             actionWithTitle:self.localStrings.userSatisfactionAlertAnswerNo
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action)
                                             {
                                                 userNotSatisfiedBlock();
                                             }]];
            [userSatisfationAlert addAction:[UIAlertAction
                                             actionWithTitle:self.localStrings.userSatisfactionAlertAnswerYes
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action)
                                             {
                                                 userSatisfiedBlock();
                                             }]];
            
            [self presentAlert:userSatisfationAlert fromViewController:viewController];
        }
        else
        {
            // Compatibilty for iOS 7 and older
            [self.olderIosStyleDelegate promptUserSatisfationAlertFromViewController:viewController
                                                                               title:self.localStrings.userSatisfactionAlertTitle
                                                                             message:self.localStrings.userSatisfactionAlertMessage
                                                                satisfiedButtonTitle:self.localStrings.userSatisfactionAlertAnswerYes
                                                             notSatisfiedButtonTitle:self.localStrings.userSatisfactionAlertAnswerNo
                                                                  userSatisfiedBlock:userSatisfiedBlock
                                                               userNotSatisfiedBlock:userNotSatisfiedBlock];
        }
    }
}

- (void)promptAppRatingAlertFromViewController:(__weak UIViewController*)viewController
{
    self.currentAlert = nil;
    [self delegateSafeCall:@selector(appRaterWillPromptUserRating)];
    
    __weak ADAppRater* welf = self;
    ADAppRaterCustomViewBlock userWillRateAppBlock = ^()
    {
        [welf userResponse_ratingAlert_rateApp];
    };
    
    ADAppRaterCustomViewBlock remindUserLaterBlock = ^()
    {
        [welf userResponse_ratingAlert_remindRateApp];
    };
    
    ADAppRaterCustomViewBlock userRefusedBlock = ^()
    {
        [welf userResponse_ratingAlert_declineRateApp];
    };
    
    if ([self.customViewsDelegate respondsToSelector:@selector(promptAppRatingAlertFromViewController:userWillRateAppBlock:remindUserLaterBlock:userRefusedBlock:)])
    {
        [self.customViewsDelegate promptAppRatingAlertFromViewController:viewController
                                                     userWillRateAppBlock:userWillRateAppBlock
                                                     remindUserLaterBlock:remindUserLaterBlock
                                                         userRefusedBlock:userRefusedBlock];
    }
    else
    {
        if ([UIAlertController class])
        {
            UIAlertController* feedbackRequestAlert = [UIAlertController
                                                       alertControllerWithTitle:self.localStrings.appRatingAlertTitle
                                                       message:self.localStrings.appRatingAlertMessage
                                                       preferredStyle:UIAlertControllerStyleAlert];
            [feedbackRequestAlert addAction:[UIAlertAction
                                             actionWithTitle:self.localStrings.appRatingAlertAnswerRate
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action)
                                             {
                                                 userWillRateAppBlock();
                                             }]];
            [feedbackRequestAlert addAction:[UIAlertAction
                                             actionWithTitle:self.localStrings.appRatingAlertAnswerRemindMe
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action)
                                             {
                                                 remindUserLaterBlock();
                                             }]];
            [feedbackRequestAlert addAction:[UIAlertAction
                                             actionWithTitle:self.localStrings.appRatingAlertAnswerDontRate
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action)
                                             {
                                                 userRefusedBlock();
                                             }]];
            
            [self presentAlert:feedbackRequestAlert fromViewController:viewController];
        }
        else
        {
            // Compatibilty for iOS 7 and older
            [self.olderIosStyleDelegate promptAppRatingAlertFromViewController:viewController
                                                                         title:self.localStrings.appRatingAlertTitle
                                                                       message:self.localStrings.appRatingAlertMessage
                                                               rateButtonTitle:self.localStrings.appRatingAlertAnswerRate
                                                             remindButtonTitle:self.localStrings.appRatingAlertAnswerRemindMe
                                                             refuseButtonTitle:self.localStrings.appRatingAlertAnswerDontRate
                                                          userWillRateAppBlock:userWillRateAppBlock
                                                          remindUserLaterBlock:remindUserLaterBlock
                                                              userRefusedBlock:userRefusedBlock];
        }
    }
}

- (void)promptFeedbackRequestAlertFromViewController:(__weak UIViewController*)viewController
{
    self.currentAlert = nil;
    [self delegateSafeCall:@selector(appRaterWillPromptFeedbackRequest)];

    __weak ADAppRater* welf = self;
    ADAppRaterCustomViewBlock userWillSendFeedbackBlock = ^()
    {
        [welf userResponse_feedbackRequestAlert_sendFeedbackFromViewController:viewController];
    };
    
    ADAppRaterCustomViewBlock userWillNotSendFeedbackBlock = ^()
    {
        [welf userResponse_feedbackRequestAlert_declineFeedback];
    };
    
    if ([self.customViewsDelegate respondsToSelector:@selector(promptFeedbackRequestAlertFromViewController:userWillSendFeedbackBlock:userWillNotSendFeedbackBlock:)])
    {
        [self.customViewsDelegate promptFeedbackRequestAlertFromViewController:viewController
                                                     userWillSendFeedbackBlock:userWillSendFeedbackBlock
                                                  userWillNotSendFeedbackBlock:userWillNotSendFeedbackBlock];
    }
    else
    {
        if ([UIAlertController class])
        {
            UIAlertController* feedbackRequestAlert = [UIAlertController
                                                       alertControllerWithTitle:self.localStrings.userFeedbackAlertTitle
                                                       message:self.localStrings.userFeedbackAlertMessage
                                                       preferredStyle:UIAlertControllerStyleAlert];
            [feedbackRequestAlert addAction:[UIAlertAction
                                             actionWithTitle:self.localStrings.userFeedbackAlertAnswerYes
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action)
                                             {
                                                 userWillSendFeedbackBlock();
                                             }]];
            [feedbackRequestAlert addAction:[UIAlertAction
                                             actionWithTitle:self.localStrings.userFeedbackAlertAnswerNo
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action)
                                             {
                                                 userWillNotSendFeedbackBlock();
                                             }]];
            
            [self presentAlert:feedbackRequestAlert fromViewController:viewController];
        }
        else
        {
            // Compatibilty for iOS 7 and older
            [self.olderIosStyleDelegate promptFeedbackRequestAlertFromViewController:viewController
                                                                               title:self.localStrings.userFeedbackAlertTitle
                                                                             message:self.localStrings.userFeedbackAlertMessage
                                                                     sendButtonTitle:self.localStrings.userFeedbackAlertAnswerYes
                                                                  declineButtonTitle:self.localStrings.userFeedbackAlertAnswerNo
                                                           userWillSendFeedbackBlock:userWillSendFeedbackBlock
                                                        userWillNotSendFeedbackBlock:userWillNotSendFeedbackBlock];
        }
    }
}

- (void)displayThankYouAlertFromViewController:(__weak UIViewController*)viewController
{
    self.currentAlert = nil;
    [self delegateSafeCall:@selector(appRaterWillDisplayThankYouAlert)];

    ADAppRaterCustomViewBlock completionBlock = ^()
    {
        [ADAppRater AR_logConsole:@"ThankYouAlert completionBlock"];
    };
    
    if ([self.customViewsDelegate respondsToSelector:@selector(displayThankYouAlertFromViewController:completionBlock:)])
    {
        [self.customViewsDelegate displayThankYouAlertFromViewController:viewController
                                                         completionBlock:completionBlock];
    }
    else
    {
        if ([UIAlertController class])
        {
            UIAlertController* thanksAlert = [UIAlertController
                                              alertControllerWithTitle:self.localStrings.thankUserAlertTitle
                                              message:self.localStrings.thankUserAlertMessage
                                              preferredStyle:UIAlertControllerStyleAlert];
            [thanksAlert addAction:[UIAlertAction
                                    actionWithTitle:self.localStrings.thankUserAlertDismiss
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action)
                                    {
                                        completionBlock();
                                    }]];
            
            [self presentAlert:thanksAlert fromViewController:viewController];
        }
        else
        {
            // Compatibilty for iOS 7 and older
            [self.olderIosStyleDelegate displayThankYouAlertFromViewController:viewController
                                                                         title:self.localStrings.thankUserAlertTitle
                                                                       message:self.localStrings.thankUserAlertMessage
                                                            dismissButtonTitle:self.localStrings.thankUserAlertDismiss
                                                               completionBlock:completionBlock];
        }
    }
}

#pragma mark User Rating Alert - User Response

- (void)userResponse_ratingAlert_rateApp
{
    [self delegateSafeCall:@selector(appRaterUserDidAgreeToRateApp)];
    self.ratedThisVersion = YES;
    [self.appStoreConnector openRatingsPageInAppStore];
}

- (void)userResponse_ratingAlert_remindRateApp
{
    [self delegateSafeCall:@selector(appRaterUserDidRequestReminderToRateApp)];
    self.userLastRemindedToRate = [NSDate date];
}

- (void)userResponse_ratingAlert_declineRateApp
{
    [self delegateSafeCall:@selector(appRaterUserDidDeclineToRateApp)];
    self.declinedThisVersion = YES;
}

#pragma mark Feedback Request Alert - User Response

- (void)userResponse_feedbackRequestAlert_sendFeedbackFromViewController:(__weak UIViewController*)viewController
{
    [ADAppRater AR_logConsole:@"FeedbackRequest positiveBlock"];
    [self delegateSafeCall:@selector(appRaterUserDidAgreeToSendFeedback)];
    [self presentFeedbackMailComposerFromViewController:viewController];
}

- (void)userResponse_feedbackRequestAlert_declineFeedback
{
    [ADAppRater AR_logConsole:@"FeedbackRequest negativeBlock"];
    [self delegateSafeCall:@selector(appRaterUserDidDeclineToSendFeedback)];
}

#pragma mark - Mail Compose ViewController

- (void)presentFeedbackMailComposerFromViewController:(__weak UIViewController*)viewController
{
    self.currentAlert = nil;
    
    __weak ADAppRater* welf = self;
    ADAppRaterCustomViewBlock userSentFeedbackBlock = ^()
    {
        [welf displayThankYouAlertFromViewController:viewController];
    };

    ADAppRaterCustomViewBlock userDidNotSendFeedbackBlock = ^()
    {
        [ADAppRater AR_logConsole:@"User canceled feedback sending"];
    };

    if ([self.customViewsDelegate respondsToSelector:@selector(presentFeedbackFormFromViewController:userSentFeedbackBlock:userDidNotSendFeedbackBlock:)])
    {
        [self.customViewsDelegate presentFeedbackFormFromViewController:viewController
                                                  userSentFeedbackBlock:userSentFeedbackBlock
                                            userDidNotSendFeedbackBlock:userDidNotSendFeedbackBlock];
    }
    else
    {
        if ([MFMailComposeViewController canSendMail])
        {
            // Setup mail composer view
            MFMailComposeViewController* mailComposer = [[MFMailComposeViewController alloc] init];
            mailComposer.mailComposeDelegate = self;            
            [mailComposer setSubject:self.localStrings.feedbackFormSubject];
            [mailComposer setMessageBody:self.localStrings.feedbackFormBody isHTML:NO];
            
            if (self.localStrings.feedbackFormRecipient)
            {
                [mailComposer setToRecipients:@[self.localStrings.feedbackFormRecipient]];
            }
            else
            {
                [ADAppRater AR_logConsole:@"WARNING!! No email address provided for feedback form recipient!!"];
            }
            
            [viewController presentViewController:mailComposer animated:YES completion:nil];
        }
        else
        {
            /// TODO: Add an error message
            [ADAppRater AR_logConsole:@"Could not send email from this device"];
        }
    }
}

#pragma mark Mail Compose Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    void (^dismissCompletion)();
    
    if (result == MFMailComposeResultSent)
    {
        UIViewController* baseVC = controller.presentingViewController;
        dismissCompletion = ^()
        {
            [self displayThankYouAlertFromViewController:baseVC];
        };
    }
    
    // Dismiss composer
    [controller dismissViewControllerAnimated:YES completion:dismissCompletion];
}

#pragma mark - Private Helpers

- (void)startRaterFlowFromViewController:(__weak UIViewController*)viewController online:(BOOL)isOnline
{
    if (isOnline)
    {
        // Make sure originating VC is still alive and visible
        if (viewController == nil)
        {
            [ADAppRater AR_logConsole:@"Can't start rating flow since originating ViewController was released"];
        }
        else if (viewController.presentedViewController != nil ||
                 (viewController.navigationController != nil && viewController.navigationController.topViewController != viewController))
        {
            [ADAppRater AR_logConsole:@"Can't start rating flow since originating ViewController is not visible"];
        }
        else
        {
            [self resetUserLastRemindedDate];
            self.userLastPromptedToRate = [NSDate date];
            
            [self promptUserSatisfationAlertFromViewController:viewController];
        }
    }
    else
    {
        [ADAppRater AR_logConsole:@"Can't start rating flow since in offline mode"];
    }
}

- (void)promptDirectRatingFromViewController:(__weak UIViewController*)viewController online:(BOOL)isOnline
{
    if (isOnline)
    {
        // Make sure originating VC is still alive and visible
        if (viewController == nil)
        {
            [ADAppRater AR_logConsole:@"Can't prompt rating flow since originating ViewController was released"];
        }
        else if (viewController.presentedViewController != nil ||
                 viewController.navigationController.topViewController != viewController)
        {
            [ADAppRater AR_logConsole:@"Can't prompt rating flow since originating ViewController is not visible"];
        }
        else
        {
            [self resetUserLastRemindedDate];
            self.userLastPromptedToRate = [NSDate date];
            
            [self promptAppRatingAlertFromViewController:viewController];
        }
    }
    else
    {
        [ADAppRater AR_logConsole:@"Can't prompt rating flow since in offline mode"];
    }
}

- (void)presentAlert:(UIAlertController*)alertController fromViewController:(__weak UIViewController*)viewController
{
    [viewController presentViewController:alertController animated:YES completion:nil];
    self.currentAlert = alertController;
}

- (void)resetUserLastRemindedDate
{
    [self.userDefaults removeObjectForKey:kADAppRaterLastRemindedKey];
}

- (NSDictionary*)mergeEvents:(NSDictionary*)events1 withEvents:(NSDictionary*)events2
{
    // Restore old events to continue count
    NSMutableDictionary* merged = events2.mutableCopy;
    
    for (NSString* ev in events1.allKeys)
    {
        NSNumber* val1 = events1[ev];
        if ([events2.allKeys containsObject:ev])
        {
            NSNumber* val2 = events2[ev];
            merged[ev] = @(val1.integerValue + val2.integerValue);
        }
        else
        {
            merged[ev] = val1;
        }
    }
    return merged;
}

- (void)registerEvent:(NSString*)eventName
{
    NSInteger counter = [self countForEvent:eventName];
    [self setCount:++counter forEvent:eventName];
}

- (NSInteger)countForEvent:(NSString*)eventName
{
    NSNumber* countNumber = [self.persistEventCounters objectForKey:eventName];
    return countNumber.integerValue;
}

- (void)setCount:(NSInteger)count forEvent:(NSString*)eventName
{
    NSMutableDictionary* events = self.persistEventCounters.mutableCopy;
    [events setValue:@(count) forKey:eventName];
    self.persistEventCounters = events;
}

- (BOOL)isScenarioComplete:(ADEventScenario *)scenario eventList:(NSDictionary*)eventList
{
    BOOL isScenarioComplete = YES;
    
    // First make sure scenaio is not empty
    if ([scenario isValid])
    {
        // Check each criteria in scenario
        for (ADEventCriteria* currCriteria in scenario.eventCriterias)
        {
            NSNumber* num = [eventList objectForKey:currCriteria.eventName];
            if (![currCriteria isCreteriaFulfilled:num])
            {
                isScenarioComplete = NO;
                break;
            }
        }
    }
    else
    {
        isScenarioComplete = NO;
    }
    
    return isScenarioComplete;
}

- (void)delegateSafeCall:(SEL)selector
{
    if ([self.delegate respondsToSelector:selector])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.delegate performSelector:selector];
#pragma clang diagnostic pop
    }
    else
    {
        [ADAppRater AR_logConsole:[NSString stringWithFormat:@"Delegate does not implement %@ method", NSStringFromSelector(selector)]];
    }
}

#pragma mark -

+ (void)AR_logConsole:(NSString*)message
{
    if (sharedAppRater.enableLog)
    {
        NSString* logM = [NSString stringWithFormat:@"%@: %@", NSStringFromClass([self class]), message];
        if ([sharedAppRater.delegate respondsToSelector:@selector(appRaterLogToConsole:)])
        {
            [sharedAppRater.delegate appRaterLogToConsole:message];
        }
        else
        {
            NSLog(@"%@", logM);
        }
    }
}

@end
