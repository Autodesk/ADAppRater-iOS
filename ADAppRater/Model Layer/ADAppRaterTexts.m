//
//  ADAppRaterTexts.m
//  ADAppRater
//
//  Created by Amir Shavit on 7/20/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import "ADAppRaterTexts.h"
#import "ADAppRater_Protected.h"

static NSString* const kUserSatisfactionAlertMessageFormat = @"Do you find %@ useful?";
static NSString* const kUserSatisfactionAlertAnswerYes = @"Yes";
static NSString* const kUserSatisfactionAlertAnswerNo = @"No";

static NSString* const kAppRatingAlertTitle = @"Thank You";
static NSString* const kAppRatingAlertMessageFormat = @"We're happy that you find %@ useful! It'd be really helpful if you rated us.";
static NSString* const kAppRatingAlertAnswerRateFormat = @"Rate %@";
static NSString* const kAppRatingAlertAnswerRemindMe = @"Remind Me Later";
static NSString* const kAppRatingAlertAnswerDontRate = @"No, Thanks";

static NSString* const kUserFeedbackAlertMessageFormat = @"Please let us know how to make %@ better for you!";
static NSString* const kUserFeedbackAlertAnswerYes = @"Contact us";
static NSString* const kUserFeedbackAlertAnswerNo = @"No thanks";

static NSString* const kThankUserAlertTitle = @"Thanks!";
static NSString* const kThankUserAlertMessage = @"Thank you for your feedback!";
static NSString* const kThankUserAlertDismiss = @"Close";

static NSString* const kFeedbackFormRecipient;
static NSString* const kFeedbackFormSubject = @"Feedback";

@implementation ADAppRaterTexts

- (instancetype)init
{
    NSString* applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if (applicationName.length == 0)
    {
        applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
    }

    return [self initWithApplicationName:applicationName];
}

- (instancetype)initWithApplicationName:(NSString*)applicationName
{
    return [self initWithApplicationName:applicationName feedbackRecipientEmail:nil];
}

- (instancetype)initWithApplicationName:(NSString*)applicationName
                 feedbackRecipientEmail:(NSString*)email
{
    self = [super init];
    if (self)
    {
        self.applicationName = applicationName;
        
        self.feedbackFormRecipient = email;
    }
    return self;
}

#pragma mark - Override Getters

- (NSString*)userSatisfactionAlertTitle
{
    return (_userSatisfactionAlertTitle ? _userSatisfactionAlertTitle : nil);
}

- (NSString*)userSatisfactionAlertMessage;
{
    return (_userSatisfactionAlertMessage ? _userSatisfactionAlertMessage :
            [NSString stringWithFormat:kUserSatisfactionAlertMessageFormat, self.applicationName]);
}

- (NSString*)userSatisfactionAlertAnswerYes;
{
    return (_userSatisfactionAlertAnswerYes ? _userSatisfactionAlertAnswerYes : kUserSatisfactionAlertAnswerYes);
}

- (NSString*)userSatisfactionAlertAnswerNo;
{
    return (_userSatisfactionAlertAnswerNo ? _userSatisfactionAlertAnswerNo : kUserSatisfactionAlertAnswerNo);
}

- (NSString*)appRatingAlertTitle
{
    return (_appRatingAlertTitle ? _appRatingAlertTitle : kAppRatingAlertTitle);
}

- (NSString*)appRatingAlertMessage
{
    return (_appRatingAlertMessage ? _appRatingAlertMessage :
            [NSString stringWithFormat:kAppRatingAlertMessageFormat, self.applicationName]);
}

- (NSString*)appRatingAlertAnswerRate
{
    return (_appRatingAlertAnswerRate ? _appRatingAlertAnswerRate :
            [NSString stringWithFormat:kAppRatingAlertAnswerRateFormat, self.applicationName]);
}

- (NSString*)appRatingAlertAnswerRemindMe
{
    return (_appRatingAlertAnswerRemindMe ? _appRatingAlertAnswerRemindMe : kAppRatingAlertAnswerRemindMe);
}

- (NSString*)appRatingAlertAnswerDontRate
{
    return (_appRatingAlertAnswerDontRate ? _appRatingAlertAnswerDontRate : kAppRatingAlertAnswerDontRate);
}

- (NSString*)userFeedbackAlertTitle
{
    return (_userFeedbackAlertTitle ? _userFeedbackAlertTitle : nil);
}

- (NSString*)userFeedbackAlertMessage
{
    return (_userFeedbackAlertMessage ? _userFeedbackAlertMessage : [NSString stringWithFormat:kUserFeedbackAlertMessageFormat, self.applicationName]);
}

- (NSString*)userFeedbackAlertAnswerYes
{
    return (_userFeedbackAlertAnswerYes ? _userFeedbackAlertAnswerYes : kUserFeedbackAlertAnswerYes);
}

- (NSString*)userFeedbackAlertAnswerNo
{
    return (_userFeedbackAlertAnswerNo ? _userFeedbackAlertAnswerNo : kUserFeedbackAlertAnswerNo);
}

- (NSString*)thankUserAlertTitle
{
    return (_thankUserAlertTitle ? _thankUserAlertTitle : kThankUserAlertTitle);
}

- (NSString*)thankUserAlertMessage
{
    return (_thankUserAlertMessage ? _thankUserAlertMessage : kThankUserAlertMessage);
}

- (NSString*)thankUserAlertDismiss
{
    return (_thankUserAlertDismiss ? _thankUserAlertDismiss : kThankUserAlertDismiss);
}

- (NSString*)feedbackFormRecipient
{
    if (_feedbackFormRecipient == nil)
    {
        [ADAppRater AR_logConsole:@"WARNING!! No email address provided for feedback form recipient!!"];
    }
    return _feedbackFormRecipient;
}

- (NSString*)feedbackFormSubject
{
    return (_feedbackFormSubject ? _feedbackFormSubject : kFeedbackFormSubject);
}

- (NSString*)feedbackFormBody
{
    return (_feedbackFormBody ? _feedbackFormBody : nil);
}

@end
