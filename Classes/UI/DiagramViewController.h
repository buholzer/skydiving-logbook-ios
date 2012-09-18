//
//  DiagramViewController.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/8/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawingView.h"
#import "LogEntryImage.h"

@protocol DiagramViewDelegate<NSObject>
- (void)diagramUpdated;
@end

@interface DiagramViewController : UIViewController<UIAlertViewDelegate>
{
	DrawingView *drawingView;
	
	LogEntryImage *logEntryImage;
	id<DiagramViewDelegate> delegate;
    BOOL isNew;
}

- (id)initWithLogEntryImage:(LogEntryImage *)img isNew:(BOOL)new delegate:(id<DiagramViewDelegate>)theDelegate;

@end
