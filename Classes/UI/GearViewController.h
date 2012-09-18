//
//  GearViewController.h
//  SkydiveLogbook
//
//  Created by Tom Cain on 2/19/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotesCell.h"
#import "DeleteButtonCell.h"
#import "NotesViewController.h"
#import "RigComponentViewController.h"
#import "RigReminderViewController.h"
#import "Rig.h"
#import "TableModel.h"

@interface GearViewController : UITableViewController <UITextFieldDelegate,
													UIAlertViewDelegate,
													NotesDelegate,
													RigComponentDelegate,
													RigReminderDelegate>
{
	IBOutlet UITableViewCell *nameCell;
	IBOutlet UITextField *nameField;
	IBOutlet UITableViewCell *primaryCell;
	IBOutlet UISwitch *primaryField;
	IBOutlet UITableViewCell *archiveCell;
	IBOutlet UISwitch *archiveField;
	IBOutlet UITableViewCell *jumpCountCell;
	IBOutlet UILabel *jumpCountField;
	IBOutlet UITableViewCell *addComponentCell;
	IBOutlet UITableViewCell *addReminderCell;
	NotesCell *notesCell;
	DeleteButtonCell *deleteCell;
	
	TableModel *tableModel;
	
	Rig *rig;
	BOOL isNewRig;
}

- (id)initWithRig:(Rig *)newRig isNew:(BOOL)isNew;

@end
