//
//  LogEntrySkydiveTypeMappingPolicy.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 8/28/10.
//  Copyright 2010 NA. All rights reserved.
//

@interface LogEntrySkydiveTypeMappingPolicy : NSEntityMigrationPolicy
{

}

- (NSManagedObject *)skydiveType:(NSMigrationManager *)manager name:(NSString *)name;
@end
