//
//  ADAppRaterManagerTests.m
//  ADAppRater Demo
//
//  Created by Amir Shavit on 6/11/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import "ADARManagerBaseTestCase.h"
#import "ADAppRaterManager_TestsInternal.h"
#import "ADEventScenario.h"

#define SECONDS_IN_A_DAY 86400.0

@interface ADAppRaterManagerTests : ADARManagerBaseTestCase

@end

@implementation ADAppRaterManagerTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

#pragma mark - App Rater Version

- (void)testAppRaterVersion_shouldReturnConstSameAsPlist
{
    // Arrange
    NSString* plistVersion = [[NSBundle bundleForClass:[ADAppRater class]] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];

    // Assert
    XCTAssertEqualObjects([ADAppRater appRaterVersion], plistVersion);
}

#pragma mark - Should Prompt - Criteria Tests

#ifdef DEBUG
- (void)testShouldPromptForRating_previewMode_shouldReturnTrue
{
    // Arrange
    self.raterManager.previewMode = YES;
    
    // Act
    BOOL shouldPrompt = [self.raterManager shouldPromptForRating];
    
    // Assert
    XCTAssertTrue(shouldPrompt);
}
#endif

#pragma mark User Previously Responded

- (void)testShouldPromptForRating_ratedThisVersoin_shouldReturnFalse
{
    // Arrange
    OCMStub([self.mockUserDefaults objectForKey:@"AD_AppRaterLastRatedVersion"]).andReturn(self.raterManager.applicationVersion);
    
    // Make sure the min usage is met
    self.raterManager.currentVersionDaysUntilPrompt = 0;
    self.raterManager.currentVersionLaunchesUntilPrompt = 0;
    
    // Act
    BOOL shouldPrompt = [self.raterManager shouldPromptForRating];
    
    // Assert
    XCTAssertFalse(shouldPrompt);
}

- (void)testShouldPromptForRating_ratedAnyVersoin_shouldReturnFalse
{
    // Arrange
    OCMStub([self.mockUserDefaults objectForKey:@"AD_AppRaterLastRatedVersion"]).andReturn(@"someVersion");
    
    // Make sure the min usage is met
    self.raterManager.currentVersionDaysUntilPrompt = 0;
    self.raterManager.currentVersionLaunchesUntilPrompt = 0;
    
    // Act
    BOOL shouldPrompt = [self.raterManager shouldPromptForRating];
    
    // Assert
    XCTAssertFalse(shouldPrompt);
}

- (void)testShouldPromptForRating_ratedAnyVersoinWithPromptForNewVersion_passedFrequent_shouldReturnTrue
{
    // Arrange
    NSInteger frequncyLimit = 30;
    NSDate *lastPrompted = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay
                                                                    value:-(frequncyLimit + 5)
                                                                   toDate:[NSDate date]
                                                                  options:kNilOptions];
    
    self.raterManager.promptForNewVersionIfUserRated = YES;
    OCMStub([self.mockUserDefaults objectForKey:@"AD_AppRaterLastRatedVersion"]).andReturn(@"someVersion");
    OCMStub([self.mockUserDefaults objectForKey:@"AD_AppRaterLastPromptedDate"]).andReturn(lastPrompted);
    
    // Make sure the min usage is met
    self.raterManager.limitPromptFrequency = frequncyLimit;
    self.raterManager.currentVersionDaysUntilPrompt = 0;
    self.raterManager.currentVersionLaunchesUntilPrompt = 0;
    
    // Act
    BOOL shouldPrompt = [self.raterManager shouldPromptForRating];
    
    // Assert
    XCTAssertTrue(shouldPrompt);
}

