//
//  ADMockingHelpers.m
//  ADAppRater Demo
//
//  Created by Amir Shavit on 6/14/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import "ADMockingHelpers.h"

@implementation ADMockingHelpers

+ (void)unmockForClass:(Class)cl
{
    id dummyMock = OCMClassMock(cl);
    [dummyMock stopMocking];
}

@end
