//
//  ImageViewerViewController.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageViewerViewController.h"
#import "RepositoryManager.h"

@implementation ImageViewerViewController

- (id)initWithLogEntryImage:(LogEntryImage *)img delegate:(id<ImageViewerViewDelegate>)theDelegate
{
    if (self = [super init])
	{
        logEntryImage = img;
        delegate = theDelegate;
        
        self.title = NSLocalizedString(@"ImageTitle", @"");
        
        // init scroll view
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        [scrollView setBackgroundColor:[UIColor blackColor]];
        [scrollView setCanCancelContentTouches:NO];
        scrollView.clipsToBounds = YES;
        scrollView.minimumZoomScale = 1;
        scrollView.maximumZoomScale = 10;
        [scrollView setScrollEnabled:YES];
        scrollView.delegate = self;
        scrollView.indicatorStyle = UIScrollViewIndicatorStyleDefault;
        [self.view addSubview:scrollView];
        
        // init image view
        imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        imageView.image = logEntryImage.Image;
        [scrollView addSubview:imageView];
        
        // add done button
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
        self.navigationItem.rightBarButtonItem = doneButton;
        
        // add delete button
        UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DeleteButton", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(promptDelete)];
        self.navigationItem.leftBarButtonItem = deleteButton;
        
		self.hidesBottomBarWhenPushed = YES;
	}
	
	return self;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
        
    // get image
    UIImage *image = logEntryImage.Image;
    
    // get image/view sizes
    CGSize viewSize = self.view.bounds.size;
    CGSize imageSize = image.size;
    
    // get scaled image size
    CGSize scaledImageSize = imageSize;
    if (imageSize.height > imageSize.width)
    {
        CGFloat scale = viewSize.height / imageSize.height;
        scaledImageSize = CGSizeMake(scale * imageSize.width, viewSize.height);
    }
    else
    {
        CGFloat scale = viewSize.width / imageSize.width;
        scaledImageSize = CGSizeMake(viewSize.width, scale * imageSize.height);
    }
    
    // create rect for scaled image centered in view
    CGRect imageViewRect = CGRectMake(
                      (viewSize.width - scaledImageSize.width)/2,
                      (viewSize.height - scaledImageSize.height)/2,
                      scaledImageSize.width,
                      scaledImageSize.height);
        
    // update scroll view
    scrollView.frame = self.view.bounds;
    [scrollView setContentSize:CGSizeMake(imageViewRect.size.width, imageViewRect.size.height)];    
    
    // update image view
    imageView.frame = imageViewRect;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

- (void)done
{
	// return to prev view
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)promptDelete
{
    // otherwise, show prompt
	// show delete prompt
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
													message:NSLocalizedString(@"LogEntryPhotoDeleteConfirmation", @"")
												   delegate:self
										  cancelButtonTitle:NSLocalizedString(@"NoButton", @"")
										  otherButtonTitles:NSLocalizedString(@"YesButton", @""), nil];
	[alert show];
}

- (void)delete
{
    // delete
    LogEntryRepository *repository = [[RepositoryManager instance] logEntryRepository];
    [repository deleteLogEntryImage:logEntryImage];
    
    // notify delegate
    if (delegate != NULL)
    {
        [delegate imageDeleted];
    }
    
    // return to prev view
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
        [self delete];
	}
}

@end
