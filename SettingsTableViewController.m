//
//  SettingsTableViewController.m
//  crowdlink
//
//  Created by William Seaman on 2/17/15.
//  Copyright (c) 2015 Loudsoftware. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "SettingsTableViewCell.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "AppSharedModel.h"
#import "GMDCircleLoader.h"

@interface SettingsTableViewController ()
//@property (strong, nonatomic) CBMutableCharacteristic   *transferCharacteristic;
@end

@implementation SettingsTableViewController

@synthesize FindMeSwitch = _FindMeSwitch;
@synthesize searchSwitch = _searchSwitch;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    // Set the title of the navigation item
    [[self navigationItem] setTitle:@"Settings"];
    
    _searchSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(screenWidth - 75, 15, 30, 30)];
    [_searchSwitch setTag:0];
    [_searchSwitch setOn:TRUE];
     [_searchSwitch addTarget:self action:@selector(toggleBeaconBroadcast:) forControlEvents:UIControlEventValueChanged];
    
    _FindMeSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(screenWidth - 75, 15, 30, 30)];
    [_FindMeSwitch setTag:1];
   [_FindMeSwitch addTarget:self action:@selector(toggleBeaconBroadcast:) forControlEvents:UIControlEventValueChanged];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    if([[self peripheralManager] isAdvertising])
    {
        //start activity indicator
        [GMDCircleLoader setOnView:self.view withTitle:@"Broadcasting to Friends" animated:YES];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    if([[self peripheralManager] isAdvertising])
    {
        //stop activity indicator
        [GMDCircleLoader hideFromView:self.view animated:YES];
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
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    static NSString *CellIdentifier = @"SettingsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.accessoryView =nil;
    
    UILabel * cellLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,3, cell.frame.size.width - 100, 50)];
    
    [cellLabel setTextColor:[UIColor whiteColor]];


    UIButton * btnRefresh = [[UIButton alloc] init];

    [btnRefresh setFrame:CGRectMake(4,3,170, 50)];
    [btnRefresh setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btnRefresh setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    
    switch ([indexPath row]) {
                    case 0:
                        [cellLabel setText:@"Search for Friends"];
                        [[cell contentView] addSubview: cellLabel];
                        [[cell contentView] addSubview:_searchSwitch];
                        break;
                    case 1:
                        [cellLabel setText:@"Let Friends Find Me"];
                        [[cell contentView] addSubview: cellLabel];
                        [[cell contentView] addSubview:_FindMeSwitch];
                        break;
                    case 2:
                        [btnRefresh addTarget:self action:@selector(refreshFriends:) forControlEvents:UIControlEventTouchUpInside];
                        [btnRefresh setTitle:@"Refresh Friends List" forState:UIControlStateNormal];
                        [[cell contentView] addSubview:btnRefresh];
                        break;
                    default:
                        break;
                }


    return cell;
    
}

- (void)showPicture:(NSNotification*)notification
{
    
}

- (void)refreshFriends:(NSNotification*)notification
{
    //only needed if a new friend has downloaded the app for first use
    [[[AppSharedModel sharedModel] friendsTableViewController] requestFacebookFriends];
    
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [appDelegate showMessage:@"Friends list has been refreshed" withTitle:@"Completed"];
}

