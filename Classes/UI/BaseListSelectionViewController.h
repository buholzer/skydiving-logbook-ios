//
//  BaseListSelectionViewController.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/4/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ListSelectionDelegate<NSObject>
- (void)listSelectionChanged;
@end

@interface BaseListSelectionViewController : UITableViewController
{
}

@property (strong) NSArray *items;
@property (strong) id<ListSelectionDelegate> delegate;

- (void)addItem;
- (BOOL)isMultiSelect;
- (void)loadData;
- (NSString *)itemName:(id)item;
- (BOOL)isSelected:(id)item;
- (void)setSelected:(id)item;

@end
