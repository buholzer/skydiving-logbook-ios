//
//  DatabaseSerializer.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/22/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "DatabaseExporter.h"
#import "RepositoryManager.h"
#import "ImportExportConstants.h"
#import "LogEntry.h"
#import "Signature.h"

// weight constants for progress
static float LogEntryWeight = 0.7;
static float SignatureWeight = 0.2;
static float SkydiveTypeWeight = 0.025;
static float LocationWeight = 0.025;
static float AircraftWeight = 0.025;
static float RigWeight = 0.025;

@interface DatabaseExporter(Private)
- (void)serializeLogbookHistory;
- (void)serializeLogEntries;
- (void)serializeSignatures;
- (void)serializeSkydiveTypes;
- (void)serializeLocations;
- (void)serializeAircrafts;
- (void)serializeRigs;
- (NSString *)rigsString:(LogEntry *)entry;
- (NSString *)writeLogEntryImageToFile:(LogEntryImage *)image;
@end

@implementation DatabaseExporter

- (id)initWithOptions:(NSString *)outputDir delegate:(id<DatabaseExportDelegate>)theDelegate
{
	if (self = [super init])
	{
        outputDirectory = outputDir;
		delegate = theDelegate;
	}
	return self;
}

- (void)beginExport
{	
    // get output files
    NSString *xmlPath = [outputDirectory stringByAppendingPathComponent:XmlFileName];
    NSString *csvPath = [outputDirectory stringByAppendingPathComponent:CsvFileName];
    
    // create serializers
    serializer = [[XmlSerializer alloc] initWithFilePath:xmlPath];
    csvSerializer = [[CsvSerializer alloc] initWithFilePath:csvPath];
    
	// start doc
	[serializer startDocument];
	[serializer startTagWithAttributes:@"skydiving_logbook"
                            attribute1:@"version"
                                value1:@"2"
							attribute2:@"xmlns"
								value2:@"http://www.skydiving-logbook.org/logbook"];
	
	// logbook history
	[self serializeLogbookHistory];
	
	// log entries
	[self serializeLogEntries];

	// signatures
	[self serializeSignatures];
	
	// skydive types
	[self serializeSkydiveTypes];
	
	// locations
	[self serializeLocations];
	
	// aircrafts
	[self serializeAircrafts];
	
	// rigs
	[self serializeRigs];
	
	// end tag
	[serializer endTag:@"skydiving_logbook"];
	
	// close file
	[serializer closeFile];
    
    // invoke delegate for xml/csv
    [delegate databaseExportComplete:xmlPath csvPath:csvPath];
}

- (void)serializeLogbookHistory
{
	// get history
    LogbookHistoryRepository *repository = [[RepositoryManager instance] logbookHistoryRepository];
	LogbookHistory *history = [repository history];
	
	[serializer startTag:@"logbook_history"];
	[serializer tagWithNumber:@"freefall_time" number:history.FreefallTime];
	[serializer tagWithNumber:@"cutaways" number:history.Cutaways];
	[serializer endTag:@"logbook_history"];
}

