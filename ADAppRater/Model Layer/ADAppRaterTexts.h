//
//  ADAppRaterTexts.h
//  ADAppRater
//
//  Created by Amir Shavit on 7/20/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  @brief `ADAppRaterTexts` class bunles the text strings used for the default UI flow.
 *  @discussion To change the default strings, you can either access the default instance: `[ADAppRater sharedInstance].localStrings`
 *  @discussion Or create a new instance `[ADAppRater sharedInstance].localStrings = [[ADAppRaterTexts alloc] initWithApplicationName:@"App Name" feedbackRecipientEmail:@"support@your.mail"]`
 *  @discussion To customize the texts ADAppRater will display, insert your customized strings to the appropriate `ADAppRaterTexts` property.
 *  @discussion If you have implemented every method of the `ADARCustomViewsDelegate` protocol, you do not have to set your strings to this class, as your custom view will handle the texts.
 *  @warning Leaving this class unchanged will use the default strings (localized to available laguages).
 */
@interface ADAppRaterTexts : NSObject

@property (nonatomic, strong) NSString* applicationName;

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


/**
 *  Instantiate a new text strings file using default text strings
 *  @param applicationName Application name to insert in some text strings format
 */
- (instancetype)initWithApplicationName:(NSString*)applicationName;

/**
 *  Instantiate a new text strings file using default text strings
 *  @param applicationName Application name to insert in some text strings format
 *  @param email           Email address to use as reciepient for default feedback form
 */
- (instancetype)initWithApplicationName:(NSString*)applicationName
                 feedbackRecipientEmail:(NSString*)email;

@end
