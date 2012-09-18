//
//  TotalsViewController.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 4/28/10.
//  Copyright 2010 NA. All rights reserved.
//

@interface KeyValuePair: NSObject
{
}

@property (strong) NSString *key;
@property (strong) NSString *value;

+ (KeyValuePair *)pairWithKey:(NSString *)theKey andValue:(NSString*)theValue;
@end

@interface KeyValueArray: NSObject
{
}
@property (strong) NSString *name;
@property (strong) NSMutableArray *keyValues;

+ (KeyValueArray *)arrayWithName:(NSString *)theName;
@end


@interface TotalJumpCountViewController : UITableViewController
{
	NSMutableArray *data;
}

- (id)initController;

@end


