//
//  ADEventScenarioTests.m
//  ADAppRater Demo
//
//  Created by Amir Shavit on 6/16/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import "ADTestCase.h"
#import "ADEventScenario.h"

@interface ADEventScenarioTests : ADTestCase

@end

@implementation ADEventScenarioTests

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

- (void)testObjectInit_withOneCriteria
{
    // Arrange
    NSString* name1 = @"some name";
    NSInteger count1 = 98;
    ADEventCriteria* criteria1 = [[ADEventCriteria alloc] initWithEventName:name1 eventCount:count1];
    NSArray* criterias = @[criteria1];
    
    // Act
    ADEventScenario* scenario = [[ADEventScenario alloc] initWithEventCriterias:criterias];
    
    // Assert
    XCTAssertEqualObjects(scenario.eventCriterias, criterias);
    XCTAssertEqual(scenario.eventCriterias.count, 1);
}

- (void)testObjectInit_withTwoCriteria
{
    // Arrange
    NSString* name1 = @"some name";
    NSInteger count1 = 98;
    ADEventCriteria* criteria1 = [[ADEventCriteria alloc] initWithEventName:name1 eventCount:count1];

    NSString* name2 = @"another name";
    NSInteger count2 = 145;
    ADEventCriteria* criteria2 = [[ADEventCriteria alloc] initWithEventName:name2 eventCount:count2];
    NSArray* criterias = @[criteria1, criteria2];
    
    // Act
    ADEventScenario* scenario = [[ADEventScenario alloc] initWithEventCriterias:criterias];
    
    // Assert
    XCTAssertEqualObjects(scenario.eventCriterias, criterias);
    XCTAssertEqual(scenario.eventCriterias.count, 2);
}

#pragma mark - Is Equal

- (void)testIsScenarioEqual_shouldReturnTrue
{
    // Arrange
    NSString* name1 = @"some name";
    NSInteger count1 = 98;
    ADEventCriteria* criteria1 = [[ADEventCriteria alloc] initWithEventName:name1 eventCount:count1];
    
    NSString* name2 = @"another name";
    NSInteger count2 = 145;
    ADEventCriteria* criteria2 = [[ADEventCriteria alloc] initWithEventName:name2 eventCount:count2];
   
    ADEventScenario* scenario1 = [[ADEventScenario alloc] initWithEventCriterias:@[criteria1, criteria2]];
    ADEventScenario* scenario2 = [[ADEventScenario alloc] initWithEventCriterias:@[criteria2, criteria1]];

    // Act
    BOOL isEqual = [scenario1 isEqual:scenario2];
    
    // Assert
    XCTAssertTrue(isEqual);
}

- (void)testIsScenarioEqual_similiarScenario_shouldReturnFalse
{
    // Arrange
    NSString* name1 = @"some name";
    NSInteger count1 = 98;
    ADEventCriteria* criteria1 = [[ADEventCriteria alloc] initWithEventName:name1 eventCount:count1];
    
    NSString* name2 = @"another name";
    NSInteger count2 = 145;
    ADEventCriteria* criteria2 = [[ADEventCriteria alloc] initWithEventName:name2 eventCount:count2];
    
    ADEventScenario* scenario1 = [[ADEventScenario alloc] initWithEventCriterias:@[criteria1, criteria2]];
    ADEventScenario* scenario2 = [[ADEventScenario alloc] initWithEventCriterias:@[criteria2]];
    
    // Act
    BOOL isEqual = [scenario1 isEqual:scenario2];
    
    // Assert
    XCTAssertFalse(isEqual);
}

- (void)testIsScenarioEqual_shouldReturnFalse
{
    // Arrange
    NSString* name1 = @"some name";
    NSInteger count1 = 98;
    ADEventCriteria* criteria1 = [[ADEventCriteria alloc] initWithEventName:name1 eventCount:count1];
    
    NSString* name2 = @"another name";
    NSInteger count2 = 145;
    ADEventCriteria* criteria2 = [[ADEventCriteria alloc] initWithEventName:name2 eventCount:count2];
    
    ADEventScenario* scenario1 = [[ADEventScenario alloc] initWithEventCriterias:@[criteria1]];
    ADEventScenario* scenario2 = [[ADEventScenario alloc] initWithEventCriterias:@[criteria2]];
    
    // Act
    BOOL isEqual = [scenario1 isEqual:scenario2];
    
    // Assert
    XCTAssertFalse(isEqual);
}

@end
