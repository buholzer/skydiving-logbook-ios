//
//  FreefallProfile.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 8/25/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "FreefallProfile.h"

// freefall profile types
static NSString *VerticalFreefallProfileType = @"Vertical";
static NSString *HorizontalFreefallProfileType = @"Horizontal";
static NSString *TrackingFreefallProfileType = @"Tracking";
static NSString *WingsuitFreefallProfileType = @"Wingsuit";
static NSString *SkysurfingFreefallProfileType = @"Skysurfing";

@implementation FreefallProfileUtil

+ (NSArray *)freefallProfileStrings
{
	return [NSArray arrayWithObjects:
			[FreefallProfileUtil typeToString:Vertical],
			[FreefallProfileUtil typeToString:Horizontal],
			[FreefallProfileUtil typeToString:Tracking],
			[FreefallProfileUtil typeToString:Wingsuit],
			[FreefallProfileUtil typeToString:Skysurfing],
			nil];
}

+(NSString *)typeToString:(enum FreefallProfileType)type
{
	switch (type)
	{
		case Vertical:
			return VerticalFreefallProfileType;
		case Horizontal:
			return HorizontalFreefallProfileType;
		case Tracking:
			return TrackingFreefallProfileType;
		case Wingsuit:
			return WingsuitFreefallProfileType;
		case Skysurfing:
			return SkysurfingFreefallProfileType;
		default:
			return HorizontalFreefallProfileType;
	}
}

+ (enum FreefallProfileType)stringToType:(NSString *)string
{
	if ([string isEqualToString:VerticalFreefallProfileType])
	{
		return Vertical;
	}
	else if ([string isEqualToString:HorizontalFreefallProfileType])
	{
		return Horizontal;
	}
	else if ([string isEqualToString:TrackingFreefallProfileType])
	{
		return Tracking;
	}
	else if ([string isEqualToString:WingsuitFreefallProfileType])
	{
		return Wingsuit;
	}
	else if ([string isEqualToString:SkysurfingFreefallProfileType])
	{
		return Skysurfing;
	}
	else
	{
		return Horizontal;
	}
}

@end