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
@end

@implementation ADAppRaterTextsTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testAppRaterTextsAppName
{
    NSString* appName = @"someName";
    ADAppRaterTexts* textObject = [[ADAppRaterTexts alloc] initWithApplicationName:appName feedbackRecipientEmail:@"someMail"];

    XCTAssertEqualObjects(textObject.applicationName, appName);
}

- (void)testAppRater_SatisfactionAlert_DefaultTexts
{
    NSString* appName = @"someName";
    ADAppRaterTexts* textObject = [[ADAppRaterTexts alloc] initWithApplicationName:appName feedbackRecipientEmail:@"someMail"];
    
    XCTAssertEqualObjects(textObject.userSatisfactionAlertMessage, @"Do you find someName useful?");
    XCTAssertEqualObjects(textObject.userSatisfactionAlertAnswerYes, @"Yes");
    XCTAssertEqualObjects(textObject.userSatisfactionAlertAnswerNo, @"No");
    XCTAssertNil(textObject.userSatisfactionAlertTitle);
}

- (void)testAppRater_RatingAlert_DefaultTexts
{
    NSString* appName = @"someName";
    ADAppRaterTexts* textObject = [[ADAppRaterTexts alloc] initWithApplicationName:appName feedbackRecipientEmail:@"someMail"];
    
    XCTAssertEqualObjects(textObject.appRatingAlertTitle, @"Thank You");
    XCTAssertEqualObjects(textObject.appRatingAlertMessage, @"We're happy that you find someName useful! It'd be really helpful if you rated us.");
    XCTAssertEqualObjects(textObject.appRatingAlertAnswerRate, @"Rate someName");
    XCTAssertEqualObjects(textObject.appRatingAlertAnswerRemindMe, @"Remind Me Later");
    XCTAssertEqualObjects(textObject.appRatingAlertAnswerDontRate, @"No, Thanks");
}

- (void)testAppRater_FeedbackAlert_DefaultTexts
{
    NSString* appName = @"someName";
    ADAppRaterTexts* textObject = [[ADAppRaterTexts alloc] initWithApplicationName:appName feedbackRecipientEmail:@"someMail"];
    
    XCTAssertNil(textObject.userFeedbackAlertTitle);
    XCTAssertEqualObjects(textObject.userFeedbackAlertMessage, @"Please let us know how to make someName better for you!");
    XCTAssertEqualObjects(textObject.userFeedbackAlertAnswerYes, @"Contact us");
    XCTAssertEqualObjects(textObject.userFeedbackAlertAnswerNo, @"No thanks");
}

- (void)testAppRater_ThankUserAlert_DefaultTexts
{
    NSString* appName = @"someName";
    ADAppRaterTexts* textObject = [[ADAppRaterTexts alloc] initWithApplicationName:appName feedbackRecipientEmail:@"someMail"];
    
    XCTAssertEqualObjects(textObject.thankUserAlertTitle, @"Thanks!");
    XCTAssertEqualObjects(textObject.thankUserAlertMessage, @"Thank you for your feedback!");
    XCTAssertEqualObjects(textObject.thankUserAlertDismiss, @"Close");
}

- (void)testAppRater_FeedbackForm_DefaultTexts
{
    NSString* appName = @"someName";
    ADAppRaterTexts* textObject = [[ADAppRaterTexts alloc] initWithApplicationName:appName feedbackRecipientEmail:@"someMail"];
    
    XCTAssertEqualObjects(textObject.feedbackFormRecipient, @"someMail");
    XCTAssertEqualObjects(textObject.feedbackFormSubject, @"Feedback");
    XCTAssertNil(textObject.feedbackFormBody);
}

- (void)testAppRater_FeedbackForm_DefaultTexts_initWithoutEmail
{
    NSString* appName = @"someName";
    ADAppRaterTexts* textObject = [[ADAppRaterTexts alloc] initWithApplicationName:appName];
    
    id mockAppRater = OCMStrictClassMock([ADAppRater class]);
    OCMExpect([mockAppRater AR_logConsole:@"WARNING!! No email address provided for feedback form recipient!!"]);
    
    NSString* getMail = textObject.feedbackFormRecipient;
    
    XCTAssertNil(getMail);
    XCTAssertEqualObjects(textObject.feedbackFormSubject, @"Feedback");
    XCTAssertNil(textObject.feedbackFormBody);
    OCMVerifyAll(mockAppRater);
}

/**
@property (nonatomic, strong) NSString* userSatisfactionAlertTitle;
@property (nonatomic, strong) NSString* userSatisfactionAlertMessage;
@property (nonatomic, strong) NSString* userSatisfactionAlertAnswerYes;
@property (nonatomic, strong) NSString* userSatisfactionAlertAnswerNo;

@property (nonatomic, strong) NSString* appRatingAlertTitle;
@property (nonatomic, strong) NSString* appRatingAlertMessage;
@property (nonatomic, strong) NSString* appRatingAlertAnswerRate;
@property (nonatomic, strong) NSString* appRatingAlertAnswerRemindMe;
@property (nonatomic, strong) NSString* appRatingAlertAnswerDontRate;

@property (nonatomic, strong) NSString* userFeedbackAlertTitle;
@property (nonatomic, strong) NSString* userFeedbackAlertMessage;
@property (nonatomic, strong) NSString* userFeedbackAlertAnswerYes;
@property (nonatomic, strong) NSString* userFeedbackAlertAnswerNo;

@property (nonatomic, strong) NSString* thankUserAlertTitle;
@property (nonatomic, strong) NSString* thankUserAlertMessage;
@property (nonatomic, strong) NSString* thankUserAlertDismiss;

@property (nonatomic, strong) NSString* feedbackFormRecipient;
@property (nonatomic, strong) NSString* feedbackFormSubject;
@property (nonatomic, strong) NSString* feedbackFormBody;
8
*/
@end
