//
//  DrawingView.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/8/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DrawingView : UIImageView
{
	CGMutablePathRef currentPath;
	UILabel *instructionsLabel;
}

- (void)showClearInstructions;
- (void)clearDrawing;

@end
