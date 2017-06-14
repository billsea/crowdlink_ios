//
//  HelpViewController.h
//  crowdlink
//
//  Created by William Seaman on 2/23/15.
//  Copyright (c) 2015 Loudsoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface HelpViewController : UIViewController
@property(weak, nonatomic) IBOutlet UILabel *helpLabel;
@property(nonatomic) NSInteger helpTopicIndex;
@end
