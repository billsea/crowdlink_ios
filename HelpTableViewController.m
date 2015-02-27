//
//  HelpTableViewController.m
//  crowdlink
//
//  Created by William Seaman on 2/26/15.
//  Copyright (c) 2015 Loudsoftware. All rights reserved.
//

#import "HelpTableViewController.h"
#import "HelpViewController.h"

@interface HelpTableViewController ()

@end

NSMutableArray * helpTopics;

@implementation HelpTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the title of the navigation item
    [[self navigationItem] setTitle:@"Help"];
    
    helpTopics = [[NSMutableArray alloc] init];
    [helpTopics addObject:@"Finding Friends"];
    [helpTopics addObject:@"Allow friends to find me"];
    [helpTopics addObject:@"Refresh Friends list"];
   
    
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
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [helpTopics count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    static NSString *CellIdentifier = @"HelpCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.accessoryView =nil;
   
    UILabel * loginLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 200, 30)];
    [loginLabel setTintColor:[UIColor blueColor]];
    [loginLabel setText:[helpTopics objectAtIndex:indexPath.row]];
    
    UIImageView * arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"forward-32.png"]];
    [arrowImage setFrame:CGRectMake(screenWidth - 32, 7, 30, 30)];
    
    [cell addSubview:loginLabel];
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
    HelpViewController *detailViewController = [[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    [detailViewController setHelpTopicIndex:[indexPath row]];
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
