//
//  ADAppRating.m
//  ADAppRating
//
//  Created by Amir Shavit on 6/10/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import "ADAppRating.h"
#import "ADAppStoreConnector.h"
#import "ADAlertViewRatingDelegate.h"

static NSString *const kADAppRatingLastVersionUsedKey = @"AD_AppRatingLastVersionUsed";
static NSString *const kADAppRatingVersionFirstUsedKey = @"AD_AppRatingVersionFirstUsed";
static NSString *const kADAppRatingVersionLaunchCountKey = @"AD_AppRatingVersionLaunchCount";
static NSString *const kADAppRatingVersionEventCountKey = @"AD_AppRatingVersionEventCount";
static NSString *const kADAppRatingLastRatedVersionKey = @"AD_AppRatingLastRatedVersion";
static NSString *const kADAppRatingLastDeclinedVersionKey = @"AD_AppRatingLastDeclinedVersion";
static NSString *const kADAppRatingLastRemindedKey = @"AD_AppRatingLastReminded";

#define SECONDS_IN_A_DAY 86400.0

@interface ADAppRating ()

@property (nonatomic, strong) NSUserDefaults* userDefaults;

@property (nonatomic, strong) UIAlertController* currentAlert;
@property (nonatomic, strong) ADAppStoreConnector* appStoreConnector;
@property (nonatomic, strong) ADAlertViewRatingDelegate* olderIosStyleDelegate;
@property (nonatomic, strong) ADAppRatingTexts* localStrings;

// Extend Capabilities of public read only properties
@property (nonatomic, strong) NSDate *currentVersionFirstLaunch;
@property (nonatomic, strong) NSDate *currentVersionLastReminded;
@property (nonatomic, strong) NSDictionary* persistEventCounters;
@property (nonatomic) NSUInteger currentVersionCountLaunches;

@end

@implementation ADAppRating

static ADAppRating* sharedAppRating;
static dispatch_once_t once_token = 0;

