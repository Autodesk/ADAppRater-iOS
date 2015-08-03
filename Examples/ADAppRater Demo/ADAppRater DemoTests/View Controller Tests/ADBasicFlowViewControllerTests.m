//
//  ADBasicFlowViewControllerTests.m
//  ADAppRater Demo
//
//  Created by Amir Shavit on 6/11/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import "ADTestCase.h"

#import "ADBasicFlowViewController.h"
#import "ADAppRater.h"

@interface ADBasicFlowViewControllerTests : ADTestCase

@property (nonatomic, strong) ADBasicFlowViewController* testVC;

// Dependecies
@property (nonatomic, strong) id mockRatingManager;

@end

@implementation ADBasicFlowViewControllerTests

- (void)setUp
{
    [super setUp];

    [ADMockingHelpers unmockForClass:[ADAppRater class]];
    self.mockRatingManager = OCMClassMock([ADAppRater class]);
    OCMStub([self.mockRatingManager sharedInstance]).andReturn(self.mockRatingManager);
    
    self.testVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]
                   instantiateViewControllerWithIdentifier:@"ADBasicFlowViewController"];
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
