//
//  ADAppRaterTexts.m
//  ADAppRater
//
//  Created by Amir Shavit on 7/20/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import "ADAppRaterTexts.h"
#import "ADAppRater_Protected.h"

static NSString* const kUserSatisfactionAlertMessageFormatLocalKey = @"localUserSatisfactionAlertMessageFormat";
static NSString* const kUserSatisfactionAlertAnswerYesLocalKey = @"localUserSatisfactionAlertAnswerYes";
static NSString* const kUserSatisfactionAlertAnswerNoLocalKey = @"localUserSatisfactionAlertAnswerNo";

static NSString* const kAppRatingAlertTitleLocalKey = @"localAppRatingAlertTitle";
static NSString* const kAppRatingAlertMessageFormatLocalKey = @"localAppRatingAlertMessageFormat";
static NSString* const kAppRatingAlertAnswerRateFormatLocalKey = @"localAppRatingAlertAnswerRateFormat";
static NSString* const kAppRatingAlertAnswerRemindMeLocalKey = @"localAppRatingAlertAnswerRemindMe";
static NSString* const kAppRatingAlertAnswerDontRateLocalKey = @"localAppRatingAlertAnswerDontRate";

static NSString* const kUserFeedbackAlertMessageFormatLocalKey = @"localUserFeedbackAlertMessageFormat";
static NSString* const kUserFeedbackAlertAnswerYesLocalKey = @"localUserFeedbackAlertAnswerYes";
static NSString* const kUserFeedbackAlertAnswerNoLocalKey = @"localUserFeedbackAlertAnswerNo";

static NSString* const kThankUserAlertTitleLocalKey = @"localThankUserAlertTitle";
static NSString* const kThankUserAlertMessageLocalKey = @"localThankUserAlertMessage";
static NSString* const kThankUserAlertDismissLocalKey = @"localThankUserAlertDismiss";

static NSString* const kFeedbackFormSubjectLocalKey = @"localFeedbackFormSubject";

@interface ADAppRaterTexts ()
@property (nonatomic, strong) NSBundle *localizationBundle;
@end

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
            [NSString stringWithFormat:[self localizedStringForKey:kUserSatisfactionAlertMessageFormatLocalKey], self.applicationName]);
}

- (NSString*)userSatisfactionAlertAnswerYes;
{
    return (_userSatisfactionAlertAnswerYes ? _userSatisfactionAlertAnswerYes : [self localizedStringForKey:kUserSatisfactionAlertAnswerYesLocalKey]);
}

- (NSString*)userSatisfactionAlertAnswerNo;
{
    return (_userSatisfactionAlertAnswerNo ? _userSatisfactionAlertAnswerNo : [self localizedStringForKey:kUserSatisfactionAlertAnswerNoLocalKey]);
}

- (NSString*)appRatingAlertTitle
{
    return (_appRatingAlertTitle ? _appRatingAlertTitle : [self localizedStringForKey:kAppRatingAlertTitleLocalKey]);
}

- (NSString*)appRatingAlertMessage
{
    return (_appRatingAlertMessage ? _appRatingAlertMessage :
            [NSString stringWithFormat:[self localizedStringForKey:kAppRatingAlertMessageFormatLocalKey], self.applicationName]);
}

- (NSString*)appRatingAlertAnswerRate
{
    return (_appRatingAlertAnswerRate ? _appRatingAlertAnswerRate :
            [NSString stringWithFormat:[self localizedStringForKey:kAppRatingAlertAnswerRateFormatLocalKey], self.applicationName]);
}

- (NSString*)appRatingAlertAnswerRemindMe
{
    return (_appRatingAlertAnswerRemindMe ? _appRatingAlertAnswerRemindMe : [self localizedStringForKey:kAppRatingAlertAnswerRemindMeLocalKey]);
}

- (NSString*)appRatingAlertAnswerDontRate
{
    return (_appRatingAlertAnswerDontRate ? _appRatingAlertAnswerDontRate : [self localizedStringForKey:kAppRatingAlertAnswerDontRateLocalKey]);
}

- (NSString*)userFeedbackAlertTitle
{
    return (_userFeedbackAlertTitle ? _userFeedbackAlertTitle : nil);
}

- (NSString*)userFeedbackAlertMessage
{
    return (_userFeedbackAlertMessage ? _userFeedbackAlertMessage : [NSString stringWithFormat:[self localizedStringForKey:kUserFeedbackAlertMessageFormatLocalKey], self.applicationName]);
}

- (NSString*)userFeedbackAlertAnswerYes
{
    return (_userFeedbackAlertAnswerYes ? _userFeedbackAlertAnswerYes : [self localizedStringForKey:kUserFeedbackAlertAnswerYesLocalKey]);
}

- (NSString*)userFeedbackAlertAnswerNo
{
    return (_userFeedbackAlertAnswerNo ? _userFeedbackAlertAnswerNo : [self localizedStringForKey:kUserFeedbackAlertAnswerNoLocalKey]);
}

- (NSString*)thankUserAlertTitle
{
    return (_thankUserAlertTitle ? _thankUserAlertTitle : [self localizedStringForKey:kThankUserAlertTitleLocalKey]);
}

- (NSString*)thankUserAlertMessage
{
    return (_thankUserAlertMessage ? _thankUserAlertMessage : [self localizedStringForKey:kThankUserAlertMessageLocalKey]);
}

- (NSString*)thankUserAlertDismiss
{
    return (_thankUserAlertDismiss ? _thankUserAlertDismiss : [self localizedStringForKey:kThankUserAlertDismissLocalKey]);
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
    return (_feedbackFormSubject ? _feedbackFormSubject : [self localizedStringForKey:kFeedbackFormSubjectLocalKey]);
}

- (NSString*)feedbackFormBody
{
    return (_feedbackFormBody ? _feedbackFormBody : nil);
}

#pragma mark - Localization helper

- (NSString *)localizedStringForKey:(NSString *)key
{
    return [self.localizationBundle localizedStringForKey:key value:nil table:nil];
}

- (NSBundle *)localizationBundle
{
    if (_localizationBundle == nil)
    {
        // Load AppRater resource bundle
        NSString *bundlePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"ADAppRater" ofType:@"bundle"];
        _localizationBundle = [NSBundle bundleWithPath:bundlePath];
        
        // Iterate over languages to find first localized language available
        for (NSString* lang in [NSLocale preferredLanguages])
        {
            NSString* searchString = lang.copy;
            
            // If lang string not found - search language only with out locale
            if (![_localizationBundle.localizations containsObject:searchString])
            {
                searchString = [searchString componentsSeparatedByString:@"-"][0];
            }
            
            // Load language localization file if available
            if ([_localizationBundle.localizations containsObject:searchString])
            {
                bundlePath = [_localizationBundle pathForResource:searchString ofType:@"lproj"];
                _localizationBundle = [NSBundle bundleWithPath:bundlePath];
                break;
            }
        }
    }
    return _localizationBundle;
}

@end
