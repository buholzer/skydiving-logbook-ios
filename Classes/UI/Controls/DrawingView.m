//
//  DrawingView.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/8/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "DrawingView.h"

static CGFloat LINE_WIDTH = 4.0;

@implementation DrawingView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
	{
		self.userInteractionEnabled = YES;
		self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)showClearInstructions
{
	// init if not added
	if (instructionsLabel == nil)
	{
		// add instructions label
		instructionsLabel = [[UILabel alloc] initWithFrame:
							  CGRectMake(0, 10, self.bounds.size.width, 34)];
		instructionsLabel.text = NSLocalizedString(@"DrawingClearInstructions", @"");
		instructionsLabel.alpha = 0;
		instructionsLabel.textAlignment = UITextAlignmentCenter;
		instructionsLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:instructionsLabel];
	}

	// show label
	instructionsLabel.alpha = 1;
	
	// fade out animation
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDuration:2.0];
	instructionsLabel.alpha = 0;
	[UIView commitAnimations];
}

- (void)clearDrawing
{
	// clear image
	self.image = nil;
	// clear path
	CGPathRelease(currentPath);
	currentPath = nil;
}

- (void)updateImage
{
	UIGraphicsBeginImageContext(self.bounds.size);
	// draw the current image
	[self.image drawInRect:self.bounds];
	
	// draw current path
	CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
	CGContextSetLineWidth(UIGraphicsGetCurrentContext(), LINE_WIDTH);
	CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), [UIColor blackColor].CGColor);
	CGContextAddPath(UIGraphicsGetCurrentContext(), currentPath);
	CGContextStrokePath(UIGraphicsGetCurrentContext());
	
	// update image
	self.image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	
	// clear if double-tap
	if (touch.tapCount > 2)
	{
		[self clearDrawing];
		return;
	}
	// get location
	CGPoint location = [touch locationInView:self];
	
	// clear old path
	CGPathRelease(currentPath);
	
	// start new path
	currentPath = CGPathCreateMutable();
	CGPathMoveToPoint(currentPath, NULL, location.x, location.y);
	
	// update image
	[self updateImage];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self];
	
	// add to path
	CGPathAddLineToPoint(currentPath, NULL, location.x, location.y);
	
	// update image
	[self updateImage];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self];
	
	// add to path
	CGPathAddLineToPoint(currentPath, NULL, location.x, location.y);
	
	// update image
	[self updateImage];
}

@end
