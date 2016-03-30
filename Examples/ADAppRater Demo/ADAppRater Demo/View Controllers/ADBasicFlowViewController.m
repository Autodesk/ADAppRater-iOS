//
//  ADBasicFlowViewController.m
//  ADAppRater Demo
//
//  Created by Amir Shavit on 6/10/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import "ADBasicFlowViewController.h"

@implementation ADBasicFlowViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    [ADAppRater sharedInstance].enableLog = YES;
		[ADAppRater sharedInstance].previewMode = YES;

    // Insert your domain here to play with the demo:
    [ADAppRater sharedInstance].applicationBundleID = @"com.clickgamer.AngryBirds";
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
    [ADAppRater sharedInstance].currentVersionDaysUntilPrompt = 0;
    [ADAppRater sharedInstance].currentVersionLaunchesUntilPrompt = 0;
    [[ADAppRater sharedInstance] startRaterFlowIfCriteriaMetFromViewController:self];
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