- (void)testShouldPromptForRating_neverRatedAnyVersoinWithPromptForNewVersion_shouldReturnTrue
{
    // Arrange
    self.raterManager.promptForNewVersionIfUserRated = YES;
    
    // Make sure the min usage is met
    self.raterManager.currentVersionDaysUntilPrompt = 0;
    self.raterManager.currentVersionLaunchesUntilPrompt = 0;
    
    // Act
    BOOL shouldPrompt = [self.raterManager shouldPromptForRating];
    
    // Assert
    XCTAssertTrue(shouldPrompt);
}

#pragma mark App Usage Stats

- (void)testShouldPromptForRating_usedLongerThenMinDaysRequired_shouldReturnTrue
{
    // Arrange
    NSInteger minDays = 3;
    NSDate* first = [NSDate dateWithTimeIntervalSinceNow:(-(minDays+1) * SECONDS_IN_A_DAY)];
    self.raterManager.currentVersionDaysUntilPrompt = minDays;
    OCMStub([self.mockUserDefaults objectForKey:@"AD_AppRaterVersionFirstUsed"]).andReturn(first);
    
    // Make sure the min launch usage is met
    self.raterManager.currentVersionLaunchesUntilPrompt = 0;
    
    // Act
    BOOL shouldPrompt = [self.raterManager shouldPromptForRating];
    
    // Assert
    XCTAssertTrue(shouldPrompt);
}

- (void)testShouldPromptForRating_useExactDaysRequired_shouldReturnTrue
{
    // Arrange
    NSInteger minDays = 3;
    NSDate* first = [NSDate dateWithTimeIntervalSinceNow:(-minDays * SECONDS_IN_A_DAY)];
    self.raterManager.currentVersionDaysUntilPrompt = minDays;
    OCMStub([self.mockUserDefaults objectForKey:@"AD_AppRaterVersionFirstUsed"]).andReturn(first);
    
    // Make sure the min launch usage is met
    self.raterManager.currentVersionLaunchesUntilPrompt = 0;
    
    // Act
    BOOL shouldPrompt = [self.raterManager shouldPromptForRating];
    
    // Assert
    XCTAssertTrue(shouldPrompt);
}

- (void)testShouldPromptForRating_usedLessThenMinDaysRequired_shouldReturnFalse
{
    // Arrange
    NSInteger minDays = 3;
    NSDate* first = [NSDate dateWithTimeIntervalSinceNow:(-(minDays - 1) * SECONDS_IN_A_DAY)];
    self.raterManager.currentVersionDaysUntilPrompt = minDays;
    OCMStub([self.mockUserDefaults objectForKey:@"AD_AppRaterVersionFirstUsed"]).andReturn(first);
    
    // Make sure the min usage is met
    self.raterManager.currentVersionLaunchesUntilPrompt = 0;
    
    // Act
    BOOL shouldPrompt = [self.raterManager shouldPromptForRating];
    
    // Assert
    XCTAssertFalse(shouldPrompt);
}

- (void)testShouldPromptForRating_usedMoreLaunchesThanMinRequired_shouldReturnTrue
{
    // Arrange
    NSInteger minLaunches = 3;
    self.raterManager.currentVersionLaunchesUntilPrompt = minLaunches;
    OCMStub([self.mockUserDefaults integerForKey:@"AD_AppRaterVersionLaunchCount"]).andReturn(minLaunches + 1);
    
    // Make sure the min time usage is met
    self.raterManager.currentVersionDaysUntilPrompt = 0;
    
    // Act
    BOOL shouldPrompt = [self.raterManager shouldPromptForRating];
    
    // Assert
    XCTAssertTrue(shouldPrompt);
}

- (void)testShouldPromptForRating_usedExactLaunchesThanMinRequired_shouldReturnTrue
{
    // Arrange
    NSInteger minLaunches = 3;
    self.raterManager.currentVersionLaunchesUntilPrompt = minLaunches;
    OCMStub([self.mockUserDefaults integerForKey:@"AD_AppRaterVersionLaunchCount"]).andReturn(minLaunches);
    
    // Make sure the min time usage is met
    self.raterManager.currentVersionDaysUntilPrompt = 0;
    
    // Act
    BOOL shouldPrompt = [self.raterManager shouldPromptForRating];
    
    // Assert
    XCTAssertTrue(shouldPrompt);
}

