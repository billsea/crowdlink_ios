//
//  FriendsTableViewController.m
//  crowdlink
//
//  Created by William Seaman on 2/17/15.
//  Copyright (c) 2015 Loudsoftware. All rights reserved.
//
//this view controller will list the names of people broadcasting


#import "FriendsTableViewController.h"
#import "LoginViewController.h"
#import "Reachability.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "FriendsTableViewCell.h"

@interface FriendsTableViewController ()

@property UIBarButtonItem * logoutButton;

@end

@implementation FriendsTableViewController

@synthesize bluetoothManager = _bluetoothManager;
@synthesize myBeaconRegion = _myBeaconRegion;
@synthesize locationManager = _locationManager;
@synthesize friendsInRange = _friendsInRange;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the title of the navigation item
    [[self navigationItem] setTitle:@"Active"];
    
    
    //add new navigation bar button
    self.logoutButton = [[UIBarButtonItem alloc]
                            //initWithImage:[UIImage imageNamed:@"reload-50.png"]
                            initWithTitle:@"Logout"
                            style:UIBarButtonItemStyleBordered
                            target:self
                            action:@selector(LogoutUser:)];
    //self.addClientButton.tintColor = [UIColor blackColor];
    [[self navigationItem] setRightBarButtonItem:self.logoutButton];
    
    
    //check network
    [self checkNetworkConnection];
    
    //check bluetooth status
    [self detectBluetooth];
    
    //Monitor for broadcasting beacons
    [self startBeaconMonitoring];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //request friends
    [self requestFacebookFriends];
    
}

- (void)requestFacebookFriends
{
    self.allFacebookFriendsUsingTheApp = [[NSMutableArray alloc] init];
    
    //get friends list
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        NSArray* friends = [result objectForKey:@"data"];
        NSLog(@"Found: %lu friends", (unsigned long)friends.count);
        for (NSDictionary<FBGraphUser>* friend in friends) {
            
            [_allFacebookFriendsUsingTheApp addObject:friend];
            
            NSLog(@"I have a friend named %@ with id %@", friend.name, friend.id);
        }
        
        [[self tableView] reloadData];
    }];
}

- (IBAction)LogoutUser:(id)sender
{
    [self FacebookUserLogout];
    
    LoginViewController * loginView = [[LoginViewController alloc] init];
    //show new login view
    [self.navigationController pushViewController:loginView animated:YES];
}

//clear facebook session
- (void)FacebookUserLogout

{
    [[FBSession activeSession] closeAndClearTokenInformation];
    [[FBSession activeSession] close];
    [FBSession setActiveSession:nil];
    NSLog(@"The active facebook session: %@", [[FBSession activeSession] description]);
    
    ACAccountStore *store = [[ACAccountStore alloc] init];
    NSArray *fbAccounts = [store accountsWithAccountType:[store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook]];
    for (ACAccount *fb in fbAccounts) {
        [store renewCredentialsForAccount:fb completion:^(ACAccountCredentialRenewResult renewResult, NSError *error) {
            
        }];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return [[self allFacebookFriendsUsingTheApp] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"FriendsTableViewCell";
    
    FriendsTableViewCell *cell = (FriendsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FriendsTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    // Configure the cell...
    NSDictionary<FBGraphUser>* friend = [[self allFacebookFriendsUsingTheApp] objectAtIndex:[indexPath row]];
    
    [[cell friendNameLabel] setText:friend.name];
    
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma  mark - Beacon methods

- (void)startBeaconMonitoring
{
    // Initialize location manager and set ourselves as the delegate
    self.locationManager = [[CLLocationManager alloc] init];
    
    // New iOS 8 request for Always Authorization, required for iBeacons to work!
    //NOTE: add NSLocationAlwaysUsageDescription to beaconreceiver-info.plist to propt for location services.
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    self.locationManager.delegate = self;
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager requestAlwaysAuthorization];
    
    // Create a NSUUID with the same UUID as the broadcasting beacon
   
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:APPLICATION_BEACON_UUID];
    
    // Setup a new region with that UUID and same identifier as the broadcasting beacon
    self.myBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                             identifier:@"zipDin"];
    
    self.myBeaconRegion.notifyEntryStateOnDisplay = YES;
    self.myBeaconRegion.notifyOnEntry=YES;
    self.myBeaconRegion.notifyOnExit=YES;
    
    // Tell location manager to start monitoring for the beacon region
    [self.locationManager startMonitoringForRegion:self.myBeaconRegion];
    [self.locationManager startRangingBeaconsInRegion:self.myBeaconRegion];
    [self.locationManager startUpdatingLocation];
    
    
    // Check if beacon monitoring is available for this device
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Monitoring not available, check hardware" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil]; [alert show]; return;
    }
}

- (void)locationManager:(CLLocationManager*)manager didEnterRegion:(CLRegion *)region
{
    // We entered a region, now start looking for our target beacons!
    //self.statusLabel.text = @"Finding beacons.";
    NSLog(@"Finding beacons...");
    [self.locationManager startRangingBeaconsInRegion:self.myBeaconRegion];
}