- (void)serializeLogEntries
{
	// write csv heder
	[csvSerializer addRow:[NSArray arrayWithObjects:
								NSLocalizedString(@"JumpNumberHeader", @""),
								NSLocalizedString(@"DateHeader", @""),
								NSLocalizedString(@"LocationHeader", @""),
								NSLocalizedString(@"AircraftHeader", @""),
								NSLocalizedString(@"GearHeader", @""),
								NSLocalizedString(@"SkydiveTypeHeader", @""),
								NSLocalizedString(@"ExitAltitudeHeader", @""),
								NSLocalizedString(@"DeploymentAltitudeHeader", @""),
								NSLocalizedString(@"AltitudeUnitHeader", @""),
								NSLocalizedString(@"FreefallTimeHeader", @""),
								NSLocalizedString(@"CutawayHeader", @""),
								NSLocalizedString(@"NotesHeader", @""),
								nil]];
	
	// get log entries
    LogEntryRepository *repository = [[RepositoryManager instance] logEntryRepository];
	NSArray *logEntries = [repository loadAllEntities];
	
	// get progress increment amount
	int total = [logEntries count];
	float progressIncrement = LogEntryWeight / (float)total;
	// if no data, add entire progress weight
	if (total == 0)
		[delegate addDatabaseExportProgress:LogEntryWeight];
	
	// serialize
	[serializer startTag:@"log_entries"];
	for (LogEntry *entry in logEntries)
	{
		// write to xml
		[serializer startTag:@"log_entry"];
        [serializer tagWithString:@"id" string:entry.UniqueID];
		[serializer tagWithNumber:@"jump_number" number:entry.JumpNumber];
		[serializer tagWithDate:@"date" date:entry.Date];
		[serializer tagWithString:@"location_id" string:entry.Location.UniqueID];
		[serializer tagWithString:@"aircraft_id" string:entry.Aircraft.UniqueID];
		
        // rigs
        [serializer startTag:@"rigs"];
		for (Rig *rig in entry.Rigs)
		{
			[serializer tagWithString:@"rig_id" string:rig.UniqueID];
		}
		[serializer endTag:@"rigs"];

		[serializer tagWithString:@"skydive_type_id" string:entry.SkydiveType.UniqueID];
		[serializer tagWithNumber:@"exit_altitude" number:entry.ExitAltitude];
		[serializer tagWithNumber:@"deployment_altitude" number:entry.DeploymentAltitude];
		[serializer tagWithString:@"altitude_unit" string:entry.AltitudeUnit];
		[serializer tagWithNumber:@"freefall_time" number:entry.FreefallTime];
		[serializer tagWithNumber:@"cutaway" number:entry.Cutaway];
		[serializer tagWithString:@"notes" string:entry.Notes];
        
        // images
        [serializer startTag:@"images"];
        for (LogEntryImage *image in entry.Images)
        {
            // write image to file
            NSString *fileName = [self writeLogEntryImageToFile:image];

            // write XML
            [serializer startTag:@"image"];
            [serializer tagWithString:@"image_type" string:image.ImageType];
            [serializer tagWithString:@"image_file" string:fileName];
            [serializer tagWithString:@"image_md5" string:image.MD5];
            [serializer endTag:@"image"];
        }
        [serializer endTag:@"images"];
        
		[serializer tagWithID:@"signature_id" object:entry.Signature];
        [serializer tagWithUTCDateTime:@"last_modified_utc" date:entry.LastModifiedUTC];
        [serializer tagWithUTCDateTime:@"last_signature_utc" date:entry.LastSignatureUTC];
		[serializer endTag:@"log_entry"];
		
		// write to csv
		NSString *locationName = @"";
		NSString *aircraftName = @"";
        NSString *rigsString = @"";
		NSString *skydiveType = @"";
		NSString *altitudeUnit = @"";
        NSString *notes = @"";
		if (entry.Location != nil)
			locationName = entry.Location.Name;
		if (entry.Aircraft != nil)
			aircraftName = entry.Aircraft.Name;
        if (entry.Rigs != nil)
            rigsString = [self rigsString:entry];
		if (entry.SkydiveType != nil)
			skydiveType = entry.SkydiveType.Name;
		if (entry.AltitudeUnit != nil)
			altitudeUnit = NSLocalizedString(entry.AltitudeUnit, @"");
        if (entry.Notes != nil)
            notes = entry.Notes;
		[csvSerializer addRow:[NSArray arrayWithObjects:
								[csvSerializer formatNumber:entry.JumpNumber],
								[csvSerializer formatDate:entry.Date],
								[csvSerializer formatString:locationName],
								[csvSerializer formatString:aircraftName],
								[csvSerializer formatString:rigsString],
								[csvSerializer formatString:skydiveType],
								[csvSerializer formatNumber:entry.ExitAltitude],
								[csvSerializer formatNumber:entry.DeploymentAltitude],
								[csvSerializer formatString:altitudeUnit],
								[csvSerializer formatNumber:entry.FreefallTime],
								[csvSerializer formatNumberAsBoolean:entry.Cutaway],
								[csvSerializer formatString:notes],
								nil]];
		
		// update progress
		[delegate addDatabaseExportProgress:progressIncrement];
	}
	[serializer endTag:@"log_entries"];
}