- (void)testShouldPromptForRating_usedLessLaunchesThanMinRequired_shouldReturnFalse
{
    // Arrange
    NSInteger minLaunches = 3;
    self.raterManager.currentVersionLaunchesUntilPrompt = minLaunches;
    OCMStub([self.mockUserDefaults integerForKey:@"AD_AppRaterVersionLaunchCount"]).andReturn(minLaunches - 1);
    
    // Make sure the min time usage is met
    self.raterManager.currentVersionDaysUntilPrompt = 0;
    
    // Act
    BOOL shouldPrompt = [self.raterManager shouldPromptForRating];
    
    // Assert
    XCTAssertFalse(shouldPrompt);
}

#pragma mark Reminder

- (void)testShouldPromptForRating_passedMoreDaysSinceLastReminded_shouldReturnTrue
{
    // Arrange
    NSInteger remindDays = 3;
    NSDate *reminded = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay
                                                                value:-(remindDays+1)
                                                               toDate:[NSDate date]
                                                              options:kNilOptions];
    
    self.raterManager.remindWaitPeriod = remindDays;
    OCMStub([self.mockUserDefaults objectForKey:@"AD_AppRaterLastReminded"]).andReturn(reminded);
    
    // Make sure the min usage is met
    self.raterManager.currentVersionDaysUntilPrompt = 0;
    self.raterManager.currentVersionLaunchesUntilPrompt = 0;
    
    // Act
    BOOL shouldPrompt = [self.raterManager shouldPromptForRating];
    
    // Assert
    XCTAssertTrue(shouldPrompt);
}

- (void)testShouldPromptForRating_passedExactDaysSinceLastReminded_shouldReturnTrue
{
    // Arrange
    NSInteger remindDays = 3;
    NSDate *reminded = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay
                                                                value:-(remindDays)
                                                               toDate:[NSDate date]
                                                              options:kNilOptions];

    self.raterManager.remindWaitPeriod = remindDays;
    OCMStub([self.mockUserDefaults objectForKey:@"AD_AppRaterLastReminded"]).andReturn(reminded);
    
    // Make sure the min usage is met
    self.raterManager.currentVersionDaysUntilPrompt = 0;
    self.raterManager.currentVersionLaunchesUntilPrompt = 0;
    
    // Act
    BOOL shouldPrompt = [self.raterManager shouldPromptForRating];
    
    // Assert
    XCTAssertTrue(shouldPrompt);
}

- (void)testShouldPromptForRating_passedLessDaysSinceLastReminded_shouldReturnFalse
{
    // Arrange
    NSInteger remindDays = 3;
    NSDate *reminded = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay
                                                                value:-(remindDays-1)
                                                               toDate:[NSDate date]
                                                              options:kNilOptions];

    self.raterManager.remindWaitPeriod = remindDays;
    OCMStub([self.mockUserDefaults objectForKey:@"AD_AppRaterLastReminded"]).andReturn(reminded);
    
    // Make sure the min usage is met
    self.raterManager.currentVersionDaysUntilPrompt = 0;
    self.raterManager.currentVersionLaunchesUntilPrompt = 0;
    
    // Act
    BOOL shouldPrompt = [self.raterManager shouldPromptForRating];
    
    // Assert
    XCTAssertFalse(shouldPrompt);
}

#pragma mark Frequency

