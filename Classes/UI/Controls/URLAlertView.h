//
//  URLAlertView.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 5/4/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol URLAlertViewDelegate<NSObject>
- (void)urlSelected:(NSURL *)url;
@end


@interface URLAlertView : UIAlertView
{
    id<URLAlertViewDelegate> delegate;
}

@property (strong) UITextField *urlField;

- (id)initWithDelegate:(id<URLAlertViewDelegate>)delegate;

@end
