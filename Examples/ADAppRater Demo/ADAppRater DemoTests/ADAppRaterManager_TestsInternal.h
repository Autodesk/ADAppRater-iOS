//
//  ADAppRaterManager_TestsInternal.h
//  ADAppRater Demo
//
//  Created by Amir Shavit on 6/11/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import "ADAppRater.h"

@interface ADAppRater ()

@property (nonatomic, strong) UIAlertController* currentAlert;

- (instancetype)initWithUserDefaults:(NSUserDefaults*)userDefaults appStoreConnector:(ADAppStoreConnector*)storeConnector;

- (void)startRaterFlowFromViewController:(__weak UIViewController*)viewController online:(BOOL)isOnline;
- (void)promptDirectRatingFromViewController:(__weak UIViewController*)viewController online:(BOOL)isOnline;

- (void)promptUserSatisfationAlertFromViewController:(__weak UIViewController*)viewController;
- (void)promptFeedbackRequestAlertFromViewController:(UIViewController*)viewController;
- (void)promptAppRatingAlertFromViewController:(UIViewController*)viewController;
- (void)displayThankYouAlertFromViewController:(UIViewController*)viewController;
- (void)presentFeedbackMailComposerFromViewController:(UIViewController*)viewController;

- (BOOL)isScenarioComplete:(ADEventScenario *)scenario eventList:(NSDictionary*)eventList;

#pragma mark User Rating Alert - User Response

- (void)userResponse_ratingAlert_rateApp;
- (void)userResponse_ratingAlert_remindRateApp;
- (void)userResponse_ratingAlert_declineRateApp;

#pragma mark Feedback Request Alert - User Response

- (void)userResponse_feedbackRequestAlert_sendFeedbackFromViewController:(UIViewController*)viewController;
- (void)userResponse_feedbackRequestAlert_declineFeedback;

@end
