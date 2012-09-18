//
//  DatabaseImporter.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 5/4/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "DatabaseImporter.h"
#import "RepositoryManager.h"
#import "LogEntry.h"
#import "Location.h"
#import "Aircraft.h"
#import "Signature.h"
#import "Base64Util.h"
#import "NSData_MD5.h"

// weight constants for progress
static float LogEntryWeight = 0.8;
static float SkydiveTypeWeight = 0.05;
static float LocationWeight = 0.05;
static float AircraftWeight = 0.05;
static float RigWeight = 0.05;

static NSDateFormatter *dateFormat = nil;
static NSDateFormatter *utcDateTimeFormat = nil;

@interface DatabaseImporter(Private)
- (void)updateLogbookHistory:(DDXMLNode *)node;
- (void)addSkydiveTypes:(DDXMLNode *)skydiveTypesNode;
- (void)addSkydiveType:(DDXMLNode *)skydiveTypeNode skydiveTypes:(NSArray *)skydiveTypes repository:(SkydiveTypeRepository *)repository;
- (void)addLocations:(DDXMLNode *)locationsNode;
- (void)addLocation:(DDXMLNode *)locationNode locations:(NSArray *)locations repository:(LocationRepository *)repository;
- (void)addAircrafts:(DDXMLNode *)aircraftsNode;
- (void)addAircraft:(DDXMLNode *)aircraftNode aircrafts:(NSArray *)aircrafts repository:(AircraftRepository *)repository;
- (void)addRigs:(DDXMLNode *)rigsNode;
- (void)addRig:(DDXMLNode *)rigNode rigs:(NSArray *)rigs repository:(RigRepository *)repository;
- (void)setRigComponents:(Rig *)rig componentsNode:(DDXMLNode *)componentsNode repository:(RigRepository *)repository;
- (void)setRigReminders:(Rig *)rig remindersNode:(DDXMLNode *)remindersNode repository:(RigRepository *)repository;
- (void)addLogEntries:(DDXMLNode *)logEntriesNode signaturesNode:(DDXMLNode *)signaturesNode;
- (void)addLogEntry:(DDXMLNode *)logEntryNode logEntries:(NSArray *)logEntries repository:(LogEntryRepository *)repository;
- (void)addLogEntry:(DDXMLNode *)logEntryNode
         logEntries:(NSArray *)logEntries
   signatureNodeMap:(NSMutableDictionary *)signatureNodeMap
       signatureMap:(NSMutableDictionary *)signatureMap
         repository:(LogEntryRepository *)repository;
- (void)updateLogEntryRigs:(LogEntry *)logEntry logEntryNode:(DDXMLNode *)logEntryNode;
- (void)updateLogEntryImages:(LogEntry *)logEntry logEntryNode:(DDXMLNode *)logEntryNode;
- (void)updateLogEntrySignature:(LogEntry *)logEntry
                   logEntryNode:(DDXMLNode *)logEntryNode
               signatureNodeMap:(NSMutableDictionary *)signatureNodeMap
                   signatureMap:(NSMutableDictionary *)signatureMap
                     repository:(LogEntryRepository *)repository;
- (NSString *)stringNode:(DDXMLNode *)parent name:(NSString *)name;
- (NSNumber *)numberNode:(DDXMLNode *)parent name:(NSString *)name;
- (NSNumber *)booleanNode:(DDXMLNode *)parent name:(NSString *)name;
- (NSDate *)dateNode:(DDXMLNode *)parent name:(NSString *)name;
- (NSDate *)utcDateTimeNode:(DDXMLNode *)parent name:(NSString *)name;
- (UIImage *)imageNode:(DDXMLNode *)parent name:(NSString *)name;
- (DDXMLNode *)nodeWithName:(DDXMLNode *)parent name:(NSString *)name;
- (NSPredicate *)predicateForUniqueIDOrName:(DDXMLNode *)parent;
- (NSPredicate *)predicateForUniqueIDOrJumpNumber:(DDXMLNode *)parent;
@end

@implementation DatabaseImporter

- (id)initWithDelegate:(id<DatabaseImportDelegate>)theDelegate
{
	if (self = [super init])
	{
		delegate = theDelegate;
	}
	return self;
}

