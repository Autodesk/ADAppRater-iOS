//
//  ADCustomFlowViewController.h
//  ADAppRater Demo
//
//  Created by Amir Shavit on 6/11/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADAppRater.h"

@interface ADCustomFlowViewController : UIViewController <ADARCustomViewsDelegate>

- (IBAction)pressedStartFlowButton:(UIButton *)sender;

@end