// Singleton
+ (instancetype)sharedInstance
{
    // Only once
    dispatch_once(&once_token,
                  ^{
                      if (sharedAppRating == nil)
                      {
                          sharedAppRating = [ADAppRating new];
                      }
                  });
    
    return sharedAppRating;
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
        self.localStrings = [[ADAppRatingTexts alloc] initWithApplicationName:self.applicationName];

        // Check if this is a new version
        NSString *lastUsedVersion = [self.userDefaults objectForKey:kADAppRatingLastVersionUsedKey];
        if (!self.currentVersionFirstLaunch || ![lastUsedVersion isEqualToString:self.applicationVersion])
        {
            // Reset
            [self initCurrentVersionHistory];
            
            /// TODO: Inform about app update
//            [self.delegate appRateDidDetectAppUpdate];
//            [[NSNotificationCenter defaultCenter] postNotificationName:kADAppRatingDidDetectAppUpdate object:nil];
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
    self.enableLog = NO;

#ifdef DEBUG
    self.previewMode = NO;
#endif
}

- (void)initCurrentVersionHistory
{
    [self.userDefaults setObject:self.applicationVersion forKey:kADAppRatingLastVersionUsedKey];
    [self.userDefaults setObject:[NSDate date] forKey:kADAppRatingVersionFirstUsedKey];
    [self.userDefaults setInteger:0 forKey:kADAppRatingVersionLaunchCountKey];
    
    // Reset reminders
    [self.userDefaults removeObjectForKey:kADAppRatingLastRemindedKey];
    [self.userDefaults removeObjectForKey:kADAppRatingVersionEventCountKey];
    
    [self.userDefaults synchronize];
}

#pragma mark - Getters

// Push applicationName to update strings too
-(void)setApplicationName:(NSString *)applicationName
{
    _applicationName = applicationName;
    self.localStrings.applicationName = applicationName;
}

- (NSDate *)currentVersionFirstLaunch
{
    return [self.userDefaults objectForKey:kADAppRatingVersionFirstUsedKey];
}

- (void)setCurrentVersionFirstLaunch:(NSDate *)date
{
    [self.userDefaults setObject:date forKey:kADAppRatingVersionFirstUsedKey];
    [self.userDefaults synchronize];
}

- (NSUInteger)currentVersionCountLaunches
{
    return [self.userDefaults integerForKey:kADAppRatingVersionLaunchCountKey];
}

- (void)setCurrentVersionCountLaunches:(NSUInteger)count
{
    [self.userDefaults setInteger:(NSInteger)count forKey:kADAppRatingVersionLaunchCountKey];
    [self.userDefaults synchronize];
}

- (NSDate *)currentVersionLastReminded
{
    return [self.userDefaults objectForKey:kADAppRatingLastRemindedKey];
}

- (void)setCurrentVersionLastReminded:(NSDate *)date
{
    [self.userDefaults setObject:date forKey:kADAppRatingLastRemindedKey];
    [self.userDefaults synchronize];
}

- (NSDictionary *)persistEventCounters
{
    NSDictionary* dict = [self.userDefaults dictionaryForKey:kADAppRatingVersionEventCountKey];
    return (dict ? dict : [NSDictionary dictionary]);
}

- (void)setPersistEventCounters:(NSDictionary *)dict
{
    [self.userDefaults setObject:dict forKey:kADAppRatingVersionEventCountKey];
    [self.userDefaults synchronize];
}

- (BOOL)declinedThisVersion
{
    return [[self.userDefaults objectForKey:kADAppRatingLastDeclinedVersionKey]
            isEqualToString:self.applicationVersion];
}

- (void)setDeclinedThisVersion:(BOOL)declined
{
    [self.userDefaults setObject:(declined ? self.applicationVersion: nil)
                                              forKey:kADAppRatingLastDeclinedVersionKey];
    [self.userDefaults synchronize];
}

- (BOOL)declinedAnyVersion
{
    return [(NSString *)[self.userDefaults objectForKey:kADAppRatingLastDeclinedVersionKey] length] != 0;
}

- (BOOL)ratedThisVersion
{
    return [[self.userDefaults objectForKey:kADAppRatingLastRatedVersionKey]
            isEqualToString:self.applicationVersion];
}

- (void)setRatedThisVersion:(BOOL)rated
{
    [self.userDefaults setObject:(rated ? self.applicationVersion: nil)
                                              forKey:kADAppRatingLastRatedVersionKey];
    [self.userDefaults synchronize];
}

- (BOOL)ratedAnyVersion
{
    return [(NSString *)[self.userDefaults objectForKey:kADAppRatingLastRatedVersionKey] length] != 0;
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

- (void)startRatingFlowFromViewController:(__weak UIViewController*)viewController
{
    // First check if we're online
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        BOOL isOnline = [self.appStoreConnector isAppStoreAvailable];;
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self startRatingFlowFromViewController:viewController online:isOnline];
        });
    });
}

- (void)startRatingFlowIfCriteriaMetFromViewController:(__weak UIViewController*)viewController
{
    if ([self shouldPromptForRating])
    {
        [self startRatingFlowFromViewController:viewController];
    }
}

- (void)registerEvent:(NSString*)eventName withViewController:(__weak UIViewController*)viewController
{
    [self registerEvent:eventName];
    [self startRatingFlowIfCriteriaMetFromViewController:viewController];
}

