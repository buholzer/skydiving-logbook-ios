//
//  NSDataAdditions.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 5/19/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Base64Util)

//  Padding '=' characters are optional. Whitespace is ignored.
+ (id)dataWithBase64EncodedString:(NSString *)string;     
- (NSString *)base64Encoding;
@end
