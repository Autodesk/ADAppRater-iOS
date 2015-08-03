//
//  EventCriteria.h
//  ADAppRater
//
//  Created by Amir Shavit on 6/16/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  A single criteria that describes one term that should be completed before the user should be prompted to rate the app.
 *  This criteria is part of a bigger scenraio of criteria.
 *  @see ADEventScenario
 */
@interface ADEventCriteria : NSObject

@property (nonatomic, readonly) NSString* eventName;
@property (nonatomic, readonly) NSInteger eventCount;

- (instancetype)initWithEventName:(NSString*)eventName eventCount:(NSInteger)eventCount;

- (BOOL)isCreteriaFulfilled:(NSNumber*)registeredCount;

@end
