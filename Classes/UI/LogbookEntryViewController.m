//
//  LogbookEntryViewController.m
//  SkydiveLogbook
//
//  Created by Tom Cain on 2/19/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "RepositoryManager.h"
#import "LogbookEntryViewController.h"
#import "UIUtility.h"
#import "Calculator.h"
#import "FreefallProfile.h"
#import "DataUtil.h"
#import "LogEntryImage.h"
#import "NSData_MD5.h"

static NSInteger ImagesSectionIndex = 3;

@interface LogbookEntryViewController(Private)
- (void)showDatePicker;
- (void)showJumpNumberPicker;
- (void)showExitAltitudePicker;
- (void)showDeploymentAltitudePicker;
- (void)showDelayPicker;
- (void)hidePickers;
- (void)incrementAltitude;
- (void)decrementAltitude;
- (void)estimateDelay;
- (void)clearDistanceToTarget;
- (void)updateDelayEstimate;
- (void)refreshImageRows;
- (void)refreshFields;
@end

@implementation LogbookEntryViewController

- (id)initWithLogEntry:(LogEntry *)newLogEntry isNew:(BOOL)isNew delegate:(id<LogEntryViewControllerDelegate>)theDelegate;
{
	if (self = [super initWithNibName:@"LogbookEntryViewController" bundle:[NSBundle mainBundle]])
	{
		logEntry = newLogEntry;
		isNewLogEntry = isNew;
		isDelayEstimated = isNew;
        delegate = theDelegate;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	////////////////////////////
	
	// init custom cells/fields
	// init notes cell
	notesCell = [[NotesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NotesCell"];
	
	// init signature cell
	signatureCell = [[ImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SignatureCell"];

	// init delete button
	deleteCell = [[DeleteButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DeleteCell"];
	[deleteCell.button addTarget:self action:@selector(deleteLogEntry:) forControlEvents:UIControlEventTouchUpInside];
	deleteCell.hidden = isNewLogEntry;
	
	////////////////////////////

	// init table model
	tableModel = [[TableModel alloc] init];
	[tableModel addSection:@""];
	[tableModel addRowWithSelectMethod:0 cell:jumpNumberCell methodName:@"showJumpNumberPicker"];
	[tableModel addRowWithSelectMethod:0 cell:dateCell methodName:@"showDatePicker"];
	[tableModel addRowWithSelectMethod:0 cell:locationCell methodName:@"showLocationListController"];
	[tableModel addRowWithSelectMethod:0 cell:aircraftCell methodName:@"showAircraftListController"];
	[tableModel addRowWithSelectMethod:0 cell:gearCell methodName:@"showGearListController"];
	[tableModel addRowWithSelectMethod:0 cell:jumpTypeCell methodName:@"showTypeListController"];
	[tableModel addSection:NSLocalizedString(@"JumpProfile", @"")];
	[tableModel addRowWithSelectMethod:1 cell:exitAltCell methodName:@"showExitAltitudePicker"];
	[tableModel addRowWithSelectMethod:1 cell:deplAltCell methodName:@"showDeploymentAltitudePicker"];
	[tableModel addRowWithSelectMethod:1 cell:delayCell methodName:@"showDelayPicker"];
    [tableModel addRowWithSelectMethod:1 cell:distToTargetCell methodName:@"showDistToTargetPicker"];
	[tableModel addRow:1 cell:cutawayCell];
	[tableModel addSection:NSLocalizedString(@"Notes", @"")];
	[tableModel addRowWithSelectMethod:2 cell:notesCell methodName:@"showNotesController"];
	[tableModel addSection:NSLocalizedString(@"Images", @"")];
	if (logEntry.Signature != nil)
	{
		[tableModel addSection:NSLocalizedString(@"Signature", @"")];
		[tableModel addRow:4 cell:signatureCell];
		[tableModel addRow:4 cell:licenseCell];
		[tableModel addSection:@""];
		[tableModel addRow:5 cell:deleteCell];
	}
	else
	{
		[tableModel addSection:@""];
		[tableModel addRow:4 cell:deleteCell];
	}
	
	// init pickers and models
    datePicker = [[DatePickerView alloc] initForView:self.view table:tableView delegate:self];
    numberPicker = [[PickerView alloc] initForView:self.view table:tableView];
    
    [datePicker setDate:logEntry.Date];

	jumpNumberModel = [[NumberPickerModel alloc] initWithDigitCount:5];
	jumpNumberModel.selectedNumber = logEntry.JumpNumber;
	jumpNumberModel.delegate = self;
	
	exitAltModel = [[NumberPickerModel alloc] initWithDigitCount:5
											 maxSignificantDigit:9
														unitKeys:[NSArray arrayWithObject:logEntry.AltitudeUnit]
													   unitWidth:60];
	exitAltModel.selectedNumber = logEntry.ExitAltitude;
	exitAltModel.delegate = self;

	deplAltModel = [[NumberPickerModel alloc] initWithDigitCount:5
											 maxSignificantDigit:9
														unitKeys:[NSArray arrayWithObject:logEntry.AltitudeUnit]
													   unitWidth:60];
	deplAltModel.selectedNumber = logEntry.DeploymentAltitude;
	deplAltModel.delegate = self;

	delayModel = [[NumberPickerModel alloc] initWithDigitCount:3
										   maxSignificantDigit:9
													  unitKeys:[NSArray arrayWithObject:@"Seconds"]
													 unitWidth:100];
	delayModel.selectedNumber = logEntry.FreefallTime;
	delayModel.delegate = self;
    
    distToTargetModel = [[NumberPickerModel alloc] initWithDigitCount:3
                                                  maxSignificantDigit:9
                                                             unitKeys:[NSArray arrayWithObject:logEntry.AltitudeUnit]
                                                            unitWidth:60];
    distToTargetModel.selectedNumber = logEntry.DistanceToTarget;
    distToTargetModel.delegate = self;
	
	////////////////////////////

	// init picker toolbar buttons
	pickerDoneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(hidePickers)];
	pickerEstimateDelayButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"EstimateButton", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(estimateDelay)];
	pickerSpacerButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	pickerIncrementAltButton = [[UIBarButtonItem alloc] initWithTitle:@"+250" style:UIBarButtonItemStyleBordered target:self action:@selector(incrementAltitude)];
	pickerDecrementAltButton = [[UIBarButtonItem alloc] initWithTitle:@"-250" style:UIBarButtonItemStyleBordered target:self action:@selector(decrementAltitude)];
    pickerClearDistanceToTargetButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"ClearButton", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(clearDistanceToTarget)];
	
	// init sub-controllers
	// init location controller
	selectLocationController = [[SelectLocationViewController alloc] init];
	selectLocationController.selectedLocation = logEntry.Location;	
	selectLocationController.delegate = self;
	
	// init aircraft controller
	selectAircraftController = [[SelectAircraftViewController alloc] init];
	selectAircraftController.selectedAircraft = logEntry.Aircraft;
	selectAircraftController.delegate = self;
	
	// init gear controller
	selectGearController = [[SelectGearViewController alloc] init];
	for (Rig *rig in logEntry.Rigs)
	{
		[selectGearController.selectedGear addObject:rig];
	}
	selectGearController.delegate = self;
	
	// init type controller
	selectTypeController = [[SelectSkydiveTypeViewController alloc] init];
	selectTypeController.selectedType = logEntry.SkydiveType;
	selectTypeController.delegate = self;
    
    // init photo chooser (if available)
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        choosePhotoController = [[UIImagePickerController alloc] init];
        choosePhotoController.delegate = self;
        choosePhotoController.allowsEditing  = YES;
        if ([UIUtility isiPad])
            choosePhotoPopoverController = [[UIPopoverController alloc] initWithContentViewController:choosePhotoController];
    }
    
    // init photo taker (if available)
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        takePhotoController = [[UIImagePickerController alloc] init];
        takePhotoController.delegate = self;
        takePhotoController.allowsEditing  = YES;
        takePhotoController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }

	////////////////////////////
	
	// initial delay estimate
	[self updateDelayEstimate];
	// refresh fields
    [self refreshImageRows];
	[self refreshFields];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self hidePickers];
	[super viewWillDisappear:animated];
}

- (void)showDatePicker
{
	NSArray *toolbarItems = [NSArray arrayWithObjects:pickerSpacerButton, pickerDoneButton, nil];
	// show/hide pickers
    [numberPicker hidePicker];
    [datePicker showPicker:dateCell toolbarItems:toolbarItems];
}

- (void)showJumpNumberPicker
{
	NSArray *toolbarItems = [NSArray arrayWithObjects:pickerSpacerButton, pickerDoneButton, nil];
    // show/hide pickers
    [datePicker hidePicker];
    [numberPicker showNumberPicker:jumpNumberModel forView:jumpNumberCell toolbarItems:toolbarItems];
}

- (void)showExitAltitudePicker
{
	NSArray *toolbarItems = [NSArray arrayWithObjects:pickerIncrementAltButton, pickerDecrementAltButton, pickerSpacerButton, pickerDoneButton, nil];
    // show/hide pickers
    [datePicker hidePicker];
    [numberPicker showNumberPicker:exitAltModel forView:exitAltCell toolbarItems:toolbarItems];
	// scroll field to visible
	[tableView scrollToRowAtIndexPath:[tableView indexPathForCell:exitAltCell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)showDeploymentAltitudePicker
{
	NSArray *toolbarItems = [NSArray arrayWithObjects:pickerIncrementAltButton, pickerDecrementAltButton, pickerSpacerButton, pickerDoneButton, nil];
    // show/hide pickers
    [datePicker hidePicker];
    [numberPicker showNumberPicker:deplAltModel forView:deplAltCell toolbarItems:toolbarItems];
	// scroll field to visible
	[tableView scrollToRowAtIndexPath:[tableView indexPathForCell:deplAltCell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)showDelayPicker
{
	NSArray *toolbarItems = [NSArray arrayWithObjects:pickerEstimateDelayButton, pickerSpacerButton, pickerDoneButton, nil];
    // show/hide pickers
    [datePicker hidePicker];
    [numberPicker showNumberPicker:delayModel forView:delayCell toolbarItems:toolbarItems];
	// scroll field to visible
	[tableView scrollToRowAtIndexPath:[tableView indexPathForCell:delayCell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)showDistToTargetPicker
{
    NSArray *toolbarItems = [NSArray arrayWithObjects:pickerClearDistanceToTargetButton, pickerSpacerButton, pickerDoneButton, nil];
    // show/hide pickers
    [datePicker hidePicker];
    [numberPicker showNumberPicker:distToTargetModel forView:distToTargetCell toolbarItems:toolbarItems];
	// scroll field to visible
	[tableView scrollToRowAtIndexPath:[tableView indexPathForCell:distToTargetCell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)hidePickers
{
	// hide pickers
    [datePicker hidePicker];
    [numberPicker hidePicker];
}

- (void)incrementAltitude
{
    // get picker
    UIPickerView *picker = [numberPicker getPicker];
	// get model
	NumberPickerModel *model = (NumberPickerModel *)picker.dataSource;
	// increment altitude
	int alt = [model.selectedNumber intValue];
	alt += 250;
	if (alt > 99999)
		alt = 99999;
	// update model and picker
	model.selectedNumber = [NSNumber numberWithInt:alt];
    [model updatePicker:picker];
	// re-estimate delay
	[self updateDelayEstimate];
	// refresh fields
	[self refreshFields];
}

- (void)decrementAltitude
{
    // get picker
    UIPickerView *picker = [numberPicker getPicker];
	// get model
	NumberPickerModel *model = (NumberPickerModel *)picker.dataSource;
	// decrement altitude
	int alt = [model.selectedNumber intValue];
	alt -= 250;
	if (alt < 0)
		alt = 0;
	// update model and picker
	model.selectedNumber = [NSNumber numberWithInt:alt];
    [model updatePicker:picker];
	// re-estimate delay
	[self updateDelayEstimate];
	// refresh fields
	[self refreshFields];
}

- (void)estimateDelay
{
	isDelayEstimated = YES;
	// update model
	[self updateDelayEstimate];
	// update picker
    UIPickerView *picker = [numberPicker getPicker];
    [delayModel updatePicker:picker];
	// refresh fields
	[self refreshFields];
}

- (void)clearDistanceToTarget
{
    // clear model
    distToTargetModel.selectedNumber = nil;
    // update picker
    UIPickerView *picker = [numberPicker getPicker];
    [distToTargetModel updatePicker:picker];
    // refresh fields
    [self refreshFields];
}

- (void)showLocationListController
{
	[self.navigationController pushViewController:selectLocationController animated:YES];
}

- (void)showAircraftListController
{
	[self.navigationController pushViewController:selectAircraftController animated:YES];
}

- (void)showGearListController
{
	[self.navigationController pushViewController:selectGearController animated:YES];
}

- (void)showTypeListController
{
	[self.navigationController pushViewController:selectTypeController animated:YES];
}

- (void)showNotesController
{
	NotesViewController *controller = [[NotesViewController alloc] initWithNotes:notesCell.textView.text delegate:self];
	[self.navigationController pushViewController:controller animated:YES];
}

- (void)showDiagramController:(LogEntryImage *)logEntryImage isNew:(BOOL)isNew
{
	DiagramViewController *controller = [[DiagramViewController alloc] initWithLogEntryImage:logEntryImage isNew:isNew delegate:self];
	[self.navigationController pushViewController:controller animated:YES];
}

- (void)showImageViewerController:(LogEntryImage *)logEntryImage
{
    ImageViewerViewController *controller = [[ImageViewerViewController alloc] initWithLogEntryImage:logEntryImage delegate:self];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)updateDelayEstimate
{
	if (isDelayEstimated)
	{
		// get estimation
		NSInteger estimation = [Calculator calculateFreefallTime:[FreefallProfileUtil stringToType:selectTypeController.selectedType.FreefallProfileType]
													exitAltitude:[exitAltModel.selectedNumber intValue]
											  deploymentAltitude:[deplAltModel.selectedNumber intValue]
													altitudeUnit:[Units stringToAltitudeUnit:logEntry.AltitudeUnit]];
		// update model
		delayModel.selectedNumber = [NSNumber numberWithInt:estimation];
	}
}

- (void)choosePhoto
{
    if ([UIUtility isiPad])
    {
        // show popover controller
        CGRect rect = CGRectMake(1, 1, choosePhotoCell.frame.size.width, choosePhotoCell.frame.size.height);
        [choosePhotoPopoverController presentPopoverFromRect:rect inView:choosePhotoCell
                         permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        [self presentModalViewController:choosePhotoController animated:YES];
    }
}

- (void)takePhoto
{    
    // show controller
    [self presentModalViewController:takePhotoController animated:YES];  
}

- (void)addDiagram
{
	// create new logentryimage
    LogEntryRepository *repository = [[RepositoryManager instance] logEntryRepository];
    LogEntryImage *logEntryImage = [repository createNewDiagramForLogEntry:logEntry];
    
    // show diagram editor
    [self showDiagramController:logEntryImage isNew:YES];
}

- (void)editImage:(id)sender
{
    LogEntryImage *logEntryImage = (LogEntryImage *)sender;
    if ([logEntryImage.ImageType isEqualToString:LogEntryPhotoImageType])
    {
        [self showImageViewerController:logEntryImage];
    }
    else if ([logEntryImage.ImageType isEqualToString:LogEntryDiagramImageType])
    {
        [self showDiagramController:logEntryImage isNew:NO];
    }
}

- (void)refreshImageRows
{
    // clear all current rows
	[tableModel clearSection:ImagesSectionIndex];
	
	// for each image
	ImageCell *cell;
    int cellIndex = 0;
    for (LogEntryImage *logEntryImage in logEntry.Images)
    {
        // create cell name
        NSMutableString *cellName = [[NSMutableString alloc] initWithString:@"ImageCell"];
        [cellName appendString:[NSString stringWithFormat:@"%d", cellIndex]];
        
        // create cell, add row
        cell = [[ImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        [cell updateImage:logEntryImage.Image];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		[tableModel addRowWithSelectMethodAndObject:ImagesSectionIndex
											   cell:cell
										 methodName:@"editImage:"
											 object:logEntryImage];
	}
	
	// add "add photo" and "add diagram" rows
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        [tableModel addRowWithSelectMethod:ImagesSectionIndex cell:choosePhotoCell methodName:@"choosePhoto"];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        [tableModel addRowWithSelectMethod:ImagesSectionIndex cell:takePhotoCell methodName:@"takePhoto"];
	[tableModel addRowWithSelectMethod:ImagesSectionIndex cell:addDiagramCell methodName:@"addDiagram"];
}

- (void)refreshFields
{
    // notify delegate
    [delegate jumpNumberChanged:jumpNumberModel.selectedNumber];
    
    // update fields
	jumpNumberField.text = [UIUtility formatNumber:jumpNumberModel.selectedNumber];
	dateField.text = [UIUtility formatDate:[datePicker getDate]];
	locationField.text = selectLocationController.selectedLocation != nil ? selectLocationController.selectedLocation.Name : @"";
	aircraftField.text = selectAircraftController.selectedAircraft != nil ? selectAircraftController.selectedAircraft.Name : @"";
	jumpTypeField.text = selectTypeController.selectedType != nil ? selectTypeController.selectedType.Name : @"";
	exitAltField.text = [UIUtility formatAltitude:exitAltModel.selectedNumber unit:logEntry.AltitudeUnit];
	deplAltField.text = [UIUtility formatAltitude:deplAltModel.selectedNumber unit:logEntry.AltitudeUnit];
	delayField.text = [UIUtility formatDelay:[delayModel.selectedNumber intValue] estimated:isDelayEstimated];
    distToTargetField.text = [UIUtility formatDistance:distToTargetModel.selectedNumber unit:logEntry.AltitudeUnit];
	cutawayField.on = [logEntry.Cutaway boolValue];
	notesCell.textView.text = logEntry.Notes;
    [signatureCell updateImage:logEntry.Signature.Image];
	licenseField.text = logEntry.Signature.License;	
	
	// set gear text
	NSString *gearText = @"";
	for (int i = 0; i < [selectGearController.selectedGear count]; i++)
	{
		gearText = [gearText stringByAppendingString:[[selectGearController.selectedGear objectAtIndex:i] Name]];
		if (i < [selectGearController.selectedGear count] - 1)
		{
			gearText = [gearText stringByAppendingString:@", "];
		}
	}
	gearField.text = gearText;
}

- (LogEntry *)getLogEntry
{
    return logEntry;
}

- (void)save
{
	// update if there are changes
    
    if (![jumpNumberModel.selectedNumber isEqualToNumber:logEntry.JumpNumber])
        logEntry.JumpNumber = jumpNumberModel.selectedNumber;
    
    NSDate *date = [datePicker getDate];
    if (![date isEqualToDate:logEntry.Date])
        logEntry.Date = date;
    
    if (logEntry.Location != selectLocationController.selectedLocation)
        logEntry.Location = selectLocationController.selectedLocation;
    
    if (logEntry.Aircraft != selectAircraftController.selectedAircraft)
        logEntry.Aircraft = selectAircraftController.selectedAircraft;
	
    if (logEntry.SkydiveType != selectTypeController.selectedType)
        logEntry.SkydiveType = selectTypeController.selectedType;
	
    if (![exitAltModel.selectedNumber isEqualToNumber:logEntry.ExitAltitude])
        logEntry.ExitAltitude = exitAltModel.selectedNumber;
    
    if (![deplAltModel.selectedNumber isEqualToNumber:logEntry.DeploymentAltitude])
        logEntry.DeploymentAltitude = deplAltModel.selectedNumber;
    
    if (![delayModel.selectedNumber isEqualToNumber:logEntry.FreefallTime])
        logEntry.FreefallTime = delayModel.selectedNumber;
    
    if (![UIUtility numbersAreEqual:logEntry.DistanceToTarget num2:distToTargetModel.selectedNumber])
        logEntry.DistanceToTarget = distToTargetModel.selectedNumber;
    
    NSNumber *cutawayNum = [NSNumber numberWithBool:cutawayField.on];
    if (![cutawayNum isEqualToNumber:logEntry.Cutaway])
        logEntry.Cutaway = cutawayNum;
    
    if (![UIUtility stringsAreEqual:logEntry.Notes str2:notesCell.textView.text])
        logEntry.Notes = notesCell.textView.text;
 
    NSSet *selectedRigs = [NSSet setWithArray:selectGearController.selectedGear];
    if (![logEntry.Rigs isEqualToSet:selectedRigs])
    {
        [logEntry removeRigs:logEntry.Rigs];
        [logEntry addRigs:selectedRigs];
    }

    // if has changes, update last modified
    if ([logEntry hasChanges] || isNewLogEntry)
        logEntry.LastModifiedUTC = [DataUtil currentDate];
	
	// save
    LogEntryRepository *repository = [[RepositoryManager instance] logEntryRepository];
	[repository save];
}

- (void)deleteLogEntry:(id)sender
{
	// show delete prompt
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
													message:NSLocalizedString(@"LogEntryDeleteConfirmation", @"")
												   delegate:self
										  cancelButtonTitle:NSLocalizedString(@"NoButton", @"")
										  otherButtonTitles:NSLocalizedString(@"YesButton", @""),
                                                            NSLocalizedString(@"LogEntryDeleteYesAdjustButton", @""), nil];
	[alert show];
}

#pragma mark -
#pragma mark - NumberPickerModelDelegate

- (void)numberPickerModelChanged:(id)source
{
	// if manually setting delay, stop auto-estimation
	if (source == delayModel)
		isDelayEstimated = NO;

	// re-estimate delay
	[self updateDelayEstimate];
	// refresh fields
	[self refreshFields];
}

#pragma mark -
#pragma mark - DatePickerModelDelegate

 - (void)datePickerChanged:(NSDate *)selectedDate
{
    dateField.text = [UIUtility formatDate:selectedDate];
}

#pragma mark -
#pragma mark - ListSelectionDelegate

- (void)listSelectionChanged
{
	// re-estimate delay (if new jump type selected)
	[self updateDelayEstimate];
	// refresh fields
	[self refreshFields];
}

#pragma mark -
#pragma mark - NotesDelegate

- (void)notesUpdated:(NSString *)notes
{
    notesCell.textView.text = notes;
	// to resize cell
	[tableView reloadData];
}

#pragma mark -
#pragma mark - DiagramViewDelegate

- (void)diagramUpdated
{
    // refresh table
    [self refreshImageRows];
	[tableView reloadData];
}

#pragma mark -
#pragma mark - ImageViewViewerDelegate

- (void)imageDeleted
{
    // refresh table
    [self refreshImageRows];
	[tableView reloadData];
}

#pragma mark -
#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // create new logentryimage
    LogEntryRepository *repository = [[RepositoryManager instance] logEntryRepository];
    LogEntryImage *logEntryImage = [repository createNewPhotoForLogEntry:logEntry];
    
    // set image
    UIImage *image = (UIImage *)[info valueForKey:UIImagePickerControllerEditedImage];
    NSData *imageData = UIImagePNGRepresentation(image);
    logEntryImage.Image = image;
    logEntryImage.MD5 = [imageData md5];
    
    [picker dismissModalViewControllerAnimated:YES];
    
    // refresh table
    [self refreshImageRows];
	[tableView reloadData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		// delete
        LogEntryRepository *repository = [[RepositoryManager instance] logEntryRepository];
		[repository deleteLogEntry:logEntry];
		
		// notify delegate
        [delegate logEntryDeleted];
	}
    else if (buttonIndex == 2)
    {
        // get jump #
        NSInteger jumpNumber = [logEntry.JumpNumber intValue];
        
		// delete
        LogEntryRepository *repository = [[RepositoryManager instance] logEntryRepository];
		[repository deleteLogEntry:logEntry];
        
        // decrement jump #'s
        [repository decrementJumpNumbersAbove:jumpNumber];
        
        // notify delegate
        [delegate logEntryDeleted];
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

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// deselect row
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	    
    // get method
	NSString *methodName = [tableModel rowMethodName:indexPath.section rowIndex:indexPath.row];
	id object = [tableModel rowMethodObject:indexPath.section rowIndex:indexPath.row];
	
	// check if empty
	if ([methodName length] > 0)
	{
		SEL methodSelector = NSSelectorFromString(methodName);
		if (object != NULL)
		{
			[self performSelector:methodSelector withObject:object];
		}
		else
		{
			[self performSelector:methodSelector];
		}
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
