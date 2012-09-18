//
//  NotesViewController.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/21/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NotesDelegate <NSObject>
- (void)notesUpdated:(NSString *)notes;
@end

@interface NotesViewController : UIViewController
{
	IBOutlet UITextView *notesField;
	
	NSString *notes;
}

@property (strong) id<NotesDelegate> delegate;

- (id)initWithNotes:(NSString *)theNotes delegate:(id<NotesDelegate>)theDelegate;

@end
