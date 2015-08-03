//
//  ADARManagerBaseTestCase.m
//  ADAppRater Demo
//
//  Created by Amir Shavit on 6/16/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import "ADARManagerBaseTestCase.h"
#import "ADAppRaterManager_TestsInternal.h"

@implementation ADARManagerBaseTestCase

- (void)setUp
{
    [super setUp];
    
    [ADMockingHelpers unmockForClass:[NSUserDefaults class]];
    self.mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    
    self.mockAppStoreConnector = OCMStrictClassMock([ADAppStoreConnector class]);
    
    self.raterManager = [[ADAppRater alloc] initWithUserDefaults:self.mockUserDefaults
                                               appStoreConnector:self.mockAppStoreConnector];
}

- (void)tearDown
{
    self.raterManager = nil;
    self.mockUserDefaults = nil;
    self.mockAppStoreConnector = nil;
    
    [ADMockingHelpers unmockForClass:[NSUserDefaults class]];
    
    [super tearDown];
}

@end
