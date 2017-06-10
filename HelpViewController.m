//
//  HelpViewController.m
//  crowdlink
//
//  Created by William Seaman on 2/23/15.
//  Copyright (c) 2015 Loudsoftware. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()

@end

@implementation HelpViewController
NSMutableArray * helpTopics;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Set the title of the navigation item
    [[self navigationItem] setTitle:@"Help"];
    
    helpTopics = [[NSMutableArray alloc] init];
    [helpTopics addObject:@"When you start Crowdlink, the app will begin searching for your Facebook friends' devices which are set to Broadcast Mode, and within 300 feet. Friends that are found will be displayed in the 'Friends Nearby’ list. Tap on a Friend in the list to display a friends position details. The details display will show the distance to the selected friend in meters and feet, and your relative position as a flashing dot. Please note: Broadcasting for friends is disabled in Search Mode"];
    [helpTopics addObject:@"To allow friends to find you, switch to Broadcast Mode by tapping the “Let Friends Find Me” toggle switch in the Settings Tab. Please Note: Crowdlink must be running in the foreground for friends to track your signal. Search mode is disabled in Broadcast Mode"];
    [helpTopics addObject:@"If a new user has just downloaded the Crowdlink app, you may need to refresh your friends list. To do this, go to the Settings Tab, and and tap the Refresh Friends button."];
    
    [self showTopicDetails];
}

- (void) showTopicDetails
{
    [_helpLabel setText:[helpTopics objectAtIndex:_helpTopicIndex]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ad Banner delegate methods
-(void)bannerViewWillLoadAd:(ADBannerView *)banner{
    NSLog(@"Ad Banner will load ad.");
}
-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
    NSLog(@"Ad Banner did load ad.");
}
-(BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave{
    NSLog(@"Ad Banner action is about to begin.");
    
    return YES;
}
-(void)bannerViewActionDidFinish:(ADBannerView *)banner{
    NSLog(@"Ad Banner action did finish");
}
-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
  NSLog(@"Unable to show ads. Error: %@", [error localizedDescription]);
}
@end
