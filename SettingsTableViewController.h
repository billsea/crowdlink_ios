//
//  SettingsTableViewController.h
//  crowdlink
//
//  Created by William Seaman on 2/17/15.
//  Copyright (c) 2015 Loudsoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

@interface SettingsTableViewController
    : UITableViewController <CBPeripheralManagerDelegate>

@property(strong, nonatomic) CLBeaconRegion *myBeaconRegion;
@property(strong, nonatomic) NSDictionary *myBeaconData;
@property(strong, nonatomic) CBPeripheralManager *peripheralManager;
@property UISwitch *FindMeSwitch;
@property UISwitch *searchSwitch;
- (void)toggleBeaconBroadcast:(id)sender;
- (void)refreshFriends:(NSNotification *)notification;
@end
