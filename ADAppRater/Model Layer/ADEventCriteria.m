//
//  EventCriteria.m
//  ADAppRating Demo
//
//  Created by Amir Shavit on 6/16/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import "ADEventCriteria.h"

@interface ADEventCriteria ()

/// TODO: Add support for more relationships / Operators
@property (nonatomic, strong) NSString* eventName;
@property (nonatomic) NSInteger eventCount;

@end

@implementation ADEventCriteria

- (instancetype)initWithEventName:(NSString*)eventName eventCount:(NSInteger)eventCount
{
    self = [super init];
    if (self)
    {
        self.eventName = eventName;
        self.eventCount = eventCount;
    }
    return self;
}

- (BOOL)isCreteriaFulfilled:(NSNumber*)registeredCount
{
    // First make sure event name is real
    if (self.eventName.length == 0)
    {
        return NO;
    }

    return (self.eventCount <= registeredCount.integerValue);
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    BOOL isEqual = NO;
    if ([object isKindOfClass:[self class]])
    {
        ADEventCriteria* other = (ADEventCriteria*)object;
        isEqual = ([self.eventName isEqual:other.eventName] &&
                   self.eventCount == other.eventCount);
    }
    return isEqual;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"ADEventCriteria.name = %@, minimum times = %d", self.eventName, (int)self.eventCount];
}

@end
