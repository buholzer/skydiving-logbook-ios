//
//  RigComponentViewController.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/25/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "RigComponentViewController.h"
#import "RepositoryManager.h"
#import "UIUtility.h"

@implementation RigComponentViewController

- (id)initWithComponent:(RigComponent *)newComponent isNew:(BOOL)isNew delegate:(id<RigComponentDelegate>)theDelegate;
{
	if (self = [super initWithNibName:@"RigComponentViewController" bundle:nil])
	{
		component = newComponent;
		isNewComponent = isNew;
		delegate = theDelegate;
		
		self.hidesBottomBarWhenPushed = YES;
	}
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// set title
	self.title = NSLocalizedString(@"RigComponentTitle", @"");
	
	// add done button
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save)];
	self.navigationItem.leftBarButtonItem = saveButton;
	
	// add cancel button
    if (isNewComponent)
    {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
        self.navigationItem.rightBarButtonItem = cancelButton;
    }
	
	// init delete button
	deleteCell = [[DeleteButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DeleteCell"];
	[deleteCell.button addTarget:self action:@selector(deleteComponent:) forControlEvents:UIControlEventTouchUpInside];
	deleteCell.hidden = isNewComponent;
	
	// init notes cell
	notesCell = [[NotesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NotesCell"];
	
	// init table model
	tableModel = [[TableModel alloc] init];
	[tableModel addSection:@""];
	[tableModel addRow:0 cell:nameCell];
	[tableModel addRow:0 cell:serialCell];
	[tableModel addSection:NSLocalizedString(@"Notes", @"")];
	[tableModel addRowWithSelectMethod:1 cell:notesCell methodName:@"showNotesController"];
	[tableModel addSection:@""];
	[tableModel addRow:2 cell:deleteCell];
	
	// update UI
	nameField.text = component.Name;
	serialField.text = component.SerialNumber;
	notesCell.textView.text = component.Notes;
}

- (void)showNotesController
{
	NotesViewController *controller = [[NotesViewController alloc] initWithNotes:notesCell.textView.text delegate:self];
	[self.navigationController pushViewController:controller animated:YES];
}

- (void)save
{
	// update component
    if (![UIUtility stringsAreEqual:component.Name str2:nameField.text])
        component.Name = nameField.text;
    
    if (![UIUtility stringsAreEqual:component.SerialNumber str2:serialField.text])
        component.SerialNumber = serialField.text;
    
    if (![UIUtility stringsAreEqual:component.Notes str2:notesCell.textView.text])
        component.Notes = notesCell.textView.text;
	
	// notify delegate
	if (delegate != NULL)
	{
		[delegate componentUpdated];
	}
	
	// navigate to prev view
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)cancel
{
	// if new
	if (isNewComponent == YES)
	{
		// delete
        RigRepository *repository = [[RepositoryManager instance] rigRepository];
		[repository deleteComponent:component];
	}
	// return to prev view
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteComponent:(id)sender
{
	// show delete prompt
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
													message:NSLocalizedString(@"RigComponentDeleteConfirmation", @"")
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
        RigRepository *repository = [[RepositoryManager instance] rigRepository];
		[repository deleteComponent:component];
		
		// notify delegate
		if (delegate != NULL)
		{
			[delegate componentUpdated];
		}
		
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
		// invoke method
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

