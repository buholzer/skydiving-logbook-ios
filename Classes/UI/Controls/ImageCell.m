//
//  ImageCell.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/10/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "ImageCell.h"

@implementation ImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
	{
		imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		[self.contentView addSubview:imageView];
    }
    return self;
}

- (void)updateImage:(UIImage *)image
{
    imageView.image = image;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
    CGRect bounds = self.contentView.bounds;
	imageView.frame = bounds;
}

- (CGFloat)getCellHeight
{
    CGFloat defaultHeight = [super getCellHeight];
    // if no image, return default
    if (imageView.image == nil)
        return defaultHeight;

    CGFloat cellWidth = [self getDefaultCellWidth];
    CGSize imgSize = imageView.image.size;
    // get scale % based on cell width
    CGFloat scale = cellWidth / imgSize.width;
    scale = MIN(scale, 1); // don't upscale
    CGFloat scaledHeight = imgSize.height * scale;
    
    return MAX(scaledHeight, defaultHeight);
}

@end
