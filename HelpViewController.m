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
//@synthesize adBanner = _adBanner;

@synthesize helpTopicIndex = _helpTopicIndex;
@synthesize helpLabel = _helpLabel;

NSMutableArray * helpTopics;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Set the title of the navigation item
    [[self navigationItem] setTitle:@"Help"];
    
    helpTopics = [[NSMutableArray alloc] init];
    [helpTopics addObject:@"When you start Crowdlink, the app will begin searching for your friends who have the Crowdlink app runnning, and are broadcasting. Friends will show up in the Friends Nearby list. Click on a Friend in the list to get location details."];
    [helpTopics addObject:@"You can allow friends to find you by tapping Settings, in the bottom tab bar, and swithching on the 'let friends find me' toggle button."];
    [helpTopics addObject:@"If a new user has just downloaded the Crowdling app, you may need to refresh your friends list. To do this, go to the Settings Tab, and and tap the Refresh Friends button."];
    
    [self showTopicDetails];
    
    // Make self the delegate of the ad banner.
    //self.adBanner.delegate = self;
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
