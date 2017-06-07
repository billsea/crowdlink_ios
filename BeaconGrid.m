//
//  BeaconGrid.m
//  crowdlink
//
//  Created by William Seaman on 2/22/15.
//  Copyright (c) 2015 Loudsoftware. All rights reserved.
//

#import "BeaconGrid.h"


#define gridLineDistance 50
#define kLogBase 2

@implementation BeaconGrid

- (id)initWithFrame:(CGRect)gridFrame
{
    self = [super init];
    if (self) {
        self.contentsScale = [UIScreen mainScreen].scale;
        self.gridFrame = gridFrame;
        //[self buildGrid];
        [self buildOvals];
       
    }
    return self;
    
}

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
        [linePath addCurveToPoint:CGPointMake(_gridFrame.size.width, location) controlPoint1:CGPointMake(10, 104 + x) controlPoint2:CGPointMake(152, 217 + x + (x/2))];
        
        line.path=linePath.CGPath;
        line.fillColor = nil;
        line.opacity = 1.0;
        line.strokeColor = [UIColor darkGrayColor].CGColor;
        [self addSublayer:line];
    }
}

- (void) buildOvals
{
    CAShapeLayer *oval = [CAShapeLayer layer];
    UIBezierPath *ovalPath=[UIBezierPath bezierPathWithOvalInRect:_gridFrame];
    
    oval.path = ovalPath.CGPath;
    oval.fillColor = [UIColor lightGrayColor].CGColor;
    oval.opacity = 0.3;
    [self addSublayer:oval];
    
    CAShapeLayer *ovalInner = [CAShapeLayer layer];
    
    float offset = 0.75;
    float centerX = _gridFrame.size.width/2;
    float centerXOffset = (_gridFrame.size.width * offset)/2;
    float centerXDiff = centerX - centerXOffset;
    
    CGRect innerRect = CGRectMake(centerXDiff, _gridFrame.origin.y, _gridFrame.size.width * offset, _gridFrame.size.height * offset);
    UIBezierPath *ovalPathInner =[UIBezierPath bezierPathWithOvalInRect:innerRect];
    
    ovalInner.path = ovalPathInner.CGPath;
    ovalInner.fillColor = [UIColor lightGrayColor].CGColor;
    ovalInner.opacity = 0.3;
    [self addSublayer:ovalInner];
}

@end
