//
//  ADEventCriteriaTests.m
//  ADAppRater Demo
//
//  Created by Amir Shavit on 6/16/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import "ADTestCase.h"
#import "ADEventCriteria.h"

@interface ADEventCriteriaTests : ADTestCase

@end

@implementation ADEventCriteriaTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testObjectInit
{
    // Arrange
    NSString* name = @"some name";
    NSInteger count = 98;
    
    // Act
    ADEventCriteria* criteria = [[ADEventCriteria alloc]
                                 initWithEventName:name eventCount:count];
    
    // Assert
    XCTAssertEqualObjects(criteria.eventName, name);
    XCTAssertEqual(criteria.eventCount, count);
}

#pragma mark - Is Equal

- (void)testIsCriteriasEqual_shouldReturnTrue
{
    // Arrange
    NSString* name = @"an event";
    NSInteger count = 98;
    ADEventCriteria* criteria1 = [[ADEventCriteria alloc]
                                 initWithEventName:name eventCount:count];
    ADEventCriteria* criteria2 = [[ADEventCriteria alloc]
                                  initWithEventName:name eventCount:(count)];
    
    // Act
    BOOL isEqual = [criteria1 isEqual:criteria2];
    
    // Assert
    XCTAssertTrue(isEqual);
}

- (void)testIsCriteriasEqual_shouldReturnFalse
{
    // Arrange
    NSString* name = @"an event";
    NSInteger count = 98;
    ADEventCriteria* criteria1 = [[ADEventCriteria alloc]
                                  initWithEventName:name eventCount:count];
    ADEventCriteria* criteria2 = [[ADEventCriteria alloc]
                                  initWithEventName:name eventCount:(count+1)];
    
    // Act
    BOOL isEqual = [criteria1 isEqual:criteria2];
    
    // Assert
    XCTAssertFalse(isEqual);
}

#pragma mark - Completions

- (void)testIsCriteriaComplete_eventNameIsNil_shouldReturnFalse
{
    // Arrange
    NSInteger count = 98;
    ADEventCriteria* criteria = [[ADEventCriteria alloc]
                                 initWithEventName:nil eventCount:count];
    
    // Act
    BOOL isComplete = [criteria isCreteriaFulfilled:@(count + 1)];
    
    // Assert
    XCTAssertFalse(isComplete);
}

- (void)testIsCriteriaComplete_eventNameIsEmpty_shouldReturnFalse
{
    // Arrange
    NSString* name = @"";
    NSInteger count = 98;
    ADEventCriteria* criteria = [[ADEventCriteria alloc]
                                 initWithEventName:name eventCount:count];
    
    // Act
    BOOL isComplete = [criteria isCreteriaFulfilled:@(count + 1)];
    
    // Assert
    XCTAssertFalse(isComplete);
}

- (void)testIsCriteriaComplete_notOccuredEnoughYet_shouldReturnFalse
{
    // Arrange
    NSString* name = @"an event";
    NSInteger count = 98;
    ADEventCriteria* criteria = [[ADEventCriteria alloc]
                                 initWithEventName:name eventCount:count];
    
    // Act
    BOOL isComplete = [criteria isCreteriaFulfilled:@(count - 1)];
    
    // Assert
    XCTAssertFalse(isComplete);
}

- (void)testIsCriteriaComplete_notOccuredAtAll_shouldReturnFalse
{
    // Arrange
    NSString* name = @"an event";
    NSInteger count = 98;
    ADEventCriteria* criteria = [[ADEventCriteria alloc]
                                 initWithEventName:name eventCount:count];
    
    // Act
    BOOL isComplete = [criteria isCreteriaFulfilled:nil];
    
    // Assert
    XCTAssertFalse(isComplete);
}

- (void)testIsCriteriaComplete_OccuredMoreThenMinimum_shouldReturnTrue
{
    // Arrange
    NSString* name = @"an event";
    NSInteger count = 98;
    ADEventCriteria* criteria = [[ADEventCriteria alloc]
                                 initWithEventName:name eventCount:count];
    
    // Act
    BOOL isComplete = [criteria isCreteriaFulfilled:@(count + 1)];
    
    // Assert
    XCTAssertTrue(isComplete);
}

- (void)testIsCriteriaComplete_OccuredExactTimesNeeded_shouldReturnTrue
{
    // Arrange
    NSString* name = @"an event";
    NSInteger count = 98;
    ADEventCriteria* criteria = [[ADEventCriteria alloc]
                                 initWithEventName:name eventCount:count];
    
    // Act
    BOOL isComplete = [criteria isCreteriaFulfilled:@(count)];
    
    // Assert
    XCTAssertTrue(isComplete);
}



@end
