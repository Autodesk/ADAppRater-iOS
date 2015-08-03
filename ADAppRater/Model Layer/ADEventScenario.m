//
//  EventScenario.m
//  ADAppRater
//
//  Created by Amir Shavit on 6/16/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import "ADEventScenario.h"

@interface ADEventScenario ()
@property (nonatomic, strong) NSArray* eventCriterias;
@end

@implementation ADEventScenario

- (instancetype)initWithEventCriterias:(NSArray*)eventCriterias
{
    self = [super init];
    if (self) {
        self.eventCriterias = eventCriterias;
    }
    return self;
}

- (BOOL)isValid
{
    return (self.eventCriterias.count > 0);
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    BOOL isEqual = NO;
    if ([object isKindOfClass:[self class]])
    {
        ADEventScenario* other = (ADEventScenario*)object;
        if (self.eventCriterias.count == other.eventCriterias.count)
        {
            isEqual = YES;
            for (ADEventCriteria* currCriteria in self.eventCriterias)
            {
                if (![other.eventCriterias containsObject:currCriteria])
                {
                    isEqual = NO;
                    break;
                }
            }
        }
    }
    return isEqual;
}

@end
