//
//  ADARManagerBaseTestCase.h
//  ADAppRater Demo
//
//  Created by Amir Shavit on 6/16/15.
//  Copyright (c) 2015 Autodesk. All rights reserved.
//

#import "ADTestCase.h"
#import "ADAppRater.h"
#import "ADAppStoreConnector.h"

@interface ADARManagerBaseTestCase : ADTestCase

@property (nonatomic, strong) ADAppRater* raterManager;

// Dependencies
@property (nonatomic, strong) id mockUserDefaults;
@property (nonatomic, strong) id mockAppStoreConnector;

@end
