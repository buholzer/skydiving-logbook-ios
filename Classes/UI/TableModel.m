//
//  TableModel.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/25/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "TableModel.h"

static NSString *SectionTitleKey = @"sectionTitle";
static NSString *SectionRowsKey = @"SectionRows";
static NSString *RowTableCellKey = @"RowTableCell";
static NSString *RowMethodNameKey = @"RowMethodName";
static NSString *RowMethodObjectKey = @"RowMethodObject";

@implementation TableModel

- (id)init
{
	if (self = [super init])
	{
		sectionArray = [[NSMutableArray alloc] initWithCapacity:2];
	}
	return self;
}

- (void)addSection:(NSString *)sectionTitle
{
	NSMutableArray *rows = [[NSMutableArray alloc] initWithCapacity:1];
	NSDictionary *section = [NSDictionary dictionaryWithObjectsAndKeys:
							 sectionTitle, SectionTitleKey,
							 rows, SectionRowsKey,
							 nil];
	[sectionArray addObject:section];
}

- (NSInteger)sectionCount
{
	return [sectionArray count];
}

- (NSString *)sectionTitle:(NSInteger)index
{
	return [[sectionArray objectAtIndex:index] valueForKey:SectionTitleKey];
}

- (void)clearSection:(NSInteger)index
{
	NSMutableArray *rows = [[sectionArray objectAtIndex:index] valueForKey:SectionRowsKey];
	[rows removeAllObjects];
}

- (void)clearAll
{
	sectionArray = [[NSMutableArray alloc] initWithCapacity:2];
}

- (void)addRow:(NSInteger)sectionIndex cell:(UITableViewCell *)cell
{
	NSMutableArray *rows = [[sectionArray objectAtIndex:sectionIndex] valueForKey:SectionRowsKey];
	NSDictionary *row = [NSDictionary dictionaryWithObjectsAndKeys:
						 cell, RowTableCellKey,
						 nil];
	[rows addObject:row];
}

- (void)addRowWithSelectMethod:(NSInteger)sectionIndex cell:(UITableViewCell *)cell methodName:(NSString *)methodName
{
	NSMutableArray *rows = [[sectionArray objectAtIndex:sectionIndex] valueForKey:SectionRowsKey];
	NSDictionary *row = [NSDictionary dictionaryWithObjectsAndKeys:
						 cell, RowTableCellKey,
						 methodName, RowMethodNameKey,
						 nil];
	[rows addObject:row];
}

- (void)addRowWithSelectMethodAndObject:(NSInteger)sectionIndex cell:(UITableViewCell *)cell methodName:(NSString *)methodName object:(id)object
{
	NSMutableArray *rows = [[sectionArray objectAtIndex:sectionIndex] valueForKey:SectionRowsKey];
	NSDictionary *row = [NSDictionary dictionaryWithObjectsAndKeys:
						 cell, RowTableCellKey,
						 methodName, RowMethodNameKey,
						 object, RowMethodObjectKey,
						 nil];
	[rows addObject:row];
}

- (NSInteger)rowCount:(NSInteger)sectionIndex
{
	NSMutableArray *rows = [[sectionArray objectAtIndex:sectionIndex] valueForKey:SectionRowsKey];
	return [rows count];
}

- (UITableViewCell *)rowCell:(NSInteger)sectionIndex rowIndex:(NSInteger)rowIndex
{
	NSMutableArray *rows = [[sectionArray objectAtIndex:sectionIndex] valueForKey:SectionRowsKey];
	return [[rows objectAtIndex:rowIndex] valueForKey:RowTableCellKey];
}

- (NSString *)rowMethodName:(NSInteger)sectionIndex rowIndex:(NSInteger)rowIndex
{
	NSMutableArray *rows = [[sectionArray objectAtIndex:sectionIndex] valueForKey:SectionRowsKey];
	return [[rows objectAtIndex:rowIndex] valueForKey:RowMethodNameKey];
}

- (id)rowMethodObject:(NSInteger)sectionIndex rowIndex:(NSInteger)rowIndex
{
	NSMutableArray *rows = [[sectionArray objectAtIndex:sectionIndex] valueForKey:SectionRowsKey];
	return [[rows objectAtIndex:rowIndex] valueForKey:RowMethodObjectKey];
}

@end
