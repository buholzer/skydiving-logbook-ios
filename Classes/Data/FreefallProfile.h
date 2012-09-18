//
//  FreefallProfile.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 8/25/10.
//  Copyright 2010 NA. All rights reserved.
//

typedef enum FreefallProfileType
{
	Vertical,
	Horizontal,
	Tracking,
	Wingsuit,
	Skysurfing
} FreefallProfileType;

@interface FreefallProfileUtil: NSObject
{
	
}

+ (NSArray *)freefallProfileStrings;
+ (NSString *)typeToString:(enum FreefallProfileType)type;
+ (enum FreefallProfileType)stringToType:(NSString *)string;
@end

