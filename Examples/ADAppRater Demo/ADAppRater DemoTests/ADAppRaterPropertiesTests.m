//
//  ADAppRaterPropertiesTests.m
//  ADAppRater Demo
//
//  Created by Amir Shavit on 6/15/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import "ADARManagerBaseTestCase.h"

#import "ADAppRaterManager_TestsInternal.h"

@interface ADAppRaterPropertiesTests : ADARManagerBaseTestCase

@end

@implementation ADAppRaterPropertiesTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

#pragma mark - Default Params

- (void)testInitializeManager_shouldHaveDefaultProperties
{
    // Arrange
    NSString* name = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleNameKey];
    NSString* version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString* bundle = [[NSBundle mainBundle] bundleIdentifier];
    
    // Act
    
    // Assert
    XCTAssertEqualObjects(self.raterManager.applicationName, name);
    XCTAssertEqualObjects(self.raterManager.applicationVersion, version);
    XCTAssertEqualObjects(self.raterManager.applicationBundleID, bundle);
    XCTAssertEqual(self.raterManager.currentVersionDaysUntilPrompt, 1);
    XCTAssertEqual(self.raterManager.currentVersionLaunchesUntilPrompt, 3);
    XCTAssertEqual(self.raterManager.remindWaitPeriod, 5);
    XCTAssertEqual(self.raterManager.limitPromptFrequency, 30);
    XCTAssertFalse(self.raterManager.promptForNewVersionIfUserRated);
    XCTAssertFalse(self.raterManager.enableLog);
    
#ifdef DEBUG
    XCTAssertFalse(self.raterManager.previewMode);
#endif
}

#pragma mark - User Reactions

- (void)testUserRatedApp_shouldSaveToPersistent
{
    // Arrange
    
    // Act
    self.raterManager.ratedThisVersion = YES;
    
    // Assert
    OCMVerify([self.mockUserDefaults setObject:[OCMArg any] forKey:@"AD_AppRaterLastRatedVersion"]);
}

- (void)testUserRatedKeyFoundInPersistent_shouldReturnRatedFlagsTrue
{
    // Arrange
    OCMStub([self.mockUserDefaults objectForKey:@"AD_AppRaterLastRatedVersion"]).andReturn(self.raterManager.applicationVersion);
    
    // Act
    
    // Assert
    XCTAssertTrue(self.raterManager.ratedThisVersion);
    XCTAssertTrue(self.raterManager.ratedAnyVersion);
}

- (void)testUserRatedKeyNotFoundInPersistent_shouldReturnRatedFlagsFalse
{
    // Arrange
    
    // Act
    
    // Assert
    XCTAssertFalse(self.raterManager.ratedThisVersion);
    XCTAssertFalse(self.raterManager.ratedAnyVersion);
}

- (void)testUserDeclinedRated_shouldSaveToPersistent
{
    // Arrange
    
    // Act
    self.raterManager.declinedThisVersion = YES;
    
    // Assert
    OCMVerify([self.mockUserDefaults setObject:[OCMArg any] forKey:@"AD_AppRaterLastDeclinedVersion"]);
}

- (void)testUserDeclinedKeyFoundInPersistent_shouldReturnDeclinedFlagsTrue
{
    // Arrange
    OCMStub([self.mockUserDefaults objectForKey:@"AD_AppRaterLastDeclinedVersion"]).andReturn(self.raterManager.applicationVersion);
    
    // Act
    
    // Assert
    XCTAssertTrue(self.raterManager.declinedThisVersion);
    XCTAssertTrue(self.raterManager.declinedAnyVersion);
}

- (void)testUserDeclinedKeyFoundInPersistent_shouldReturnDeclinedFlagsFalse
{
    // Arrange
    
    // Act
    
    // Assert
    XCTAssertFalse(self.raterManager.declinedThisVersion);
    XCTAssertFalse(self.raterManager.declinedAnyVersion);
}


@end
