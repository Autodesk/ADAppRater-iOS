//
//  ADCustomFlowViewControllerTests.m
//  ADAppRater Demo
//
//  Created by Amir Shavit on 6/11/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import "ADTestCase.h"

#import "ADCustomFlowViewController.h"
#import "ADAppRater.h"

@interface ADCustomFlowViewControllerTests : ADTestCase

@property (nonatomic, strong) ADCustomFlowViewController* testVC;

// Dependecies
@property (nonatomic, strong) id mockRatingManager;

@end

@implementation ADCustomFlowViewControllerTests

- (void)setUp
{
    [super setUp];

    [ADMockingHelpers unmockForClass:[ADAppRater class]];
    self.mockRatingManager = OCMClassMock([ADAppRater class]);
    OCMStub([self.mockRatingManager sharedInstance]).andReturn(self.mockRatingManager);

    self.testVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]
                   instantiateViewControllerWithIdentifier:@"ADCustomFlowViewController"];
    [self.testVC view];
}

- (void)tearDown
{
    self.testVC = nil;
    self.mockRatingManager = nil;
    [ADMockingHelpers unmockForClass:[ADAppRater class]];

    [super tearDown];
}

- (void)testPressedStartFlowButton_shouldStartFlow
{
    // Arrange
    OCMExpect([self.mockRatingManager startRaterFlowFromViewController:self.testVC]);
    
    // Act
    [self.testVC pressedStartFlowButton:nil];
    
    // Assert
    OCMVerifyAll(self.mockRatingManager);
}

@end
