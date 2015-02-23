//
//  BeaconGrid.h
//  crowdlink
//
//  Created by William Seaman on 2/22/15.
//  Copyright (c) 2015 Loudsoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface BeaconGrid : CALayer

@property (nonatomic, assign) CGRect gridFrame;

- (id)initWithFrame:(CGRect)gridFrame;

@end
