//
//  NotesViewController.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/21/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "NotesViewController.h"

@interface NotesViewController(Private)
- (void)done;
@end

@implementation NotesViewController

@synthesize delegate;

- (id)initWithNotes:(NSString *)theNotes delegate:(id<NotesDelegate>)theDelegate
{
	if (self = [super initWithNibName:@"NotesViewController" bundle:nil])
	{
		notes = theNotes;
		self.delegate = theDelegate;
		
		self.hidesBottomBarWhenPushed = YES;
	}
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"Notes", @"");
	
	// this will cause auto-resize when the view is resized
	notesField.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	
	// add done button
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
	self.navigationItem.leftBarButtonItem = doneButton;
	
	// set notes
	notesField.text = notes;
}

- (void)viewWillAppear:(BOOL)animated 
{
    // listen for keyboard hide/show notifications so we can properly adjust the table's height
	[super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

	[notesField becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated 
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)done
{
	// notify delegate
	if (self.delegate != NULL)
	{
		[self.delegate notesUpdated:notesField.text];
	}
	
	// nav back
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)keyboardWillShow:(NSNotification *)aNotification 
{
	// the keyboard is showing so resize the view's height
	CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect frame = self.view.frame;
    frame.size.height -= keyboardRect.size.height;
	
    [UIView beginAnimations:nil context:NULL];
    notesField.frame = frame;
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    // the keyboard is hiding reset the table's height
	CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect frame = self.view.frame;
    frame.size.height += keyboardRect.size.height;
	
    [UIView beginAnimations:nil context:NULL];
    notesField.frame = frame;
    [UIView commitAnimations];
}

- (void)dealloc
{
    self.delegate = nil;
}

@end