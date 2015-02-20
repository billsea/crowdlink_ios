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

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the title of the navigation item
    [[self navigationItem] setTitle:@"Settings"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
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
    
    static NSString *simpleTableIdentifier = @"SettingsTableViewCell";
    
    SettingsTableViewCell *cell = (SettingsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SettingsTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    
    UILabel * cellLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0, cell.frame.size.width - 100, 50)];

    
    
    UISwitch * tSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(cell.frame.size.width - 60,5, 50, 50)];
    UIButton * btnRefresh = [[UIButton alloc] init];
                             
    [btnRefresh setFrame:CGRectMake(10,0,140, 50)];
    [btnRefresh setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btnRefresh setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    
    // Configure the cell...
    switch ([indexPath row]) {
        case 0:
            [tSwitch addTarget:self action:@selector(toggleBeaconBroadcast:) forControlEvents:UIControlEventValueChanged];
            [cellLabel setText:@"Let others find me"];
            [cell addSubview: cellLabel];
            [cell addSubview:tSwitch];
            break;
        case 1:
            [tSwitch addTarget:self action:@selector(showPicture:) forControlEvents:UIControlEventValueChanged];
            [cellLabel setText:@"Show my picture"];
            [cell addSubview:cellLabel];
            [cell addSubview:tSwitch];
            break;
        case 2:
            [btnRefresh addTarget:self action:@selector(refreshFriends:) forControlEvents:UIControlEventTouchUpInside];
            [btnRefresh setTitle:@"Refresh Friends" forState:UIControlStateNormal];
            [cell addSubview:btnRefresh];
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
}

#pragma mark - beacon methods
- (void)toggleBeaconBroadcast:(id)sender
{
    UISwitch * broadcastToggle = sender;
    
    if(![[self peripheralManager] isAdvertising] && [broadcastToggle isOn])
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
    }
    else
    {
        //stop broadcasting
        [[self peripheralManager] stopAdvertising];
        
        //start beacon monitoring
        [[[AppSharedModel sharedModel] friendsTableViewController]startBeaconMonitoring];
        
    }
}

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager*)peripheral
{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn)
    {
        // Bluetooth is on
        
        // Update our status label
        NSLog(@"Broadcasting...");
        
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
