//
//  LogbookEntryViewController.h
//  SkydiveLogbook
//
//  Created by Tom Cain on 2/19/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogEntry.h"
#import "Signature.h"
#import "Location.h"
#import "Aircraft.h"
#import "SelectLocationViewController.h"
#import "SelectAircraftViewController.h"
#import "SelectGearViewController.h"
#import "SelectSkydiveTypeViewController.h"
#import "NotesViewController.h"
#import "DiagramViewController.h"
#import "ImageViewerViewController.h"
#import "DeleteButtonCell.h"
#import "NotesCell.h"
#import "ImageCell.h"
#import "TableModel.h"
#import "NumberPickerModel.h"
#import "PickerView.h"
#import "DatePickerView.h"

@protocol LogEntryViewControllerDelegate<NSObject>
- (void)jumpNumberChanged:(NSNumber *)jumpNumber;
- (void)logEntryDeleted;
@end

@interface LogbookEntryViewController : UIViewController <UITableViewDelegate,
															UITableViewDataSource,
															UITextFieldDelegate,
															UIAlertViewDelegate,
															NumberPickerModelDelegate,
                                                            DatePickerDelegate,
															ListSelectionDelegate,
															NotesDelegate,
															DiagramViewDelegate,
                                                            ImageViewerViewDelegate,
                                                            UIImagePickerControllerDelegate,
                                                            UINavigationControllerDelegate>
{
	IBOutlet UITableView *tableView;
	IBOutlet UITableViewCell *jumpNumberCell;
	IBOutlet UILabel *jumpNumberField;
	IBOutlet UITableViewCell *dateCell;
	IBOutlet UILabel *dateField;
	IBOutlet UITableViewCell *locationCell;
	IBOutlet UILabel *locationField;
	IBOutlet UITableViewCell *aircraftCell;
	IBOutlet UILabel *aircraftField;
	IBOutlet UITableViewCell *gearCell;
	IBOutlet UILabel *gearField;
	
	IBOutlet UITableViewCell *jumpTypeCell;
	IBOutlet UILabel *jumpTypeField;
	IBOutlet UITableViewCell *exitAltCell;
	IBOutlet UILabel *exitAltField;
	IBOutlet UITableViewCell *deplAltCell;
	IBOutlet UILabel *deplAltField;
	IBOutlet UITableViewCell *delayCell;
	IBOutlet UILabel *delayField;
	IBOutlet UITableViewCell *distToTargetCell;
	IBOutlet UILabel *distToTargetField;
	IBOutlet UITableViewCell *cutawayCell;
	IBOutlet UISwitch *cutawayField;
    
    IBOutlet UITableViewCell *choosePhotoCell;
    IBOutlet UITableViewCell *takePhotoCell;
    IBOutlet UITableViewCell *addDiagramCell;
	
	IBOutlet UITableViewCell *licenseCell;
	IBOutlet UILabel *licenseField;
    
    DatePickerView *datePicker;
    PickerView *numberPicker;
	
	UIBarButtonItem *pickerDoneButton;
	UIBarButtonItem *pickerIncrementAltButton;
	UIBarButtonItem *pickerDecrementAltButton;
	UIBarButtonItem *pickerEstimateDelayButton;
    UIBarButtonItem *pickerClearDistanceToTargetButton;
	UIBarButtonItem *pickerSpacerButton;
	
	NotesCell *notesCell;
	ImageCell *signatureCell;
	DeleteButtonCell *deleteCell;
	
	TableModel *tableModel;
	NumberPickerModel *jumpNumberModel;
	NumberPickerModel *exitAltModel;
	NumberPickerModel *deplAltModel;
	NumberPickerModel *delayModel;
    NumberPickerModel *distToTargetModel;
    
    UIPopoverController *choosePhotoPopoverController;
    UIImagePickerController *choosePhotoController;
    UIImagePickerController *takePhotoController;
	
	SelectLocationViewController *selectLocationController;
	SelectAircraftViewController *selectAircraftController;
	SelectGearViewController *selectGearController;
	SelectSkydiveTypeViewController *selectTypeController;
	
    id<LogEntryViewControllerDelegate> delegate;
	LogEntry *logEntry;
	BOOL isNewLogEntry;
	BOOL isDelayEstimated;
}

- (id)initWithLogEntry:(LogEntry *)newLogEntry isNew:(BOOL)isNew delegate:(id<LogEntryViewControllerDelegate>)delegate;
- (LogEntry *)getLogEntry;
- (void)save;

@end
