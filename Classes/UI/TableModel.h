//
//  TableModel.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/25/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TableModel : NSObject
{
	NSMutableArray *sectionArray;
}

- (void)addSection:(NSString *)sectionTitle;
- (NSInteger)sectionCount;
- (NSString *)sectionTitle:(NSInteger)index;
- (void)clearSection:(NSInteger)index;
- (void)clearAll;

- (void)addRow:(NSInteger)sectionIndex cell:(UITableViewCell *)cell;
- (void)addRowWithSelectMethod:(NSInteger)sectionIndex cell:(UITableViewCell *)cell methodName:(NSString *)methodName;
- (void)addRowWithSelectMethodAndObject:(NSInteger)sectionIndex cell:(UITableViewCell *)cell methodName:(NSString *)methodName object:(id)object;
- (NSInteger)rowCount:(NSInteger)sectionIndex;
- (UITableViewCell *)rowCell:(NSInteger)sectionIndex rowIndex:(NSInteger)rowIndex;
- (NSString *)rowMethodName:(NSInteger)sectionIndex rowIndex:(NSInteger)rowIndex;
- (id)rowMethodObject:(NSInteger)sectionIndex rowIndex:(NSInteger)rowIndex;

@end
