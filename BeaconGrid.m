//
//  BeaconGrid.m
//  crowdlink
//
//  Created by William Seaman on 2/22/15.
//  Copyright (c) 2015 Loudsoftware. All rights reserved.
//

#import "BeaconGrid.h"


#define gridLineDistance 50
#define kLogBase			2

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
    
    
    
    for(int x = 0;x<_gridFrame.size.height - x;x=x+gridLineDistance)
    {
        
        int value = 100 + x;
        
        double location = value; //logValueForNumber(value, kLogBase) * value;
        
        [linePath moveToPoint: CGPointMake(_gridFrame.origin.x,location)];
        //[linePath addLineToPoint:CGPointMake(_gridFrame.size.width, 100)];
        
        [linePath addCurveToPoint:CGPointMake(_gridFrame.size.width, location) controlPoint1:CGPointMake(10, 104 + x) controlPoint2:CGPointMake(152, 217 + x + (x/2))];
        
        line.path=linePath.CGPath;
        line.fillColor = nil;
        line.opacity = 1.0;
        line.strokeColor = [UIColor darkGrayColor].CGColor;
        [self addSublayer:line];
    }
    
}

@end
