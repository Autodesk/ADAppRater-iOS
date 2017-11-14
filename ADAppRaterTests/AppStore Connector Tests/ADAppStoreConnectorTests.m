//
//  ADAppStoreConnectorTests.m
//  ADAppRater Demo
//
//  Created by Amir Shavit on 6/24/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import "ADTestCase.h"
#import "ADAppStoreConnector_TestsInternal.h"

@interface ADAppStoreConnectorTests : ADTestCase
@property (nonatomic, strong) id appstoreConnector;
@end

@implementation ADAppStoreConnectorTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.appstoreConnector = OCMPartialMock([ADAppStoreConnector new]);
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSetApplicationBundleId_shouldUpdatePrivateProperty
{
    // Arrange
    NSString* bundleId = @"some.bundle.id";
    
    // Act
    [self.appstoreConnector setApplicationBundleID:bundleId];
    
    // Assert
    XCTAssertEqualObjects([self.appstoreConnector applicationBundleID], bundleId);
}

- (void)testSetAppStoreId_shouldUpdatePrivateProperty
{
    // Arrange
    NSInteger storeId = 78956;
    
    // Act
    [self.appstoreConnector setAppStoreID:storeId];
    
    // Assert
    XCTAssertEqual([self.appstoreConnector appStoreID], storeId);
}

- (void)testSetAppStoreCountry_shouldUpdatePrivateProperty
{
    // Arrange
    NSString* country = @"The Bset Country";
    
    // Act
    [self.appstoreConnector setAppStoreCountry:country];
    
    // Assert
    XCTAssertEqual([self.appstoreConnector appStoreCountry], country);
}

#pragma mark Open Ratings Page

- (void)testIsAppStoreAvailable_shouldReturnTrue
{
    // Arrange
    id mockStoreConnector = OCMPartialMock(self.appstoreConnector);
    OCMStub([mockStoreConnector checkForConnectivity:[OCMArg anyObjectRef]]).andReturn(200);
    
    // Act
    BOOL val = [mockStoreConnector isAppStoreAvailable];
    
    // Assert
    XCTAssertTrue(val);
}

- (void)testIsAppStoreAvailable_noInternet_shouldReturnFalse
{
    // Arrange
    id mockStoreConnector = OCMPartialMock(self.appstoreConnector);
    OCMStub([mockStoreConnector checkForConnectivity:[OCMArg anyObjectRef]]).andReturn(0);
    
    // Act
    BOOL val = [mockStoreConnector isAppStoreAvailable];
    
    // Assert
    XCTAssertFalse(val);
}

- (void)testIsAppStoreAvailable_withError_shouldReturnFalse
{
    // Arrange
    id mockStoreConnector = OCMPartialMock(self.appstoreConnector);
    
    // Mock Error
    NSError* error = [NSError errorWithDomain:@"com.test.domain" code:(-1009) userInfo:nil];
    OCMStub([mockStoreConnector checkForConnectivity:&error]).andReturn(400);
    
    // Act
    BOOL val = [mockStoreConnector isAppStoreAvailable];
    
    // Assert
    XCTAssertFalse(val);
}

#pragma mark Open Ratings Page

- (void)testOpenRatingsPageInAppStore_noAppStoreId_shouldStartConnectivityChack
{
    // Arrange
    OCMStub([self.appstoreConnector appStoreID]).andReturn(0);
    OCMExpect([self.appstoreConnector checkForConnectivityInBackground]);
    
    // Act
    [self.appstoreConnector openRatingsPageInAppStore];
    
    // Assert
    OCMVerifyAll(self.appstoreConnector);
}

- (void)testOpenRatingsPageInAppStore_ratingsURLValidStoreSchemeOnSimulator_shouldInvokeDelegateError
{
    // Arrange
    NSURL* url = [NSURL URLWithString:@"itms-apps://my.domain.com/some/path"];
    OCMStub([self.appstoreConnector ratingsURL]).andReturn(url);
    OCMStub([self.appstoreConnector appStoreID]).andReturn(555);
    
    id mockDelegate = OCMStrictProtocolMock(@protocol(ADARDelegate));
    OCMExpect([mockDelegate appRaterAppStoreCouldNotConnect:[OCMArg isKindOfClass:[NSError class]]]);
    
    OCMStub([self.appstoreConnector delegate]).andReturn(mockDelegate);
    
    // Act
    [self.appstoreConnector openRatingsPageInAppStore];
    
    // Assert
    OCMVerifyAll(mockDelegate);
}

- (void)testOpenRatingsPageInAppStore_validRatingsURL_shouldOpenStoreAndInvokeDelegate
{
    // Arrange
    NSURL* url = [NSURL URLWithString:@"a-scheme://my.domain.com/some/path"];
    OCMStub([self.appstoreConnector ratingsURL]).andReturn(url);
    
    // Mock expectation from delegate
    id mockDelegate = OCMStrictProtocolMock(@protocol(ADARDelegate));
    OCMStub([self.appstoreConnector delegate]).andReturn(mockDelegate);
    OCMExpect([mockDelegate appRaterAppStoreDidOpen]);
    
    // Mock expectation from sharedApplication
    id mockSharedApp = OCMStrictClassMock([UIApplication class]);
    OCMStub([mockSharedApp sharedApplication]).andReturn(mockSharedApp);
    OCMExpect([mockSharedApp openURL:url]);
    
    // Act
    [self.appstoreConnector openRatingsPageInAppStore];
    
    // Assert
    OCMVerifyAll(mockDelegate);
    OCMVerifyAll(mockSharedApp);
    
    // Unmock application class
    [ADMockingHelpers unmockForClass:[UIApplication class]];
}


@end
