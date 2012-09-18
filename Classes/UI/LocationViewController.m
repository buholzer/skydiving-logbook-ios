//
//  LocationViewController.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/19/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "RepositoryManager.h"
#import "LocationViewController.h"
#import "UIUtility.h"
#import "DataUtil.h"

@implementation LocationViewController

- (id)initWithLocation:(Location *)theLocation isNew:(BOOL)isNew
{
	if (self = [super initWithNibName:@"LocationViewController" bundle:nil])
	{
		location = theLocation;
		isNewLocation = isNew;
		
		self.hidesBottomBarWhenPushed = YES;
	}
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
		
	// set title
	if (isNewLocation == YES)
	{
		self.title = NSLocalizedString(@"NewLocationTitle", @"");
	}
	else
	{
		self.title = NSLocalizedString(@"LocationInfoTitle", @"");
	}
	
	// add save button
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save)];
	self.navigationItem.leftBarButtonItem = saveButton;
    
    // add cancel button if is new
    if (isNewLocation)
    {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
        self.navigationItem.rightBarButtonItem = cancelButton;
    }
		
	// init delete button
	deleteCell = [[DeleteButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DeleteCell"];
	[deleteCell.button addTarget:self action:@selector(deleteLocation:) forControlEvents:UIControlEventTouchUpInside];
	deleteCell.hidden = isNewLocation;
	
	// init notes cell
	notesCell = [[NotesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NotesCell"];
	
	// init section array
	tableModel = [[TableModel alloc] init];
	[tableModel addSection:@""];
	[tableModel addRow:0 cell:nameCell];
	[tableModel addRow:0 cell:homeCell];
	[tableModel addSection:NSLocalizedString(@"Notes", @"")];
	[tableModel addRowWithSelectMethod:1 cell:notesCell methodName:@"showNotesController"];
	[tableModel addSection:@""];
	[tableModel addRow:2 cell:deleteCell];
	
	// update UI
	nameField.text = location.Name;
	homeField.on = [location.Home boolValue];
	notesCell.textView.text = location.Notes;
}

- (void)showNotesController
{
	NotesViewController *controller = [[NotesViewController alloc] initWithNotes:notesCell.textView.text delegate:self];
	[self.navigationController pushViewController:controller animated:YES];
}

- (void)save
{
    // get repository
    LocationRepository *repository = [[RepositoryManager instance] locationRepository];
    
    // if home set
	if (homeField.on)
	{
        // clear home locations
        [repository clearHomeLocations];
	}

    // update
    if (![UIUtility stringsAreEqual:location.Name str2:nameField.text])
        location.Name = nameField.text;
	
    NSNumber *isHome = [NSNumber numberWithBool:homeField.on];
    if (![UIUtility numbersAreEqual:location.Home num2:isHome])
        location.Home = isHome;
    
    if (![UIUtility stringsAreEqual:location.Notes str2:notesCell.textView.text])
        location.Notes = notesCell.textView.text;
    
    // update last modified
    if ([location hasChanges] || isNewLocation)
        location.LastModifiedUTC = [DataUtil currentDate];
	
	// save
	[repository save];
    	
	// navigate to prev view
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)cancel
{
	// rollback any changes
    LocationRepository *repository = [[RepositoryManager instance] locationRepository];
	[repository rollback];
    
	// return to prev view
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteLocation:(id)sender
{
	// show delete prompt
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
													message:NSLocalizedString(@"LocationDeleteConfirmation", @"")
												   delegate:self
										  cancelButtonTitle:NSLocalizedString(@"NoButton", @"")
										  otherButtonTitles:NSLocalizedString(@"YesButton", @""), nil];
	[alert show];
}

#pragma mark -
#pragma mark - NotesDelegate

- (void)notesUpdated:(NSString *)notes
{
	// update
	notesCell.textView.text = notes;
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		// delete
        LocationRepository *repository = [[RepositoryManager instance] locationRepository];
		[repository deleteLocation:location];
		// return to prev view
		[self.navigationController popViewControllerAnimated:YES];
	}
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	[textField resignFirstResponder];
	return YES;
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [tableModel sectionCount];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [tableModel sectionTitle:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [tableModel rowCount:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [tableModel rowCell:indexPath.section rowIndex:indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// get method
	NSString *methodName = [tableModel rowMethodName:indexPath.section rowIndex:indexPath.row];
	
	// check if empty
	if ([methodName length] > 0)
	{
		SEL methodSelector = NSSelectorFromString(methodName);
		[self performSelector:methodSelector];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// get cell
	UITableViewCell *cell = [tableModel rowCell:indexPath.section rowIndex:indexPath.row];
	
	// return calculated height
	return [cell getCellHeight];
}

@end
