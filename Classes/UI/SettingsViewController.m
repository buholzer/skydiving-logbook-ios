//
//  SettingsViewController.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/19/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "SettingsViewController.h"
#import "RepositoryManager.h"
#import "SettingsRepository.h"
#import "Units.h"
#import "UIUtility.h"

@interface SettingsViewController(Private)
- (void)setPickerVisible:(BOOL)visible;
- (void)showPicker:(NumberPickerModel *)model;
- (void)showHourPicker;
- (void)showMinutePicker;
- (void)showSecondPicker;
- (void)showCutawayPicker;
- (void)showExitAltitudePicker;
- (void)showDeploymentAltitudePicker;
- (void)hidePicker;
- (void)updateFields;
@end

@implementation SettingsViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder])
	{
		self.hidesBottomBarWhenPushed = YES;
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// init table model
	tableModel = [[TableModel alloc]  init];
	[tableModel addSection:NSLocalizedString(@"LogbookHistory", @"")];
	[tableModel addRowWithSelectMethod:0 cell:freefallTimeCell methodName:@"showHourPicker"];
	[tableModel addRowWithSelectMethod:0 cell:cutawayCell methodName:@"showCutawayPicker"];
	[tableModel addSection:NSLocalizedString(@"LogbookSettings", @"")];
	[tableModel addRowWithSelectMethod:1 cell:defaultExitAltCell methodName:@"showExitAltitudePicker"];
	[tableModel addRowWithSelectMethod:1 cell:defaultDeplAltCell methodName:@"showDeploymentAltitudePicker"];
	[tableModel addSection:NSLocalizedString(@"UnitOfMeasure", @"")];
	[tableModel addRowWithSelectMethod:2 cell:unitsUSCell methodName:@"setUSUnits"];
	[tableModel addRowWithSelectMethod:2 cell:unitsMetricCell methodName:@"setMetricUnits"];
	
	// init cells
	unitsUSCell.textLabel.text = NSLocalizedString(@"US", @"");
	unitsMetricCell.textLabel.text = NSLocalizedString(@"Metric", @"");
    
    // init picker view
    pickerView = [[PickerView alloc] initForView:self.view table:tableView];
	
	// init picker models
	// hour
	hourModel = [[NumberPickerModel alloc] initWithDigitCount:3
										  maxSignificantDigit:9
													 unitKeys:[NSArray arrayWithObject:@"hours"]
													unitWidth:120];
	hourModel.delegate = self;
	// minute
	minuteModel = [[NumberPickerModel alloc] initWithDigitCount:2
											maxSignificantDigit:5
													   unitKeys:[NSArray arrayWithObject:@"minutes"]
													  unitWidth:164];
	minuteModel.delegate = self;
	// second
	secondModel = [[NumberPickerModel alloc] initWithDigitCount:2
											maxSignificantDigit:5
													   unitKeys:[NSArray arrayWithObject:@"seconds"]
													  unitWidth:164];
	secondModel.delegate = self;
	// cutaways
	cutawayModel = [[NumberPickerModel alloc] initWithDigitCount:2];
	cutawayModel.delegate = self;
	// exit altitude
	defaultExitAltModel = [[NumberPickerModel alloc] initWithDigitCount:5];
	defaultExitAltModel.delegate = self;
	// deployment altitude
	defaultDeplAltModel = [[NumberPickerModel alloc] initWithDigitCount:5];
	defaultDeplAltModel.delegate = self;

	// init picker toolbar buttons
	pickerDoneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(hidePicker)];
	pickerHourButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SettingsHourButton", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(showHourPicker)];
	pickerMinuteButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SettingsMinuteButton", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(showMinutePicker)];
	pickerSecondButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SettingsSecondButton", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(showSecondPicker)];
	pickerSpacerButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];

	// get history
    LogbookHistoryRepository *repository = [[RepositoryManager instance] logbookHistoryRepository];
	LogbookHistory *history = [repository history];
	
	// get freefall time pieces
	int totalSeconds = [history.FreefallTime intValue];
	int hours = totalSeconds / 3600;
	int secondsLeftFromHours = totalSeconds % 3600;
	int minutes = secondsLeftFromHours / 60;
	int seconds = secondsLeftFromHours % 60;
	
	// init history models
	hourModel.selectedNumber = [NSNumber numberWithInt:hours];
	minuteModel.selectedNumber = [NSNumber numberWithInt:minutes];
	secondModel.selectedNumber = [NSNumber numberWithInt:seconds];
	cutawayModel.selectedNumber = history.Cutaways;
	
	// init uom selection
	enum UnitOfMeasure uom = [SettingsRepository unitOfMeasure];
	if (uom == US)
		unitsUSCell.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		unitsMetricCell.accessoryType = UITableViewCellAccessoryCheckmark;
	
	// init exit/depl altitudes
	defaultExitAltModel.selectedNumber = [SettingsRepository defaultExitAltitude];
	defaultDeplAltModel.selectedNumber = [SettingsRepository defaultDeploymentAltitude];

	// update fields
	[self updateFields];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[pickerView hidePicker];
	[super viewWillDisappear:animated];
}

