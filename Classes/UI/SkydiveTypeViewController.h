//
//  SkydiveTypeViewController.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 9/2/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SkydiveType.h"
#import "NotesCell.h"
#import "DeleteButtonCell.h"
#import "NotesViewController.h"
#import "TableModel.h"
#import "SelectFreefallProfileViewController.h"

@interface SkydiveTypeViewController : UITableViewController <UITextFieldDelegate,
																UIAlertViewDelegate,
																ListSelectionDelegate,
																NotesDelegate>
{
	IBOutlet UITableViewCell *nameCell;
	IBOutlet UITextField *nameField;
    IBOutlet UITableViewCell *defaultCell;
	IBOutlet UISwitch *defaultField;
	IBOutlet UITableViewCell *freefallProfileCell;
	IBOutlet UILabel *freefallProfileField;
	NotesCell *notesCell;
	DeleteButtonCell *deleteCell;
	
	TableModel *tableModel;
	
	SelectFreefallProfileViewController *selectProfileController;
	
	SkydiveType *skydiveType;
	BOOL isNewSkydiveType;
}

- (id)initWithSkydiveType:(SkydiveType *)theSkydiveType isNew:(BOOL)isNew;

@end
