//
//  ADAlertViewRatingDelegate.m
//  ADAppRater
//
//  Created by Amir Shavit on 6/14/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import "ADAlertViewRatingDelegate.h"
#import <UIKit/UIKit.h>

#define kAlertTagUserSatisfaction 951
#define kAlertTagFeedbackRequestAlert 952
#define kAlertTagThankYouAlert 953
#define kAlertTagRateAppAlert 954

@interface ADAlertViewRatingDelegate () <UIAlertViewDelegate>

@property (nonatomic, copy) ADAppRaterCustomViewBlock positiveBlock;
@property (nonatomic, copy) ADAppRaterCustomViewBlock negativeBlock;
@property (nonatomic, copy) ADAppRaterCustomViewBlock otherCompletionBlock;

@end

@implementation ADAlertViewRatingDelegate

- (void)promptUserSatisfationAlertFromViewController:(UIViewController*)viewController
                                               title:(NSString*)title
                                             message:(NSString*)message
                                satisfiedButtonTitle:(NSString*)positiveButton
                             notSatisfiedButtonTitle:(NSString*)negativeButton
                                  userSatisfiedBlock:(ADAppRaterCustomViewBlock)userSatisfiedBlock
                               userNotSatisfiedBlock:(ADAppRaterCustomViewBlock)userNotSatisfiedBlock
{
    self.positiveBlock = userSatisfiedBlock;
    self.negativeBlock = userNotSatisfiedBlock;
    
    UIAlertView* userSatisfationAlert = [self alertViewWithTitle:title message:message buttons:@[negativeButton, positiveButton]];
    userSatisfationAlert.tag = kAlertTagUserSatisfaction;
    [userSatisfationAlert show];
}

- (void)promptAppRatingAlertFromViewController:(UIViewController*)viewController
                                          title:(NSString*)title
                                        message:(NSString*)message
                                rateButtonTitle:(NSString*)positiveButton
                              remindButtonTitle:(NSString*)remindButton
                              refuseButtonTitle:(NSString*)refuseButton
                           userWillRateAppBlock:(ADAppRaterCustomViewBlock)userWillRateAppBlock
                           remindUserLaterBlock:(ADAppRaterCustomViewBlock)remindUserLaterBlock
                               userRefusedBlock:(ADAppRaterCustomViewBlock)userRefusedBlock
{
    self.positiveBlock = userWillRateAppBlock;
    self.otherCompletionBlock = remindUserLaterBlock;
    self.negativeBlock = userRefusedBlock;
    
    UIAlertView* ratingRequestAlert = [self alertViewWithTitle:title message:message buttons:@[positiveButton, remindButton, refuseButton]];
    ratingRequestAlert.tag = kAlertTagRateAppAlert;
    ratingRequestAlert.cancelButtonIndex = 2;
    [ratingRequestAlert show];
}

- (void)promptFeedbackRequestAlertFromViewController:(UIViewController*)viewController
                                               title:(NSString*)title
                                             message:(NSString*)message
                                     sendButtonTitle:(NSString*)positiveButton
                                  declineButtonTitle:(NSString*)negativeButton
                           userWillSendFeedbackBlock:(ADAppRaterCustomViewBlock)userWillSendFeedbackBlock
                        userWillNotSendFeedbackBlock:(ADAppRaterCustomViewBlock)userWillNotSendFeedbackBlock
{
    self.positiveBlock = userWillSendFeedbackBlock;
    self.negativeBlock = userWillNotSendFeedbackBlock;
    
    UIAlertView* feedbackRequestAlert = [self alertViewWithTitle:title message:message buttons:@[negativeButton, positiveButton]];
    feedbackRequestAlert.tag = kAlertTagFeedbackRequestAlert;
    [feedbackRequestAlert show];
}

- (void)displayThankYouAlertFromViewController:(UIViewController*)viewController
                                         title:(NSString*)title
                                       message:(NSString*)message
                            dismissButtonTitle:(NSString*)dismissButton
                               completionBlock:(ADAppRaterCustomViewBlock)completion
{
    self.positiveBlock = completion;
    
    UIAlertView* thankYouAlert = [self alertViewWithTitle:title message:message buttons:@[dismissButton]];
    thankYouAlert.tag = kAlertTagThankYouAlert;
    [thankYouAlert show];
}

#pragma mark - UIAlertView Initializer

- (UIAlertView*)alertViewWithTitle:(NSString*)title
                           message:(NSString*)message
                           buttons:(NSArray*)buttons
{
    UIAlertView* alertView = [[UIAlertView alloc]
                                         initWithTitle:title
                                         message:message
                                         delegate:self
                                         cancelButtonTitle:nil
                                         otherButtonTitles:nil];
    for (NSString* btn in buttons)
    {
        [alertView addButtonWithTitle:btn];
    }
    return alertView;
}


#pragma mark - Invoke Alert Blocks

- (void)dismissedUserSatisfactionAlertWithButton:(NSInteger)index
{
    
    if (index == 1)
    {
        if (self.positiveBlock)
            self.positiveBlock();
    }
    else
    {
        if (self.negativeBlock)
            self.negativeBlock();
    }
    
    self.negativeBlock = nil;
    self.positiveBlock = nil;
}

- (void)dismissedRateRequestAlertWithButton:(NSInteger)index
{
    if (index == 0)
    {
        if (self.positiveBlock)
            self.positiveBlock();
    }
    else if (index == 1)
    {
        if (self.otherCompletionBlock)
            self.otherCompletionBlock();
    }
    else
    {
        if (self.negativeBlock)
            self.negativeBlock();
    }
    
    self.positiveBlock = nil;
    self.otherCompletionBlock = nil;
    self.negativeBlock = nil;
}

- (void)dismissedFeedbackRequestAlertWithButton:(NSInteger)index
{
    if (index == 1)
    {
        if (self.positiveBlock)
            self.positiveBlock();
    }
    else
    {
        if (self.negativeBlock)
            self.negativeBlock();
    }
    
    self.negativeBlock = nil;
    self.positiveBlock = nil;
}

- (void)dismissedThankYouAlertWithButton:(NSInteger)index
{
    if (self.positiveBlock)
        self.positiveBlock();

    self.positiveBlock = nil;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case kAlertTagUserSatisfaction:
        {
            [self dismissedUserSatisfactionAlertWithButton:buttonIndex];
            break;
        }
            
        case kAlertTagRateAppAlert:
        {
            [self dismissedRateRequestAlertWithButton:buttonIndex];
            break;
        }
            
        case kAlertTagFeedbackRequestAlert:
        {
            [self dismissedFeedbackRequestAlertWithButton:buttonIndex];
            break;
        }
            
        case kAlertTagThankYouAlert:
        {
            [self dismissedThankYouAlertWithButton:buttonIndex];
            break;
        }
            
        default:
            break;
    }
}


@end
