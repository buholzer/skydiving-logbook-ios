//
//  DeleteButtonCell.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/23/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "DeleteButtonCell.h"

static UIImage *backgroundImage = nil;

@implementation DeleteButtonCell

@synthesize button;

+ (void)initialize
{
	backgroundImage = [[UIImage imageNamed:@"redbutton.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
	{
		// create/init button
		self.button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button setTitle:NSLocalizedString(@"DeleteButton", @"") forState:UIControlStateNormal];
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[button.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
		[button setBackgroundImage:backgroundImage forState:UIControlStateNormal];

		// add to cell
		[self.contentView addSubview:button];
	}
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	button.frame = self.contentView.bounds;
}

@end
