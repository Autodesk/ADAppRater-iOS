//
//  ADAlertViewRatingDelegate.h
//  ADAppRating Demo
//
//  Created by Amir Shavit on 6/14/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADARCustomViewsDelegate.h"

@interface ADAlertViewRatingDelegate : NSObject

- (void)promptUserSatisfationAlertFromViewController:(UIViewController*)viewController
                                               title:(NSString*)title
                                             message:(NSString*)message
                                satisfiedButtonTitle:(NSString*)positiveButton
                             notSatisfiedButtonTitle:(NSString*)negativeButton
                                  userSatisfiedBlock:(ADCustomRatingViewCompletionBlock)userSatisfiedBlock
                               userNotSatisfiedBlock:(ADCustomRatingViewCompletionBlock)userNotSatisfiedBlock;

- (void)promptUserRatingAlertFromViewController:(UIViewController*)viewController
                                          title:(NSString*)title
                                        message:(NSString*)message
                                rateButtonTitle:(NSString*)positiveButton
                              remindButtonTitle:(NSString*)remindButton
                              refuseButtonTitle:(NSString*)refuseButton
                           userWillRateAppBlock:(ADCustomRatingViewCompletionBlock)userWillRateAppBlock
                           remindUserLaterBlock:(ADCustomRatingViewCompletionBlock)remindUserLaterBlock
                               userRefusedBlock:(ADCustomRatingViewCompletionBlock)userRefusedBlock;

- (void)promptFeedbackRequestAlertFromViewController:(UIViewController*)viewController
                                               title:(NSString*)title
                                             message:(NSString*)message
                                     sendButtonTitle:(NSString*)positiveButton
                                  declineButtonTitle:(NSString*)negativeButton
                           userWillSendFeedbackBlock:(ADCustomRatingViewCompletionBlock)userWillSendFeedbackBlock
                        userWillNotSendFeedbackBlock:(ADCustomRatingViewCompletionBlock)userWillNotSendFeedbackBlock;

- (void)displayThankYouAlertFromViewController:(UIViewController*)viewController
                                         title:(NSString*)title
                                       message:(NSString*)message
                            dismissButtonTitle:(NSString*)dismissButton
                               completionBlock:(ADCustomRatingViewCompletionBlock)completion;

@end
