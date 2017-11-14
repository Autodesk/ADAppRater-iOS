//
//  ADARCustomViewsDelegate.h
//  ADAppRater
//
//  Created by Amir Shavit on 6/11/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIViewController;

typedef void (^ADAppRaterCustomViewBlock)(void);

/**
 *  @brief `ADARCustomViewsDelegate` protocol defines methods to support presentation of custom views for the rating flow, instead of using the default iOS `UIAlertController` (or `UIAlertView`).
 *  @discussion These are called by the `ADAppRater` class according the the advancment of the rating flow.
 *  @discussion All protocol methods are optional.
 */
@protocol ADARCustomViewsDelegate <NSObject>

@optional

/**
 *  Tells the delegate the user should be asked if he is satisfied with the app.
 *  @discussion This is the first step of the rating flow. This is called to first check if the user likes the app. 
 *  @discussion Implement this method to provide a custom view or custom texts to check user satisfaction with the app. If you do not implement this method, the default UI and text will be used.
 *  @discussion Optional
 *  @param viewController        The current UIViewController that is to display the question UI
 *  @param userSatisfiedBlock    The custom view should call this block if the user answered he is satisfied with the app. This block continues the rating request flow.
 *  @param userNotSatisfiedBlock The custom view should call this block if the user answered he is not satisfied with the app. This block continues to request the user to send feedback (not to the store.
 */
- (void)promptUserSatisfationAlertFromViewController:(UIViewController*)viewController
                                  userSatisfiedBlock:(ADAppRaterCustomViewBlock)userSatisfiedBlock
                               userNotSatisfiedBlock:(ADAppRaterCustomViewBlock)userNotSatisfiedBlock;

/**
 *  Tells the delegate the user should be asked to rate the app on Apple's App Store.
 *  @discussion This is called when the user should be asked to rate the app.
 *  @discussion Implement this method to provide a custom view or custom texts to ask user to rate the app. If you do not implement this method, the default UI and text will be used.
 *  @discussion Optional
 *  @param viewController        The current UIViewController that is to display the question UI
 *  @param userWillRateAppBlock  The custom view should call this block if the user is willing to rate the app. This block continues the flow and opens the app's page on the app store.
 *  @param remindUserLaterBlock  The custom view should call this block if the user asked to be asked again later. This block end the flow for now, to start again on a different occasion.
 *  @param userRefusedBlock      The custom view should call this block if the user is not willing to rate the app. This block ends the flow.
 */
- (void)promptAppRatingAlertFromViewController:(UIViewController *)viewController
                           userWillRateAppBlock:(ADAppRaterCustomViewBlock)userWillRateAppBlock
                           remindUserLaterBlock:(ADAppRaterCustomViewBlock)remindUserLaterBlock
                               userRefusedBlock:(ADAppRaterCustomViewBlock)userRefusedBlock;

/**
 *  Tells the delegate the user should be requested to send feedback on the app.
 *  @discussion This is called if a user answered he is not satisfied with app.
 *  @discussion Implement this method to provide a custom view or custom texts to request the user to send feedback. If you do not implement this method, the default UI and text will be used.
 *  @discussion Optional
 *  @param viewController               The current UIViewController that is to display the question UI
 *  @param userWillSendFeedbackBlock    The custom view should call this block if the user answered he is willing to send us feedback. This block continues the flow to the feedback form.
 *  @param userWillNotSendFeedbackBlock The custom view should call this block if the user answered he is not willing to send us feedback. This block ends the flow.
 */
- (void)promptFeedbackRequestAlertFromViewController:(UIViewController*)viewController
                           userWillSendFeedbackBlock:(ADAppRaterCustomViewBlock)userWillSendFeedbackBlock
                        userWillNotSendFeedbackBlock:(ADAppRaterCustomViewBlock)userWillNotSendFeedbackBlock;

/**
 *  Tells the delegate the users has successfully finished sending us his feedback.
 *  @discussion This is called if a user has successfully sent his feedback.
 *  @discussion Implement this method to provide a custom view or custom texts to thank the user for his feedback. If you do not implement this method, the default UI and text will be used.
 *  @discussion Optional
 *  @param viewController  The current UIViewController that is to display the message to the user
 *  @param completion      The custom view should call this block after dismissing the message. This block ends the flow.
 */
- (void)displayThankYouAlertFromViewController:(UIViewController*)viewController
                               completionBlock:(ADAppRaterCustomViewBlock)completion;

/**
 *  Tells the delegate the user has agreed to send his feedback.
 *  @discussion This is called if a user has agreed to send feedback after answering his is not satisfied with the app.
 *  @discussion Implement this method to provide a custom form or custom texts for the feedback email/form. If you do not implement this method, the default email app will be used.
 *  @discussion Optional
 *  @param viewController              The current UIViewController that is to present the feedback form
 *  @param userSentFeedbackBlock       The custom view should call this block after the user has successfully sent his feedback. This block continues the flow to theank the user.
 *  @param userDidNotSendFeedbackBlock The custom form should call this block after user canceled the feedback form. This block ends the flow.
 */
- (void)presentFeedbackFormFromViewController:(UIViewController*)viewController
                        userSentFeedbackBlock:(ADAppRaterCustomViewBlock)userSentFeedbackBlock
                  userDidNotSendFeedbackBlock:(ADAppRaterCustomViewBlock)userDidNotSendFeedbackBlock;

@end
