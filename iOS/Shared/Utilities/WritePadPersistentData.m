//
//  WritePadPersistentData.m
//  WritePad
//
//  Created by Stanislav Miasnikov on 10/11/09.
//  Copyright 2009 PhatWare Corp.. All rights reserved.
//

#import "OptionKeys.h"
#import "LanguageManager.h"
#import "RecognizerManager.h"
#import "WritePadPersistentData.h"
#import "utils.h"

@interface WritePadPersistentData()

@property (nonatomic, retain) LanguageManager * languageManager;

@end

// define item names
static NSString * strItemUserDict = @"com.PhatWare.WritePad.UserDict";
static NSString * strItemWordList = @"com.PhatWare.WritePad.WordList";
static NSString * strItemLearner = @"com.PhatWare.WritePad.Learner";
static NSString * strItemShortcut = @"com.PhatWare.WritePad.Shortcut";

typedef struct 
{
	CGFloat		date;
	NSUInteger	flags;
	NSUInteger	reserved1;
	NSUInteger	reserved2;
} USER_DATA_SETTINGS;

@implementation WritePadPersistentData

- (id) initWithLanguageManager:(LanguageManager *)langMan
{
    self = [super init];
	if ( self )
	{
        self.languageManager = langMan;
	}
	return self;
}

- (NSString *) localDocumentsFolder
{
    NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES ) objectAtIndex:0];
    return documentsDirectoryPath;
}

- (NSUInteger) loadPersistentData:(Boolean)force
{
    NSUInteger	result = 0;
    NSURL * urlBase = [utils sharedRecoDataURL];
    if ( nil == urlBase )
        return result;

    NSString *	strUserFile =  [self.languageManager userFilePathOfType:USERDATA_DICTIONARY];
    NSString *	strCorrector =  [self.languageManager userFilePathOfType:USERDATA_AUTOCORRECTOR];
    NSString *	strLearner =  [self.languageManager userFilePathOfType:USERDATA_LEARNER];
    NSString *	strShortcut =  [[self localDocumentsFolder] stringByAppendingPathComponent:@USER_SHORTCUT_FILE];
    
    NSError *	err = nil;
    NSDictionary * attrib;
    NSData *    fileData;

    NSDate *	lastModified = nil;
    NSTimeInterval  time = [[utils recoGroupUserDefaults] doubleForKey:kWritePadPersistentDataDate];
    if ( time > 1 )
        lastModified = [NSDate dateWithTimeIntervalSinceReferenceDate:time];
    
    NSURL *     dataFileURL = [urlBase URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [self.languageManager infoPasteboardName], strItemUserDict]];
    if ( nil != dataFileURL )
    {
        fileData = [NSData dataWithContentsOfURL:dataFileURL];
        if ( nil != fileData && [fileData length] > 0 )
        {
            attrib = [[NSFileManager defaultManager] attributesOfItemAtPath:strUserFile error:&err];
            NSDate * fileModified = [attrib objectForKey:NSFileModificationDate];
            if ( force || nil == fileModified || nil == lastModified || [fileModified compare:lastModified] == NSOrderedAscending )
            {
                if ( ! [[NSFileManager defaultManager] removeItemAtPath:strUserFile error:&err] )
                    NSLog( @"Can't delete exsiting file: %@", err);
                if ( ! [[NSFileManager defaultManager] createFileAtPath:strUserFile contents:fileData attributes:nil] )
                    NSLog( @"Can't create file, %@", strUserFile );
                else
                    result |= PRESISTDATA_USERDICT;
            }
        }
    }
    
    dataFileURL = [urlBase URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [self.languageManager infoPasteboardName], strItemLearner]];
    if ( nil != dataFileURL )
    {
        fileData = [NSData dataWithContentsOfURL:dataFileURL];
        if ( fileData != nil && [fileData length] > 0 )
        {
            // check the file date
            attrib = [[NSFileManager defaultManager] attributesOfItemAtPath:strLearner error:&err];
            NSDate * fileModified = [attrib objectForKey:NSFileModificationDate];
            if ( force || nil == fileModified || nil == lastModified || [fileModified compare:lastModified] == NSOrderedAscending )
            {
                if ( ! [[NSFileManager defaultManager] removeItemAtPath:strLearner error:&err] )
                    NSLog( @"Can't delete exsiting file: %@", err);			
                if ( ! [[NSFileManager defaultManager] createFileAtPath:strLearner contents:fileData attributes:nil] )
                    NSLog( @"Can't create file, %@", strLearner );
                else 
                    result |= PRESISTDATA_LEARNER;
            }
        }
    }
    
    dataFileURL = [urlBase URLByAppendingPathComponent:[NSString stringWithFormat:@"INT.%@", strItemShortcut]];
    if ( nil != dataFileURL )
    {
        fileData = [NSData dataWithContentsOfURL:dataFileURL];
        if ( fileData != nil && [fileData length] > 0 )
        {
            // check the file date
            attrib = [[NSFileManager defaultManager] attributesOfItemAtPath:strShortcut error:&err];
            NSDate * fileModified = [attrib objectForKey:NSFileModificationDate];
            if ( force || nil == fileModified || nil == lastModified || [fileModified compare:lastModified] == NSOrderedAscending )
            {
                if ( ! [[NSFileManager defaultManager] removeItemAtPath:strShortcut error:&err] )
                    NSLog( @"Can't delete exsiting file: %@", err);			
                if ( ! [[NSFileManager defaultManager] createFileAtPath:strShortcut contents:fileData attributes:nil] )
                    NSLog( @"Can't create file, %@", strShortcut );
                else 
                    result |= PRESISTDATA_SHORTCUT;
            }
        }
    }
    
    dataFileURL = [urlBase URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [self.languageManager infoPasteboardName], strItemWordList]];
    if ( nil != dataFileURL )
    {
        fileData = [NSData dataWithContentsOfURL:dataFileURL];
        if ( fileData != nil && [fileData length] > 0 )
        {
            // check the file date
            attrib = [[NSFileManager defaultManager] attributesOfItemAtPath:strCorrector error:&err];
            NSDate * fileModified = [attrib objectForKey:NSFileModificationDate];
            if ( force || nil == fileModified || nil == lastModified || [fileModified compare:lastModified] == NSOrderedAscending )
            {
                if ( ! [[NSFileManager defaultManager] removeItemAtPath:strCorrector error:&err] )
                    NSLog( @"Can't delete exsiting file: %@", err);			
                if ( ! [[NSFileManager defaultManager] createFileAtPath:strCorrector contents:fileData attributes:nil] )
                    NSLog( @"Can't create file, %@", strCorrector );
                else 
                    result |= PRESISTDATA_WORDLIST;
            }
        }
    }
    
    // set "private" date time
    [[NSUserDefaults standardUserDefaults] setDouble:[NSDate timeIntervalSinceReferenceDate] forKey:kWritePadPersistentDataDate];
    return result;
}

