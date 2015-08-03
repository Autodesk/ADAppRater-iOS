//
//  ADAppRatingTexts.h
//  ADAppRating Demo
//
//  Created by Amir Shavit on 7/20/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADAppRatingTexts : NSObject

@property (nonatomic, strong) NSString* applicationName;

@property (nonatomic, strong) NSString* userSatisfactionAlertTitle;
@property (nonatomic, strong) NSString* userSatisfactionAlertMessage;
@property (nonatomic, strong) NSString* userSatisfactionAlertAnswerYes;
@property (nonatomic, strong) NSString* userSatisfactionAlertAnswerNo;

@property (nonatomic, strong) NSString* userRatingAlertTitle;
@property (nonatomic, strong) NSString* userRatingAlertMessage;
@property (nonatomic, strong) NSString* userRatingAlertAnswerRate;
@property (nonatomic, strong) NSString* userRatingAlertAnswerRemindMe;
@property (nonatomic, strong) NSString* userRatingAlertAnswerDontRate;

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
