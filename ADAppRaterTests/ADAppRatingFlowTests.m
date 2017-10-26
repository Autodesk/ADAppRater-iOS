//
//  ADAppRaterFlowTests.m
//  ADAppRater Demo
//
//  Created by Amir Shavit on 6/16/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import "ADARManagerBaseTestCase.h"
#import <MessageUI/MessageUI.h>

#import "ADAppRaterManager_TestsInternal.h"

@interface ADAppRaterFlowTests : ADARManagerBaseTestCase
@property (nonatomic, strong) id mockDelegate;
@end

@implementation ADAppRaterFlowTests

- (void)setUp
{
    [super setUp];

    self.mockDelegate = OCMStrictProtocolMock(@protocol(ADARDelegate));
    self.raterManager.delegate = self.mockDelegate;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Start Flow

- (void)testStartRatingFlowFromViewController_online_vcAlive_shouldPromptRate
{
    // Arrange
    OCMExpect([self.mockDelegate appRaterWillPromptUserSatisfaction]);
    
    id mockVc = OCMClassMock([UIViewController class]);
    id mockNav = OCMClassMock([UINavigationController class]);
    OCMStub([mockVc navigationController]).andReturn(mockNav);
    OCMStub([mockNav topViewController]).andReturn(mockVc);
    
    id mockRatingManager = OCMPartialMock(self.raterManager);
    OCMExpect([mockRatingManager promptUserSatisfationAlertFromViewController:[OCMArg any]]).andForwardToRealObject;
    OCMExpect([mockRatingManager setUserLastPromptedToRate:[OCMArg isKindOfClass:[NSDate class]]]);
    
    // Act
    [mockRatingManager startRaterFlowFromViewController:mockVc online:YES];
    
    // Assert
    OCMVerifyAll(mockRatingManager);
    OCMVerifyAll(self.mockDelegate);
    XCTAssertEqual(self.raterManager.currentAlert.actions.count, 2);
    XCTAssertEqualObjects(((UIAlertAction*)self.raterManager.currentAlert.actions[0]).title, @"No");
    XCTAssertEqualObjects(((UIAlertAction*)self.raterManager.currentAlert.actions[1]).title, @"Yes");
}

- (void)testStartRatingFlowFromViewController_online_vcNil_shouldNotPrompt
{
    // Arrange
//    OCMExpect([self.mockDelegate appRateWillPromptUserSatisfaction]); // Expected not to be called
    
    // Act
    [self.raterManager startRaterFlowFromViewController:nil online:YES];
    
    // Assert
    OCMVerifyAll(self.mockDelegate);
    XCTAssertEqual(self.raterManager.currentAlert.actions.count, 0);
}

- (void)testStartRatingFlowFromViewController_online_vcPresenting_shouldNotPrompt
{
    // Arrange
//    OCMExpect([self.mockDelegate appRateWillPromptUserSatisfaction]); // Expected not to be called
    
    id mockVc = OCMClassMock([UIViewController class]);
    OCMStub([mockVc presentedViewController]).andReturn([OCMArg any]);
    
    // Act
    [self.raterManager startRaterFlowFromViewController:mockVc online:YES];
    
    // Assert
    OCMVerifyAll(self.mockDelegate);
    XCTAssertEqual(self.raterManager.currentAlert.actions.count, 0);
}

- (void)testStartRatingFlowFromViewController_online_vcPushedAnother_shouldNotPrompt
{
    // Arrange
//    OCMExpect([self.mockDelegate appRateWillPromptUserSatisfaction]); // Expected not to be called
    
    id mockVc = OCMClassMock([UIViewController class]);
    id mockNav = OCMClassMock([UINavigationController class]);
    OCMStub([mockVc navigationController]).andReturn(mockNav);
    OCMStub([mockNav topViewController]).andReturn(nil);
    
    // Act
    [self.raterManager startRaterFlowFromViewController:mockVc online:YES];
    
    // Assert
    OCMVerifyAll(self.mockDelegate);
    XCTAssertEqual(self.raterManager.currentAlert.actions.count, 0);
}

- (void)testStartRatingFlowFromViewController_offline_shouldNotPrompt
{
    // Arrange
//    OCMExpect([self.mockDelegate appRateWillPromptUserSatisfaction]); // Expected not to be called

    id mockVc = OCMClassMock([UIViewController class]);
    id mockNav = OCMClassMock([UINavigationController class]);
    OCMStub([mockVc navigationController]).andReturn(mockNav);
    OCMStub([mockNav topViewController]).andReturn(mockVc);

    // Act
    [self.raterManager startRaterFlowFromViewController:mockVc online:NO];

    // Assert
    OCMVerifyAll(self.mockDelegate);
    XCTAssertEqual(self.raterManager.currentAlert.actions.count, 0);
}

#pragma mark - Direct Prompting

- (void)testDirectRatingPromptFromViewController_online_vcAlive_shouldPromptRate
{
    // Arrange
    OCMExpect([self.mockDelegate appRaterWillPromptUserRating]);
    
    id mockVc = OCMClassMock([UIViewController class]);
    id mockNav = OCMClassMock([UINavigationController class]);
    OCMStub([mockVc navigationController]).andReturn(mockNav);
    OCMStub([mockNav topViewController]).andReturn(mockVc);
    
    id mockRatingManager = OCMPartialMock(self.raterManager);
    OCMExpect([mockRatingManager promptAppRatingAlertFromViewController:[OCMArg any]]).andForwardToRealObject;
    OCMExpect([mockRatingManager setUserLastPromptedToRate:[OCMArg isKindOfClass:[NSDate class]]]);
    
    // Act
    [mockRatingManager promptDirectRatingFromViewController:mockVc online:YES];
    
    // Assert
    OCMVerifyAll(mockRatingManager);
    OCMVerifyAll(self.mockDelegate);
    XCTAssertEqual(self.raterManager.currentAlert.actions.count, 3);
    XCTAssertEqualObjects(((UIAlertAction*)self.raterManager.currentAlert.actions[0]).title, @"Rate ADAppRater");
    XCTAssertEqualObjects(((UIAlertAction*)self.raterManager.currentAlert.actions[1]).title, @"Remind Me Later");
    XCTAssertEqualObjects(((UIAlertAction*)self.raterManager.currentAlert.actions[2]).title, @"No, Thanks");
}

- (void)testDirectRatingPromptFromViewController_online_vcNil_shouldNotPrompt
{
    // Arrange
//        OCMExpect([self.mockDelegate appRateWillPromptUserRating]); // Expected not to be called
    
    // Act
    [self.raterManager promptDirectRatingFromViewController:nil online:YES];
    
    // Assert
    OCMVerifyAll(self.mockDelegate);
    XCTAssertEqual(self.raterManager.currentAlert.actions.count, 0);
}

- (void)testDirectRatingPromptFromViewController_online_vcPresenting_shouldNotPrompt
{
    // Arrange
//        OCMExpect([self.mockDelegate appRateWillPromptUserRating]); // Expected not to be called
    
    id mockVc = OCMClassMock([UIViewController class]);
    OCMStub([mockVc presentedViewController]).andReturn([OCMArg any]);
    
    // Act
    [self.raterManager promptDirectRatingFromViewController:mockVc online:YES];
    
    // Assert
    OCMVerifyAll(self.mockDelegate);
    XCTAssertEqual(self.raterManager.currentAlert.actions.count, 0);
}

- (void)testDirectRatingPromptFromViewController_online_vcPushedAnother_shouldNotPrompt
{
    // Arrange
//        OCMExpect([self.mockDelegate appRateWillPromptUserRating]); // Expected not to be called
    
    id mockVc = OCMClassMock([UIViewController class]);
    id mockNav = OCMClassMock([UINavigationController class]);
    OCMStub([mockVc navigationController]).andReturn(mockNav);
    OCMStub([mockNav topViewController]).andReturn(nil);
    
    // Act
    [self.raterManager promptDirectRatingFromViewController:mockVc online:YES];
    
    // Assert
    OCMVerifyAll(self.mockDelegate);
    XCTAssertEqual(self.raterManager.currentAlert.actions.count, 0);
}

- (void)testDirectRatingPromptFromViewController_offline_shouldNotPrompt
{
    // Arrange
//        OCMExpect([self.mockDelegate appRateWillPromptUserRating]); // Expected not to be called
    
    id mockVc = OCMClassMock([UIViewController class]);
    id mockNav = OCMClassMock([UINavigationController class]);
    OCMStub([mockVc navigationController]).andReturn(mockNav);
    OCMStub([mockNav topViewController]).andReturn(mockVc);
    
    // Act
    [self.raterManager promptDirectRatingFromViewController:mockVc online:NO];
    
    // Assert
    OCMVerifyAll(self.mockDelegate);
    XCTAssertEqual(self.raterManager.currentAlert.actions.count, 0);
}

#pragma mark - Satisfaction Alert

- (void)testPromptSatisfactionAlert_shouldDisplaySatisfactionAlert
{
    // Arrange
    OCMExpect([self.mockDelegate appRaterWillPromptUserSatisfaction]);
    
    UIViewController* vc = [UIViewController new];
    
    // Act
    [self.raterManager promptUserSatisfationAlertFromViewController:vc];
    
    // Assert
    OCMVerifyAll(self.mockDelegate);
    XCTAssertEqual(self.raterManager.currentAlert.actions.count, 2);
    XCTAssertEqualObjects(((UIAlertAction*)self.raterManager.currentAlert.actions[0]).title, @"No");
    XCTAssertEqualObjects(((UIAlertAction*)self.raterManager.currentAlert.actions[1]).title, @"Yes");
}

- (void)testPromptSatisfactionAlert_shouldInvokeDelegatePrompt
{
    // Arrange
    OCMExpect([self.mockDelegate appRaterWillPromptUserSatisfaction]);

    id mockCustomViewDelegate = OCMStrictProtocolMock(@protocol(ADARCustomViewsDelegate));
    OCMExpect([mockCustomViewDelegate
               promptUserSatisfationAlertFromViewController:[OCMArg any]
               userSatisfiedBlock:[OCMArg any]
               userNotSatisfiedBlock:[OCMArg any]]);
    
    self.raterManager.customViewsDelegate = mockCustomViewDelegate;
    UIViewController* vc = [UIViewController new];
    
    // Act
    [self.raterManager promptUserSatisfationAlertFromViewController:vc];
    
    // Assert
    OCMVerifyAll(self.mockDelegate);
    OCMVerifyAll(mockCustomViewDelegate);
    XCTAssertNil(self.raterManager.currentAlert, @"Delegate should handle alert instead of Rating Manager");
}

#pragma mark - User Rating Alert

- (void)testPromptUserRatingAlert_shouldDisplayUserRatingAlert
{
    // Arrange
    OCMExpect([self.mockDelegate appRaterWillPromptUserRating]);

    UIViewController* vc = [UIViewController new];
    
    // Act
    [self.raterManager promptAppRatingAlertFromViewController:vc];
    
    // Assert
    OCMVerifyAll(self.mockDelegate);
    XCTAssertEqual(self.raterManager.currentAlert.actions.count, 3);
    XCTAssertEqualObjects(((UIAlertAction*)self.raterManager.currentAlert.actions[0]).title, @"Rate ADAppRater");
    XCTAssertEqualObjects(((UIAlertAction*)self.raterManager.currentAlert.actions[1]).title, @"Remind Me Later");
    XCTAssertEqualObjects(((UIAlertAction*)self.raterManager.currentAlert.actions[2]).title, @"No, Thanks");
}

- (void)testPromptUserRatingAlert_shouldInvokeDelegatePrompt
{
    // Arrange
    OCMExpect([self.mockDelegate appRaterWillPromptUserRating]);

    id mockCustomViewDelegate = OCMStrictProtocolMock(@protocol(ADARCustomViewsDelegate));
    OCMExpect([mockCustomViewDelegate
               promptAppRatingAlertFromViewController:[OCMArg any]
               userWillRateAppBlock:[OCMArg any]
               remindUserLaterBlock:[OCMArg any]
               userRefusedBlock:[OCMArg any]]);
    
    self.raterManager.customViewsDelegate = mockCustomViewDelegate;
    UIViewController* vc = [UIViewController new];
    
    // Act
    [self.raterManager promptAppRatingAlertFromViewController:vc];
    
    // Assert
    OCMVerifyAll(self.mockDelegate);
    OCMVerifyAll(mockCustomViewDelegate);
    XCTAssertNil(self.raterManager.currentAlert, @"Delegate should handle alert instead of Rating Manager");
}

- (void)testPromptUserRatingAlert_userPressedRateApp_shouldUpdatePersistAndDelegate
{
    // Arrange
    OCMExpect([self.mockDelegate appRaterUserDidAgreeToRateApp]);
    OCMExpect([self.mockUserDefaults setObject:self.raterManager.applicationVersion
                                        forKey:@"AD_AppRaterLastRatedVersion"]);
    OCMExpect([self.mockAppStoreConnector openRatingsPageInAppStore]);
    
    // Act
    [self.raterManager userResponse_ratingAlert_rateApp];
    
    // Assert
    OCMVerifyAll(self.mockDelegate);
    OCMVerifyAll(self.mockUserDefaults);
    OCMVerifyAll(self.mockAppStoreConnector);
}

- (void)testPromptUserRatingAlert_userPressedDeclineRateApp_shouldUpdatePersistAndDelegate
{
    // Arrange
    OCMExpect([self.mockDelegate appRaterUserDidDeclineToRateApp]);
    OCMExpect([self.mockUserDefaults setObject:self.raterManager.applicationVersion
                                        forKey:@"AD_AppRaterLastDeclinedVersion"]);
    
    // Act
    [self.raterManager userResponse_ratingAlert_declineRateApp];
    
    // Assert
    OCMVerifyAll(self.mockDelegate);
    OCMVerifyAll(self.mockUserDefaults);
}

- (void)testPromptUserRatingAlert_userPressedRemindRateApp_shouldUpdatePersistAndDelegate
{
    // Arrange
    OCMExpect([self.mockDelegate appRaterUserDidRequestReminderToRateApp]);
    OCMExpect([self.mockUserDefaults setObject:[OCMArg isKindOfClass:[NSDate class]]
                                        forKey:@"AD_AppRaterLastReminded"]);
    
    // Act
    [self.raterManager userResponse_ratingAlert_remindRateApp];
    
    // Assert
    OCMVerifyAll(self.mockDelegate);
    OCMVerifyAll(self.mockUserDefaults);
}

#pragma mark - Request Feedback

- (void)testRequestFeedbackAlert_shouldDisplayAlert
{
    // Arrange
    OCMExpect([self.mockDelegate appRaterWillPromptFeedbackRequest]);

    UIViewController* vc = [UIViewController new];
    
    // Act
    [self.raterManager promptFeedbackRequestAlertFromViewController:vc];
    
    // Assert
    OCMVerifyAll(self.mockDelegate);
    XCTAssertEqual(self.raterManager.currentAlert.actions.count, 2);
    XCTAssertEqualObjects(((UIAlertAction*)self.raterManager.currentAlert.actions[0]).title, @"Contact us");
    XCTAssertEqualObjects(((UIAlertAction*)self.raterManager.currentAlert.actions[1]).title, @"No thanks");
}

- (void)testRequestFeedbackAlert_shouldInvokeDelegatePrompt
{
    // Arrange
    OCMExpect([self.mockDelegate appRaterWillPromptFeedbackRequest]);

    id mockCustomViewDelegate = OCMStrictProtocolMock(@protocol(ADARCustomViewsDelegate));
    OCMExpect([mockCustomViewDelegate
               promptFeedbackRequestAlertFromViewController:[OCMArg any]
               userWillSendFeedbackBlock:[OCMArg any]
               userWillNotSendFeedbackBlock:[OCMArg any]]);
    
    self.raterManager.customViewsDelegate = mockCustomViewDelegate;
    UIViewController* vc = [UIViewController new];
    
    // Act
    [self.raterManager promptFeedbackRequestAlertFromViewController:vc];
    
    // Assert
    OCMVerifyAll(self.mockDelegate);
    OCMVerifyAll(mockCustomViewDelegate);
    XCTAssertNil(self.raterManager.currentAlert, @"Delegate should handle alert instead of Rating Manager");
}

- (void)testRequestFeedbackAlert_userPressedSendFeedback_shouldOpenMailAndDelegate
{
    // Arrange
    OCMExpect([self.mockDelegate appRaterUserDidAgreeToSendFeedback]);
    
    id mockRatingManager = OCMPartialMock(self.raterManager);
    OCMExpect([mockRatingManager presentFeedbackMailComposerFromViewController:[OCMArg any]]);
    
    // Act
    [mockRatingManager userResponse_feedbackRequestAlert_sendFeedbackFromViewController:nil];
    
    // Assert
    OCMVerifyAll(self.mockDelegate);
    OCMVerifyAll(mockRatingManager);
}

- (void)testRequestFeedbackAlert_userPressedDeclineFeedback_shouldInvokeDelegate
{
    // Arrange
    OCMExpect([self.mockDelegate appRaterUserDidDeclineToSendFeedback]);
    
    // Act
    [self.raterManager userResponse_feedbackRequestAlert_declineFeedback];
    
    // Assert
    OCMVerifyAll(self.mockDelegate);
}

#pragma mark - Thank User

- (void)testThankUserAlert_shouldDisplayAlert
{
    // Arrange
    OCMExpect([self.mockDelegate appRaterWillDisplayThankYouAlert]);

    UIViewController* vc = [UIViewController new];
    
    // Act
    [self.raterManager displayThankYouAlertFromViewController:vc];
    
    // Assert
    OCMVerifyAll(self.mockDelegate);
    XCTAssertEqual(self.raterManager.currentAlert.actions.count, 1);
    XCTAssertEqualObjects(((UIAlertAction*)self.raterManager.currentAlert.actions[0]).title, @"Close");
}

- (void)testThankUserAlert_shouldInvokeDelegate
{
    // Arrange
    OCMExpect([self.mockDelegate appRaterWillDisplayThankYouAlert]);

    id mockCustomViewDelegate = OCMStrictProtocolMock(@protocol(ADARCustomViewsDelegate));
    OCMExpect([mockCustomViewDelegate displayThankYouAlertFromViewController:[OCMArg any]
                                                   completionBlock:[OCMArg any]]);
    
    self.raterManager.customViewsDelegate = mockCustomViewDelegate;
    UIViewController* vc = [UIViewController new];
    
    // Act
    [self.raterManager displayThankYouAlertFromViewController:vc];
    
    // Assert
    OCMVerifyAll(self.mockDelegate);
    OCMVerifyAll(mockCustomViewDelegate);
    XCTAssertNil(self.raterManager.currentAlert, @"Delegate should handle alert instead of Rating Manager");
}

#pragma mark - Feedback Email

- (void)testFeedbackEmail_shouldDisplayMailScreen
{
    // Arrange
    id mockMailComposer = OCMClassMock([MFMailComposeViewController class]);
    [[[mockMailComposer stub] andReturnValue:@YES] canSendMail];
    [[[mockMailComposer stub] andReturn:mockMailComposer] alloc];
    
    UIViewController* vc = [UIViewController new];
    
    // Act
    [self.raterManager presentFeedbackMailComposerFromViewController:vc];
    
    // Assert
    OCMVerify([mockMailComposer setMailComposeDelegate:self.raterManager]);
    OCMVerify([mockMailComposer setSubject:[OCMArg any]]);
    
    [ADMockingHelpers unmockForClass:[MFMailComposeViewController class]];
}

- (void)testFeedbackEmail_shouldInvokeDelegate
{
    // Arrange
    id mockCustomViewDelegate = OCMStrictProtocolMock(@protocol(ADARCustomViewsDelegate));
    OCMExpect([mockCustomViewDelegate presentFeedbackFormFromViewController:[OCMArg any]
                                                      userSentFeedbackBlock:[OCMArg any]
                                                userDidNotSendFeedbackBlock:[OCMArg any]]);
    
    self.raterManager.customViewsDelegate = mockCustomViewDelegate;
    UIViewController* vc = [UIViewController new];
    
    // Act
    [self.raterManager presentFeedbackMailComposerFromViewController:vc];
    
    // Assert
    OCMVerifyAll(mockCustomViewDelegate);
}

/// TODO: The dismiss completion is not called so test is not reliable
//- (void)testFeedbackEmail_sendShouldDismissMailAndThankUser
//{
//    // Arrange
//    id mockMailComposer = OCMClassMock([MFMailComposeViewController class]);
//    [[[mockMailComposer stub] andReturnValue:@YES] canSendMail];
//    [[[mockMailComposer stub] andReturn:mockMailComposer] alloc];
//    (void)[[[mockMailComposer stub] andReturn:mockMailComposer] init];
//
//    UIViewController* vc = [UIViewController new];
//    [[[mockMailComposer stub] andReturn:vc] presentingViewController];
//    [[[mockMailComposer stub] and:vc] presentingViewController];
//
//    [self.ratingManager presentFeedbackMailComposerFromViewController:vc];
//
//    // Act
//    [self.ratingManager mailComposeController:mockMailComposer
//                          didFinishWithResult:MFMailComposeResultSent
//                                        error:nil];
//
//    // Assert
//    XCTAssertEqual(self.ratingManager.currentAlert.actions.count, 5, @"Rating flow should present the thank you alert");
//    XCTAssertNil(self.ratingManager.currentAlert, @"Rating flow should present the thank you alert");
//    XCTAssertNotNil(self.ratingManager.currentAlert, @"Rating flow should present the thank you alert");
//}
//- (void)testFeedbackEmail_cancelShouldDismissMailScreen
//{
//    // Arrange
//    id mockMailComposer = OCMClassMock([MFMailComposeViewController class]);
//    [[[mockMailComposer stub] andReturnValue:@YES] canSendMail];
//    [[[mockMailComposer stub] andReturn:mockMailComposer] alloc];
//    (void)[[[mockMailComposer stub] andReturn:mockMailComposer] init];
//
//    UIViewController* vc = [UIViewController new];
//    [self.ratingManager presentFeedbackMailComposerFromViewController:vc];
//
//    // Act
//    [self.ratingManager mailComposeController:mockMailComposer
//                          didFinishWithResult:MFMailComposeResultCancelled
//                                        error:nil];
//
//    // Assert
//    XCTAssertNil(self.ratingManager.currentAlert, @"Rating flow should not present the thank you alert");
//    XCTAssertNotNil(self.ratingManager.currentAlert, @"Rating flow should present the thank you alert");
//}

@end
