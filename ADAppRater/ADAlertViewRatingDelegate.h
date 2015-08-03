//
//  ADAlertViewRatingDelegate.h
//  ADAppRater
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
                                  userSatisfiedBlock:(ADAppRaterCustomViewBlock)userSatisfiedBlock
                               userNotSatisfiedBlock:(ADAppRaterCustomViewBlock)userNotSatisfiedBlock;

- (void)promptAppRatingAlertFromViewController:(UIViewController*)viewController
                                          title:(NSString*)title
                                        message:(NSString*)message
                                rateButtonTitle:(NSString*)positiveButton
                              remindButtonTitle:(NSString*)remindButton
                              refuseButtonTitle:(NSString*)refuseButton
                           userWillRateAppBlock:(ADAppRaterCustomViewBlock)userWillRateAppBlock
                           remindUserLaterBlock:(ADAppRaterCustomViewBlock)remindUserLaterBlock
                               userRefusedBlock:(ADAppRaterCustomViewBlock)userRefusedBlock;

- (void)promptFeedbackRequestAlertFromViewController:(UIViewController*)viewController
                                               title:(NSString*)title
                                             message:(NSString*)message
                                     sendButtonTitle:(NSString*)positiveButton
                                  declineButtonTitle:(NSString*)negativeButton
                           userWillSendFeedbackBlock:(ADAppRaterCustomViewBlock)userWillSendFeedbackBlock
                        userWillNotSendFeedbackBlock:(ADAppRaterCustomViewBlock)userWillNotSendFeedbackBlock;

- (void)displayThankYouAlertFromViewController:(UIViewController*)viewController
                                         title:(NSString*)title
                                       message:(NSString*)message
                            dismissButtonTitle:(NSString*)dismissButton
                               completionBlock:(ADAppRaterCustomViewBlock)completion;

@end
