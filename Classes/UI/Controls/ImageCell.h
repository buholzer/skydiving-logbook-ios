//
//  ImageCell.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/10/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewCellAdditions.h"

@interface ImageCell : UITableViewCell
{
    UIImageView *imageView;
}

- (void)updateImage:(UIImage *)image;

@end
