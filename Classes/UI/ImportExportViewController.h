//
//  ImportExportViewController.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/19/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "ExportTask.h"
#import "ImportTask.h"

extern NSString * const DropBoxAuthenticationNotification;

@interface ImportExportViewController : UIViewController<
    ExportTaskDelegate,
    MFMailComposeViewControllerDelegate>
{
    ExportTask *exportTask;
    ImportTask *importTask;
    
    BOOL isExport;
    ExportDestination exportDestination;
    ImportSource importSource;

	IBOutlet UIButton *exportToEmailButton;
    IBOutlet UIButton *logoutOfDropBoxButton;
}

- (IBAction)exportToEmail:(id)sender;
- (IBAction)exportToDropBox:(id)sender;
- (IBAction)importFromUrl:(id)sender;
- (IBAction)importFromDropBox:(id)sender;
- (IBAction)logoutOfDropBox:(id)sender;

@end
