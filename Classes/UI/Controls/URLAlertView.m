//
//  URLAlertView.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 5/4/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "URLAlertView.h"

@implementation URLAlertView

@synthesize urlField;

- (id)initWithDelegate:(id<URLAlertViewDelegate>)theDelegate
{
	if (self = [super initWithTitle:NSLocalizedString(@"URLDialogTitle", @"")
                            message:NSLocalizedString(@"URLDialogMessage", @"")
                           delegate:nil
                  cancelButtonTitle:NSLocalizedString(@"CancelButton", @"")
                  otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil])
	{
        // set delegate
        delegate = theDelegate;
        
        // create url field
		UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(16, 80, 250, 25)];
		field.backgroundColor = [UIColor whiteColor];
		field.clearButtonMode = UITextFieldViewModeWhileEditing;
		field.keyboardType = UIKeyboardTypeURL;
		field.autocorrectionType = UITextAutocorrectionTypeNo;
		field.autocapitalizationType = UITextAutocapitalizationTypeNone;
		[field becomeFirstResponder];
		[self addSubview:field];
		
		self.urlField = field;
	}
	return self;
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    [super dismissWithClickedButtonIndex:buttonIndex animated:animated];
    
    if (buttonIndex == 1)
    {
        // get url string
        NSMutableString *urlStr = [NSMutableString stringWithString:urlField.text];
		
		// fix up url
		if (![[urlStr lowercaseString] hasPrefix:@"http://"])
			[urlStr insertString:@"http://" atIndex:0];
        
        // get base url
        NSURL *url = [NSURL URLWithString:urlStr];
        
        // invoke delegate
        [delegate urlSelected:url];
    }
}

@end
