//
//  ADAppStoreConnector.m
//  ADAppRating Demo
//
//  Created by Amir Shavit on 6/14/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import "ADAppStoreConnector.h"
#import <UIKit/UIKit.h>

static NSString *const kARErrorDomain = @"AppRateErrorDomain";

typedef NS_ENUM(NSUInteger, ARErrorCode)
{
    ARErrorBundleIdDoesNotMatchAppStore = 1,
    ARErrorApplicationNotFoundOnAppStore,
    ARErrorApplicationIsNotLatestVersion,
    ARErrorCouldNotOpenRatingPageURL
};

static NSString *const kARAppStoreIDKey = @"AppRateAppStoreID";


static NSString *const kARAppLookupURLFormat = @"http://itunes.apple.com/%@/lookup";

static NSString *const kARiOSAppStoreURLScheme = @"itms-apps";
static NSString *const kARiOSAppStoreURLFormat = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@&pageNumber=0&sortOrdering=2&mt=8";
static NSString *const kARiOS7AppStoreURLFormat = @"itms-apps://itunes.apple.com/app/id%@";

#define REQUEST_TIMEOUT 60.0

@interface ADAppStoreConnector ()

@property (nonatomic) NSUInteger appStoreID;
@property (nonatomic) NSUInteger appStoreGenreID;
@property (nonatomic, copy) NSString *applicationBundleID;
@property (nonatomic, strong) NSString *appStoreCountry;
@property (nonatomic, strong) NSURL *ratingsURL;

@property (nonatomic, assign) BOOL checkingForAppStoreID;


@end

@implementation ADAppStoreConnector

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // Get country
        self.appStoreCountry = [(NSLocale *)[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
        if ([self.appStoreCountry isEqualToString:@"150"])
        {
            self.appStoreCountry = @"eu";
        }
        else if (!self.appStoreCountry || [[self.appStoreCountry stringByReplacingOccurrencesOfString:@"[A-Za-z]{2}" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, 2)] length])
        {
            self.appStoreCountry = @"us";
        }
        
        // Bundle id
        self.applicationBundleID = [[NSBundle mainBundle] bundleIdentifier];
    }
    return self;
}

#pragma mark - Public Methods

- (void)setApplicationBundleID:(NSString *)applicationBundleID
{
    _applicationBundleID = applicationBundleID;
}

- (void)setAppStoreID:(NSUInteger)appStoreID
{
    _appStoreID = appStoreID;
}

- (BOOL)isAppStoreAvailable
{
    //first check iTunes
    NSError *error = nil;
    NSInteger statusCode = [self checkForConnectivity:&error];

    if (statusCode == 0 || error)
    {
        return NO;
    }
    else
        return YES;
}

- (void)openRatingsPageInAppStore
{
    if (!self.ratingsURL && self.appStoreID == 0)
    {
        self.checkingForAppStoreID = YES;
        [self checkForConnectivityInBackground];
        return;
    }
    
    NSString *cantOpenMessage = nil;
    
#if TARGET_IPHONE_SIMULATOR
    
    if ([[self.ratingsURL scheme] isEqualToString:kARiOSAppStoreURLScheme])
    {
        cantOpenMessage = @"ADAppRating could not open the ratings page because the App Store is not available on the iOS simulator";
    }
    
#elif DEBUG
    
    if (![[UIApplication sharedApplication] canOpenURL:self.ratingsURL])
    {
        cantOpenMessage = [NSString stringWithFormat:@"ADAppRating was unable to open the specified ratings URL: %@", self.ratingsURL];
    }
    
#endif
    
    if (cantOpenMessage)
    {
        NSLog(@"%@", cantOpenMessage);
        NSError *error = [NSError errorWithDomain:kARErrorDomain
                                             code:ARErrorCouldNotOpenRatingPageURL
                                         userInfo:@{NSLocalizedDescriptionKey: cantOpenMessage}];
        if ([self.delegate respondsToSelector:@selector(appRateAppStoreCouldNotConnect:)])
        {
            [self.delegate appRateAppStoreCouldNotConnect:error];
        }
    }
    else
    {
        NSLog(@"ADAppRating will open the App Store ratings page using the following URL: %@", self.ratingsURL);
        
        [[UIApplication sharedApplication] openURL:self.ratingsURL];
        if ([self.delegate respondsToSelector:@selector(appRateAppStoreDidOpen)])
        {
            [self.delegate appRateAppStoreDidOpen];
        }
    }
}

#pragma mark - Private Helpers