- (NSUInteger) reloadPersistentDataIfNeeded
{
    NSUInteger result = [self loadPersistentData:NO];
    return result;
}

#if !__has_feature(objc_arc)

- (void) dealloc
{
	self.languageManager = nil;
	[super dealloc];
}
#endif //

- (NSUInteger) updatePersistentData:(BOOL)force
{
    NSUInteger	result = 0;
    NSURL * urlBase = [utils sharedRecoDataURL];
    if ( nil == urlBase )
        return result;
    
	NSString *	strUserFile =  [self.languageManager userFilePathOfType:USERDATA_DICTIONARY];
	NSString *	strLearner =  [self.languageManager userFilePathOfType:USERDATA_LEARNER];
    NSError *   err = nil;
    NSData *    fileData;
    NSDictionary * attrib;
    NSDate *	lastModified = nil;
    NSTimeInterval  time = [[NSUserDefaults standardUserDefaults] doubleForKey:kWritePadPersistentDataDate];
    if ( time > 1 )
    {
        lastModified = [NSDate dateWithTimeIntervalSinceReferenceDate:time];
    }
    NSURL *     dataFileURL = [urlBase URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [self.languageManager infoPasteboardName], strItemUserDict]];
    if ( nil != dataFileURL )
    {
        attrib = [[NSFileManager defaultManager] attributesOfItemAtPath:strUserFile error:&err];
        NSDate * fileModified = [attrib objectForKey:NSFileModificationDate];
        if ( force || nil == fileModified || nil == lastModified || [fileModified compare:lastModified] == NSOrderedDescending )
        {
            fileData = [NSData dataWithContentsOfFile:strUserFile];
            if ( nil != fileData && [fileData length] > 0 )
            {
                if ( ! [[NSFileManager defaultManager] removeItemAtURL:dataFileURL error:&err] )
                    NSLog( @"Can't delete exsiting file: %@", err);
                if ( ! [fileData writeToURL:dataFileURL atomically:YES] )
                    NSLog( @"Can't create file, %@", dataFileURL );
                else
                    result |= PRESISTDATA_USERDICT;
            }
        }
    }
    dataFileURL = [urlBase URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [self.languageManager infoPasteboardName], strItemLearner]];
    if ( nil != dataFileURL )
    {
        attrib = [[NSFileManager defaultManager] attributesOfItemAtPath:strLearner error:&err];
        NSDate * fileModified = [attrib objectForKey:NSFileModificationDate];
        if ( force || nil == fileModified || nil == lastModified || [fileModified compare:lastModified] == NSOrderedDescending )
        {
            fileData = [NSData dataWithContentsOfFile:strLearner];
            if ( nil != fileData && [fileData length] > 0 )
            {
                if ( ! [[NSFileManager defaultManager] removeItemAtURL:dataFileURL error:&err] )
                    NSLog( @"Can't delete exsiting file: %@", err);
                if ( ! [fileData writeToURL:dataFileURL atomically:YES] )
                    NSLog( @"Can't create file, %@", dataFileURL );
                else
                    result |= PRESISTDATA_LEARNER;
            }
        }
    }
    