- (BOOL)beginImport:(NSData *)xmlData
{
	// parse document
	NSError *error;
	DDXMLDocument *xmlDocument = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    
    // get root element
    DDXMLElement *rootElement = [xmlDocument rootElement];
	
    // check version
    NSNumber *version = [self numberNode:rootElement name:@"version"];
    if ([version intValue] != 2)
    {
        errorMessage = NSLocalizedString(@"ImportIncorrectXMLVersionMessage", nil);
        return FALSE;
    }
    
	// create lists/maps
	skydiveTypeMap = [[NSMutableDictionary alloc] initWithCapacity:0];
	locationMap = [[NSMutableDictionary alloc] initWithCapacity:0];
	aircraftMap = [[NSMutableDictionary alloc] initWithCapacity:0];
	rigMap = [[NSMutableDictionary alloc] initWithCapacity:0];
	
	// get elements
	DDXMLNode *historyNode = [self nodeWithName:rootElement name:@"logbook_history"];
	DDXMLNode *skydiveTypesNode = [self nodeWithName:rootElement name:@"skydive_types"];
	DDXMLNode *logEntriesNode = [self nodeWithName:rootElement name:@"log_entries"];
	DDXMLNode *signaturesNode = [self nodeWithName:rootElement name:@"signatures"];
	DDXMLNode *locationsNode = [self nodeWithName:rootElement name:@"locations"];
	DDXMLNode *aircraftsNode = [self nodeWithName:rootElement name:@"aircrafts"];
	DDXMLNode *rigsNode = [self nodeWithName:rootElement name:@"rigs"];
	
	// update history
	[self updateLogbookHistory:historyNode];
	
	// add skydive types
	[self addSkydiveTypes:skydiveTypesNode];
	
	// add locations
	[self addLocations:locationsNode];
	
	// add aircrafts
	[self addAircrafts:aircraftsNode];

	// add rigs
	[self addRigs:rigsNode];

	// add log entries
	[self addLogEntries:logEntriesNode signaturesNode:signaturesNode];
    
    // return success
    return TRUE;
}

- (void)updateLogbookHistory:(DDXMLNode *)node
{
	// update
    LogbookHistoryRepository *repository = [[RepositoryManager instance] logbookHistoryRepository];
	LogbookHistory *history = [repository history];
	history.FreefallTime = [self numberNode:node name:@"freefall_time"];
	history.Cutaways = [self numberNode:node name:@"cutaways"];
	// save
	[repository save];
}

- (void)addSkydiveTypes:(DDXMLNode *)skydiveTypesNode;
{
	// get skydive types
    SkydiveTypeRepository *repository = [[RepositoryManager instance] skydiveTypeRepository];
	NSArray *skydiveTypes = [repository loadAllEntities];
	
	// get progress increment amount
	int total = [skydiveTypesNode childCount];
	// if no data, add entire progress weight
	if (total <= 0)
	{
		[delegate addDatabaseImportProgress:SkydiveTypeWeight];
		return;
	}
	float progressIncrement = SkydiveTypeWeight / (float)total;
	
	// for each skydive type node
	for (DDXMLNode *skydiveTypeNode in [skydiveTypesNode children])
	{
		// skip non-elements
		if ([skydiveTypeNode kind] != DDXMLElementKind)
			continue;
        
        // add type
        [self addSkydiveType:skydiveTypeNode skydiveTypes:skydiveTypes repository:repository];
		
		// update progress
		[delegate addDatabaseImportProgress:progressIncrement];
	}
}

