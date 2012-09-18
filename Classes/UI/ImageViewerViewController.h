//
//  ImageViewerViewController.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogEntryImage.h"

@protocol ImageViewerViewDelegate<NSObject>
- (void)imageDeleted;
@end

@interface ImageViewerViewController : UIViewController<UIAlertViewDelegate,UIScrollViewDelegate>
{
    UIScrollView *scrollView;
    UIImageView *imageView;
    
    id<ImageViewerViewDelegate> delegate;
    LogEntryImage *logEntryImage;
    
    CGFloat previousScale;
    CGFloat previousRotation;
    
    CGFloat beginX;
    CGFloat beginY;
}

- (id)initWithLogEntryImage:(LogEntryImage *)logEntryImage delegate:(id<ImageViewerViewDelegate>)theDelegate;

@end
