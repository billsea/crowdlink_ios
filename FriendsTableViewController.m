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
#import "Friend.h"
#import "FriendDetailViewController.h"
#import "AppSharedModel.h"
#import "GMDCircleLoader.h"
#import "HelpTableViewController.h"

@interface FriendsTableViewController ()

@property UIBarButtonItem * logoutButton;
@property UIBarButtonItem * helpButton;

@end

@implementation FriendsTableViewController

@synthesize bluetoothManager = _bluetoothManager;
@synthesize myBeaconRegion = _myBeaconRegion;
@synthesize locationManager = _locationManager;
@synthesize friendsInRange = _friendsInRange;
@synthesize activityIndicatorStopped = _activityIndicatorStopped;



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the title of the navigation item
    [[self navigationItem] setTitle:@"Friends Nearby"];
    
    
    //add new navigation bar button
    self.logoutButton = [[UIBarButtonItem alloc]
                            //initWithImage:[UIImage imageNamed:@"reload-50.png"]
                            initWithTitle:@"Logout"
                            style:UIBarButtonItemStyleBordered
                            target:self
                            action:@selector(LogoutUser:)];
    //self.addClientButton.tintColor = [UIColor blackColor];
    [[self navigationItem] setLeftBarButtonItem:self.logoutButton];
    
    
    //add help navigation bar button
    self.helpButton = [[UIBarButtonItem alloc]
                       //initWithImage:[UIImage imageNamed:@"reload-50.png"]
                       initWithTitle:@"Help"
                       style:UIBarButtonItemStyleBordered
                       target:self
                       action:@selector(ViewHelp:)];
    //self.addClientButton.tintColor = [UIColor blackColor];
    [[self navigationItem] setRightBarButtonItem:self.helpButton];

    
    //check network
    [self checkNetworkConnection];
    
    //check bluetooth status
    [self detectBluetooth];
    
    
    //initialize friends in range
    self.friendsInRange = [[NSMutableArray alloc] init];
    
    self.activityIndicatorStopped = TRUE;
    
    //Monitor for broadcasting beacons
    [self startBeaconMonitoring];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //request friends
    [self requestFacebookFriends];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    if(self.activityIndicatorStopped==FALSE)
    {
        //stop activity indicator
        [GMDCircleLoader hideFromView:self.view animated:YES];
        self.activityIndicatorStopped = TRUE;
        
        

    }
}


- (void)viewDidAppear:(BOOL)animated
{
    if([[AppSharedModel sharedModel] beaconIsBroadcasting] == false && self.activityIndicatorStopped == YES)
    {
        [GMDCircleLoader hideFromView:self.view animated:YES];
         //star activity indicator
         [GMDCircleLoader setOnView:self.view withTitle:@"Searching for friends" animated:YES];
         self.activityIndicatorStopped = FALSE;
    }
    else if ([[AppSharedModel sharedModel] beaconIsBroadcasting] == TRUE)
    {
        [GMDCircleLoader hideFromView:self.view animated:YES];
        
        //set activity indicator for broadcast
        [GMDCircleLoader setOnView:self.view withTitle:@"Broadcasting to Friends" animated:YES];
        
        [[self friendsInRange] removeAllObjects];
        
        [[self tableView] reloadData];
        
       // [GMDCircleLoader hideFromView:self.view animated:YES];
        self.activityIndicatorStopped = TRUE;
    }
    
}

- (IBAction)ViewHelp:(id)sender
{
    HelpTableViewController * helpView = [[HelpTableViewController alloc] init];
    // Push the view controller.
    [self.navigationController pushViewController:helpView animated:YES];
    
}

#pragma mark facebook methods

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
            
           // NSLog(@"I have a friend named %@ with id %@", friend.name, friend.id);
        }
        
        //[[self tableView] reloadData];
    }];
}

- (IBAction)LogoutUser:(id)sender
{
    [self stopBeaconMonitoring];
    
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
    return [[self friendsInRange] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //stop activity indicator
    [GMDCircleLoader hideFromView:self.view animated:YES];
   self.activityIndicatorStopped = TRUE;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    static NSString *CellIdentifier = @"HelpCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.accessoryView =nil;
    
    
    //Configure the cell...
    Friend * friendInRange = [[self friendsInRange] objectAtIndex:[indexPath row]];
    UIImage * fbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:friendInRange.PictureURL]]];
    
    
    //friend fb picture
    UIImageView * friendImage = [[UIImageView alloc] initWithImage:fbImage];
    [friendImage setBackgroundColor:[UIColor blackColor]];
    [friendImage setFrame:CGRectMake(5, 5, 75, 75)];
    