- (void)addSkydiveType:(DDXMLNode *)skydiveTypeNode skydiveTypes:(NSArray *)skydiveTypes repository:(SkydiveTypeRepository *)repository
{
    // find existing skydive type by unique ID or name
    SkydiveType *skydiveType;
    NSPredicate *filter = [self predicateForUniqueIDOrName:skydiveTypeNode];
    NSArray *filtered = [skydiveTypes filteredArrayUsingPredicate:filter];
    
    // get last modified utc date
    NSDate *lastModified = [self utcDateTimeNode:skydiveTypeNode name:@"last_modified_utc"];
    
    // check if updating is needed (either new entry, or was modified later)
    BOOL needsUpdate = false;
    if ([filtered count] == 0)
    {
        // if not found, create new
        skydiveType = [repository createNewSkydiveType];
        needsUpdate = true;
    }
    else
    {
        // if found, get
        skydiveType = [filtered objectAtIndex:0];
        // check last modified to see if needs updating
        if ([lastModified compare:skydiveType.LastModifiedUTC] == NSOrderedDescending)
            needsUpdate = true;
    }
    
    // do update if necessary
    if (needsUpdate)
    {
        // update
        skydiveType.UniqueID = [self stringNode:skydiveTypeNode name:@"id"];
        skydiveType.Name = [self stringNode:skydiveTypeNode name:@"name"];
        skydiveType.Default = [self booleanNode:skydiveTypeNode name:@"default"];
        skydiveType.FreefallProfileType = [self stringNode:skydiveTypeNode name:@"freefall_profile"];
        skydiveType.Notes = [self stringNode:skydiveTypeNode name:@"notes"];
        skydiveType.Active = [self booleanNode:skydiveTypeNode name:@"active"];
        skydiveType.LastModifiedUTC = [self utcDateTimeNode:skydiveTypeNode name:@"last_modified_utc"];
        // save
        [repository save];
    }
    
    // store in map with xml id
    NSString *idValue = [self stringNode:skydiveTypeNode name:@"id"];
    [skydiveTypeMap setValue:skydiveType forKey:idValue];
}

- (void)addLocations:(DDXMLNode *)locationsNode;
{
	// get locations
    LocationRepository *repository = [[RepositoryManager instance] locationRepository];
	NSArray *locations = [repository loadAllEntities];
	
	// get progress increment amount
	int total = [locationsNode childCount];
	// if no data, add entire progress weight
	if (total == 0)
    {
		[delegate addDatabaseImportProgress:LocationWeight];
        return;
    }
	float progressIncrement = LocationWeight / (float)total;
	
	// for each location node
	for (DDXMLNode *locationNode in [locationsNode children])
	{
		// skip non-elements
		if ([locationNode kind] != DDXMLElementKind)
			continue;
        
        // add location
        [self addLocation:locationNode locations:locations repository:repository];

		// update progress
		[delegate addDatabaseImportProgress:progressIncrement];
	}
}

- (void)addLocation:(DDXMLNode *)locationNode locations:(NSArray *)locations repository:(LocationRepository *)repository
{
    // find location by unique ID or name
    Location *location;
    NSPredicate *filter = [self predicateForUniqueIDOrName:locationNode];
    NSArray *filtered = [locations filteredArrayUsingPredicate:filter];
    
    // get last modified utc date
    NSDate *lastModified = [self utcDateTimeNode:locationNode name:@"last_modified_utc"];
    
    // check if updating is needed (either new entry, or was modified later)
    BOOL needsUpdate = false;
    if ([filtered count] == 0)
    {
        // if not found, create new
        location = [repository createNewLocation];
        needsUpdate = true;
    }
    else
    {
        // if found, get
        location = [filtered objectAtIndex:0];
        // check last modified to see if needs updating
        if ([lastModified compare:location.LastModifiedUTC] == NSOrderedDescending)
            needsUpdate = true;
    }
    
    // do update if necessary
    if (needsUpdate)
    {
        // update
        location.UniqueID = [self stringNode:locationNode name:@"id"];
        location.Name = [self stringNode:locationNode name:@"name"];
        location.Home = [self booleanNode:locationNode name:@"home"];
        location.Notes = [self stringNode:locationNode name:@"notes"];
        location.Active = [self booleanNode:locationNode name:@"active"];
        location.LastModifiedUTC = [self utcDateTimeNode:locationNode name:@"last_modified_utc"];
        // save
        [repository save];
    }
	
    // store in map
    NSString *idValue = [self stringNode:locationNode name:@"id"];
    [locationMap setValue:location forKey:idValue];
}

- (void)addAircrafts:(DDXMLNode *)aircraftsNode;
{
	// get aircrafts
    AircraftRepository *repository = [[RepositoryManager instance] aircraftRepository];
	NSArray *aircrafts = [repository loadAllEntities];

	// get progress increment amount
	int total = [aircraftsNode childCount];
	// if no data, add entire progress weight
	if (total == 0)
    {
		[delegate addDatabaseImportProgress:AircraftWeight];
        return;
    }
	float progressIncrement = AircraftWeight / (float)total;
	
	// for each aircraft node
	for (DDXMLNode *aircraftNode in [aircraftsNode children])
	{
		// skip non-elements
		if ([aircraftNode kind] != DDXMLElementKind)
			continue;
        
        // add aircraft
        [self addAircraft:aircraftNode aircrafts:aircrafts repository:repository];
	
		// update progress
		[delegate addDatabaseImportProgress:progressIncrement];
	}
}