- (void)showHourPicker
{
    NSArray *toolbarItems = [NSArray arrayWithObjects:
                             pickerHourButton,
                             pickerMinuteButton,
                             pickerSecondButton,
                             pickerSpacerButton,
                             pickerDoneButton, nil];
    [pickerView showNumberPicker:hourModel forView:freefallTimeCell toolbarItems:toolbarItems];
	
	// scroll field to visible
	[tableView scrollToRowAtIndexPath:[tableView indexPathForCell:freefallTimeCell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)showMinutePicker
{
    NSArray *toolbarItems = [NSArray arrayWithObjects:
                             pickerHourButton,
                             pickerMinuteButton,
                             pickerSecondButton,
                             pickerSpacerButton,
                             pickerDoneButton, nil];
    [pickerView showNumberPicker:minuteModel forView:freefallTimeCell toolbarItems:toolbarItems];

	// scroll field to visible
	[tableView scrollToRowAtIndexPath:[tableView indexPathForCell:freefallTimeCell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)showSecondPicker
{
    NSArray *toolbarItems = [NSArray arrayWithObjects:
                             pickerHourButton,
                             pickerMinuteButton,
                             pickerSecondButton,
                             pickerSpacerButton,
                             pickerDoneButton, nil];
    [pickerView showNumberPicker:secondModel forView:freefallTimeCell toolbarItems:toolbarItems];

	// scroll field to visible
	[tableView scrollToRowAtIndexPath:[tableView indexPathForCell:freefallTimeCell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)showCutawayPicker
{
    NSArray *toolbarItems = [NSArray arrayWithObjects:pickerSpacerButton, pickerDoneButton, nil];
    [pickerView showNumberPicker:cutawayModel forView:cutawayCell toolbarItems:toolbarItems];
    
	// scroll field to visible
	[tableView scrollToRowAtIndexPath:[tableView indexPathForCell:cutawayCell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)showExitAltitudePicker
{
    NSArray *toolbarItems = [NSArray arrayWithObjects:pickerSpacerButton, pickerDoneButton, nil];
    [pickerView showNumberPicker:defaultExitAltModel forView:defaultExitAltCell toolbarItems:toolbarItems];

	// scroll field to visible
	[tableView scrollToRowAtIndexPath:[tableView indexPathForCell:defaultExitAltCell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];	
}

- (void)showDeploymentAltitudePicker
{
    NSArray *toolbarItems = [NSArray arrayWithObjects:pickerSpacerButton, pickerDoneButton, nil];
    [pickerView showNumberPicker:defaultDeplAltModel forView:defaultDeplAltCell toolbarItems:toolbarItems];

	// scroll field to visible
	[tableView scrollToRowAtIndexPath:[tableView indexPathForCell:defaultDeplAltCell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];	
}

- (void)hidePicker
{
    [pickerView hidePicker];
}

- (void)setUSUnits
{
	// update repo
	[SettingsRepository setUnitOfMeasure:US];
	// update check marks
	unitsUSCell.accessoryType = UITableViewCellAccessoryCheckmark;
	unitsMetricCell.accessoryType = UITableViewCellAccessoryNone;
	// update fields
	[self updateFields];
	// reload table
	[tableView reloadData];
}

- (void)setMetricUnits
{
	// update repo
	[SettingsRepository setUnitOfMeasure:Metric];
	// update check marks
	unitsUSCell.accessoryType = UITableViewCellAccessoryNone;
	unitsMetricCell.accessoryType = UITableViewCellAccessoryCheckmark;
	// update fields
	[self updateFields];
	// reload table
	[tableView reloadData];
}

- (void)updateFields
{
	// logbook history labels
	freefallTimeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"FreefallTimeFormat", @""),
							  [hourModel.selectedNumber intValue],
							  [minuteModel.selectedNumber intValue],
							  [secondModel.selectedNumber intValue]];
	cutawayLabel.text = [NSString stringWithFormat:@"%d",
							[cutawayModel.selectedNumber intValue]];
	// logbook settings
	NSString *unitStr = [Units altitudeToString:[SettingsRepository altitudeUnit]];
	defaultExitAltLabel.text = [UIUtility formatAltitude:defaultExitAltModel.selectedNumber
													unit:unitStr];
	defaultDeplAltLabel.text = [UIUtility formatAltitude:defaultDeplAltModel.selectedNumber
													unit:unitStr];
}

#pragma mark -
#pragma mark - NumberPickerModelDelegate

- (void)numberPickerModelChanged:(id)source
{
	// get freefall time values
	int hours = [hourModel.selectedNumber intValue];
	int minutes = [minuteModel.selectedNumber intValue];
	int seconds = [secondModel.selectedNumber intValue];
	int totalSeconds = (hours * 60 * 60) + (minutes * 60) + seconds;
	
	// get history
    LogbookHistoryRepository *repository = [[RepositoryManager instance] logbookHistoryRepository];
	LogbookHistory *history = [repository history];
	// update history
	history.FreefallTime = [NSNumber numberWithInt:totalSeconds];
	history.Cutaways = cutawayModel.selectedNumber;
	// save
	[repository save];
	
	// update logbook settings
	[SettingsRepository setDefaultExitAltitude:defaultExitAltModel.selectedNumber];
	[SettingsRepository setDefaultDeploymentAltitude:defaultDeplAltModel.selectedNumber];
	
	// update fields
	[self updateFields];
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
	
	// check if empty
	if ([methodName length] > 0)
	{
		// invoke method
		SEL methodSelector = NSSelectorFromString(methodName);
		[self performSelector:methodSelector];
	}
}

@end
