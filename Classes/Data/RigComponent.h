//
//  RigComponent.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/26/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Rig;

@interface RigComponent :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * SerialNumber;
@property (nonatomic, retain) NSString * Name;
@property (nonatomic, retain) NSString * Notes;
@property (nonatomic, retain) Rig * Rig;

@end