- (void)addAircraft:(DDXMLNode *)aircraftNode aircrafts:(NSArray *)aircrafts repository:(AircraftRepository *)repository
{
    // find aircraft by unique ID or name
    Aircraft *aircraft;
    NSPredicate *filter = [self predicateForUniqueIDOrName:aircraftNode];
    NSArray *filtered = [aircrafts filteredArrayUsingPredicate:filter];
    
    // get last modified utc date
    NSDate *lastModified = [self utcDateTimeNode:aircraftNode name:@"last_modified_utc"];
    
    // check if updating is needed (either new entry, or was modified later)
    BOOL needsUpdate = false;
    if ([filtered count] == 0)
    {
        // if not found, create new
        aircraft = [repository createNewAircraft];
        needsUpdate = true;
    }
    else
    {
        // if found, get
        aircraft = [filtered objectAtIndex:0];
        // check last modified to see if needs updating
        if ([lastModified compare:aircraft.LastModifiedUTC] == NSOrderedDescending)
            needsUpdate = true;
    }
    
    // do update if necessary
    if (needsUpdate)
    {
        // update
        aircraft.UniqueID = [self stringNode:aircraftNode name:@"id"];
        aircraft.Name = [self stringNode:aircraftNode name:@"name"];
        aircraft.Default = [self booleanNode:aircraftNode name:@"default"];
        aircraft.Notes = [self stringNode:aircraftNode name:@"notes"];
        aircraft.Active = [self booleanNode:aircraftNode name:@"active"];
        aircraft.LastModifiedUTC = [self utcDateTimeNode:aircraftNode name:@"last_modified_utc"];
        // save
        [repository save];
    }
	
    // store in map
    NSString *idValue = [self stringNode:aircraftNode name:@"id"];
    [aircraftMap setValue:aircraft forKey:idValue];
}

- (void)addRigs:(DDXMLNode *)rigsNode;
{
	// get rigs
    RigRepository *repository = [[RepositoryManager instance] rigRepository];
	NSArray *rigs = [repository loadAllEntities];
	
	// get progress increment amount
	int total = [rigsNode childCount];
	// if no data, add entire progress weight
	if (total == 0)
    {
		[delegate addDatabaseImportProgress:RigWeight];
        return;
    }
	float progressIncrement = RigWeight / (float)total;
	
	// for each rig
	for (DDXMLNode *rigNode in [rigsNode children])
	{
		// skip non-elements
		if ([rigNode kind] != DDXMLElementKind)
			continue;
        
        // add rig
        [self addRig:rigNode rigs:rigs repository:repository];
	
		// update progress
		[delegate addDatabaseImportProgress:progressIncrement];
	}
}

- (void)addRig:(DDXMLNode *)rigNode rigs:(NSArray *)rigs repository:(RigRepository *)repository
{
    // find rig by unique id or name
    Rig *rig;
    NSPredicate *filter = [self predicateForUniqueIDOrName:rigNode];
    NSArray *filtered = [rigs filteredArrayUsingPredicate:filter];
    
    // get last modified utc date
    NSDate *lastModified = [self utcDateTimeNode:rigNode name:@"last_modified_utc"];
    
    // check if updating is needed (either new entry, or was modified later)
    BOOL needsUpdate = false;
    if ([filtered count] == 0)
    {
        // if not found, create new
        rig = [repository createNewRig];
        needsUpdate = true;
    }
    else
    {
        // if found, get
        rig = [filtered objectAtIndex:0];
        // check last modified to see if needs updating
        if ([lastModified compare:rig.LastModifiedUTC] == NSOrderedDescending)
            needsUpdate = true;
    }
    
    // do update if necessary
    if (needsUpdate)
    {
        // update
        rig.UniqueID = [self stringNode:rigNode name:@"id"];
        rig.Name = [self stringNode:rigNode name:@"name"];
        rig.Primary = [self booleanNode:rigNode name:@"primary"];
        rig.Archived = [self booleanNode:rigNode name:@"archived"];
        rig.Notes = [self stringNode:rigNode name:@"notes"];
        rig.Active = [self booleanNode:rigNode name:@"active"];
        rig.LastModifiedUTC = [self utcDateTimeNode:rigNode name:@"last_modified_utc"];
        
        // set components/reminders
        DDXMLNode *componentsNode = [self nodeWithName:rigNode name:@"components"];
        DDXMLNode *remindersNode = [self nodeWithName:rigNode name:@"reminders"];
        [self setRigComponents:rig componentsNode:componentsNode repository:repository];
        [self setRigReminders:rig remindersNode:remindersNode repository:repository];
        // save
        [repository save];
    }
    
    // store in map
    NSString *idValue = [self stringNode:rigNode name:@"id"];
    [rigMap setValue:rig forKey:idValue];
}