- (void)testShouldPromptForRating_passedLessDaysSinceLastPrompted_shouldReturnFalse
{
    // Arrange
    NSInteger frequncyLimit = 30;
    NSDate *lastPrompted = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay
                                                                    value:-(frequncyLimit-1)
                                                                   toDate:[NSDate date]
                                                                  options:kNilOptions];
    
    self.raterManager.promptForNewVersionIfUserRated = YES;
    self.raterManager.limitPromptFrequency = frequncyLimit;
    OCMStub([self.mockUserDefaults objectForKey:@"AD_AppRaterLastPromptedDate"]).andReturn(lastPrompted);
    
    // Act
    BOOL shouldPrompt = [self.raterManager shouldPromptForRating];
    
    // Assert
    XCTAssertFalse(shouldPrompt);
}

#pragma mark Scenarios

- (void)testShouldPromptForRating_singleScenarioComplete_shouldReturnTrue
{
    // Arrange
    id mockDict = OCMStrictClassMock([NSDictionary class]);
    OCMStub([mockDict count]).andReturn(1);
    OCMExpect([self.mockUserDefaults dictionaryForKey:@"AD_AppRaterVersionEventCount"]).andReturn(mockDict);

    id scenario1 = OCMStrictClassMock([ADEventScenario class]);
    self.raterManager.eventScenariosUntilPrompt = @[scenario1];
    
    // Make sure the min usage is met
    self.raterManager.currentVersionDaysUntilPrompt = 0;
    self.raterManager.currentVersionLaunchesUntilPrompt = 0;
    
    id mockRatingManager = OCMPartialMock(self.raterManager);
    OCMExpect([mockRatingManager isScenarioComplete:OCMOCK_ANY eventList:OCMOCK_ANY]).andReturn(YES);
    
    // Act
    BOOL shouldPrompt = [mockRatingManager shouldPromptForRating];
    
    // Assert
    XCTAssertTrue(shouldPrompt);
    OCMVerifyAll(mockRatingManager);
}

- (void)testShouldPromptForRating_secondScenarioComplete_shouldReturnTrue
{
    // Arrange
    id mockDict = OCMStrictClassMock([NSDictionary class]);
    OCMStub([mockDict count]).andReturn(1);
    OCMExpect([self.mockUserDefaults dictionaryForKey:@"AD_AppRaterVersionEventCount"]).andReturn(mockDict);
    
    id scenario1 = OCMStrictClassMock([ADEventScenario class]);
    id scenario2 = OCMStrictClassMock([ADEventScenario class]);
    self.raterManager.eventScenariosUntilPrompt = @[scenario1, scenario2];
    
    // Make sure the min usage is met
    self.raterManager.currentVersionDaysUntilPrompt = 0;
    self.raterManager.currentVersionLaunchesUntilPrompt = 0;
    
    id mockRatingManager = OCMPartialMock(self.raterManager);
    OCMExpect([mockRatingManager isScenarioComplete:OCMOCK_ANY eventList:OCMOCK_ANY]).andReturn(NO);
    OCMExpect([mockRatingManager isScenarioComplete:OCMOCK_ANY eventList:OCMOCK_ANY]).andReturn(YES); // Called Twice

    // Act
    BOOL shouldPrompt = [mockRatingManager shouldPromptForRating];
    
    // Assert
    XCTAssertTrue(shouldPrompt);
    OCMVerifyAll(mockRatingManager);
}

- (void)testShouldPromptForRating_firstOfTwoScenariosComplete_shouldReturnTrue_andSecondScenrioNotChecked
{
    // Arrange
    id mockDict = OCMStrictClassMock([NSDictionary class]);
    OCMStub([mockDict count]).andReturn(2);
    OCMExpect([self.mockUserDefaults dictionaryForKey:@"AD_AppRaterVersionEventCount"]).andReturn(mockDict);
    
    id scenario1 = OCMStrictClassMock([ADEventScenario class]);
    id scenario2 = OCMStrictClassMock([ADEventScenario class]);
    self.raterManager.eventScenariosUntilPrompt = @[scenario1, scenario2];
    
    // Make sure the min usage is met
    self.raterManager.currentVersionDaysUntilPrompt = 0;
    self.raterManager.currentVersionLaunchesUntilPrompt = 0;
    
    id mockRatingManager = OCMPartialMock(self.raterManager);
    OCMExpect([mockRatingManager isScenarioComplete:OCMOCK_ANY eventList:OCMOCK_ANY]).andReturn(YES); // Called only once
    
    // Act
    BOOL shouldPrompt = [mockRatingManager shouldPromptForRating];
    
    // Assert
    XCTAssertTrue(shouldPrompt);
    OCMVerifyAll(mockRatingManager);
}

