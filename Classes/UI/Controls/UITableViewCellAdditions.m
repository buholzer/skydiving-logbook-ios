//
//  VariableHeightCell.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UITableViewCellAdditions.h"
#import "UIUtility.h"

static CGFloat CellHeight = 44;
static CGFloat iPhoneCellWidth = 280;
static CGFloat iPadCellWidth = 640;
static CGFloat CellInset = 10;

@implementation UITableViewCell (UITableViewCellAdditions)

- (CGFloat)getCellHeight
{
    return CellHeight;
}

- (CGFloat)calculateCellHeight:(NSString *)text font:(UIFont *)font
{
    // get size constraint
    CGFloat cellWidth = [self getDefaultCellWidth];
    CGSize constraint = CGSizeMake(cellWidth - (CellInset * 2), FLT_MAX);
    // calculate size
    CGSize size = [text sizeWithFont:font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    CGFloat height = size.height + (CellInset * 2);
    return MAX(CellHeight, height);
}

- (CGFloat)getDefaultCellWidth
{
    if ([UIUtility isiPad])
    {
        return iPadCellWidth;
    }
    else
    {
        return iPhoneCellWidth;
    }
}

@end
