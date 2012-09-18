//
//  NameValueCell.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 4/28/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "NameValueCell.h"

static float NameFontSize = 12;
static float ValueFontSize = 17;

@implementation NameValueCell

@synthesize nameLabel, valueLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
	{
        // create/add labels
		self.valueLabel = [[UILabel alloc] init];
		self.valueLabel.font = [UIFont systemFontOfSize:ValueFontSize];
		self.valueLabel.textAlignment = UITextAlignmentRight; 
		[self.contentView addSubview:self.valueLabel];
		
		self.nameLabel = [[UILabel alloc] init];
		self.nameLabel.font = [UIFont boldSystemFontOfSize:NameFontSize];
		self.nameLabel.textAlignment = UITextAlignmentLeft;
		[self.contentView addSubview:self.nameLabel];
		
		
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect bounds = self.contentView.bounds;
	CGRect adjustedBounds = CGRectMake(
									   bounds.origin.x + 10,
									   bounds.origin.y + 3,
									   bounds.size.width - 10,
									   bounds.size.height - 3);

	// get sizes based on text values
	CGSize nameLabelSize = [nameLabel.text sizeWithFont:nameLabel.font constrainedToSize:adjustedBounds.size lineBreakMode:UILineBreakModeClip];
	CGSize valueLabelSize = [valueLabel.text sizeWithFont:valueLabel.font constrainedToSize:adjustedBounds.size lineBreakMode:UILineBreakModeClip];
	
	// set name label frame
	self.nameLabel.frame = CGRectMake(adjustedBounds.origin.x,
									  adjustedBounds.size.height/2 - nameLabelSize.height/2,
									  nameLabelSize.width,
									  nameLabelSize.height);
	
	// set value label frame
	self.valueLabel.frame = CGRectMake(adjustedBounds.size.width - valueLabelSize.width,
									   adjustedBounds.size.height/2 - valueLabelSize.height/2,
									   valueLabelSize.width,
									   valueLabelSize.height);
}
@end