- (NSString *)rigsString:(LogEntry *)entry
{
	// set gear text
	NSMutableString *string = [NSMutableString stringWithCapacity:0];
	NSEnumerator *rigs = [entry.Rigs objectEnumerator];
	Rig *rig = [rigs nextObject];
	while (rig)
	{
		[string appendString:rig.Name];
		rig = [rigs nextObject];
		if (rig != nil)
		{
			[string appendString:@", "];
		}
	}
	
	return string;
}

- (void)serializeSignatures
{
	// get signatures
    LogEntryRepository *repository = [[RepositoryManager instance] logEntryRepository];
	NSArray *signatures = [repository loadAllSignatures];
	
	// get progress increment amount
	int total = [signatures count];
	float progressIncrement = SignatureWeight / (float)total;
	// if no data, add entire progress weight
	if (total == 0)
		[delegate addDatabaseExportProgress:SignatureWeight];
	
	// serialize
	[serializer startTag:@"signatures"];
	for (Signature *signature in signatures)
	{
		[serializer startTag:@"signature"];
		[serializer tagWithID:@"id" object:signature];
		[serializer tagWithString:@"license" string:signature.License];
		[serializer tagWithImage:@"image" image:signature.Image];
		[serializer endTag:@"signature"];
		
		// update progress
		[delegate addDatabaseExportProgress:progressIncrement];
	}
	[serializer endTag:@"signatures"];
}

- (void)serializeSkydiveTypes
{
	// get skydive types
    SkydiveTypeRepository *repository = [[RepositoryManager instance] skydiveTypeRepository];
	NSArray *skydiveTypes = [repository loadAllEntities];
	
	// get progress increment amount
	int total = [skydiveTypes count];
	float progressIncrement = SkydiveTypeWeight / (float)total;
	// if no data, add entire progress weight
	if (total == 0)
		[delegate addDatabaseExportProgress:SkydiveTypeWeight];
	
	// serialize
	[serializer startTag:@"skydive_types"];
	for (SkydiveType *skydiveType in skydiveTypes)
	{
		[serializer startTag:@"skydive_type"];
		[serializer tagWithString:@"id" string:skydiveType.UniqueID];
		[serializer tagWithString:@"name" string:skydiveType.Name];
		[serializer tagWithNumber:@"default" number:skydiveType.Default];
		[serializer tagWithString:@"freefall_profile_type" string:skydiveType.FreefallProfileType];
		[serializer tagWithString:@"notes" string:skydiveType.Notes];
		[serializer tagWithNumber:@"active" number:skydiveType.Active];
        [serializer tagWithUTCDateTime:@"last_modified_utc" date:skydiveType.LastModifiedUTC];
		[serializer endTag:@"skydive_type"];
		
		// update progress
		[delegate addDatabaseExportProgress:progressIncrement];
	}
	[serializer endTag:@"skydive_types"];
}

- (void)serializeLocations
{
	// get locations
    LocationRepository *repository = [[RepositoryManager instance] locationRepository];
	NSArray *locations = [repository loadAllEntities];

	// get progress increment amount
	int total = [locations count];
	float progressIncrement = LocationWeight / (float)total;
	// if no data, add entire progress weight
	if (total == 0)
		[delegate addDatabaseExportProgress:LocationWeight];
	
	// serialize
	[serializer startTag:@"locations"];
	for (Location *location in locations)
	{
		[serializer startTag:@"location"];
		[serializer tagWithString:@"id" string:location.UniqueID];
		[serializer tagWithString:@"name" string:location.Name];
		[serializer tagWithNumber:@"home" number:location.Home];
		[serializer tagWithString:@"notes" string:location.Notes];
		[serializer tagWithNumber:@"active" number:location.Active];
        [serializer tagWithUTCDateTime:@"last_modified_utc" date:location.LastModifiedUTC];
		[serializer endTag:@"location"];
		
		// update progress
		[delegate addDatabaseExportProgress:progressIncrement];
	}
	[serializer endTag:@"locations"];
}