- (void)setRigComponents:(Rig *)rig componentsNode:(DDXMLNode *)componentsNode repository:(RigRepository *)repository
{
    // delete existing components
    NSSet *components = [NSSet setWithSet:rig.Components];
    for (RigComponent *component in components)
    {
        [repository deleteComponent:component];
    }
	
	// for each component node
	for (DDXMLNode *componentNode in [componentsNode children])
	{
		// skip non-elements
		if ([componentNode kind] != DDXMLElementKind)
			continue;
		
		// create new component
		RigComponent *component = [repository createNewComponentForRig:rig];
		component.Name = [self stringNode:componentNode name:@"name"];
		component.SerialNumber = [self stringNode:componentNode name:@"serial_number"];
	}
}

- (void)setRigReminders:(Rig *)rig remindersNode:(DDXMLNode *)remindersNode repository:(RigRepository *)repository
{
    // delete existing reminders
    NSSet *reminders = [NSSet setWithSet:rig.Reminders];
    for (RigReminder *reminder in reminders)
    {
        [repository deleteReminder:reminder];
    }
    
	// for each reminder node
	for (DDXMLNode *reminderNode in [remindersNode children])
	{
		// skip non-elements
		if ([reminderNode kind] != DDXMLElementKind)
			continue;
		
		// create new reminder
		RigReminder *reminder = [repository createNewReminderForRig:rig];
		reminder.Name = [self stringNode:reminderNode name:@"name"];
		reminder.Interval = [self numberNode:reminderNode name:@"interval"];
		reminder.IntervalUnit = [self stringNode:reminderNode name:@"interval_unit"];
		reminder.LastCompletedDate = [self dateNode:reminderNode name:@"last_completed_date"];		
	}
}

- (void)addLogEntries:(DDXMLNode *)logEntriesNode signaturesNode:(DDXMLNode *)signaturesNode
{
	// get log entries
    LogEntryRepository *repository = [[RepositoryManager instance] logEntryRepository];
	NSArray *logEntries = [repository loadAllEntities];
						   
	// create signature maps
	NSMutableDictionary *signatureNodeMap = [NSMutableDictionary dictionaryWithCapacity:[signaturesNode childCount]];
	NSMutableDictionary *signatureMap = [NSMutableDictionary dictionaryWithCapacity:[signaturesNode childCount]];
	for (DDXMLNode *signatureNode in [signaturesNode children])
	{
		// skip non-elements
		if ([signatureNode kind] != DDXMLElementKind)
			continue;
		
		// add to map
		NSString *idValue = [self stringNode:signatureNode name:@"id"];
		[signatureNodeMap setValue:signatureNode forKey:idValue];
	}
	
	// get progress increment amount
	int total = [logEntriesNode childCount];
	// if no data, add entire progress weight
	if (total == 0)
    {
		[delegate addDatabaseImportProgress:LogEntryWeight];
        return;
    }
	float progressIncrement = LogEntryWeight / (float)total;
	
	// for each log entry
	for (DDXMLNode *logEntryNode in [logEntriesNode children])
	{
		// skip non-elements
		if ([logEntryNode kind] != DDXMLElementKind)
			continue;
        
        // add log entry
        [self addLogEntry:logEntryNode
               logEntries:logEntries
         signatureNodeMap:signatureNodeMap
             signatureMap:signatureMap
               repository:repository];
        
		// update progress
		[delegate addDatabaseImportProgress:progressIncrement];
	}
    	
	// save
	[repository save];
}

