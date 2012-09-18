//
//  SignatureViewController.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/11/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawingView.h"

@interface SignatureViewController : UIViewController <UITextFieldDelegate>
{
	IBOutlet UITextField *licenseField;
	IBOutlet UIView *licenseView;
	IBOutlet DrawingView *drawingView;
	
	NSArray *logEntries;
}

- (id)initWithLogEntries:(NSArray *)theLogEntries;

@end