- (void)testShouldPromptForRating_threeScenariosIncomplete_shouldReturnFalse
{
    // Arrange
    id mockDict = OCMStrictClassMock([NSDictionary class]);
    OCMStub([mockDict count]).andReturn(2);
    OCMExpect([self.mockUserDefaults dictionaryForKey:@"AD_AppRaterVersionEventCount"]).andReturn(mockDict);
    
    id scenario1 = OCMStrictClassMock([ADEventScenario class]);
    id scenario2 = OCMStrictClassMock([ADEventScenario class]);
    id scenario3 = OCMStrictClassMock([ADEventScenario class]);
    self.raterManager.eventScenariosUntilPrompt = @[scenario1, scenario2, scenario3];
    
    // Make sure the min usage is met
    self.raterManager.currentVersionDaysUntilPrompt = 0;
    self.raterManager.currentVersionLaunchesUntilPrompt = 0;
    
    id mockRatingManager = OCMPartialMock(self.raterManager);
    OCMExpect([mockRatingManager isScenarioComplete:OCMOCK_ANY eventList:OCMOCK_ANY]).andReturn(NO);
    OCMExpect([mockRatingManager isScenarioComplete:OCMOCK_ANY eventList:OCMOCK_ANY]).andReturn(NO);
    OCMExpect([mockRatingManager isScenarioComplete:OCMOCK_ANY eventList:OCMOCK_ANY]).andReturn(NO); // Called three times
    
    // Act
    BOOL shouldPrompt = [mockRatingManager shouldPromptForRating];
    
    // Assert
    XCTAssertFalse(shouldPrompt);
    OCMVerifyAll(mockRatingManager);
}

#pragma mark - Event Handling

- (void)testRegisterEvent_shouldSaveToPersist_firstEventOfKind
{
    // Arrange
    NSString* eventName = @"anyEvent";
    NSInteger currentEventCount = 0;
    NSDictionary* mockDict;

    OCMExpect([self.mockUserDefaults dictionaryForKey:@"AD_AppRaterVersionEventCount"]).andReturn(mockDict);
    OCMExpect([self.mockUserDefaults setObject:[OCMArg checkWithBlock:[self blockTestEventDictionaryWithEvent:eventName expectedEventCount:currentEventCount+1]]
                                        forKey:@"AD_AppRaterVersionEventCount"]);

    // Act
    [self.raterManager registerEvent:eventName withViewController:nil];
    
    // Assert
    OCMVerifyAll(self.mockUserDefaults);
}

- (void)testRegisterEvent_shouldSaveToPersist_secondEventOfKind
{
    // Arrange
    NSString* eventName = @"anyEvent";
    NSInteger currentEventCount = 4;
    NSDictionary* mockDict = @{eventName : @(currentEventCount)};
    
    OCMExpect([self.mockUserDefaults dictionaryForKey:@"AD_AppRaterVersionEventCount"]).andReturn(mockDict);
    OCMExpect([self.mockUserDefaults setObject:[OCMArg checkWithBlock:[self blockTestEventDictionaryWithEvent:eventName
                                                                                           expectedEventCount:currentEventCount+1]]
                                        forKey:@"AD_AppRaterVersionEventCount"]);
    
    // Act
    [self.raterManager registerEvent:eventName withViewController:nil];
    
    // Assert
    OCMVerifyAll(self.mockUserDefaults);
}