- (void)addLogEntry:(DDXMLNode *)logEntryNode
         logEntries:(NSArray *)logEntries
   signatureNodeMap:(NSMutableDictionary *)signatureNodeMap
       signatureMap:(NSMutableDictionary *)signatureMap
          repository:(LogEntryRepository *)repository
{
    // find entry by unique ID or jump number
    LogEntry *logEntry;
    NSPredicate *filter = [self predicateForUniqueID:logEntryNode];
    NSArray *filtered = [logEntries filteredArrayUsingPredicate:filter];
    
    // check if updating is needed (either new entry, or was modified later)
    NSDate *lastModifiedDate = [self utcDateTimeNode:logEntryNode name:@"last_modified_utc"];
    BOOL needsUpdate = false;
    if ([filtered count] == 0)
    {
        // if not found, create new
        logEntry = [repository createWithDefaults];
        needsUpdate = true;
    }
    else
    {
        // if found, get
        logEntry = [filtered objectAtIndex:0];
        // check last modified to see if needs updating
        if ([lastModifiedDate compare:logEntry.LastModifiedUTC] == NSOrderedDescending)
            needsUpdate = true;
    }
    
    // update log entry if needed
    if (needsUpdate)
    {
        logEntry.UniqueID = [self stringNode:logEntryNode name:@"id"];
        logEntry.JumpNumber = [self numberNode:logEntryNode name:@"jump_number"];
        logEntry.Date = [self dateNode:logEntryNode name:@"date"];
        logEntry.Location = [locationMap valueForKey:[self stringNode:logEntryNode name:@"location_id"]];
        logEntry.Aircraft = [aircraftMap valueForKey:[self stringNode:logEntryNode name:@"aircraft_id"]];
        logEntry.SkydiveType = [skydiveTypeMap valueForKey:[self stringNode:logEntryNode name:@"skydive_type_id"]];
        logEntry.ExitAltitude = [self numberNode:logEntryNode name:@"exit_altitude"];
        logEntry.DeploymentAltitude = [self numberNode:logEntryNode name:@"deployment_altitude"];
        logEntry.AltitudeUnit = [self stringNode:logEntryNode name:@"altitude_unit"];
        logEntry.FreefallTime = [self numberNode:logEntryNode name:@"freefall_time"];
        logEntry.Cutaway = [self booleanNode:logEntryNode name:@"cutaway"];
        logEntry.Notes = [self stringNode:logEntryNode name:@"notes"];
        logEntry.LastModifiedUTC = lastModifiedDate;
        
        // update rigs
        [self updateLogEntryRigs:logEntry logEntryNode:logEntryNode];
        
        // update images
        [self updateLogEntryImages:logEntry logEntryNode:logEntryNode repository:repository];
    }
    
    // update signature if needed
    [self updateLogEntrySignature:logEntry
                     logEntryNode:logEntryNode
                 signatureNodeMap:signatureNodeMap
                     signatureMap:signatureMap
                       repository:repository];
}

- (void)updateLogEntryRigs:(LogEntry *)logEntry logEntryNode:(DDXMLNode *)logEntryNode
{
    // delete rigs
    [logEntry removeRigs:logEntry.Rigs];
    
    // add rigs
    DDXMLNode *rigsNode = [self nodeWithName:logEntryNode name:@"rigs"];
    for (DDXMLNode *rigIdNode in [rigsNode children])
    {
        if ([rigIdNode kind] != DDXMLElementKind)
            continue;
        [logEntry addRigsObject:[rigMap valueForKey:[rigIdNode stringValue]]];
    }
}