- (NSURL *)ratingsURL
{
    if (_ratingsURL)
    {
        return _ratingsURL;
    }
    
    else if (self.appStoreID > 0)
    {
        NSLog(@"ADAppRating could not find the App Store ID for this application. If the application is not intended for App Store release then you must specify a custom ratingsURL.");
        
        NSString *URLString;
        
        float iOSVersion = [[UIDevice currentDevice].systemVersion floatValue];
        if (iOSVersion >= 7.0f && iOSVersion < 7.1f)
        {
            URLString = kARiOS7AppStoreURLFormat;
        }
        else
        {
            URLString = kARiOSAppStoreURLFormat;
        }
        
        _ratingsURL = [NSURL URLWithString:[NSString stringWithFormat:URLString, @(self.appStoreID)]];
        return _ratingsURL;
    }
    else return nil;
}

#pragma mark HTTP Management

- (NSString *)valueForKey:(NSString *)key inJSON:(id)json
{
    if ([json isKindOfClass:[NSString class]])
    {
        //use legacy parser
        NSRange keyRange = [json rangeOfString:[NSString stringWithFormat:@"\"%@\"", key]];
        if (keyRange.location != NSNotFound)
        {
            NSInteger start = keyRange.location + keyRange.length;
            NSRange valueStart = [json rangeOfString:@":" options:(NSStringCompareOptions)0 range:NSMakeRange(start, [(NSString *)json length] - start)];
            if (valueStart.location != NSNotFound)
            {
                start = valueStart.location + 1;
                NSRange valueEnd = [json rangeOfString:@"," options:(NSStringCompareOptions)0 range:NSMakeRange(start, [(NSString *)json length] - start)];
                if (valueEnd.location != NSNotFound)
                {
                    NSString *value = [json substringWithRange:NSMakeRange(start, valueEnd.location - start)];
                    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    while ([value hasPrefix:@"\""] && ![value hasSuffix:@"\""])
                    {
                        if (valueEnd.location == NSNotFound)
                        {
                            break;
                        }
                        NSInteger newStart = valueEnd.location + 1;
                        valueEnd = [json rangeOfString:@"," options:(NSStringCompareOptions)0 range:NSMakeRange(newStart, [(NSString *)json length] - newStart)];
                        value = [json substringWithRange:NSMakeRange(start, valueEnd.location - start)];
                        value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    }
                    
                    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
                    value = [value stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
                    value = [value stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\r" withString:@"\r"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\t" withString:@"\t"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\f" withString:@"\f"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\b" withString:@"\f"];
                    
                    while (YES)
                    {
                        NSRange unicode = [value rangeOfString:@"\\u"];
                        if (unicode.location == NSNotFound || unicode.location + unicode.length == 0)
                        {
                            break;
                        }
                        
                        uint32_t c = 0;
                        NSString *hex = [value substringWithRange:NSMakeRange(unicode.location + 2, 4)];
                        NSScanner *scanner = [NSScanner scannerWithString:hex];
                        [scanner scanHexInt:&c];
                        
                        if (c <= 0xffff)
                        {
                            value = [value stringByReplacingCharactersInRange:NSMakeRange(unicode.location, 6) withString:[NSString stringWithFormat:@"%C", (unichar)c]];
                        }
                        else
                        {
                            //convert character to surrogate pair
                            uint16_t x = (uint16_t)c;
                            uint16_t u = (c >> 16) & ((1 << 5) - 1);
                            uint16_t w = (uint16_t)u - 1;
                            unichar high = 0xd800 | (w << 6) | x >> 10;
                            unichar low = (uint16_t)(0xdc00 | (x & ((1 << 10) - 1)));
                            
                            value = [value stringByReplacingCharactersInRange:NSMakeRange(unicode.location, 6) withString:[NSString stringWithFormat:@"%C%C", high, low]];
                        }
                    }
                    return value;
                }
            }
        }
    }
    else
    {
        return json[key];
    }
    return nil;
}

- (void)setAppStoreIDOnMainThread:(NSString *)appStoreIDString
{
    _appStoreID = [appStoreIDString integerValue];
    [[NSUserDefaults standardUserDefaults] setInteger:_appStoreID forKey:kARAppStoreIDKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)connectionSucceeded
{
    if (self.checkingForAppStoreID)
    {
        //no longer checking
        self.checkingForAppStoreID = NO;
        
        //open app store
        [self openRatingsPageInAppStore];
    }
}

- (void)connectionError:(NSError *)error
{
    if (self.checkingForAppStoreID)
    {
        //no longer checking
        self.checkingForAppStoreID = NO;
        
        //log the error
        if (error)
        {
            NSLog(@"ADAppRating rating process failed because: %@", [error localizedDescription]);
        }
        else
        {
            NSLog(@"ADAppRating rating process failed because an unknown error occured");
        }
        
        if ([self.delegate respondsToSelector:@selector(appRateAppStoreCouldNotConnect:)])
        {
            [self.delegate appRateAppStoreCouldNotConnect:error];
        }
    }
}

- (void)checkForConnectivityInBackground
{
    if ([NSThread isMainThread])
    {
        [self performSelectorInBackground:@selector(checkForConnectivityInBackground) withObject:nil];
        return;
    }
    
    @autoreleasepool
    {
        //prevent concurrent checks
        static BOOL checking = NO;
        if (checking) return;
        checking = YES;
        
        //first check iTunes
        NSError *error = nil;
        [self checkForConnectivity:&error];
        
        // Handle errors (ignoring sandbox issues)
        if (error && !(error.code == EPERM && [error.domain isEqualToString:NSPOSIXErrorDomain] && _appStoreID))
        {
            [self performSelectorOnMainThread:@selector(connectionError:) withObject:error waitUntilDone:YES];
        }
        else if (self.appStoreID)
        {
            //show prompt
            [self performSelectorOnMainThread:@selector(connectionSucceeded) withObject:nil waitUntilDone:YES];
        }
        
        //finished
        checking = NO;
    }
}

- (NSInteger)checkForConnectivity:(NSError **)error;
{
    NSString *iTunesServiceURL = [NSString stringWithFormat:kARAppLookupURLFormat, self.appStoreCountry];
    if (_appStoreID) //important that we check ivar and not getter in case it has changed
    {
        iTunesServiceURL = [iTunesServiceURL stringByAppendingFormat:@"?id=%@", @(_appStoreID)];
    }
    else
    {
        iTunesServiceURL = [iTunesServiceURL stringByAppendingFormat:@"?bundleId=%@", self.applicationBundleID];
    }
    
    NSLog(@"ADAppRating is checking %@ to retrieve the App Store details...", iTunesServiceURL);

    NSURLResponse *response = nil;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:iTunesServiceURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:REQUEST_TIMEOUT];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
    NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
    if (data && statusCode == 200)
    {
        //in case error is garbage...
        error = nil;
        
        id json = nil;
        if ([NSJSONSerialization class])
        {
            json = [[NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:error][@"results"] lastObject];
        }
        else
        {
            //convert to string
            json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        
        if (!error)
        {
            //check bundle ID matches
            NSString *bundleID = [self valueForKey:@"bundleId" inJSON:json];
            if (bundleID)
            {
                if ([bundleID isEqualToString:self.applicationBundleID])
                {
                    //get genre
                    if (self.appStoreGenreID == 0)
                    {
                        self.appStoreGenreID = [[self valueForKey:@"primaryGenreId" inJSON:json] integerValue];
                    }
                    
                    //get app id
                    if (!_appStoreID)
                    {
                        NSString *appStoreIDString = [self valueForKey:@"trackId" inJSON:json];
                        [self performSelectorOnMainThread:@selector(setAppStoreIDOnMainThread:) withObject:appStoreIDString waitUntilDone:YES];
                        
                        NSLog(@"ADAppRating found the app on iTunes. The App Store ID is %@", appStoreIDString);
                    }
                    
                    /// TODO: Check version
//                    if (self.onlyPromptIfLatestVersion)
//                    {
//                        NSString *latestVersion = [self valueForKey:@"version" inJSON:json];
//                        if ([latestVersion compare:self.applicationVersion options:NSNumericSearch] == NSOrderedDescending)
//                        {
//                            NSLog(@"ADAppRating found that the installed application version (%@) is not the latest version on the App Store, which is %@", self.applicationVersion, latestVersion);
//                            
//                            error = [NSError errorWithDomain:kARErrorDomain code:ARErrorApplicationIsNotLatestVersion userInfo:@{NSLocalizedDescriptionKey: @"Installed app is not the latest version available"}];
//                        }
//                    }
                }
                else
                {
                    NSLog(@"ADAppRating found that the application bundle ID (%@) does not match the bundle ID of the app found on iTunes (%@) with the specified App Store ID (%@)", self.applicationBundleID, bundleID, @(self.appStoreID));
                    
                    *error = [NSError errorWithDomain:kARErrorDomain
                                                 code:ARErrorBundleIdDoesNotMatchAppStore
                                             userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Application bundle ID does not match expected value of %@", bundleID]}];
                }
            }
            else if (_appStoreID || !self.ratingsURL)
            {
                NSLog(@"ADAppRating could not find this application on iTunes. If your app is not intended for App Store release then you must specify a custom ratingsURL. If this is the first release of your application then it's not a problem that it cannot be found on the store yet");
                
                *error = [NSError errorWithDomain:kARErrorDomain
                                             code:ARErrorApplicationNotFoundOnAppStore
                                         userInfo:@{NSLocalizedDescriptionKey: @"The application could not be found on the App Store."}];
            }
            else if (!_appStoreID)
            {
                NSLog(@"ADAppRating could not find your app on iTunes. If your app is not yet on the store or is not intended for App Store release then don't worry about this");
            }
        }
    }
    else if (statusCode >= 400)
    {
        //http error
        NSString *message = [NSString stringWithFormat:@"The server returned a %@ error", @(statusCode)];
        *error = [NSError errorWithDomain:@"HTTPResponseErrorDomain" code:statusCode userInfo:@{NSLocalizedDescriptionKey: message}];
    }
    
    return statusCode;
}

@end
