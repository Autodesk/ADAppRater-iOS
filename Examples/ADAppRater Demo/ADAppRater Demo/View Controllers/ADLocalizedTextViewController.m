//
//  ADLocalizedTextViewController.m
//  ADAppRater Demo
//
//  Created by Amir Shavit on 9/10/15.
//  Copyright © 2015 Autodesk. All rights reserved.
//

#import "ADLocalizedTextViewController.h"

@implementation ADLocalizedTextViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    [ADAppRater sharedInstance].enableLog = YES;
    [ADAppRater sharedInstance].previewMode = YES;
    
    // Insert your domain here to play with the demo:
    [ADAppRater sharedInstance].applicationBundleID = @"com.your.bundleid";
    
    [self localizeAppRaterStrings];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)localizeAppRaterStrings
{
    ADAppRaterTexts* raterStrings = [ADAppRater sharedInstance].localStrings;
    
    raterStrings.userSatisfactionAlertTitle = @"Add a localized title here";
    raterStrings.userSatisfactionAlertMessage = @"Localize asking the user if he likes the app";
    raterStrings.userSatisfactionAlertAnswerYes = @"Local Yes";
    raterStrings.userSatisfactionAlertAnswerNo = @"Local No";
    
    // You can also localize the rest of the strings all or some of them
    
//    raterStrings.appRatingAlertTitlel
//    raterStrings.appRatingAlertMessage;
//    raterStrings.appRatingAlertAnswerRate;
//    raterStrings.appRatingAlertAnswerRemindMe;
//    raterStrings.appRatingAlertAnswerDontRate;
    
//    raterStrings.userFeedbackAlertTitle;
//    raterStrings.userFeedbackAlertMessage;
//    raterStrings.userFeedbackAlertAnswerYes;
//    raterStrings.userFeedbackAlertAnswerNo;
    
//    raterStrings.thankUserAlertTitle;
//    raterStrings.thankUserAlertMessage;
//    raterStrings.thankUserAlertDismiss;
    
//    raterStrings.feedbackFormRecipient;
//    raterStrings.feedbackFormSubject;
//    raterStrings.feedbackFormBody;
}

- (IBAction)pressedStartFlowButton:(UIButton *)sender
{
    NSLog(@"pressedStartFlowButton");
    
    [[ADAppRater sharedInstance] startRaterFlowFromViewController:self];
}

- (IBAction)pressedResetRatingHistory:(UIButton *)sender
{
#ifdef DEBUG
    [[ADAppRater sharedInstance] resetUsageHistory];
#else
    NSLog(@"Reset function is not available outside DEBUG mode");
#endif
}

@end
