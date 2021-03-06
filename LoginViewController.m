//
//  LoginViewController.m
//  crowdlink
//
//  Created by William Seaman on 2/17/15.
//  Copyright (c) 2015 Loudsoftware. All rights reserved.
//

#import "LoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
#import "AboutViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
- (void)viewDidLoad {
  [super viewDidLoad];
  // Set the title of the navigation item
  [[self navigationItem] setTitle:@"Login"];

  // add help navigation bar button
  self.aboutButton =
      [[UIBarButtonItem alloc] initWithTitle:@"About"
                                       style:UIBarButtonItemStyleBordered
                                      target:self
                                      action:@selector(ViewAbout:)];
  [[self navigationItem] setRightBarButtonItem:self.aboutButton];
}

- (IBAction)facebookSignon:(id)sender {
  [self signonWithFacebook];
}

- (void)signonWithFacebook {
  // If the session state is any of the two "open" states when the button is
  // clicked
  if (FBSession.activeSession.state == FBSessionStateOpen ||
      FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {

    // Close the session and remove the access token from the cache
    // The session state handler (in the app delegate) will be called
    // automatically
    [FBSession.activeSession closeAndClearTokenInformation];

    // If the session state is not any of the two "open" states when the button
    // is clicked
  } else {
    // Open a session showing the user the login UI
    // You must ALWAYS ask for public_profile permissions when opening a session
    NSArray *permissions =
        [NSArray arrayWithObjects:@"public_profile", @"user_friends", nil];
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session,
                                                      FBSessionState state,
                                                      NSError *error) {

                                    // Retrieve the app delegate
                                    AppDelegate *appDelegate =
                                        (AppDelegate *)
                                            [UIApplication sharedApplication]
                                                .delegate;
                                    // Call the app delegate's
                                    // sessionStateChanged:state:error method to
                                    // handle session state changes
                                    [appDelegate sessionStateChanged:session
                                                               state:state
                                                               error:error];
                                  }];
  }
}

- (IBAction)ViewAbout:(id)sender {
  AboutViewController *aboutView = [[AboutViewController alloc] init];
  // Push the view controller.
  [self.navigationController pushViewController:aboutView animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

  // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {

  // Return the number of rows in the section.
  return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  CGRect screenRect = [[UIScreen mainScreen] bounds];
  CGFloat screenWidth = screenRect.size.width;

  static NSString *CellIdentifier = @"LoginCell";
  UITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:CellIdentifier];
  }
  cell.accessoryView = nil;

  UIImageView *fbImage = [[UIImageView alloc]
      initWithImage:[UIImage imageNamed:@"FB-f-Logo__blue_29.png"]];
  [fbImage setFrame:CGRectMake(5, 6, 30, 30)];
  UILabel *loginLabel =
      [[UILabel alloc] initWithFrame:CGRectMake(43, 6, 200, 30)];
  [loginLabel setTintColor:[UIColor blueColor]];
  [loginLabel setText:@"Login with Facebook"];

  UIImageView *arrowImage = [[UIImageView alloc]
      initWithImage:[UIImage imageNamed:@"forward-32.png"]];
  [arrowImage setFrame:CGRectMake(screenWidth - 32, 7, 30, 30)];

  [cell addSubview:fbImage];
  [cell addSubview:loginLabel];
  [cell addSubview:arrowImage];
  return cell;
}

#pragma mark table view delegate methods

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  // Navigation logic may go here, for example:
  // Create the next view controller.
  [self signonWithFacebook];
}

- (IBAction)loginImage:(id)sender {
  [self signonWithFacebook];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}
@end