- (void)updateLogEntryImages:(LogEntry *)logEntry logEntryNode:(DDXMLNode *)logEntryNode repository:(LogEntryRepository *)repository
{
    // keep track of imported md5s to see which need to be deleted
    NSMutableArray *md5s = [NSMutableArray arrayWithCapacity:0];

    // check for older "diagram" node
    UIImage *diagram = [self imageNode:logEntryNode name:@"diagram"];
    if (diagram)
    {
        // get data and md5
        NSData *diagramData = UIImagePNGRepresentation(diagram);
        NSString *md5 = [diagramData md5];
        
        // add to md5s
        [md5s addObject:md5];
        
        // find corresponding logEntryImage using md5
        NSPredicate *md5Filter = [NSPredicate predicateWithFormat:@"MD5 == %@", md5];
        NSSet *filtered = [logEntry.Images filteredSetUsingPredicate:md5Filter];
        
        // if not found, add image
        if ([filtered count] == 0)
        {
            LogEntryImage *logEntryImage = [repository createNewDiagramForLogEntry:logEntry];
            logEntryImage.Image = diagram;
            logEntryImage.ImageType = LogEntryDiagramImageType;
            logEntryImage.MD5 = md5;
        }
    }
    
    // get image nodes, skip if not found
    DDXMLNode *imagesNode = [self nodeWithName:logEntryNode name:@"images"];
    if (!imagesNode)
        return;
    
    // process images
    for (DDXMLNode *imageNode in [imagesNode children])
    {
        if ([imageNode kind] != DDXMLElementKind)
            continue;
        
        // get md5 from xml
        NSString *md5 = [self stringNode:imageNode name:@"image_md5"];
        
        // add to md5s
        [md5s addObject:md5];
        
        // find corresponding logEntryImage using md5
        NSPredicate *md5Filter = [NSPredicate predicateWithFormat:@"MD5 == %@", md5];
        NSSet *filtered = [logEntry.Images filteredSetUsingPredicate:md5Filter];
        
        // if found, continue
        if ([filtered count] == 1)
            continue;
        
        // create image import info
        ImageImportInfo *imageInfo = [[ImageImportInfo alloc] init];
        imageInfo.logEntryUniqueId = logEntry.UniqueID;
        imageInfo.imageType = [self stringNode:imageNode name:@"image_type"];
        imageInfo.imageMD5 = md5;
        imageInfo.imageFileName = [self stringNode:imageNode name:@"image_file"];
        
        // add import info to delegate
        [delegate addImageImport:imageInfo];
    }
    
    // get images that no longer exist in XML
    NSMutableArray *imagesToDelete = [NSMutableArray arrayWithCapacity:0];
    for (LogEntryImage *logEntryImage in logEntry.Images)
    {
        if (![md5s containsObject:logEntryImage.MD5])
        {
            // add to deleted list
            [imagesToDelete addObject:logEntryImage];
        }
    }
    
    // delete images to be deleted
    for (LogEntryImage *logEntryImage in imagesToDelete)
    {
        [repository deleteLogEntryImage:logEntryImage];
    }
}

- (void)importImages:(NSArray *)imagesImportInfo
{
    // get repository
    LogEntryRepository *repository = [[RepositoryManager instance] logEntryRepository];
    
    for (ImageImportInfo *imageInfo in imagesImportInfo)
    {
        // get log entry
        NSPredicate *logEntryFilter = [NSPredicate predicateWithFormat:@"UniqueID = %@", imageInfo.logEntryUniqueId];
        NSArray *logEntries = [repository loadEntitiesWithFilter:logEntryFilter];
        LogEntry *logEntry = [logEntries objectAtIndex:0];
        
        // create log entry image
        LogEntryImage *logEntryImage = nil;
        if ([imageInfo.imageType isEqualToString:LogEntryDiagramImageType])
        {
            logEntryImage = [repository createNewDiagramForLogEntry:logEntry];
        }
        else
        {
            logEntryImage = [repository createNewPhotoForLogEntry:logEntry];
        }
        // update log entry image
        logEntryImage.MD5 = imageInfo.imageMD5;
        logEntryImage.Image = imageInfo.image;
    }
    
    // save all
    [repository save];
}

- (void)updateLogEntrySignature:(LogEntry *)logEntry
                   logEntryNode:(DDXMLNode *)logEntryNode
               signatureNodeMap:(NSMutableDictionary *)signatureNodeMap
                   signatureMap:(NSMutableDictionary *)signatureMap
                     repository:(LogEntryRepository *)repository
{
    // check if signature needs updating
    NSDate *lastSignatureDate = [self utcDateTimeNode:logEntryNode name:@"last_signature_utc"];
    if (lastSignatureDate &&
        (!logEntry.LastSignatureUTC ||
         [lastSignatureDate compare:logEntry.LastSignatureUTC] == NSOrderedDescending))
    {
        // get signature id
        NSString *signatureId = [self stringNode:logEntryNode name:@"signature_id"];
        
        // create signature if needed
        if (signatureId &&
            [signatureId length] > 0 &&
            [signatureMap valueForKey:signatureId] == nil &&
            [signatureNodeMap valueForKey:signatureId] != nil)
        {
            // get signature node
            DDXMLNode *signatureNode = [signatureNodeMap valueForKey:signatureId];
            // create signature
            Signature *signature = [repository createNewSignature];
            signature.License = [self stringNode:signatureNode name:@"license"];
            signature.Image = [self imageNode:signatureNode name:@"image"];
            // put in map
            [signatureMap setValue:signature forKey:signatureId];
        }
        
        // update log entry
        logEntry.Signature = [signatureMap valueForKey:signatureId];
        logEntry.LastSignatureUTC = lastSignatureDate;
    }
}