#ifndef APP_EXTENSION
    // these do not change in the keyboard extension
    NSString *	strCorrector =  [self.languageManager userFilePathOfType:USERDATA_AUTOCORRECTOR];
    dataFileURL = [urlBase URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [self.languageManager infoPasteboardName], strItemWordList]];
    if ( nil != dataFileURL )
    {
        attrib = [[NSFileManager defaultManager] attributesOfItemAtPath:strCorrector error:&err];
        NSDate * fileModified = [attrib objectForKey:NSFileModificationDate];
        if ( force || nil == fileModified || nil == lastModified || [fileModified compare:lastModified] == NSOrderedDescending )
        {
            fileData = [NSData dataWithContentsOfFile:strCorrector];
            if ( nil != fileData && [fileData length] > 0 )
            {
                if ( ! [[NSFileManager defaultManager] removeItemAtURL:dataFileURL error:&err] )
                    NSLog( @"Can't delete exsiting file: %@", err);
                if ( ! [fileData writeToURL:dataFileURL atomically:YES] )
                    NSLog( @"Can't create file, %@", dataFileURL );
                else
                    result |= PRESISTDATA_WORDLIST;
            }
        }
    }
    
    NSString *	strShortcut =  [[self localDocumentsFolder] stringByAppendingPathComponent:@USER_SHORTCUT_FILE];
    dataFileURL = [urlBase URLByAppendingPathComponent:[NSString stringWithFormat:@"INT.%@", strItemShortcut]];
    if ( nil != dataFileURL )
    {
        attrib = [[NSFileManager defaultManager] attributesOfItemAtPath:strShortcut error:&err];
        NSDate * fileModified = [attrib objectForKey:NSFileModificationDate];
        if ( force || nil == fileModified || nil == lastModified || [fileModified compare:lastModified] == NSOrderedDescending )
        {
            fileData = [NSData dataWithContentsOfFile:strShortcut];
            if ( nil != fileData && [fileData length] > 0 )
            {
                if ( ! [[NSFileManager defaultManager] removeItemAtURL:dataFileURL error:&err] )
                    NSLog( @"Can't delete exsiting file: %@", err);
                if ( ! [fileData writeToURL:dataFileURL atomically:YES] )
                    NSLog( @"Can't create file, %@", dataFileURL );
                else
                    result |= PRESISTDATA_SHORTCUT;
            }
        }
    }
#endif // APP_EXTENSION
    
    if ( result != 0 )
    {
        NSUserDefaults * sharedDefs = [utils recoGroupUserDefaults];
        [sharedDefs setDouble:[NSDate timeIntervalSinceReferenceDate] forKey:kWritePadPersistentDataDate];
        [sharedDefs synchronize];
    }
    return result;
}

@end