- (BOOL)shouldPromptForRating
{
#ifdef DEBUG
    // Preview mode?
    if (self.previewMode)
    {
        [ADAppRating AR_logConsole:@"Preview mode is enabled - make sure you disable this for release"];
        return YES;
    }
#endif
    
    // Check if we've rated this version
    if (self.ratedThisVersion)
    {
        [ADAppRating AR_logConsole:@"Did not prompt for rating because the user has already rated this version"];
        return NO;
    }
    
    // Check if we've rated any version
    else if (self.ratedAnyVersion && !self.promptForNewVersionIfUserRated)
    {
        [ADAppRating AR_logConsole:@"Did not prompt for rating because the user has already rated this app, and promptForNewVersionIfUserRated is disabled"];
        return NO;
    }
    
    // Check if we've declined to rate the app
    else if (self.declinedThisVersion ||
             (self.declinedAnyVersion && !self.promptForNewVersionIfUserRated))
    {
        [ADAppRating AR_logConsole:@"Did not prompt for rating because the user has declined to rate the app"];
        return NO;
    }
    
    // Check how long we've been using this version
    else if ([[NSDate date] timeIntervalSinceDate:self.currentVersionFirstLaunch] < self.currentVersionDaysUntilPrompt * SECONDS_IN_A_DAY)
    {
        [ADAppRating AR_logConsole:[NSString stringWithFormat:@"Did not prompt for rating because the app was first used less than %d days ago", (int)self.currentVersionDaysUntilPrompt]];
        return NO;
    }
    
    // Check how many times we've used current version
    else if (self.currentVersionCountLaunches < self.currentVersionLaunchesUntilPrompt)
    {
        [ADAppRating AR_logConsole:[NSString stringWithFormat:@"Did not prompt for rating because the app has only been used %d times", (int)self.currentVersionCountLaunches]];
        return NO;
    }
    
    // Check if within the reminder period
    else if (self.currentVersionLastReminded &&
             [[NSDate date] timeIntervalSinceDate:self.currentVersionLastReminded] < self.remindWaitPeriod * SECONDS_IN_A_DAY)
    {
        [ADAppRating AR_logConsole:[NSString stringWithFormat:@"Did not prompt for rating because the user last asked to be reminded less than %i days ago",
                          (int)self.remindWaitPeriod]];
        return NO;
    }
    
    // Check if any scenario of significant events is completed
    else if (self.eventScenariosUntilPrompt.count > 0)
    {
        // Retrieve event dict
        NSDictionary* eventList = self.persistEventCounters;
        if (eventList.count == 0)
        {
            [ADAppRating AR_logConsole:@"No events have been logged yet"];
            return NO;
        }
        
        // Itterate over scenarios
        for (ADEventScenario* currScenario in self.eventScenariosUntilPrompt)
        {
            if ([self isScenarioComplete:currScenario eventList:eventList])
            {
                [ADAppRating AR_logConsole:@"Found a complete scenario! Lets prompt!"];
                return YES;
            }
        }
        
        [ADAppRating AR_logConsole:[NSString stringWithFormat:@"None of the %d scenarios has been completed yet",
                                    (int)self.eventScenariosUntilPrompt.count]];
        return NO;
    }
    
    
    [ADAppRating AR_logConsole:@"All Crtieria met! Lets prompt!"];
    return YES;
}

- (void)promptDirectAppRatingFromViewController:(UIViewController *__weak)viewController
{
    // First check if we're online
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       BOOL isOnline = [self.appStoreConnector isAppStoreAvailable];;
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          [self promptDirectAppRatingFromViewController:viewController online:isOnline];
                                      });
                   });
}

#ifdef DEBUG
- (void)resetUsageHistory
{
    [self initCurrentVersionHistory];
    
    [self.userDefaults removeObjectForKey:kADAppRatingLastDeclinedVersionKey];
    [self.userDefaults removeObjectForKey:kADAppRatingLastRatedVersionKey];
    [self.userDefaults synchronize];
}
#endif

#pragma mark - Display Alert

