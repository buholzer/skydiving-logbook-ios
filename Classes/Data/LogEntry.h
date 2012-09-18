//
//  LogEntry.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Aircraft, Location, Rig, Signature, SkydiveType;

@interface LogEntry : NSManagedObject

@property (nonatomic, retain) NSString * AltitudeUnit;
@property (nonatomic, retain) NSNumber * DistanceToTarget;
@property (nonatomic, retain) NSNumber * DeploymentAltitude;
@property (nonatomic, retain) NSNumber * Cutaway;
@property (nonatomic, retain) NSNumber * ExitAltitude;
@property (nonatomic, retain) NSDate * LastModifiedUTC;
@property (nonatomic, retain) NSString * UniqueID;
@property (nonatomic, retain) NSNumber * FreefallTime;
@property (nonatomic, retain) NSDate * LastSignatureUTC;
@property (nonatomic, retain) NSString * Notes;
@property (nonatomic, retain) NSDate * Date;
@property (nonatomic, retain) NSNumber * JumpNumber;
@property (nonatomic, retain) SkydiveType *SkydiveType;
@property (nonatomic, retain) Location *Location;
@property (nonatomic, retain) NSSet *Rigs;
@property (nonatomic, retain) Aircraft *Aircraft;
@property (nonatomic, retain) Signature *Signature;
@property (nonatomic, retain) NSSet *Images;
@end

@interface LogEntry (CoreDataGeneratedAccessors)

- (void)addRigsObject:(Rig *)value;
- (void)removeRigsObject:(Rig *)value;
- (void)addRigs:(NSSet *)values;
- (void)removeRigs:(NSSet *)values;
- (void)addImagesObject:(NSManagedObject *)value;
- (void)removeImagesObject:(NSManagedObject *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;
@end
