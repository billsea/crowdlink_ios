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
#define searchStartDistanceY 200

@interface FriendDetailViewController ()
@property (nonatomic, weak) MultiplePulsingHaloLayer *mutiHalo;
@property (nonatomic, strong) IBOutlet UIImageView *beaconViewMuti;
@end

FlashingDot * flashingDot;
float searchDotIncrement;
CGPoint beaconScreenPosition;

@implementation FriendDetailViewController

@synthesize selectedFriend = _selectedFriend;
@synthesize beaconViewMuti = _beaconViewMuti;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Set the title of the navigation item
    [[self navigationItem] setTitle:[[self selectedFriend] FullName]];
    
    //set increment for flashing dot
    NSLog(@"accuracty:%f",[[[self selectedFriend] Accuracy] floatValue]);
    searchDotIncrement = searchStartDistanceY/[[[self selectedFriend] Accuracy] floatValue];
    
    
    [self addBeaconHalo];
}

- (void) addBeaconHalo
{
    //position the multi-halo
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    beaconScreenPosition = CGPointMake(screenWidth/2, (screenHeight/2) - 100);
    
    
    //add image
    float imageSize = 80;
    _beaconViewMuti = [[UIImageView alloc] initWithFrame:CGRectMake(beaconScreenPosition.x - (imageSize/2), beaconScreenPosition.y - (imageSize/2), imageSize, imageSize)];

     UIImage * fbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.selectedFriend.PictureURL]]];
    
    [_beaconViewMuti setImage:fbImage];

    _beaconViewMuti.layer.cornerRadius = _beaconViewMuti.bounds.size.width/2.0;
    _beaconViewMuti.clipsToBounds = YES;
    _beaconViewMuti.layer.borderWidth = 1.0f;
    
    [self.view addSubview:_beaconViewMuti];
   
    
    //flashing dot for searching device
    flashingDot = [FlashingDot layer];
    flashingDot.position = CGPointMake(beaconScreenPosition.x,beaconScreenPosition.y + searchStartDistanceY);
    //flashingDot.position = CGPointMake(self.beaconViewMuti.center.x, self.beaconViewMuti.center.y + searchStartDistanceY);
    flashingDot.radius = 20;
    flashingDot.fromValueForAlpha = 1;
    flashingDot.keyTimeForHalfOpacity = 1;
    flashingDot.fromValueForRadius = 1;
    flashingDot.animationDuration = 1;
    [self.view.layer addSublayer:flashingDot];
 
    ///setup multiple halo layer
    //you can specify the number of halos by initial method or by instance property "haloLayerNumber"
    MultiplePulsingHaloLayer *multiLayer = [[MultiplePulsingHaloLayer alloc] initWithHaloLayerNum:3 andStartInterval:1];
    multiLayer.animationDuration = 4;
    self.mutiHalo = multiLayer;
    self.mutiHalo.position = beaconScreenPosition;//self.beaconViewMuti.center;
    self.mutiHalo.useTimingFunction = NO;
    [self.mutiHalo buildSublayers];
   [self.view.layer insertSublayer:self.mutiHalo below:self.beaconViewMuti.layer];
    
    self.mutiHalo.radius = 1 * kMaxRadius;
    
    UIColor *color = [UIColor colorWithRed:0.62711
                                     green:0.51694
                                      blue:1.0
                                     alpha:1.0];
   // UIColor * color = [UIColor greenColor];
    [self.mutiHalo setHaloLayerColor:color.CGColor];
   


}

//called from location manager(beacon loop in FriendsTableViewController) to update the accuracy text
- (void)updateDisplay
{
    if([[[self selectedFriend] Accuracy] intValue] < 0)
    {
        //user stopped broadcasting or quit. return to friendsTableView
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        for(Friend * f in [[AppSharedModel sharedModel] friendsInRangeAll])
        {
            if([[f FacebookID] isEqualToString:[[self selectedFriend] FacebookID]])
            {
                [self setSelectedFriend:f];
            }
        }
        
       //round the accuracy for display
        float roundedValue = round(2.0f * [[[self selectedFriend] Accuracy] floatValue]) / 2.0f;
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setMaximumFractionDigits:1];
        [formatter setRoundingMode: NSNumberFormatterRoundDown];
        NSString *roundedAccuracy = [formatter stringFromNumber:[NSNumber numberWithFloat:roundedValue]];
        
        
        [[self accuracyLabel] setText:roundedAccuracy];
        [self updateDotPosition:[[self selectedFriend] Accuracy]];
    }
}

- (void)updateDotPosition:(NSString *)distance
{
    float newYposition = [distance floatValue] * searchDotIncrement;
    
    if(newYposition < 75)
    {
        flashingDot.backgroundColor = [UIColor redColor].CGColor;

    }
    else if(newYposition < 150)
    {
        flashingDot.backgroundColor = [UIColor orangeColor].CGColor;
        flashingDot.pulseInterval = 1;
    }
   
    else
    {
        flashingDot.backgroundColor = [UIColor blueColor].CGColor;

    }
    
    flashingDot.position = CGPointMake(beaconScreenPosition.x,beaconScreenPosition.y + newYposition);
    //flashingDot.position = CGPointMake(self.beaconViewMuti.center.x, self.beaconViewMuti.center.y + newYposition);
    
    //adjust starting point if needed
    if(newYposition > searchStartDistanceY)
    {
        searchDotIncrement = searchStartDistanceY/[[[self selectedFriend] Accuracy] floatValue];
    }
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