- (NSString *)stringNode:(DDXMLNode *)parent name:(NSString *)name
{
	DDXMLNode *node = [self nodeWithName:parent name:name];
	if (!node)
		return nil;
	return [node stringValue];
}

- (NSNumber *)numberNode:(DDXMLNode *)parent name:(NSString *)name
{
	DDXMLNode *node = [self nodeWithName:parent name:name];
	if (!node)
		return nil;
	return [NSNumber numberWithInt:[[node stringValue] intValue]];
}

- (NSNumber *)booleanNode:(DDXMLNode *)parent name:(NSString *)name
{
	DDXMLNode *node = [self nodeWithName:parent name:name];
	if (!node)
		return [NSNumber numberWithInt:0];
	if ([[[node stringValue] lowercaseString] isEqualToString:@"true"])
		return [NSNumber numberWithInt:1];
	else if ([[node stringValue] isEqualToString:@"1"])
		return [NSNumber numberWithInt:1];	
	else
		return [NSNumber numberWithInt:0];
}

- (NSDate *)dateNode:(DDXMLNode *)parent name:(NSString *)name
{
	if (dateFormat == nil)
	{
		dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"yyyy-MM-dd"];
	}
	DDXMLNode *node = [self nodeWithName:parent name:name];
	if (!node)
		return nil;
	// get just date part (should be first 10 chars)
	NSString *dateStr = [node stringValue];
	if ([dateStr length] < 10)
		return nil;
	dateStr = [dateStr substringToIndex:10];
	return [dateFormat dateFromString:dateStr];
}

- (NSDate *)utcDateTimeNode:(DDXMLNode *)parent name:(NSString *)name
{
	if (utcDateTimeFormat == nil)
	{
		utcDateTimeFormat = [[NSDateFormatter alloc] init];
        [utcDateTimeFormat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
		[utcDateTimeFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
	}
	DDXMLNode *node = [self nodeWithName:parent name:name];
	if (!node)
		return nil;
	// get just date part (should be first 10 chars)
	NSString *dateStr = [node stringValue];

	return [utcDateTimeFormat dateFromString:dateStr];
}

- (UIImage *)imageNode:(DDXMLNode *)parent name:(NSString *)name
{
	DDXMLNode *node = [self nodeWithName:parent name:name];
	if (!node)
		return nil;
	NSString *imageStr = [node stringValue];
	if (imageStr == nil || [imageStr length] <= 0)
		return nil;
    
	NSData *imageData = [NSData dataWithBase64EncodedString:imageStr];
	return [UIImage imageWithData:imageData];
}

- (DDXMLNode *)nodeWithName:(DDXMLNode *)parent name:(NSString *)name
{
	if (!parent)
		return nil;
    
    // check child nodes
	for (DDXMLNode *child in [parent children])
	{
		if ([child kind] != DDXMLElementKind)
			continue;
		if ([[child localName] isEqualToString:name])
			return child;
	}
    
    // if element, check attributes
    if ([parent kind] == DDXMLElementKind)
    {
        DDXMLElement *parentElement = (DDXMLElement*)parent;
        return [parentElement attributeForName:name];
    }
    
	return nil;
}

- (NSPredicate *)predicateForUniqueIDOrName:(DDXMLNode *)parent
{
	NSString *name = [self stringNode:parent name:@"name"];
	NSString *uniqueId = [self stringNode:parent name:@"id"];
	NSPredicate *nameFilter = [NSPredicate predicateWithFormat:@"Name == %@", name];
	NSPredicate *idFilter = [NSPredicate predicateWithFormat:@"UniqueID == %@", uniqueId];
	NSPredicate *filter = [NSCompoundPredicate orPredicateWithSubpredicates:
						   [NSArray arrayWithObjects:nameFilter, idFilter, nil]];
	
	return filter;
}

- (NSPredicate *)predicateForUniqueID:(DDXMLNode *)parent
{
	NSString *uniqueId = [self stringNode:parent name:@"id"];
	NSPredicate *idFilter = [NSPredicate predicateWithFormat:@"UniqueID == %@", uniqueId];
    return idFilter;
}
@end
