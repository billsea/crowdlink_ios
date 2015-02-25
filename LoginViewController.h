//
//  LoginViewController.h
//  crowdlink
//
//  Created by William Seaman on 2/17/15.
//  Copyright (c) 2015 Loudsoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
- (IBAction)loginImage:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
