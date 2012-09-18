//
//  ImageToDataTransformer.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/8/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "ImageToDataTransformer.h"


@implementation ImageToDataTransformer

+ (BOOL)allowsReverseTransformation
{
	return YES;
}

+ (Class)transformedValueClass
{
	return [NSData class];
}

- (id)transformedValue:(id)value
{
	NSData *data = UIImagePNGRepresentation(value);
	return data;
}

- (id)reverseTransformedValue:(id)value
{
	UIImage *uiImage = [[UIImage alloc] initWithData:value];
	return uiImage;
}


@end
