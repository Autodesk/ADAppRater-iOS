//
//  ADARManagerBaseTestCase.m
//  ADAppRater Demo
//
//  Created by Amir Shavit on 6/16/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import "ADARManagerBaseTestCase.h"
#import "ADAppRaterManager_TestsInternal.h"

@interface ADARManagerBaseTestCase ()
@property (nonatomic, strong) id mockBundle;
@property (nonatomic, strong) id mockLocale;
@end

@implementation ADARManagerBaseTestCase

- (void)setUp
{
    [super setUp];
    
    [self unmockObjects];
    self.mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    
    self.mockBundle = OCMClassMock([NSBundle class]);
    OCMStub([self.mockBundle mainBundle]).andReturn([NSBundle bundleForClass:[ADAppRater class]]);
    
    self.mockLocale = OCMClassMock([NSLocale class]);
    OCMStub([self.mockLocale preferredLanguages]).andReturn(@[@"en"]);

    self.mockAppStoreConnector = OCMStrictClassMock([ADAppStoreConnector class]);
    
    self.raterManager = [[ADAppRater alloc] initWithUserDefaults:self.mockUserDefaults
                                               appStoreConnector:self.mockAppStoreConnector];
}

- (void)tearDown
{
    self.raterManager = nil;
    self.mockUserDefaults = nil;
    self.mockAppStoreConnector = nil;
    self.mockLocale = nil;
    
    [self unmockObjects];
    
    [super tearDown];
}

- (void)unmockObjects
{
    [ADMockingHelpers unmockForClass:[NSUserDefaults class]];
    [ADMockingHelpers unmockForClass:[NSBundle class]];
    [ADMockingHelpers unmockForClass:[NSLocale class]];
}

@end
