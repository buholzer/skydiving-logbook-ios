//
//  LocationViewController.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/19/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import "NotesCell.h"
#import "DeleteButtonCell.h"
#import "NotesViewController.h"
#import "TableModel.h"

@interface LocationViewController : UITableViewController <UITextFieldDelegate,
															UIAlertViewDelegate,
															NotesDelegate>
{
	IBOutlet UITableViewCell *nameCell;
	IBOutlet UITextField *nameField;
	IBOutlet UITableViewCell *homeCell;
	IBOutlet UISwitch *homeField;
	NotesCell *notesCell;
	DeleteButtonCell *deleteCell;
	
	TableModel *tableModel;
	
	Location *location;
	BOOL isNewLocation;
}

- (id)initWithLocation:(Location *)theLocation isNew:(BOOL)isNew;

@end
