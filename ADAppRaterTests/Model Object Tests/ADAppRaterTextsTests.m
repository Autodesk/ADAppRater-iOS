//
//  ADAppRaterTextsTests.m
//  ADAppRater Demo
//
//  Created by Amir Shavit on 9/9/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import "ADTestCase.h"
#import "ADAppRaterTexts.h"
#import "ADAppRater_Protected.h"

@interface ADAppRaterTextsTests : ADTestCase
@property (nonatomic, strong) id mockLocale;
@end

@implementation ADAppRaterTextsTests

- (void)setUp
{
    [super setUp];
    
    [ADMockingHelpers unmockForClass:[NSLocale class]];
   self.mockLocale = OCMClassMock([NSLocale class]);
    OCMStub([self.mockLocale preferredLanguages]).andReturn(@[@"en"]);
}

- (void)tearDown
{
    self.mockLocale = nil;
    [ADMockingHelpers unmockForClass:[NSLocale class]];

    [super tearDown];
}

- (void)testAppRaterTextsAppName
{
    // Arrange
    NSString* appName = @"someName";
    ADAppRaterTexts* textObject = [[ADAppRaterTexts alloc] initWithApplicationName:appName feedbackRecipientEmail:@"someMail"];

    // Assert
    XCTAssertEqualObjects(textObject.applicationName, appName);
}

- (void)testAppRater_SatisfactionAlert_DefaultTexts
{
    // Arrange
    NSString* appName = @"someName";
    ADAppRaterTexts* textObject = [[ADAppRaterTexts alloc] initWithApplicationName:appName feedbackRecipientEmail:@"someMail"];
    
    // Assert
    XCTAssertEqualObjects(textObject.userSatisfactionAlertMessage, @"Do you find someName useful?");
    XCTAssertEqualObjects(textObject.userSatisfactionAlertAnswerYes, @"Yes");
    XCTAssertEqualObjects(textObject.userSatisfactionAlertAnswerNo, @"No");
    XCTAssertEqualObjects(textObject.userSatisfactionAlertTitle, @"");
}

- (void)testAppRater_SatisfactionAlert_CustomTexts
{
    // Arrange
    NSString* appName = @"someName";
    ADAppRaterTexts* textObject = [[ADAppRaterTexts alloc] initWithApplicationName:appName feedbackRecipientEmail:@"someMail"];
    
    textObject.userSatisfactionAlertTitle = @"A title";
    textObject.userSatisfactionAlertMessage = @"A message";
    textObject.userSatisfactionAlertAnswerYes = @"A yes";
    textObject.userSatisfactionAlertAnswerNo = @"A no";
    
    // Assert
    XCTAssertNotNil(textObject.userSatisfactionAlertTitle,
                    @"This should not be the default string");
    XCTAssertNotEqualObjects(textObject.userSatisfactionAlertMessage, @"Do you find someName useful?",
                             @"This should not be the default string");
    XCTAssertNotEqualObjects(textObject.userSatisfactionAlertAnswerYes, @"Yes",
                             @"This should not be the default string");
    XCTAssertNotEqualObjects(textObject.userSatisfactionAlertAnswerNo, @"No",
                             @"This should not be the default string");
}

- (void)testAppRater_RatingAlert_DefaultTexts
{
    // Arrange
    NSString* appName = @"someName";
    ADAppRaterTexts* textObject = [[ADAppRaterTexts alloc] initWithApplicationName:appName feedbackRecipientEmail:@"someMail"];
    
    // Assert
    XCTAssertEqualObjects(textObject.appRatingAlertTitle, @"Thank You");
    XCTAssertEqualObjects(textObject.appRatingAlertMessage, @"We're happy that you find someName useful! It'd be really helpful if you rated us.");
    XCTAssertEqualObjects(textObject.appRatingAlertAnswerRate, @"Rate someName");
    XCTAssertEqualObjects(textObject.appRatingAlertAnswerRemindMe, @"Remind Me Later");
    XCTAssertEqualObjects(textObject.appRatingAlertAnswerDontRate, @"No, Thanks");
}

- (void)testAppRater_RatingAlert_CustomTexts
{
    // Arrange
    NSString* appName = @"someName";
    ADAppRaterTexts* textObject = [[ADAppRaterTexts alloc] initWithApplicationName:appName feedbackRecipientEmail:@"someMail"];

    textObject.appRatingAlertTitle = @"A title";
    textObject.appRatingAlertMessage = @"A message";
    textObject.appRatingAlertAnswerRate = @"Button 1";
    textObject.appRatingAlertAnswerRemindMe = @"Button 2";
    textObject.appRatingAlertAnswerDontRate = @"Button 3";

    // Assert
    XCTAssertNotEqualObjects(textObject.appRatingAlertTitle, @"Thank You",
                             @"This should not be the default string");
    XCTAssertNotEqualObjects(textObject.appRatingAlertMessage, @"We're happy that you find someName useful! It'd be really helpful if you rated us.",
                             @"This should not be the default string");
    XCTAssertNotEqualObjects(textObject.appRatingAlertAnswerRate, @"Rate someName",
                             @"This should not be the default string");
    XCTAssertNotEqualObjects(textObject.appRatingAlertAnswerRemindMe, @"Remind Me Later",
                             @"This should not be the default string");
    XCTAssertNotEqualObjects(textObject.appRatingAlertAnswerDontRate, @"No, Thanks",
                          @"This should not be the default string");
}

