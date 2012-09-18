//
//  NotesCell.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/23/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "NotesCell.h"

// font size
static CGFloat fontSize = 16;

@implementation NotesCell

@synthesize textView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
	{
		// init cell
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        // create/add text view
		textView = [[UITextView alloc] init];
		textView.editable = NO;
		textView.scrollEnabled = NO;
		textView.font = [UIFont systemFontOfSize:fontSize];
		textView.userInteractionEnabled = NO;
		[self.contentView addSubview:textView];
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect bounds = self.contentView.bounds;
	textView.frame = CGRectMake(bounds.origin.x + 5, bounds.origin.y + 5, bounds.size.width - 5, bounds.size.height - 5);
}

- (CGFloat)getCellHeight
{
    return [self calculateCellHeight:textView.text font:textView.font];
}

@end
