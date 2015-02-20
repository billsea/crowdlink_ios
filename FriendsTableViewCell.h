//
//  FriendsTableViewCell.h
//  crowdlink
//
//  Created by William Seaman on 2/18/15.
//  Copyright (c) 2015 Loudsoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userPicture;

@property (weak, nonatomic) IBOutlet UILabel *friendNameLabel;
@end
