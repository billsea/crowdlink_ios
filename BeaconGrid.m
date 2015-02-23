//
//  BeaconGrid.m
//  crowdlink
//
//  Created by William Seaman on 2/22/15.
//  Copyright (c) 2015 Loudsoftware. All rights reserved.
//

#import "BeaconGrid.h"

@implementation BeaconGrid


- (id)initWithFrame:(CGRect)gridFrame
{
    self = [super init];
    if (self) {
        self.contentsScale = [UIScreen mainScreen].scale;
        self.gridFrame = gridFrame;
        [self buildGrid];
       
    }
    return self;
    
}

//- (id)init {
//    return [self initWithFrame:CGRectMake(0, 0, 0, 0)];
//}


- (void)setGridFrame:(CGRect)gridFrame
{
    _gridFrame = gridFrame;
    [self setFrame:_gridFrame];
}

- (void)buildGrid
{
        //draw horizontal lines
    CAShapeLayer *line = [CAShapeLayer layer];
    UIBezierPath *linePath=[UIBezierPath bezierPath];
    
    [linePath moveToPoint: CGPointMake(_gridFrame.origin.x,100)];
    //[linePath addLineToPoint:CGPointMake(_gridFrame.size.width, 100)];
    
   [linePath addCurveToPoint:CGPointMake(_gridFrame.size.width, 100) controlPoint1:CGPointMake(300, 150) controlPoint2:CGPointMake(300, 150)];
    
    line.path=linePath.CGPath;
    line.fillColor = nil;
    line.opacity = 1.0;
    line.strokeColor = [UIColor redColor].CGColor;
    [self addSublayer:line];

    
}

@end
