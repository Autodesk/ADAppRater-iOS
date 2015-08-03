//
//  EventScenario.h
//  ADAppRater
//
//  Created by Amir Shavit on 6/16/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADEventCriteria.h"

/**
 *  Scenario in which the user should be prompted to rate the app.
 *  In order for te scenario to complete, a list of criterias should be met and fullfilled.
 *  @see ADEventCriteria
 */
@interface ADEventScenario : NSObject

/**
 *  List of criterias that define the scenario in which to prompt user to rate the app.
 *  @see ADEventCriteria
 */
@property (nonatomic, readonly) NSArray* eventCriterias;

- (instancetype)initWithEventCriterias:(NSArray*)eventCriterias;

- (BOOL)isValid;

@end
