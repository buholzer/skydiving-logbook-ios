//
//  AircraftViewController.h
//  SkydiveLogbook
//
//  Created by Tom Cain on 2/19/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Aircraft.h"
#import "DeleteButtonCell.h"
#import "NotesCell.h"
#import "NotesViewController.h"
#import "TableModel.h"

@interface AircraftViewController : UITableViewController <UITextFieldDelegate,
															UIAlertViewDelegate,
															NotesDelegate>
{
	IBOutlet UITableViewCell *nameCell;
	IBOutlet UITextField *nameField;
	IBOutlet UITableViewCell *defaultCell;
	IBOutlet UISwitch *defaultField;
	NotesCell *notesCell;
	DeleteButtonCell *deleteCell;

	TableModel *tableModel;
	
	Aircraft *aircraft;
	BOOL isNewAircraft;
}

- (id)initWithAircraft:(Aircraft *)newAircraft isNew:(BOOL)isNew;

@end
