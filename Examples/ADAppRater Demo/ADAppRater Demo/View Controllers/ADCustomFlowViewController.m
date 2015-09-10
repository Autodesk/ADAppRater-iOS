//
//  ADCustomFlowViewController.m
//  ADAppRater Demo
//
//  Created by Amir Shavit on 6/11/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import "ADCustomFlowViewController.h"

@implementation ADCustomFlowViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    [ADAppRater sharedInstance].enableLog = YES;
    [ADAppRater sharedInstance].previewMode = YES;
    [ADAppRater sharedInstance].customViewsDelegate = self;

    // Insert your domain here to play with the demo:
    [ADAppRater sharedInstance].applicationBundleID = @"com.your.bundleid";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pressedStartFlowButton:(UIButton *)sender
{
    NSLog(@"pressedStartFlowButton");
    
    [[ADAppRater sharedInstance] startRaterFlowFromViewController:self];
}

- (IBAction)pressedStartFlowCriteriaCheck:(UIButton *)sender
{
    NSLog(@"pressedStartFlowCriteriaCheck");
    [[ADAppRater sharedInstance] setCurrentVersionDaysUntilPrompt:0];   
    [[ADAppRater sharedInstance] startRaterFlowIfCriteriaMetFromViewController:self];
}

#pragma mark - ADARCustomViewsDelegate

- (void)promptUserSatisfationAlertFromViewController:(UIViewController*)viewController
                                  userSatisfiedBlock:(ADAppRaterCustomViewBlock)userSatisfiedBlock
                               userNotSatisfiedBlock:(ADAppRaterCustomViewBlock)userNotSatisfiedBlock
{
    UIAlertController* userSatisfationAlert = [UIAlertController
                                               alertControllerWithTitle:@"Custom Satisfaction Alert"
                                               message:@"This was popped from the custom delegate. Do you like this?"
                                               preferredStyle:UIAlertControllerStyleAlert];
    [userSatisfationAlert addAction:[UIAlertAction
                                     actionWithTitle:@"Not at all :("
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                         userNotSatisfiedBlock();
                                     }]];
    [userSatisfationAlert addAction:[UIAlertAction
                                     actionWithTitle:@"This is GREAT!"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                         userSatisfiedBlock();
                                     }]];
    
    [viewController showViewController:userSatisfationAlert sender:self];
}

- (void)promptAppRatingAlertFromViewController:(UIViewController *)viewController
                           userWillRateAppBlock:(ADAppRaterCustomViewBlock)userWillRateAppBlock
                           remindUserLaterBlock:(ADAppRaterCustomViewBlock)remindUserLaterBlock
                               userRefusedBlock:(ADAppRaterCustomViewBlock)userRefusedBlock
{
    UIAlertController* userSatisfationAlert = [UIAlertController
                                               alertControllerWithTitle:@"Custom Rating Alert"
                                               message:@"This was popped from the custom delegate. Will you rate this app?"
                                               preferredStyle:UIAlertControllerStyleAlert];
    [userSatisfationAlert addAction:[UIAlertAction
                                     actionWithTitle:@"I'd love to RATE !!"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                         userWillRateAppBlock();
                                     }]];
    [userSatisfationAlert addAction:[UIAlertAction
                                     actionWithTitle:@"Maybe some other time"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                         remindUserLaterBlock();
                                     }]];
    [userSatisfationAlert addAction:[UIAlertAction
                                     actionWithTitle:@"I don't rate apps"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                         userRefusedBlock();
                                     }]];
    
    [viewController showViewController:userSatisfationAlert sender:self];
}

- (void)promptFeedbackRequestAlertFromViewController:(UIViewController*)viewController
                           userWillSendFeedbackBlock:(ADAppRaterCustomViewBlock)userWillSendFeedbackBlock
                        userWillNotSendFeedbackBlock:(ADAppRaterCustomViewBlock)userWillNotSendFeedbackBlock
{
    UIAlertController* feedbackRequestAlert = [UIAlertController
                                               alertControllerWithTitle:@"Custom Feedback Requst Alert"
                                               message:@"This was popped from the custom delegate. Please provide feedback"
                                               preferredStyle:UIAlertControllerStyleAlert];
    [feedbackRequestAlert addAction:[UIAlertAction
                                     actionWithTitle:@"Answer feedback"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                         userWillSendFeedbackBlock();
                                     }]];
    [feedbackRequestAlert addAction:[UIAlertAction
                                     actionWithTitle:@"No"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                         userWillNotSendFeedbackBlock();
                                     }]];
    
    [viewController showViewController:feedbackRequestAlert sender:self];
}

- (void)displayThankYouAlertFromViewController:(UIViewController*)viewController
                               completionBlock:(ADAppRaterCustomViewBlock)completion
{
    UIAlertController* feedbackRequestAlert = [UIAlertController
                                               alertControllerWithTitle:@"Custom Appreciation Alert"
                                               message:@"This was popped from the custom delegate. Show your appreciation to the user"
                                               preferredStyle:UIAlertControllerStyleAlert];
    [feedbackRequestAlert addAction:[UIAlertAction
                                     actionWithTitle:@"Cool"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                         completion();
                                     }]];
    
    [viewController showViewController:feedbackRequestAlert sender:self];
}

- (void)presentFeedbackFormFromViewController:(UIViewController*)viewController
                        userSentFeedbackBlock:(ADAppRaterCustomViewBlock)userSentFeedbackBlock
                  userDidNotSendFeedbackBlock:(ADAppRaterCustomViewBlock)userDidNotSendFeedbackBlock
{
    UIAlertController* feedbackRequestAlert = [UIAlertController
                                               alertControllerWithTitle:@"Custom Feedback Form Alert"
                                               message:@"This was popped from the custom delegate. Here you can open an email form or custom form."
                                               preferredStyle:UIAlertControllerStyleAlert];
    [feedbackRequestAlert addAction:[UIAlertAction
                                     actionWithTitle:@"User sent form"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                         userSentFeedbackBlock();
                                     }]];
    [feedbackRequestAlert addAction:[UIAlertAction
                                     actionWithTitle:@"User did not send form"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                         userDidNotSendFeedbackBlock();
                                     }]];
    
    [viewController showViewController:feedbackRequestAlert sender:self];
}


@end
