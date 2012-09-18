//
//  UUID_UtcMappingPolicy.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Signature.h"

@interface UUID_UtcMappingPolicy : NSEntityMigrationPolicy
{
    
}

- (NSDate*)defaultLastModifiedDate;
- (NSDate*)defaultLastSignatureDate:(Signature*)signature;
- (NSString*)newUUID;

@end
