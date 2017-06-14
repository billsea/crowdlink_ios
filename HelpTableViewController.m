
//
//  HelpTableViewController.m
//  crowdlink
//
//  Created by William Seaman on 2/26/15.
//  Copyright (c) 2015 Loudsoftware. All rights reserved.
//

#import "HelpTableViewController.h"
#import "HelpViewController.h"

@interface HelpTableViewController () {
  NSMutableArray *_helpTopics;
}

@end

@implementation HelpTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  // Set the title of the navigation item
  [[self navigationItem] setTitle:@"Help"];

  _helpTopics = [[NSMutableArray alloc] init];
  [_helpTopics addObject:@"Finding Friends"];
  [_helpTopics addObject:@"Allow friends to find me"];
  [_helpTopics addObject:@"Refresh Friends list"];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return [_helpTopics count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  CGRect screenRect = [[UIScreen mainScreen] bounds];
  CGFloat screenWidth = screenRect.size.width;

  static NSString *CellIdentifier = @"HelpCell";
  UITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:CellIdentifier];
  }

  [cell setBackgroundColor:[UIColor clearColor]];
  cell.accessoryView = nil;

  UILabel *loginLabel =
      [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 200, 30)];
  [loginLabel setTextColor:[UIColor whiteColor]];

  [loginLabel setText:[_helpTopics objectAtIndex:indexPath.row]];

  UIImageView *arrowImage = [[UIImageView alloc]
      initWithImage:[UIImage imageNamed:@"showSettings.png"]];
  [arrowImage setBackgroundColor:[UIColor blackColor]];
  [arrowImage setFrame:CGRectMake(screenWidth - 32, 7, 30, 48)];

  [cell addSubview:loginLabel];
  [cell addSubview:arrowImage];

  return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  HelpViewController *detailViewController =
      [[HelpViewController alloc] initWithNibName:@"HelpViewController"
                                           bundle:nil];
  [detailViewController setHelpTopicIndex:[indexPath row]];
  [self.navigationController pushViewController:detailViewController
                                       animated:YES];
}
@end
d
