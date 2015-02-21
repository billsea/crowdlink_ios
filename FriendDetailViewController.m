//
//  FriendDetailViewController.m
//  crowdlink
//
//  Created by William Seaman on 2/19/15.
//  Copyright (c) 2015 Loudsoftware. All rights reserved.
//


#import "FriendDetailViewController.h"
#import "AppSharedModel.h"
#import "MultiplePulsingHaloLayer.h"
#import "PulsingHaloLayer.h"
#import "FlashingDot.h"

#define kMaxRadius 160

@interface FriendDetailViewController ()
@property (nonatomic, weak) MultiplePulsingHaloLayer *mutiHalo;
@property (nonatomic, weak) IBOutlet UIImageView *beaconViewMuti;
@end


@implementation FriendDetailViewController

@synthesize selectedFriend = _selectedFriend;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Set the title of the navigation item
    [[self navigationItem] setTitle:[[self selectedFriend] FullName]];
    
    [self addBeaconHalo];
}

- (void) addBeaconHalo
{
    //position the multi-halo
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    CGPoint screenPosition = CGPointMake(screenWidth/2, (screenHeight/2) - 100);
    [[self beaconViewMuti] setCenter:screenPosition];
   // [[self beaconViewMuti] setImage:[UIImage imageNamed:@"conference.32.png"]];
   // [[self beaconViewMuti]setFrame:CGRectMake(screenPosition.x, screenPosition.y, 100, 100)];
    


    
    //flashing dot for searching device
    FlashingDot * flashingDot = [FlashingDot layer];
    flashingDot.position = CGPointMake(self.beaconViewMuti.center.x, self.beaconViewMuti.center.y + 200);
    //flashingDot.radius = 10;
    [self.view.layer addSublayer:flashingDot];
 
    ///setup multiple halo layer
    //you can specify the number of halos by initial method or by instance property "haloLayerNumber"
    MultiplePulsingHaloLayer *multiLayer = [[MultiplePulsingHaloLayer alloc] initWithHaloLayerNum:3 andStartInterval:1];
    self.mutiHalo = multiLayer;
    self.mutiHalo.position = self.beaconViewMuti.center;
    self.mutiHalo.useTimingFunction = NO;
    [self.mutiHalo buildSublayers];
   [self.view.layer insertSublayer:self.mutiHalo below:self.beaconViewMuti.layer];
    
    self.mutiHalo.radius = 1 * kMaxRadius;
    
//    UIColor *color = [UIColor colorWithRed:self.rSlider.value
//                                     green:self.gSlider.value
//                                      blue:self.bSlider.value
//                                     alpha:1.0];
    UIColor * color = [UIColor redColor];
    [self.mutiHalo setHaloLayerColor:color.CGColor];
   


}

//called from location manager(beacon loop in FriendsTableViewController) to update the accuracy text
- (void)updateDisplay
{
    for(Friend * f in [[AppSharedModel sharedModel] friendsInRangeAll])
    {
        if([[f FacebookID] isEqualToString:[[self selectedFriend] FacebookID]])
        {
            [self setSelectedFriend:f];
        }
    }
    
    [[self accuracyLabel] setText:[[self selectedFriend] Accuracy]];
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



@end