- (void)testPersistingEventsOverVersion_promptEachVersionTrue_shouldResetEvents
{
    // Arrange
    NSString* eventName = @"anyEvent";
    NSInteger currentEventCount = 4;
    NSDictionary* mockDict = @{eventName : @(currentEventCount)};
    
    OCMStub([self.mockUserDefaults dictionaryForKey:@"AD_AppRaterVersionEventCount"]).andReturn(mockDict);
    OCMExpect([self.mockUserDefaults removeObjectForKey:@"AD_AppRaterVersionEventCount"]);

    self.raterManager = [[ADAppRater alloc] initWithUserDefaults:self.mockUserDefaults
                                               appStoreConnector:self.mockAppStoreConnector];
    
    // Act
    self.raterManager.promptForNewVersionIfUserRated = YES;
    
    // Assert
    XCTAssertNil(self.raterManager.tempOldVersionEventCounters);
    OCMVerifyAll(self.mockUserDefaults);
}

- (void)testPersistingEventsOverVersion_promptEachVersionFalse_shouldNotResetEvents
{
    // Arrange
    NSString* eventName = @"anyEvent";
    NSInteger currentEventCount = 4;
    NSDictionary* mockDict = @{eventName : @(currentEventCount)};
    
    OCMExpect([self.mockUserDefaults dictionaryForKey:@"AD_AppRaterVersionEventCount"]).andReturn(mockDict);
    OCMExpect([self.mockUserDefaults removeObjectForKey:@"AD_AppRaterVersionEventCount"]);
    OCMExpect([self.mockUserDefaults setObject:[OCMArg checkWithBlock:
                                                [self blockTestEventDictionaryWithEvent:eventName
                                                                     expectedEventCount:currentEventCount]]
                                        forKey:@"AD_AppRaterVersionEventCount"]);

    self.raterManager = [[ADAppRater alloc] initWithUserDefaults:self.mockUserDefaults
                                               appStoreConnector:self.mockAppStoreConnector];
    
    // Event list should be empty after init - although while mocking this does not always happen
    XCTAssertEqual(self.raterManager.persistEventCounters.count, 0);

    // Act
    self.raterManager.promptForNewVersionIfUserRated = NO;
    
    // Assert
    XCTAssertNil(self.raterManager.tempOldVersionEventCounters);
    OCMVerifyAll(self.mockUserDefaults);
}


#pragma mark - Private Helpers
#pragma mark - 

/**
 *  Create a block that will check the param a method called with, and verify it to be a NSDictionary type, and includes the expected event name and count
 *  @param eventName Expected event name tested
 *  @param count     Expected event count
 *  @return block
 */
- (BOOL(^)(id obj))blockTestEventDictionaryWithEvent:(NSString*)eventName expectedEventCount:(NSInteger)count
{
    BOOL (^block)(id obj) = ^BOOL(id obj)
    {
        [self blockLogIfNeeded:@"Start"];
        BOOL val = NO;
        [self blockLogIfNeeded:@"Check if Dict"];
        if ([obj isKindOfClass:[NSDictionary class]])
        {
            [self blockLogIfNeeded:@"It Is Dict"];
            NSDictionary* dict = (NSDictionary*)obj;
            [self blockLogIfNeeded:[NSString stringWithFormat:@"Get Counter from Dict %@", dict]];
            NSNumber* counter = dict[eventName];
            [self blockLogIfNeeded:[NSString stringWithFormat:@"Check Counter Value %@", counter]];
            if (counter.integerValue == count)
            {
                [self blockLogIfNeeded:[NSString stringWithFormat:@"Counter Value is %d", (int)count]];
                val = YES;
            }
        }
        [self blockLogIfNeeded:@"Before Return"];
        return val;
    };
    return block;
}

- (void)blockLogIfNeeded:(NSString*)logMessage
{
    NSLog(@"BLOCK: %@",logMessage);
}

@end