- (void)promptUserSatisfationAlertFromViewController:(__weak UIViewController*)viewController
{
    [self delegateSafeCall:@selector(appRateWillPromptUserSatisfaction)];
    
    __weak ADAppRating* welf = self;
    ADCustomRatingViewCompletionBlock userSatisfiedBlock = ^()
    {
        [welf promptUserRatingAlertFromViewController:viewController];
    };

    ADCustomRatingViewCompletionBlock userNotSatisfiedBlock = ^()
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

- (void)promptUserRatingAlertFromViewController:(__weak UIViewController*)viewController
{
    self.currentAlert = nil;
    [self delegateSafeCall:@selector(appRateWillPromptUserRating)];
    
    __weak ADAppRating* welf = self;
    ADCustomRatingViewCompletionBlock userWillRateAppBlock = ^()
    {
        [welf userResponse_ratingAlert_rateApp];
    };
    
    ADCustomRatingViewCompletionBlock remindUserLaterBlock = ^()
    {
        [welf userResponse_ratingAlert_remindRateApp];
    };
    
    ADCustomRatingViewCompletionBlock userRefusedBlock = ^()
    {
        [welf userResponse_ratingAlert_declineRateApp];
    };
    
    if ([self.customViewsDelegate respondsToSelector:@selector(promptUserRatingAlertFromViewController:userWillRateAppBlock:remindUserLaterBlock:userRefusedBlock:)])
    {
        [self.customViewsDelegate promptUserRatingAlertFromViewController:viewController
                                                     userWillRateAppBlock:userWillRateAppBlock
                                                     remindUserLaterBlock:remindUserLaterBlock
                                                         userRefusedBlock:userRefusedBlock];
    }
    else
    {
        if ([UIAlertController class])
        {
            UIAlertController* feedbackRequestAlert = [UIAlertController
                                                       alertControllerWithTitle:self.localStrings.userRatingAlertTitle
                                                       message:self.localStrings.userRatingAlertMessage
                                                       preferredStyle:UIAlertControllerStyleAlert];
            [feedbackRequestAlert addAction:[UIAlertAction
                                             actionWithTitle:self.localStrings.userRatingAlertAnswerRate
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action)
                                             {
                                                 userWillRateAppBlock();
                                             }]];
            [feedbackRequestAlert addAction:[UIAlertAction
                                             actionWithTitle:self.localStrings.userRatingAlertAnswerRemindMe
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action)
                                             {
                                                 remindUserLaterBlock();
                                             }]];
            [feedbackRequestAlert addAction:[UIAlertAction
                                             actionWithTitle:self.localStrings.userRatingAlertAnswerDontRate
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
            [self.olderIosStyleDelegate promptUserRatingAlertFromViewController:viewController
                                                                          title:self.localStrings.userRatingAlertTitle
                                                                        message:self.localStrings.userRatingAlertMessage
                                                                rateButtonTitle:self.localStrings.userRatingAlertAnswerRate
                                                              remindButtonTitle:self.localStrings.userRatingAlertAnswerRemindMe
                                                              refuseButtonTitle:self.localStrings.userRatingAlertAnswerDontRate
                                                           userWillRateAppBlock:userWillRateAppBlock
                                                           remindUserLaterBlock:remindUserLaterBlock
                                                               userRefusedBlock:userRefusedBlock];
        }
    }
}

- (void)promptFeedbackRequestAlertFromViewController:(__weak UIViewController*)viewController
{
    self.currentAlert = nil;
    [self delegateSafeCall:@selector(appRateWillPromptFeedbackRequest)];

    __weak ADAppRating* welf = self;
    ADCustomRatingViewCompletionBlock userWillSendFeedbackBlock = ^()
    {
        [welf userResponse_feedbackRequestAlert_sendFeedbackFromViewController:viewController];
    };
    
    ADCustomRatingViewCompletionBlock userWillNotSendFeedbackBlock = ^()
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
    [self delegateSafeCall:@selector(appRateWillDisplayThankYouAlert)];

    ADCustomRatingViewCompletionBlock completionBlock = ^()
    {
        [ADAppRating AR_logConsole:@"ThankYouAlert completionBlock"];
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
    [self delegateSafeCall:@selector(appRateUserDidAgreeToRateApp)];
    self.ratedThisVersion = YES;
    [self.appStoreConnector openRatingsPageInAppStore];
}

- (void)userResponse_ratingAlert_remindRateApp
{
    [self delegateSafeCall:@selector(appRateUserDidRequestReminderToRateApp)];
    self.currentVersionLastReminded = [NSDate date];
}

- (void)userResponse_ratingAlert_declineRateApp
{
    [self delegateSafeCall:@selector(appRateUserDidDeclineToRateApp)];
    self.declinedThisVersion = YES;
}

#pragma mark Feedback Request Alert - User Response

- (void)userResponse_feedbackRequestAlert_sendFeedbackFromViewController:(__weak UIViewController*)viewController
{
    [ADAppRating AR_logConsole:@"FeedbackRequest positiveBlock"];
    [self delegateSafeCall:@selector(appRateUserDidAgreeToSendFeedback)];
    [self presentFeedbackMailComposerFromViewController:viewController];
}

- (void)userResponse_feedbackRequestAlert_declineFeedback
{
    [ADAppRating AR_logConsole:@"FeedbackRequest negativeBlock"];
    [self delegateSafeCall:@selector(appRateUserDidDeclineToSendFeedback)];
}

#pragma mark - Mail Compose ViewController

- (void)presentFeedbackMailComposerFromViewController:(__weak UIViewController*)viewController
{
    self.currentAlert = nil;
    
    __weak ADAppRating* welf = self;
    ADCustomRatingViewCompletionBlock userSentFeedbackBlock = ^()
    {
        [welf displayThankYouAlertFromViewController:viewController];
    };

    ADCustomRatingViewCompletionBlock userDidNotSendFeedbackBlock = ^()
    {
        [ADAppRating AR_logConsole:@"User canceled feedback sending"];
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
                [ADAppRating AR_logConsole:@"WARNING!! No email address provided for feedback form recipient!!"];
            }
            
            [viewController presentViewController:mailComposer animated:YES completion:nil];
        }
        else
        {
            /// TODO: Add an error message
            [ADAppRating AR_logConsole:@"Could not send email from this device"];
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

- (void)startRatingFlowFromViewController:(__weak UIViewController*)viewController online:(BOOL)isOnline
{
    if (isOnline)
    {
        // Make sure originating VC is still alive and visible
        if (viewController == nil)
        {
            [ADAppRating AR_logConsole:@"Can't start rating flow since originating ViewController was released"];
        }
        else if (viewController.presentedViewController != nil ||
                 viewController.navigationController.topViewController != viewController)
        {
            [ADAppRating AR_logConsole:@"Can't start rating flow since originating ViewController is not visible"];
        }
        else
        {
            [self promptUserSatisfationAlertFromViewController:viewController];
        }
    }
    else
    {
        [ADAppRating AR_logConsole:@"Can't start rating flow since in offline mode"];
    }
}

- (void)promptDirectAppRatingFromViewController:(__weak UIViewController*)viewController online:(BOOL)isOnline
{
    if (isOnline)
    {
        // Make sure originating VC is still alive and visible
        if (viewController == nil)
        {
            [ADAppRating AR_logConsole:@"Can't prompt rating flow since originating ViewController was released"];
        }
        else if (viewController.presentedViewController != nil ||
                 viewController.navigationController.topViewController != viewController)
        {
            [ADAppRating AR_logConsole:@"Can't prompt rating flow since originating ViewController is not visible"];
        }
        else
        {
            [self promptUserRatingAlertFromViewController:viewController];
        }
    }
    else
    {
        [ADAppRating AR_logConsole:@"Can't prompt rating flow since in offline mode"];
    }
}

- (void)presentAlert:(UIAlertController*)alertController fromViewController:(__weak UIViewController*)viewController
{
    [viewController presentViewController:alertController animated:YES completion:nil];
    self.currentAlert = alertController;
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
        [ADAppRating AR_logConsole:[NSString stringWithFormat:@"Delegate does not implement %@ method", NSStringFromSelector(selector)]];
    }
}

#pragma mark -

+ (void)AR_logConsole:(NSString*)message
{
    if (sharedAppRating.enableLog)
    {
        NSString* logM = [NSString stringWithFormat:@"%@: %@", NSStringFromClass([self class]), message];
        if ([sharedAppRating.delegate respondsToSelector:@selector(appRateLogToConsole:)])
        {
            [sharedAppRating.delegate appRateLogToConsole:message];
        }
        else
        {
            NSLog(@"%@", logM);
        }
    }
}

@end