- (void)serializeAircrafts
{
	// get aircrafts
    AircraftRepository *repository = [[RepositoryManager instance] aircraftRepository];
	NSArray *aircrafts = [repository loadAllEntities];

	// get progress increment amount
	int total = [aircrafts count];
	float progressIncrement = AircraftWeight / (float)total;
	// if no data, add entire progress weight
	if (total == 0)
		[delegate addDatabaseExportProgress:AircraftWeight];
	
	// serialize
	[serializer startTag:@"aircrafts"];
	for (Aircraft *aircraft in aircrafts)
	{
		[serializer startTag:@"aircraft"];
		[serializer tagWithString:@"id" string:aircraft.UniqueID];
		[serializer tagWithString:@"name" string:aircraft.Name];
		[serializer tagWithNumber:@"default" number:aircraft.Default];
		[serializer tagWithString:@"notes" string:aircraft.Notes];
		[serializer tagWithNumber:@"active" number:aircraft.Active];
        [serializer tagWithUTCDateTime:@"last_modified_utc" date:aircraft.LastModifiedUTC];
		[serializer endTag:@"aircraft"];
		
		// update progress
		[delegate addDatabaseExportProgress:progressIncrement];
	}
	[serializer endTag:@"aircrafts"];
}

- (void)serializeRigs
{
	// get rigs
    RigRepository *repository = [[RepositoryManager instance] rigRepository];
	NSArray *rigs = [repository loadAllEntities];

	// get progress increment amount
	int total = [rigs count];
	float progressIncrement = RigWeight / (float)total;
	// if no data, add entire progress weight
	if (total == 0)
		[delegate addDatabaseExportProgress:RigWeight];
	
	// serialize
	[serializer startTag:@"rigs"];
	for (Rig *rig in rigs)
	{
		[serializer startTag:@"rig"];
		[serializer tagWithString:@"id" string:rig.UniqueID];
		[serializer tagWithString:@"name" string:rig.Name];
		[serializer tagWithNumber:@"primary" number:rig.Primary];
		[serializer tagWithNumber:@"archived" number:rig.Archived];
		[serializer tagWithString:@"notes" string:rig.Notes];
		[serializer tagWithNumber:@"active" number:rig.Active];
        [serializer tagWithUTCDateTime:@"last_modified_utc" date:rig.LastModifiedUTC];
		// components
		[serializer startTag:@"components"];
		for (RigComponent *component in rig.Components)
		{
			[serializer startTag:@"component"];
			[serializer tagWithString:@"name" string:component.Name];
			[serializer tagWithString:@"serial_number" string:component.SerialNumber];
			[serializer tagWithString:@"notes" string:component.Notes];
			[serializer endTag:@"component"];
		}
		[serializer endTag:@"components"];
		// reminders
		[serializer startTag:@"reminders"];
		for (RigReminder *reminder in rig.Reminders)
		{
			[serializer startTag:@"reminder"];
			[serializer tagWithString:@"name" string:reminder.Name];
			[serializer tagWithNumber:@"interval" number:reminder.Interval];
			[serializer tagWithString:@"interval_unit" string:reminder.IntervalUnit];
			[serializer tagWithDate:@"last_completed_date" date:reminder.LastCompletedDate];
			[serializer endTag:@"reminder"];
		}
		[serializer endTag:@"reminders"];
		[serializer endTag:@"rig"];
		
		// update progress
		[delegate addDatabaseExportProgress:progressIncrement];
	}
	[serializer endTag:@"rigs"];
}

- (NSString *)writeLogEntryImageToFile:(LogEntryImage *)image
{
    // create file path
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", image.MD5];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", outputDirectory, fileName];
    
    // check if file exists
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath])
    {
        // create file
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    
        // get/write data to file
        NSData *data = [NSData dataWithData:UIImageJPEGRepresentation(image.Image, 1.0f)];//1.0f = 100% quality
        [fileHandle writeData:data];
    
        // close file
        [fileHandle closeFile];
    }
    
    // call delegate
    [delegate databaseImageExported:filePath];
    
    return fileName;
}

@end