//    //round edges
//    friendImage.layer.cornerRadius = 3;
//    friendImage.clipsToBounds = YES;
//    friendImage.layer.borderWidth = 1.0f;
//    friendImage.layer.backgroundColor = [UIColor blackColor].CGColor;
    
    
    //friend name
    
    UILabel * friendLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 30, 200, 30)];
    [friendLabel setTextColor:[UIColor whiteColor]];
    
    [friendLabel setText:friendInRange.FullName];
    
    //navigation arrow
    UIImageView * arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"showSettings.png"]];
    [arrowImage setBackgroundColor:[UIColor blackColor]];
    [arrowImage setFrame:CGRectMake(screenWidth - 32, 20, 30, 48)];
    
    

    [cell addSubview:friendImage];
    [cell addSubview:friendLabel];
    [cell addSubview:arrowImage];
    
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


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    FriendDetailViewController *detailViewController = [[FriendDetailViewController alloc] initWithNibName:@"FriendDetailViewController" bundle:nil];
    
    // Pass the selected object to the new view controller.
    Friend * selFriendInRange = [[self friendsInRange] objectAtIndex:[indexPath row]];
    
    [detailViewController setSelectedFriend:selFriendInRange];
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    
    [[AppSharedModel sharedModel] setFriendsDetailViewController:detailViewController];
}


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
                                                             identifier:@"crowdlink"];
    
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
    //clear all from friendsInRange array
    [[self friendsInRange] removeAllObjects];
    [[[AppSharedModel sharedModel] friendsInRangeAll] removeAllObjects];
    
    //check if broadcasting beacon is a friend, and add to list of friends in range
    for(CLBeacon *beacon in beacons)
    {
        //get major minor
        NSString * majMinId = [NSString stringWithFormat:@"%@%@",beacon.major,beacon.minor];
        
        for (NSDictionary<FBGraphUser>* friend in _allFacebookFriendsUsingTheApp)
        {
            
          //NOTE: Using friend.id fails validation for app store!
            
            NSInteger idStringLength = [[friend objectForKey:@"id"] length];

            
            NSString * lastEightOfFriendID = [[friend objectForKey:@"id"] substringWithRange:NSMakeRange (idStringLength - 8, 8)];
            
            if([lastEightOfFriendID isEqualToString:majMinId])
               //if(([lastEightOfFriendID isEqualToString:majMinId]) || [majMinId isEqualToString:@"3630347456"]) //testing with estimote beacon
            {
                
                Friend * friendInRange = [[Friend alloc] init];
                friendInRange.FullName = friend.name;
                friendInRange.FacebookID = [friend objectForKey:@"id"];
                
//                //testing with estimote beacon
//                if([majMinId isEqualToString:@"3630347456"])
//                {
//                   friendInRange.FullName = @"Estimote Beacon";
//                    friendInRange.FacebookID = @"3630347456";
//                }
                
                friendInRange.FirstName = friend.first_name;
                friendInRange.LastName = friend.last_name;
                
                 friendInRange.PictureURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [friend objectForKey:@"id"]];
                
                friendInRange.Proximity = [NSString stringWithFormat:@"%ld",beacon.proximity];
                friendInRange.Accuracy = [NSString stringWithFormat:@"%f",beacon.accuracy];
                
                //add to friends in range
                [[self friendsInRange] addObject:friendInRange];
                [[[AppSharedModel sharedModel] friendsInRangeAll] addObject:friendInRange];
                
                //TODO: add friendInRange to core data table
            }
        }
 
    }
    
//    //start activity indicator
//    if([[self friendsInRange] count] == 0 && self.activityIndicatorStopped == TRUE)
//    {
//        [GMDCircleLoader hideFromView:self.view animated:YES];
//        [GMDCircleLoader setOnView:self.view withTitle:@"Searching for friends..." animated:YES];
//        self.activityIndicatorStopped = FALSE;
//    }
    
    //reload active friends table
        [[self tableView] reloadData];
    
    //update selected friend details
    if([[[AppSharedModel sharedModel] friendsDetailViewController] isViewLoaded])
    {
        [[[AppSharedModel sharedModel] friendsDetailViewController] updateDisplay];
    }
    
//    //collection of beacons in range
//    CLBeacon *nearestBeacon = [beacons firstObject];
//    
//    if(beacons.count > 0)
//    {
//        // You can retrieve the beacon data from its properties
//                NSString *uuid = nearestBeacon.proximityUUID.UUIDString;
//                NSString *major = [NSString stringWithFormat:@"%@", nearestBeacon.major];
//                NSString *minor = [NSString stringWithFormat:@"%@", nearestBeacon.minor];
//                NSString *proximity= [NSString stringWithFormat:@"%d", nearestBeacon.proximity];
//                NSString *accuracy= [NSString stringWithFormat:@"%f", nearestBeacon.accuracy];
//
//                NSLog(@"UUID: %@",uuid);
//                NSLog(@"MAJOR: %@", major);
//                NSLog(@"MINOR: %@", minor);
//                NSLog(@"PROXIMITY: %@", proximity);
//                NSLog(@"ACCURACY: %@",accuracy);
//        
//
//        switch(nearestBeacon.proximity) {
//            case CLProximityFar:
//                //message = @"You are far away from the beacon";
//                
//                break;
//            case CLProximityNear:
//                //message = @"You are proximity near of the beacon";
//                break;
//            case CLProximityImmediate:
//                //message = @"You are in the immediate proximity of the beacon";
//                
//                break;
//            case CLProximityUnknown:
//                return;
//        }
//
//    }
//    else
//    {
//        
//    }
    
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

- (void)stopBeaconMonitoring
{
    //stop beacon monitoring
    [self.locationManager stopRangingBeaconsInRegion:self.myBeaconRegion];
    [self.locationManager stopMonitoringForRegion:self.myBeaconRegion];
    [self.locationManager stopUpdatingLocation];
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
