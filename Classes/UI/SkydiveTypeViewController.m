//
//  SkydiveTypeViewController.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 9/2/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "SkydiveTypeViewController.h"
#import "RepositoryManager.h"
#import "SkydiveTypeViewController.h"
#import "UIUtility.h"
#import "DataUtil.h"

@implementation SkydiveTypeViewController

- (id)initWithSkydiveType:(SkydiveType *)theSkydiveType isNew:(BOOL)isNew
{
	if (self = [super initWithNibName:@"SkydiveTypeViewController" bundle:nil])
	{
		skydiveType = theSkydiveType;
		isNewSkydiveType = isNew;
		
		self.hidesBottomBarWhenPushed = YES;
	}
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// set title
	if (isNewSkydiveType == YES)
	{
		self.title = NSLocalizedString(@"NewSkydiveTypeTitle", @"");
	}
	else
	{
		self.title = NSLocalizedString(@"SkydiveTypeInfoTitle", @"");
	}
	
	// add save button
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save)];
	self.navigationItem.leftBarButtonItem = saveButton;
    
    // add cancel button if is new
    if (isNewSkydiveType)
    {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
        self.navigationItem.rightBarButtonItem = cancelButton;
    }
	   
	// init delete button
	deleteCell = [[DeleteButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DeleteCell"];
	[deleteCell.button addTarget:self action:@selector(deleteSkydiveType:) forControlEvents:UIControlEventTouchUpInside];
	deleteCell.hidden = isNewSkydiveType;
	
	// init notes cell
	notesCell = [[NotesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NotesCell"];
	
	// init section array
	tableModel = [[TableModel alloc] init];
	[tableModel addSection:@""];
	[tableModel addRow:0 cell:nameCell];
    [tableModel addRow:0 cell:defaultCell];
	[tableModel addRowWithSelectMethod:0 cell:freefallProfileCell methodName:@"showFreefallProfileListController"];
	[tableModel addSection:NSLocalizedString(@"Notes", @"")];
	[tableModel addRowWithSelectMethod:1 cell:notesCell methodName:@"showNotesController"];
	[tableModel addSection:@""];
	[tableModel addRow:2 cell:deleteCell];
	
	// update UI
	nameField.text = skydiveType.Name;
    defaultField.on = [skydiveType.Default boolValue];
	notesCell.textView.text = skydiveType.Notes;
	freefallProfileField.text = NSLocalizedString(skydiveType.FreefallProfileType, @"");
	
	// init sub-controllers
	// init freefall profile controller
	selectProfileController = [[SelectFreefallProfileViewController alloc] init];
	selectProfileController.selectedProfile = skydiveType.FreefallProfileType;
	selectProfileController.delegate = self;
}

- (void)showFreefallProfileListController
{
	[self.navigationController pushViewController:selectProfileController animated:YES];
}

- (void)showNotesController
{
	NotesViewController *controller = [[NotesViewController alloc] initWithNotes:notesCell.textView.text delegate:self];
	[self.navigationController pushViewController:controller animated:YES];
}

- (void)save
{
    // get repository
    SkydiveTypeRepository *repository = [[RepositoryManager instance] skydiveTypeRepository];

    // if default set
	if (defaultField.on)
	{
        // clear default skydive types
        [repository clearDefaultSkydiveTypes];
	}
    
	// update
    if (![UIUtility stringsAreEqual:skydiveType.Name str2:nameField.text])
        skydiveType.Name = nameField.text;
    
    NSNumber *isDefault = [NSNumber numberWithBool:defaultField.on];
    if (![UIUtility numbersAreEqual:skydiveType.Default num2:isDefault])
        skydiveType.Default = [NSNumber numberWithBool:defaultField.on];
    
    if (![UIUtility stringsAreEqual:skydiveType.FreefallProfileType str2:selectProfileController.selectedProfile])
        skydiveType.FreefallProfileType = selectProfileController.selectedProfile;
	
    if (![UIUtility stringsAreEqual:skydiveType.Notes str2:notesCell.textView.text])
        skydiveType.Notes = notesCell.textView.text;
    
    // update last modified
    if ([skydiveType hasChanges] || isNewSkydiveType)
        skydiveType.LastModifiedUTC = [DataUtil currentDate];
	
	// save
	[repository save];
	
	// navigate to prev view
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)cancel
{
	// rollback any changes
    SkydiveTypeRepository *repository = [[RepositoryManager instance] skydiveTypeRepository];
	[repository rollback];
    
	// return to prev view
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteSkydiveType:(id)sender
{
	// show delete prompt
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
													message:NSLocalizedString(@"SkydiveTypeDeleteConfirmation", @"")
												   delegate:self
										  cancelButtonTitle:NSLocalizedString(@"NoButton", @"")
										  otherButtonTitles:NSLocalizedString(@"YesButton", @""), nil];
	[alert show];
}

#pragma mark -
#pragma mark - ListSelectionDelegate

- (void)listSelectionChanged
{
	freefallProfileField.text = NSLocalizedString(selectProfileController.selectedProfile, @"");
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
        SkydiveTypeRepository *repository = [[RepositoryManager instance] skydiveTypeRepository];
		[repository deleteSkydiveType:skydiveType];
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
