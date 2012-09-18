//
//  UIUtility.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/23/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "UIUtility.h"
#import "NotesCell.h"
#import "Signature.h"

// formats
static NSDateFormatter *dateFormat = nil;
static NSNumberFormatter *numberFormat = nil;
static NSNumberFormatter *percentFormat = nil;

// colors/images
static UIColor *pastDueColor = nil;
static UIImage *skullImage = nil;

// LogEntryTableCell constants
static CGFloat MinimumCellHeight = 66;
static CGFloat MaximumNotesHeight = 54;
static CGFloat SignatureImageHeight = 22;
// view tags (these match with tags in xib file)
static NSInteger JumpNumberFieldTag = 10;
static NSInteger DateFieldTag = 20;
static NSInteger LocationFieldTag = 30;
static NSInteger AircraftFieldTag = 40;
static NSInteger JumpTypeFieldTag = 50;
static NSInteger NotesFieldTag = 60;
static NSInteger SignatureFieldTag = 70;

@interface UIUtility(Private)
+ (void)setFieldText:(UITableViewCell *)cell tag:(NSInteger)tag text:(NSString *)text;
@end

@implementation UIUtility


//////////////////////////////////////////////
/// Is iPad
/////////////////////////////////////////////
+(BOOL)isiPad
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

//////////////////////////////////////////////
/// String Formatting Methods
/////////////////////////////////////////////

+ (NSString *)formatDate:(NSDate *)date
{
	if (dateFormat == nil)
	{
		dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateStyle:NSDateFormatterMediumStyle];
	}
	return [dateFormat stringFromDate:date];
}

+(NSString *)formatNumber:(NSNumber *)number
{
	if (numberFormat == nil)
	{
		numberFormat = [[NSNumberFormatter alloc] init];
		[numberFormat setNumberStyle:NSNumberFormatterDecimalStyle];
		[numberFormat setMaximumFractionDigits:1];
		[numberFormat setRoundingMode:NSNumberFormatterRoundUp];
	}
	return [numberFormat stringFromNumber:number];
}

+(NSString *)formatProgress:(float)progress
{
	if (percentFormat == nil)
	{
		percentFormat = [[NSNumberFormatter alloc] init];
		[percentFormat setNumberStyle:NSNumberFormatterPercentStyle];
	}
	
	NSString *percentStr = [percentFormat stringFromNumber:[NSNumber numberWithFloat:progress]];
	return [NSString stringWithFormat:
			NSLocalizedString(@"ProgressFormat", @""),
			percentStr];
}

+(NSString *)formatDelay:(int)delay estimated:(BOOL)estimated
{
	if (estimated)
		return [NSString localizedStringWithFormat:@"~ %d %@", delay, NSLocalizedString(@"Seconds", @"")];
	else
		return [NSString localizedStringWithFormat:@"%d %@", delay, NSLocalizedString(@"Seconds", @"")];
}

+(NSString *)formatAltitude:(NSNumber *)altitude unit:(NSString *)unit
{
	if (numberFormat == nil)
	{
		numberFormat = [[NSNumberFormatter alloc] init];
		[numberFormat setNumberStyle:NSNumberFormatterDecimalStyle];
		[numberFormat setMaximumFractionDigits:1];
		[numberFormat setRoundingMode:NSNumberFormatterRoundUp];
	}
	// get strs
	NSString *altString = [numberFormat stringFromNumber:altitude];
	NSString *unitString = NSLocalizedString(unit, @"");

	return [NSString localizedStringWithFormat:@"%@ %@", altString, unitString];
}

+(NSString *)formatDistance:(NSNumber *)distance unit:(NSString *)unit
{
    // if no distane, empty string
    if (!distance)
        return @"";
    
	if (numberFormat == nil)
	{
		numberFormat = [[NSNumberFormatter alloc] init];
		[numberFormat setNumberStyle:NSNumberFormatterDecimalStyle];
		[numberFormat setMaximumFractionDigits:1];
		[numberFormat setRoundingMode:NSNumberFormatterRoundUp];
	}
	// get strs
	NSString *distString = [numberFormat stringFromNumber:distance];
	NSString *unitString = NSLocalizedString(unit, @"");
	
	return [NSString localizedStringWithFormat:@"%@ %@", distString, unitString];	
}

