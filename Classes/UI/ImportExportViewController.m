//
//  ImportExportViewController.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/19/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "ImportExportViewController.h"
#import "UIUtility.h"
#import "URLAlertView.h"

NSString * const DropBoxAuthenticationNotification = @"DropBoxAuthenticationNotification";

@interface ImportExportViewController(Private)
- (void)updateButtons;
- (void)doDropBoxImportExport;
- (void)doImportExport;
- (void)dropBoxAuthenticationNotification:(NSNotification *)notification;
@end

@implementation ImportExportViewController

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
    
    // register for dropbox authentication updates
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropBoxAuthenticationNotification:) name:DropBoxAuthenticationNotification object:nil];
    
    // init UI
    [self updateButtons];
}

- (void)viewDidUnload
{
    // unregister for dropbox authentication updates
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
}

- (IBAction)exportToEmail:(id)sender
{
    isExport = TRUE;
    exportDestination = ExportToEmail;
    [self doImportExport];
}

- (IBAction)exportToDropBox:(id)sender
{
    isExport = TRUE;
    exportDestination = ExportToDropBox;
    [self doDropBoxImportExport];
    
    // update buttons
    [self updateButtons];
}

- (IBAction)importFromUrl:(id)sender
{
    isExport = FALSE;
    importSource = ImportFromUrl;
    [self doImportExport];
}

- (IBAction)importFromDropBox:(id)sender
{
    isExport = FALSE;
    importSource = ImportFromDropBox;
    [self doDropBoxImportExport];
}

- (IBAction)logoutOfDropBox:(id)sender
{
    // logout, update buttons
    [[DBSession sharedSession] unlinkAll];
    [self updateButtons];
}

- (void)dropBoxAuthenticationNotification:(NSNotification *)notification
{
    [self updateButtons];
}

- (void)updateButtons
{
    // init UI
	exportToEmailButton.enabled = [MFMailComposeViewController canSendMail];
    logoutOfDropBoxButton.hidden = ![[DBSession sharedSession] isLinked];
}

- (void)doDropBoxImportExport
{
    if (![[DBSession sharedSession] isLinked])
    {
        [[DBSession sharedSession] link];
    }
    else
    {
        [self doImportExport];
    }
}

- (void)doImportExport
{
    if (isExport)
    {
        if (!exportTask)
        {
            exportTask = [[ExportTask alloc] initWithDelegate:self];
        }
        [exportTask beginExport:exportDestination];
    }
    else
    {
        if (!importTask)
        {
            importTask = [[ImportTask alloc] init];
        }
        [importTask beginImport:importSource];
    }
}

#pragma mark -
#pragma mark ExportTaskDelegate

- (void)sendEmail:(NSString*)zipFilePath
{
    // get file name
    NSString* fileName = [zipFilePath lastPathComponent];
    
    // get contents
    NSData *fileData = [NSData dataWithContentsOfFile:zipFilePath];
    
    // email ui controller
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    mailController.navigationBar.barStyle = UIBarStyleBlack;
    mailController.mailComposeDelegate = self;
    
    // compose email
    [mailController setSubject:@"Skydiving Logbook"];
    [mailController setMessageBody:NSLocalizedString(@"ExportEmailMessage", @"") isHTML:NO];
    // add file attachments
    [mailController addAttachmentData:fileData mimeType:@"application/zip" fileName:fileName];
    
    // show email ui
    [self presentModalViewController:mailController animated:YES];
}

#pragma mark 0
#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	[self dismissModalViewControllerAnimated:YES];
}

@end