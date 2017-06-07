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
#import "BeaconGrid.h"
#import "HelpTableViewController.h"

#define kMaxRadius 100
#define searchStartDistanceY 200


@interface FriendDetailViewController ()
@property (nonatomic, weak) MultiplePulsingHaloLayer *mutiHalo;
@property (nonatomic, strong) IBOutlet UIImageView *beaconViewMuti;
@property (strong, nonatomic) IBOutlet UIImageView *gridImageView;
@property UIBarButtonItem * helpButton;
@end

FlashingDot * flashingDot;
float searchDotIncrement;
BOOL _bannerIsVisible;
ADBannerView *_adBanner;

@implementation FriendDetailViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Set the title of the navigation item
    [[self navigationItem] setTitle:[[self selectedFriend] FullName]];
    
    //add help navigation bar button
    self.helpButton = [[UIBarButtonItem alloc]
                       //initWithImage:[UIImage imageNamed:@"reload-50.png"]
                       initWithTitle:@"Help"
                       style:UIBarButtonItemStyleBordered
                       target:self
                       action:@selector(ViewHelp:)];
    //self.addClientButton.tintColor = [UIColor blackColor];
    [[self navigationItem] setRightBarButtonItem:self.helpButton];
    
    //set increment for flashing dot
    NSLog(@"accuracty:%f",[[[self selectedFriend] Accuracy] floatValue]);
    searchDotIncrement = searchStartDistanceY/[[[self selectedFriend] Accuracy] floatValue];
    
    //add oval background
   [self drawGridLines];
    
    //add halo effect
    [self addBeaconHalo];
}

- (void)viewDidAppear:(BOOL)animated
{
    //iAd banner
    _adBanner = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-50, 320, 50)];
    _adBanner.delegate = self;
}

- (IBAction)ViewHelp:(id)sender
{
    HelpTableViewController * helpView = [[HelpTableViewController alloc] init];
    // Push the view controller.
    [self.navigationController pushViewController:helpView animated:YES];
}

#pragma mark grid lines

//draw ovals
- (void) drawGridLines {
   
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    float imageSizeX = screenWidth;
    float imageSizeY = self.beaconPosition.y + searchStartDistanceY;
    _gridImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.beaconPosition.x - (imageSizeX/2),self.beaconPosition.y - 100, imageSizeX, imageSizeY)];
    
    [self.view addSubview:_gridImageView];
    
    //add grid lines layer
    BeaconGrid * beaconGrid = [[BeaconGrid layer] initWithFrame:[_gridImageView bounds]];
    [self.gridImageView.layer addSublayer:beaconGrid];
}


- (CGPoint)beaconPosition
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    return CGPointMake(screenWidth/2, (screenHeight/2) - 100);
}

#pragma mark ui update

- (void) addBeaconHalo
{
    //add image
    float imageSize = 80;
    _beaconViewMuti = [[UIImageView alloc] initWithFrame:CGRectMake(self.beaconPosition.x - (imageSize/2),self.beaconPosition.y - (imageSize/2), imageSize, imageSize)];

     UIImage * fbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.selectedFriend.PictureURL]]];
    
    [_beaconViewMuti setImage:fbImage];

    _beaconViewMuti.layer.cornerRadius = _beaconViewMuti.bounds.size.width/2.0;
    _beaconViewMuti.clipsToBounds = YES;
    _beaconViewMuti.layer.borderWidth = 1.0f;
    
    [self.view addSubview:_beaconViewMuti];

    //flashing dot for searching device
    flashingDot = [FlashingDot layer];
    flashingDot.position = CGPointMake(self.beaconPosition.x,self.beaconPosition.y + searchStartDistanceY);
    flashingDot.radius = 15;
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
    self.mutiHalo.position = self.beaconPosition;//self.beaconViewMuti.center;
    self.mutiHalo.useTimingFunction = NO;
    [self.mutiHalo buildSublayers];
   [self.view.layer insertSublayer:self.mutiHalo below:self.beaconViewMuti.layer];
    
    self.mutiHalo.radius = 1 * kMaxRadius;
    UIColor * color = [UIColor redColor];
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
        
        
        [[self metersFeetLabel] setText: [self metersToFeet:[roundedAccuracy floatValue]]];
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
    
    flashingDot.position = CGPointMake(self.beaconPosition.x,self.beaconPosition.y + newYposition);
    
    //adjust starting point if needed
    if(newYposition > searchStartDistanceY)
    {
        searchDotIncrement = searchStartDistanceY/[[[self selectedFriend] Accuracy] floatValue];
    }
}

-(NSString *)metersToFeet:(float)accuracyMeters
{
    double rawFeet = accuracyMeters * 3.281;
    float roundedValue = round(2.0f * rawFeet) / 2.0f;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:1];
    [formatter setRoundingMode: NSNumberFormatterRoundDown];
    return [formatter stringFromNumber:[NSNumber numberWithFloat:roundedValue]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark iAd delegate methods
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!_bannerIsVisible)
    {
        // If banner isn't part of view hierarchy, add it
        if (_adBanner.superview == nil)
        {
            [self.view addSubview:_adBanner];
        }
        
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        
        // Assumes the banner view is just off the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
        
        [UIView commitAnimations];
        
        _bannerIsVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"Failed to retrieve ad");
    
    if (_bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        
        // Assumes the banner view is placed at the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);
        
        [UIView commitAnimations];
        
        _bannerIsVisible = NO;
    }
}

@end
