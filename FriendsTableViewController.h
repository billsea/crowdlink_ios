//
//  FriendsTableViewController.h
//  crowdlink
//
//  Created by William Seaman on 2/17/15.
//  Copyright (c) 2015 Loudsoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

@interface FriendsTableViewController
    : UITableViewController <CLLocationManagerDelegate,
                             CBCentralManagerDelegate>

@property(nonatomic, strong) CBCentralManager *bluetoothManager;
@property(strong, nonatomic) CLBeaconRegion *myBeaconRegion;
@property(strong, nonatomic) CLLocationManager *locationManager;
@property(nonatomic, strong) NSMutableArray *friendsInRange;
@property(nonatomic, strong) NSMutableArray *allFacebookFriendsUsingTheApp;
@property UIBarButtonItem *logoutButton;
@property UIBarButtonItem *helpButton;
@property BOOL activityIndicatorStopped;

- (IBAction)LogoutUser:(id)sender;
- (IBAction)ViewHelp:(id)sender;
- (void)startBeaconMonitoring;
- (void)stopBeaconMonitoring;
- (void)requestFacebookFriends;
@end
