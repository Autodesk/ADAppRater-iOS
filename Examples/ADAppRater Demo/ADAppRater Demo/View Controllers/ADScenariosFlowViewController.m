//
//  ADScenariosFlowViewController.m
//  ADAppRater Demo
//
//  Created by Amir Shavit on 6/17/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import "ADScenariosFlowViewController.h"

@interface ADScenariosFlowViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lblEventATitle;
@property (weak, nonatomic) IBOutlet UIButton *btnAddEventA;
@property (weak, nonatomic) IBOutlet UILabel *lblEventACount;

@property (weak, nonatomic) IBOutlet UILabel *lblEventBTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnAddEventB;
@property (weak, nonatomic) IBOutlet UILabel *lblEventBCount;

@property (weak, nonatomic) IBOutlet UILabel *lblEventCTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnAddEventC;
@property (weak, nonatomic) IBOutlet UILabel *lblEventCCount;

@end

@implementation ADScenariosFlowViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [ADAppRater sharedInstance].enableLog = YES;

    // Insert your domain here to play with the demo:
    [ADAppRater sharedInstance].applicationBundleID = @"com.clickgamer.AngryBirds";

    // Disable minimum days and sessions conditions
    [ADAppRater sharedInstance].currentVersionDaysUntilPrompt = 0;
    [ADAppRater sharedInstance].currentVersionLaunchesUntilPrompt = 0;
    
    // Define some scenarios to complete in order to prompt user rate:
    // First Scenario: 3 events of Type A
    ADEventCriteria* criteria1_3 = [[ADEventCriteria alloc] initWithEventName:self.lblEventATitle.text eventCount:3];
    ADEventScenario* scenario1 = [[ADEventScenario alloc] initWithEventCriterias:@[criteria1_3]];
    
    // Second Scenario: 3 events of Type B
    ADEventCriteria* criteria2_3 = [[ADEventCriteria alloc] initWithEventName:self.lblEventBTitle.text eventCount:3];
    ADEventScenario* scenario2 = [[ADEventScenario alloc] initWithEventCriterias:@[criteria2_3]];
    
    // Third Scenario: 3 events of Type C
    ADEventCriteria* criteria3_3 = [[ADEventCriteria alloc] initWithEventName:self.lblEventCTitle.text eventCount:3];
    ADEventScenario* scenario3 = [[ADEventScenario alloc] initWithEventCriterias:@[criteria3_3]];
    
    // Fourth Scenario: 1 event of each of the types
    ADEventCriteria* criteria1_1 = [[ADEventCriteria alloc] initWithEventName:self.lblEventATitle.text eventCount:1];
    ADEventCriteria* criteria2_1 = [[ADEventCriteria alloc] initWithEventName:self.lblEventBTitle.text eventCount:1];
    ADEventCriteria* criteria3_1 = [[ADEventCriteria alloc] initWithEventName:self.lblEventCTitle.text eventCount:1];
    ADEventScenario* scenario4 = [[ADEventScenario alloc] initWithEventCriterias:@[criteria1_1, criteria2_1, criteria3_1]];
    
    [ADAppRater sharedInstance].eventScenariosUntilPrompt = @[scenario1, scenario2, scenario3, scenario4];
    
    [self resetEvents:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pressedAddEventButton:(UIButton *)sender
{
    UILabel* eventCounter;
    NSString* eventName;
    if (sender == self.btnAddEventA)
    {
        eventCounter = self.lblEventACount;
        eventName = self.lblEventATitle.text;
    }
    else if (sender == self.btnAddEventB)
    {
        eventCounter = self.lblEventBCount;
        eventName = self.lblEventBTitle.text;
    }
    else if (sender == self.btnAddEventC)
    {
        eventCounter = self.lblEventCCount;
        eventName = self.lblEventCTitle.text;
    }
    
    [self incrementCounter:eventCounter];
    [[ADAppRater sharedInstance] registerEvent:eventName
                                  withViewController:self];
}

- (IBAction)resetEvents:(UIButton*)sender
{
    self.lblEventACount.text = @"0";
    self.lblEventBCount.text = @"0";
    self.lblEventCCount.text = @"0";
    
#ifdef DEBUG
    [[ADAppRater sharedInstance] resetUsageHistory];
#else
    NSLog(@"Reset function is not available outside DEBUG mode");
#endif
}

- (void)incrementCounter:(UILabel*)counter
{
    NSInteger count = counter.text.integerValue;
    counter.text = [NSString stringWithFormat:@"%d", (int)(count+1)];
}

#pragma mark - Flow

- (IBAction)unwindToScenariosFlowViewController:(UIStoryboardSegue *)segue
{
    //nothing goes here
}

@end