-(void)locationManager:(CLLocationManager*)manager didExitRegion:(CLRegion *)region
{
    // Exited the region
    //self.statusLabel.text = @"exited region - none found";
    NSLog(@"exited region - none found");
    [self.locationManager stopRangingBeaconsInRegion:self.myBeaconRegion];
    
//    [self sendLocalNotificationWithMessage:[NSString stringWithFormat:@"%@",[[[CustomerSharedModel sharedModel] closestEstablishment] ExitMessage]]];
}


-(void)locationManager:(CLLocationManager*)manager
       didRangeBeacons:(NSArray*)beacons
              inRegion:(CLBeaconRegion*)region
{
    
    
    //collection of beacons in range
    CLBeacon *nearestBeacon = [beacons firstObject];
    
    if(beacons.count > 0)
    {
        // You can retrieve the beacon data from its properties
        //        NSString *uuid = nearestBeacon.proximityUUID.UUIDString;
        //        NSString *major = [NSString stringWithFormat:@"%@", nearestBeacon.major];
        //        NSString *minor = [NSString stringWithFormat:@"%@", nearestBeacon.minor];
        //        NSString *proximity= [NSString stringWithFormat:@"%d", nearestBeacon.proximity];
        //        NSString *accuracy= [NSString stringWithFormat:@"%f", nearestBeacon.accuracy];
        //
        //        NSLog(@"UUID: %@",uuid);
        //      NSLog(@"MAJOR: %@", major);
        //        NSLog(@"PROXIMITY: %@", proximity);
        //        NSLog(@"ACCURACY: %@",accuracy);
        //
        
        //set accuracy in shared model
        // [[CustomerSharedModel sharedModel] setBeaconAccuracy:accuracy];
        
        switch(nearestBeacon.proximity) {
            case CLProximityFar:
                //message = @"You are far away from the beacon";
                
                break;
            case CLProximityNear:
                
                //set the major of the nearest beacon - update when major changes
//                if(![_nearestEstablishmentMajor isEqual: nearestBeacon.major])
//                {
//                    //get closest establishment data from web service
//                    [[CustomerSharedModel sharedModel] EstablishmentData:nearestBeacon.major];
//                    
//                    //add closest major id to shared model property
//                    [self setNearestEstablishmentMajor:nearestBeacon.major];
//                }
                
                break;
            case CLProximityImmediate:
                //message = @"You are in the immediate proximity of the beacon";
                
                break;
            case CLProximityUnknown:
                return;
        }
        
        
    }
    else{
     }
}


-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    /*
     A user can transition in or out of a region while the application is not running. When this happens CoreLocation will launch the application momentarily, call this delegate method and we will let the user know via a local notification.
     */
    
    
    if(state == CLRegionStateInside)
    {
        
        //Start Ranging
        [manager startRangingBeaconsInRegion:self.myBeaconRegion];
    }
    else if(state == CLRegionStateOutside)
    {
        
        //[self sendLocalNotificationWithMessage:@"You're outside a Zipdin region"];
    }
    else
    {
        return;
    }
    
    /*
     If the application is in the foreground, it will get a callback to application:didReceiveLocalNotification:.
     If it's not, iOS will display the notification to the user.
     */
    
    //    if (state == CLRegionStateInside)
    //    {
    //        //self.statusLabel.text = @"state inside region";
    //
    //        //Start Ranging
    //        [manager startRangingBeaconsInRegion:self.myBeaconRegion];
    //    }
    //    else
    //    {
    //        self.statusLabel.text = @"state outside";
    //        //Stop Ranging here
    //    }
}


- (void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    //self.statusLabel.text = @"monitoring started";
    //NSLog(@"monitoring started");
    [self.locationManager requestStateForRegion:self.myBeaconRegion];
}

#pragma mark - system check
- (void)detectBluetooth
{
    if(!self.bluetoothManager)
    {
        // Put on main queue so we can call UIAlertView from delegate callbacks.
        self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    }
    [self centralManagerDidUpdateState:self.bluetoothManager]; // Show initial state
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    //    NSString *stateString = nil;
    //
    //    switch(bluetoothManager.state)
    //    {
    //        case CBCentralManagerStateResetting: stateString = @"The connection with the system service was momentarily lost, update imminent."; break;
    //        case CBCentralManagerStateUnsupported: stateString = @"The platform doesn't support Bluetooth Low Energy."; break;
    //        case CBCentralManagerStateUnauthorized: stateString = @"The app is not authorized to use Bluetooth Low Energy."; break;
    //        case CBCentralManagerStatePoweredOff: stateString = @"Bluetooth is currently powered off."; break;
    //        case CBCentralManagerStatePoweredOn: stateString = @"Bluetooth is currently powered on and available to use."; break;
    //        default: stateString = @"State unknown, update imminent."; break;
    //    }
    //
    //
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bluetooth" message:stateString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil]; [alert show]; return;
    
}

- (void) checkNetworkConnection
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        NSString * alertTitle = @"Connection Error";
        NSString * alertText = [NSString stringWithFormat:@"Device is not connected to the internet."];
        [self showMessage:alertText withTitle:alertTitle];
    }
}

#pragma mark utility methods
// Show an alert message
- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

@end