- (void)testAppRater_FeedbackAlert_DefaultTexts
{
    // Arrange
    NSString* appName = @"someName";
    ADAppRaterTexts* textObject = [[ADAppRaterTexts alloc] initWithApplicationName:appName feedbackRecipientEmail:@"someMail"];
    
    // Assert
    XCTAssertEqualObjects(textObject.userFeedbackAlertTitle, @"");
    XCTAssertEqualObjects(textObject.userFeedbackAlertMessage, @"Please let us know how to make someName better for you!");
    XCTAssertEqualObjects(textObject.userFeedbackAlertAnswerYes, @"Contact us");
    XCTAssertEqualObjects(textObject.userFeedbackAlertAnswerNo, @"No thanks");
}

- (void)testAppRater_FeedbackAlert_CustomTexts
{
    // Arrange
    NSString* appName = @"someName";
    ADAppRaterTexts* textObject = [[ADAppRaterTexts alloc] initWithApplicationName:appName feedbackRecipientEmail:@"someMail"];

    textObject.userFeedbackAlertTitle = @"A title";
    textObject.userFeedbackAlertMessage = @"A message";
    textObject.userFeedbackAlertAnswerYes = @"A yes";
    textObject.userFeedbackAlertAnswerNo = @"A no";

    // Assert
    XCTAssertNotNil(textObject.userFeedbackAlertTitle,
                 @"This should not be the default string");
    XCTAssertNotEqualObjects(textObject.userFeedbackAlertMessage, @"Please let us know how to make someName better for you!",
                          @"This should not be the default string");
    XCTAssertNotEqualObjects(textObject.userFeedbackAlertAnswerYes, @"Contact us",
                          @"This should not be the default string");
    XCTAssertNotEqualObjects(textObject.userFeedbackAlertAnswerNo, @"No thanks",
                          @"This should not be the default string");
}

- (void)testAppRater_ThankUserAlert_DefaultTexts
{
    // Arrange
    NSString* appName = @"someName";
    ADAppRaterTexts* textObject = [[ADAppRaterTexts alloc] initWithApplicationName:appName feedbackRecipientEmail:@"someMail"];
    
    // Assert
    XCTAssertEqualObjects(textObject.thankUserAlertTitle, @"Thanks!");
    XCTAssertEqualObjects(textObject.thankUserAlertMessage, @"Thank you for your feedback!");
    XCTAssertEqualObjects(textObject.thankUserAlertDismiss, @"Close");
}

- (void)testAppRater_ThankUserAlert_CustomTexts
{
    // Arrange
    NSString* appName = @"someName";
    ADAppRaterTexts* textObject = [[ADAppRaterTexts alloc] initWithApplicationName:appName feedbackRecipientEmail:@"someMail"];

    textObject.thankUserAlertTitle = @"Title";
    textObject.thankUserAlertMessage = @"Message";
    textObject.thankUserAlertDismiss = @"Button";

    // Assert
    XCTAssertNotEqualObjects(textObject.thankUserAlertTitle, @"Thanks!",
                          @"This should not be the default string");
    XCTAssertNotEqualObjects(textObject.thankUserAlertMessage, @"Thank you for your feedback!",
                          @"This should not be the default string");
    XCTAssertNotEqualObjects(textObject.thankUserAlertDismiss, @"Close",
                          @"This should not be the default string");
}

- (void)testAppRater_FeedbackForm_DefaultTexts
{
    // Arrange
    NSString* appName = @"someName";
    ADAppRaterTexts* textObject = [[ADAppRaterTexts alloc] initWithApplicationName:appName feedbackRecipientEmail:@"someMail"];
    
    // Assert
    XCTAssertEqualObjects(textObject.feedbackFormRecipient, @"someMail");
    XCTAssertEqualObjects(textObject.feedbackFormSubject, @"Feedback");
    XCTAssertNil(textObject.feedbackFormBody);
}

- (void)testAppRater_FeedbackForm_CustomTexts
{
    // Arrange
    NSString* appName = @"someName";
    ADAppRaterTexts* textObject = [[ADAppRaterTexts alloc] initWithApplicationName:appName feedbackRecipientEmail:@"someMail"];

    textObject.feedbackFormRecipient = @"other email";
    textObject.feedbackFormSubject = @"subject";
    textObject.feedbackFormBody = @"body";

    // Assert
    XCTAssertNotEqualObjects(textObject.feedbackFormRecipient, @"someMail",
                          @"This should not be the default string");
    XCTAssertNotEqualObjects(textObject.feedbackFormSubject, @"Feedback",
                          @"This should not be the default string");
    XCTAssertNotNil(textObject.feedbackFormBody,
                 @"This should not be the default string");
}

- (void)testAppRater_FeedbackForm_DefaultTexts_initWithoutEmail
{
    // Arrange
    NSString* appName = @"someName";
    ADAppRaterTexts* textObject = [[ADAppRaterTexts alloc] initWithApplicationName:appName];
    
    id mockAppRater = OCMStrictClassMock([ADAppRater class]);
    OCMExpect([mockAppRater AR_logConsole:@"WARNING!! No email address provided for feedback form recipient!!"]);

    // Act
    NSString* getMail = textObject.feedbackFormRecipient;
    
    // Assert
    XCTAssertNil(getMail);
    XCTAssertEqualObjects(textObject.feedbackFormSubject, @"Feedback");
    XCTAssertNil(textObject.feedbackFormBody);
    OCMVerifyAll(mockAppRater);
}

@end
