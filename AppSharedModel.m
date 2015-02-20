//
//  AppSharedModel.m
//  crowdlink
//
//  Created by William Seaman on 2/19/15.
//  Copyright (c) 2015 Loudsoftware. All rights reserved.
//

#import "AppSharedModel.h"

@interface AppSharedModel()

@end

@implementation AppSharedModel

static AppSharedModel *_model;

@synthesize friendsTableViewController = _friendsTableViewController;
@synthesize friendsDetailViewController = _friendsDetailViewController;
@synthesize friendsInRangeAll = _friendsInRangeAll;

+(void)initialize
{
    if(self == [AppSharedModel class]) {
        _model = [[self alloc] init];
    }
}
+(AppSharedModel*)sharedModel
{
    return _model;
}

- (id)init
{
    if(_model){
        return _model;
    }
    
    self = [super init];
    
    self.friendsInRangeAll = [[NSMutableArray alloc] init];
    
    return self;
}

@end
