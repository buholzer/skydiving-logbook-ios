//
//  DiagramViewController.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/8/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "DiagramViewController.h"
#import "RepositoryManager.h"
#import "NSData_MD5.h"

@interface DiagramViewController(Private)
- (void)done;
- (void)promptDelete;
- (void)delete;
- (void)updateImage;
@end

@implementation DiagramViewController

- (id)initWithLogEntryImage:(LogEntryImage *)img isNew:(BOOL)new delegate:(id<DiagramViewDelegate>)theDelegate
{
	if (self = [super init])
	{
        logEntryImage = img;
        delegate = theDelegate;
        isNew = new;
		
		self.hidesBottomBarWhenPushed = YES;
	}
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"DiagramTitle", @"");
	
	// init view
	drawingView = [[DrawingView alloc] initWithFrame:CGRectZero];
	self.view = drawingView;
	drawingView.image = logEntryImage.Image;
	
	// add done button
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
	self.navigationItem.leftBarButtonItem = doneButton;
    
    // add delete/cancel button
    NSString *deleteText = isNew ?
        NSLocalizedString(@"CancelButton", @"") :
        NSLocalizedString(@"DeleteButton", @"");
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle:deleteText style:UIBarButtonItemStyleBordered target:self action:@selector(promptDelete)];
    self.navigationItem.rightBarButtonItem = deleteButton;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	// show instructions
	[drawingView showClearInstructions];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void)done
{
    // update image
    logEntryImage.Image = drawingView.image;
    
    // compute MD5
    NSData *imageData = UIImagePNGRepresentation(logEntryImage.Image);
    logEntryImage.MD5 = [imageData md5];
    
	// notify delegate
	if (delegate != nil)
	{
		[delegate diagramUpdated];
	}
	
	// return to prev view
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)promptDelete
{
    // if new, just delete
    if (isNew)
    {
        [self delete];
        return;
    }
    
    // otherwise, show prompt
	// show delete prompt
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
													message:NSLocalizedString(@"LogEntryDiagramDeleteConfirmation", @"")
												   delegate:self
										  cancelButtonTitle:NSLocalizedString(@"NoButton", @"")
										  otherButtonTitles:NSLocalizedString(@"YesButton", @""), nil];
	[alert show];
}

- (void)delete
{
    // delete
    LogEntryRepository *repository = [[RepositoryManager instance] logEntryRepository];
    [repository deleteLogEntryImage:logEntryImage];
    
    // notify delegate
    if (delegate != NULL)
    {
        [delegate diagramUpdated];
    }
    
    // return to prev view
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
        [self delete];
	}
}

@end
