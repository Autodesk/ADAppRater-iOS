//
//  ADMockingHelpers.h
//  ADAppRater Demo
//
//  Created by Amir Shavit on 6/14/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OCMock/OCMock.h>

@interface ADMockingHelpers : NSObject

+ (void)unmockForClass:(Class)cl;

@end