#pragma mark - beacon methods
- (void)toggleBeaconBroadcast:(id)sender
{
    UISwitch * broadcastToggle = sender;
    
    //tag 0 is search, tag 1 is fine me
    if(![[self peripheralManager] isAdvertising] && [broadcastToggle isOn] && broadcastToggle.tag == 1)
    {
        //stop beacon monitoring
        [[[AppSharedModel sharedModel] friendsTableViewController]stopBeaconMonitoring];
        
        //start beacon broadcast
        
        // Create a NSUUID object - todo: pull from db
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:APPLICATION_BEACON_UUID];
        
        AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
       //get last eight characters of facebook user id, and split to create major(4 digits) and minor(4 digits)
        NSInteger idStringLength = [[appDelegate UserFacebookID] length];
        NSString * lastEightOfID = [[appDelegate UserFacebookID] substringWithRange:NSMakeRange (idStringLength - 8, 8)];
        
        NSString * firstFourOfSubId = [lastEightOfID substringWithRange:NSMakeRange (0, 4)];//for major
        NSString * lastFourOfSubId = [lastEightOfID substringWithRange:NSMakeRange (4, 4)];//for minor
        
        NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
        
        UInt16 maj = [[formatter numberFromString:firstFourOfSubId] unsignedShortValue];
        UInt16 min = [[formatter numberFromString:lastFourOfSubId] unsignedShortValue];
        
        // Initialize the Beacon Region
        self.myBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                      major:maj
                                                                      minor:min
                                                                 identifier:@"crowdlink"];
        
        // Get the beacon data to advertise
        self.myBeaconData = [self.myBeaconRegion peripheralDataWithMeasuredPower:nil];
        
        // Start the peripheral manager
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                         queue:nil
                                                                       options:nil];
        
        
        //start activity indicator
        [GMDCircleLoader setOnView:self.view withTitle:@"Broadcasting to Friends" animated:YES];
        [[AppSharedModel sharedModel] setBeaconIsBroadcasting:TRUE];
        
        //set switch ui state
       [_searchSwitch setOn:FALSE];
       
        [appDelegate showMessage:@"You are now broadcasting to friends. To search for friends, switch on 'Search for Friends'" withTitle:@"Broadcasting..."];
        
        
    }
    else if([[self peripheralManager] isAdvertising] && [broadcastToggle isOn] && broadcastToggle.tag == 0)
    {
        //stop broadcasting
        [[self peripheralManager] stopAdvertising];
        
        //start beacon monitoring
        [[[AppSharedModel sharedModel] friendsTableViewController]startBeaconMonitoring];
        
        
        //stop activity indicator
        [GMDCircleLoader hideFromView:self.view animated:YES];
        [[AppSharedModel sharedModel] setBeaconIsBroadcasting:FALSE];
        
        [_searchSwitch setOn:TRUE];
        [_FindMeSwitch setOn:FALSE];
        
        [self showSearchMessage];
        
        
    }
    else if(![[self peripheralManager] isAdvertising] && ![broadcastToggle isOn] && broadcastToggle.tag == 0)
    {
        //stop broadcasting
        [[self peripheralManager] stopAdvertising];
        
        //start beacon monitoring
        [[[AppSharedModel sharedModel] friendsTableViewController]startBeaconMonitoring];
        
        
        //stop activity indicator
        [GMDCircleLoader hideFromView:self.view animated:YES];
        [[AppSharedModel sharedModel] setBeaconIsBroadcasting:FALSE];
        
        
        //keep search switch in on position
        
        [_searchSwitch setOn:TRUE];
        
   
    }
    else
    {
        //stop broadcasting
        [[self peripheralManager] stopAdvertising];
        
        //start beacon monitoring
        [[[AppSharedModel sharedModel] friendsTableViewController]startBeaconMonitoring];
        
        
        //stop activity indicator
        [GMDCircleLoader hideFromView:self.view animated:YES];
        [[AppSharedModel sharedModel] setBeaconIsBroadcasting:FALSE];
        
       [_searchSwitch setOn:TRUE];
        
       [self showSearchMessage];

    }
    
    
    [[self tableView] reloadData];
   
}

-(void)showSearchMessage
{
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [appDelegate showMessage:@"You are now searching for friends. To broadcast to friends, switch on 'Let Friends Find Me'" withTitle:@"Searching..."];
}

//- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
//{
//    NSLog(@"Central subscribed to characteristic");
//    [_peripheralManager setDesiredConnectionLatency:CBPeripheralManagerConnectionLatencyLow forCentral:central];
//    
//}

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager*)peripheral
{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn)
    {
        // Bluetooth is on
        
        // Update our status label
        NSLog(@"Broadcasting...");
        
//        ///////set latency to LOW = Should callback to didSubscribeToCharacteristic(above) but it's not gettng called /////////
//        // Start with the CBMutableCharacteristic
//        self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:APPLICATION_BEACON_UUID]
//                 properties:CBCharacteristicPropertyNotify
//                      value:nil
//                permissions:CBAttributePermissionsReadable];
//        
//        // Then the service
//        CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:APPLICATION_BEACON_UUID]
//                                                                           primary:YES];
//        
//        // Add the characteristic to the service
//        transferService.characteristics = @[self.transferCharacteristic];
//        
//        // And add it to the peripheral manager
//        [self.peripheralManager addService:transferService];
//        ////////////
      
  
        
        
        // Start broadcasting
        [self.peripheralManager startAdvertising:self.myBeaconData];
    }
    else if (peripheral.state == CBPeripheralManagerStatePoweredOff)
    {
        // Update our status label
        NSLog(@"Stopped...");
        
        // Bluetooth isn't on. Stop broadcasting
        [self.peripheralManager stopAdvertising];
    }
    else if (peripheral.state == CBPeripheralManagerStateUnsupported)
    {
        NSLog(@"Unsupported...");
    }
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

@end
