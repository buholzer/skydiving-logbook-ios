//
//  RigComponentViewController.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/25/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RigComponent.h"
#import "NotesCell.h"
#import "DeleteButtonCell.h"
#import "NotesViewController.h"
#import "TableModel.h"

@protocol RigComponentDelegate <NSObject>

- (void)componentUpdated;

@end


@interface RigComponentViewController : UITableViewController <UITextFieldDelegate,
																UIAlertViewDelegate,
																NotesDelegate>
{
	IBOutlet UITableViewCell *nameCell;
	IBOutlet UITextField *nameField;
	IBOutlet UITableViewCell *serialCell;
	IBOutlet UITextField *serialField;
	NotesCell *notesCell;
	DeleteButtonCell *deleteCell;
	
	TableModel *tableModel;
	
	RigComponent *component;
	BOOL isNewComponent;
	
	id<RigComponentDelegate> delegate;
}

- (id)initWithComponent:(RigComponent *)newComponent isNew:(BOOL)isNew delegate:(id<RigComponentDelegate>)theDelegate;

@end
