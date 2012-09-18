//
//  VariableHeightCell.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UITableViewCell (UITableViewCellAdditions)

- (CGFloat)getCellHeight;
- (CGFloat)calculateCellHeight:(NSString *)text font:(UIFont *)font;
- (CGFloat)getDefaultCellWidth;

@end
