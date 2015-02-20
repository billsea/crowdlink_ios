//
//  FriendDetailViewController.m
//  crowdlink
//
//  Created by William Seaman on 2/19/15.
//  Copyright (c) 2015 Loudsoftware. All rights reserved.
//

#import "FriendDetailViewController.h"
#import "AppSharedModel.h"

@interface FriendDetailViewController ()

@end



@implementation FriendDetailViewController

@synthesize selectedFriend = _selectedFriend;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[self nameLabel] setText:[[self selectedFriend] FullName]];
    [[self accuracyLabel] setText:[[self selectedFriend] Accuracy]];
}

- (void)refreshStatus
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)updateAccuracyLabel:(id)sender {
    [[self accuracyLabel] setText:[[self selectedFriend] Accuracy]];
}
@end
