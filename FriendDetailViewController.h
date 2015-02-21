//
//  FriendDetailViewController.h
//  crowdlink
//
//  Created by William Seaman on 2/19/15.
//  Copyright (c) 2015 Loudsoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Friend.h"

@interface FriendDetailViewController : UIViewController

@property Friend * selectedFriend;
@property (weak, nonatomic) IBOutlet UILabel *accuracyLabel;



- (void)updateDisplay;

@end
