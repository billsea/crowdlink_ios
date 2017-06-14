//
//  FlashingDot.h
//  crowdlink
//
//  Created by William Seaman on 2/21/15.
//  Copyright (c) 2015 Loudsoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface FlashingDot : CALayer

@property(nonatomic, assign) CGFloat radius;             // default: 60pt
@property(nonatomic, assign) CGFloat fromValueForRadius; // default: 0.0
@property(nonatomic, assign) CGFloat fromValueForAlpha;  // default: 0.45
@property(nonatomic, assign)
    CGFloat keyTimeForHalfOpacity; // default: 0.2 (range: 0 < keyTime < 1)
@property(nonatomic, assign) NSTimeInterval animationDuration; // default: 3s
@property(nonatomic, assign) NSTimeInterval pulseInterval;     // default: 0s
@property(nonatomic, assign) float repeatCount; // default: INFINITY
@property(nonatomic, assign) BOOL
    useTimingFunction; // default: YES should use timingFunction for animation

- (id)initWithRepeatCount:(float)repeatCount;

@end
