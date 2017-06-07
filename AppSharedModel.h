//
//  AppSharedModel.h
//  crowdlink
//
//  Created by William Seaman on 2/19/15.
//  Copyright (c) 2015 Loudsoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FriendsTableViewController.h"
#import "FriendDetailViewController.h"

@interface AppSharedModel : NSObject
{
    NSManagedObjectModel *dModel;
}

+(id)sharedModel;

@property (nonatomic, weak) FriendsTableViewController * friendsTableViewController;
@property (nonatomic, weak) FriendDetailViewController * friendsDetailViewController;
@property (nonatomic, strong) NSMutableArray * friendsInRangeAll;
@property BOOL beaconIsBroadcasting;

@end
