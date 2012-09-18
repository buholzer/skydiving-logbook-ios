//
//  SignatureViewController.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/11/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "SignatureViewController.h"
#import "RepositoryManager.h"
#import "Signature.h"
#import "DataUtil.h"

@implementation SignatureViewController

- (id)initWithLogEntries:(NSArray *)theLogEntries
{
	if (self = [super initWithNibName:@"SignatureViewController" bundle:nil])
	{
		logEntries = theLogEntries;
		
		self.hidesBottomBarWhenPushed = YES;
	}
	
	return self;
}

- (void)viewDidLoad
{
	self.title = NSLocalizedString(@"SignTitle", @"");
		
	// add done button
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
	self.navigationItem.rightBarButtonItem = doneButton;
	
	licenseView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	drawingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	// clear drawing/license
	licenseField.text = nil;
	drawingView.image = nil;
	[drawingView showClearInstructions];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void)done
{
	// create signature
    LogEntryRepository *repository = [[RepositoryManager instance] logEntryRepository];
	Signature *signature = [repository createNewSignature];
	
	// update signature
	signature.Image = drawingView.image;
	signature.License = licenseField.text;
	
	// update log entries
	for (LogEntry *logEntry in logEntries)
	{
        // set signature
		logEntry.Signature = signature;
        // update last signature date
        logEntry.LastSignatureUTC = [DataUtil currentDate];
	}
	
	// save
	[repository save];
	
	// finished 
	[self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// dismiss the keyboard
	[textField resignFirstResponder];
	
	return YES;
}
@end