//////////////////////////////////////////////
/// Comparison Methods
/////////////////////////////////////////////

+(BOOL)numbersAreEqual:(NSNumber *)num1 num2:(NSNumber *)num2
{
    if (!num1 && !num2)
        return TRUE;
    if (num1 && num2 && [num1 isEqualToNumber:num2])
        return TRUE;
    return FALSE;
}

+(BOOL)stringsAreEqual:(NSString *)str1 str2:(NSString *)str2
{
    if (!str1 && !str2)
        return TRUE;
    if (str1 && str2 && [str1 isEqualToString:str2])
        return TRUE;
    return FALSE;
}

//////////////////////////////////////////////
/// Gear Reminder methods
/////////////////////////////////////////////

+ (UIColor *)colorForDueStatus:(enum DueStatus)status
{
	switch (status)
	{
		case DueSoon:
			return [UIColor orangeColor];
		case PastDue:
			if (pastDueColor == nil)
			{
				pastDueColor = UIColorFromRGB(0xC40000);
			}
			return pastDueColor;
		default:
			return [UIColor blackColor];
	}
}

+ (UIImage *)imageForDueStatus:(enum DueStatus)status
{
	if (status == PastDue)
	{
		if (skullImage == nil)
		{
			skullImage = [UIImage imageNamed:@"skull_small.png"];
		}
		return skullImage;
	}
	return nil;
}



//////////////////////////////////////////////
/// Log Entry Cell Methods
/////////////////////////////////////////////

+ (void)initCellWithLogEntry:(UITableViewCell *)cell logEntry:(LogEntry *)logEntry
{
	NSString *locationName = logEntry.Location == nil ? NSLocalizedString(@"LocationPlaceHolder", @"") : logEntry.Location.Name;
	NSString *aircraftName = logEntry.Aircraft == nil ? @"" : logEntry.Aircraft.Name;
	NSString *skydiveType = logEntry.SkydiveType == nil ? @"" : logEntry.SkydiveType.Name;
	// update cell
	[self setFieldText:cell tag:JumpNumberFieldTag text:[UIUtility formatNumber:logEntry.JumpNumber]];
	[self setFieldText:cell tag:DateFieldTag text:[UIUtility formatDate:logEntry.Date]];
	[self setFieldText:cell tag:LocationFieldTag text:locationName];
	[self setFieldText:cell tag:AircraftFieldTag text:aircraftName];
	[self setFieldText:cell tag:JumpTypeFieldTag text:skydiveType];
	[self setFieldText:cell tag:NotesFieldTag text:logEntry.Notes];
    
    // set signature
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:SignatureFieldTag];
    imageView.hidden = !logEntry.Signature;
	
	// set notes height based on notes
	UILabel *notesField = (UILabel *)[cell viewWithTag:NotesFieldTag];
	CGRect notesFrame = notesField.frame;
	CGSize constraint = CGSizeMake(notesFrame.size.width, FLT_MAX);
	CGSize size = [notesField.text sizeWithFont:notesField.font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
	CGRect newBounds = CGRectMake(
								  notesFrame.origin.x,
								  notesFrame.origin.y,
								  notesFrame.size.width,
								  MIN(size.height, MaximumNotesHeight));
	notesField.frame = newBounds;
}

+ (void)setFieldText:(UITableViewCell *)cell tag:(NSInteger)tag text:(NSString *)text
{
	UILabel *label = (UILabel *)[cell viewWithTag:tag];
	label.text = text;
}

+ (CGFloat)logEntryCellHeight:(UITableViewCell *)cell
{
	// get notes height
	UILabel *notesField = (UILabel *)[cell viewWithTag:NotesFieldTag];
    CGFloat notesHeight = notesField.bounds.size.height;
    
    // get signature image height
    UIImageView *sigImageView = (UIImageView *)[cell viewWithTag:SignatureFieldTag];
    CGFloat sigImageHeight = sigImageView.hidden ? 0 : SignatureImageHeight;
	
	// height + notesfield height
	return MinimumCellHeight + MAX(notesHeight, sigImageHeight);
}

@end
