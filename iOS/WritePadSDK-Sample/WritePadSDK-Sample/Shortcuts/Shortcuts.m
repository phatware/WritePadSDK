/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    Copyright (c) 2008-2015 PhatWare(r) Corp. All rights reserved.                 * */
/* ************************************************************************************* */

/* ************************************************************************************* *
 *
 * WritePad SDK Sample
 *
 * Unauthorized distribution of this code is prohibited. For more information
 * refer to the End User Software License Agreement provided with this
 * software.
 *
 * This source code is distributed and supported by PhatWare Corp.
 * http://www.phatware.com
 *
 * THIS SAMPLE CODE CAN BE USED  AS A REFERENCE AND, IN ITS BINARY FORM,
 * IN THE USER'S PROJECT WHICH IS INTEGRATED WITH THE WRITEPAD SDK.
 * ANY OTHER USE OF THIS CODE IS PROHIBITED.
 *
 * THE MATERIAL EMBODIED ON THIS SOFTWARE IS PROVIDED TO YOU "AS-IS"
 * AND WITHOUT WARRANTY OF ANY KIND, EXPRESS, IMPLIED OR OTHERWISE,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY OR
 * FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL PHATWARE CORP.
 * BE LIABLE TO YOU OR ANYONE ELSE FOR ANY DIRECT, SPECIAL, INCIDENTAL,
 * INDIRECT OR CONSEQUENTIAL DAMAGES OF ANY KIND, OR ANY DAMAGES WHATSOEVER,
 * INCLUDING WITHOUT LIMITATION, LOSS OF PROFIT, LOSS OF USE, SAVINGS
 * OR REVENUE, OR THE CLAIMS OF THIRD PARTIES, WHETHER OR NOT PHATWARE CORP.
 * HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH LOSS, HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, ARISING OUT OF OR IN CONNECTION WITH THE
 * POSSESSION, USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 * US Government Users Restricted Rights
 * Use, duplication, or disclosure by the Government is subject to
 * restrictions set forth in EULA and in FAR 52.227.19(c)(2) or subparagraph
 * (c)(1)(ii) of the Rights in Technical Data and Computer Software
 * clause at DFARS 252.227-7013 and/or in similar or successor
 * clauses in the FAR or the DOD or NASA FAR Supplement.
 * Unpublished-- rights reserved under the copyright laws of the
 * United States.  Contractor/manufacturer is PhatWare Corp.
 * 1314 S. Grand Blvd. Ste. 2-175 Spokane, WA 99202
 *
 * ************************************************************************************* */

#import "Shortcuts.h"
#import "OptionKeys.h"
#import "utils.h"
#import "RecognizerManager.h"

typedef struct {
    WPSystemShortcut	command;
    BOOL        enabled;
    char *		name;
    char *		text;
    NSInteger	offset;
    char *      comment;
} WPSYSTEMSHORTCUT;

static WPSYSTEMSHORTCUT sysShortcuts[] =
{
    kWPSysShortcutCom,				YES,  "com",			"www..com",		-4,     ("Insert: www..com"),
    kWPSysShortcutFtp,				YES, "ftp",			"ftp://ftp.",		0,      ("Insert: ftp://ftp."),
    kWPSysShortcutNet,				YES, "net",			"www..net",		-4,     ("Insert: www..net"),
    kWPSysShortcutDate,				YES,  "date",		"",				0,      ("Insert Current Date"),
    kWPSysShortcutDateTime,			YES,  "dt",			"",				0,      ("Insert Date&Time"),
    kWPSysShortcutOrg,				YES, "org",			"www..org",		-4,     ("Insert: www..org"),
    kWPSysShortcutWww,				YES, "www",			"http://www.",		0,      ("Insert: http://www."),
    kWPSysShortcutTime,				YES, "time",		"",				0,      ("Insert Current Time"),
    
    kWPSysShortcutSelectAll,        YES,  "all",			"",				0,      ("Select All"),
    kWPSysShortcutCopy, 			YES,  "copy",		"",				0,      ("Copy"),
    kWPSysShortcutCut,				YES,  "cut",			"",				0,      ("Cut"),
    kWPSysShortcutPaste,			YES, "paste",		"",				0,      ("Paste"),
    kWPSysShortcutRedo,				YES, "redo",		"",				0,      ("Redo"),
    kWPSysShortcutSupport,			YES, "support",		"PhatWare Corp.\nhttp://www.phatware.com\ninfo@phatware.com\n",	0,  ("PhatWare Support Info"),
    kWPSysShortcutUndo,				YES, "undo",		"",				0,      ("Undo"),    
};

static NSInteger compareShortcuts (id a, id b, void *ctx)
{
    NSString * s1 = ((Shortcut *)a).name;
    NSString * s2 = ((Shortcut *)b).name;
    return [s1 caseInsensitiveCompare:s2];
}


static Shortcuts * gShortcuts = nil;

@implementation Shortcuts

+ (Shortcuts *) sharedShortcuts
{
    @synchronized(self)
    {
        if ( nil == gShortcuts )
        {
            gShortcuts = [[Shortcuts alloc] init];
        }
    }
    return gShortcuts;
}


@synthesize	delegate;
@synthesize delegateUI;
@synthesize modified;

- (id) init
{
    self = [super init];
    if (self)
    {
        _recognizer = NULL;
        _shortcutsSys = [[NSMutableArray alloc] init];
        for ( int i = 0; i < sizeof( sysShortcuts )/sizeof( sysShortcuts[0] ); i++ )
        {
            Shortcut * sc = [[Shortcut alloc] initWithName:[NSString stringWithUTF8String:sysShortcuts[i].name] shortcut:sysShortcuts[i].command];
            if ( sc != nil )
            {
                sc.text = [NSString stringWithUTF8String:sysShortcuts[i].text];
                sc.offset = sysShortcuts[i].offset;
                sc.comment = [NSString stringWithUTF8String:sysShortcuts[i].comment];
                sc.enabled = sysShortcuts[i].enabled;
                sc.showInPanel = (i < PANEL_COMMANDS);
                [_shortcutsSys addObject:sc];
#if !__has_feature(objc_arc)
                [sc release];
#endif
            }
        }
        
        [_shortcutsSys sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSComparisonResult result =  [[(Shortcut *)obj1 name] caseInsensitiveCompare:[(Shortcut *)obj2 name]];
            return result;
        }];
        
#ifndef APP_EXTENSION
        NSArray * arr = [[NSUserDefaults standardUserDefaults] arrayForKey:kRecoOptionsSystemShorthands];
        if ( arr != nil )
        {
            for ( int i = 0; i < MIN( _shortcutsSys.count, arr.count ); i++ )
            {
                Shortcut * sc = [_shortcutsSys objectAtIndex:i];
                sc.enabled = [[arr objectAtIndex:i] boolValue];
            }
        }
        else
        {
            [self saveSystemShortcuts];
        }
#endif // APP_EXTENSION
        
        _shortcutsUser = [[NSMutableArray alloc] init];
        // load user shortcuts...
        NSArray *   paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *	documentsPath = [paths objectAtIndex:0];
        _userFileName =  [[NSString alloc] initWithString:[[NSString stringWithString:documentsPath] stringByAppendingPathComponent:@USER_SHORTCUT_FILE]];
        if ( ! [[NSFileManager defaultManager] fileExistsAtPath:_userFileName] )
        {
            // ceeate the defaut user shortcut    file if it does not exist
            NSString *	resName = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@USER_SHORTCUT_FILE];
            NSError *	err = nil;
            if ( ! [[NSFileManager defaultManager] copyItemAtPath:resName toPath:_userFileName error:&err] )
            {
                NSLog( @"Can't move file from:\n%@\nto:\n%@\nError: %@",  resName, _userFileName, err );
            }
        }
        [self loadUserShortcuts];
    }
    return self;
}

- (BOOL) reloadUserShorcuts
{
    if ( [self loadUserShortcuts] )
    {
        return [self resetRecognizer];
    }
    return NO;
}

- (BOOL) resetRecognizer
{
    if ( [self isEnabled] )
    {
        [self enableRecognizer:NO];
        [self enableRecognizer:YES];
    }
    return [self isEnabled];
}

- (void) saveSystemShortcuts
{
    NSMutableArray * arr = [NSMutableArray arrayWithCapacity:[_shortcutsSys count]];
    for ( Shortcut * sc in _shortcutsSys )
    {
        [arr addObject:[NSNumber numberWithBool:sc.enabled]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:arr forKey:kRecoOptionsSystemShorthands];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL) enableRecognizer:(BOOL)bEnableReco
{
    if ( bEnableReco && [_shortcutsSys count] > 0 )
    {
        if ( NULL != _recognizer )
        {
            return HWR_Reset( _recognizer );
        }
        else
        {
            _recognizer = HWR_InitRecognizer( NULL,  NULL, NULL, NULL, LANGUAGE_ENGLISH,  NULL );
            if ( NULL != _recognizer )
            {
                NSUserDefaults *	defaults = [NSUserDefaults standardUserDefaults];
                // set recognizer options
                unsigned int	flags = (FLAG_ONLYDICT | FLAG_USERDICT | FLAG_SINGLEWORDONLY | FLAG_NOSPACE | FLAG_SMOOTHSTROKES);
                if ( [defaults boolForKey:kRecoOptionsSeparateLetters] )
                    flags |= FLAG_SEPLET;
                else
                    flags &= ~FLAG_SEPLET;
                if ( [defaults boolForKey:kRecoOptionsInternational] )
                    flags |= FLAG_INTERNATIONAL;
                else
                    flags &= ~FLAG_INTERNATIONAL;
                HWR_SetRecognitionFlags( _recognizer, flags );
                
                if ( HWR_NewUserDict( _recognizer ) )
                {
                    // add commands to the user dictionary
                    for ( int i = 0; i < [_shortcutsSys count]; i++ )
                    {
                        Shortcut *	 sc = [_shortcutsSys objectAtIndex:i];
                        if ( ! sc.enabled )
                            continue;
                        const UCHR * pszWord = [RecognizerManager uchrFromString:sc.name];
                        if ( pszWord != nil )
                        {
                            HWR_AddUserWordToDict( _recognizer, pszWord, NO );
                        }
                    }
                    for ( int i = 0; i < [_shortcutsUser count]; i++ )
                    {
                        Shortcut *	 sc = [_shortcutsUser objectAtIndex:i];
                        if ( ! sc.enabled )
                            continue;
                        const UCHR * pszWord = [RecognizerManager uchrFromString:sc.name];
                        if ( pszWord != nil )
                        {
                            HWR_AddUserWordToDict( _recognizer, pszWord, NO );
                        }
                    }
                    return YES;
                }
            }
        }
    }
    if ( NULL != _recognizer )
    {
        HWR_FreeRecognizer( _recognizer, NULL, NULL, NULL );
        _recognizer = NULL;
    }
    return (_recognizer == NULL) ? NO : YES;
}

- (BOOL) isEnabled
{
    return (_recognizer == NULL) ? NO : YES;
}

- (void) addUserShortcut:(Shortcut *)sc
{
    // add new objects to the beginning of the array
    [_shortcutsUser insertObject:sc atIndex:0];
    modified = YES;
    [self resetRecognizer];
    [self saveUserShortcuts];
}

- (void) deleteUserShortcut:(Shortcut *)sc
{
    [_shortcutsUser removeObject:sc];
    modified = YES;
    [self resetRecognizer];
    [self saveUserShortcuts];
}

- (Shortcut *) findByName:(NSString *)name
{
    for ( Shortcut * sc in _shortcutsSys )
    {
        if ( sc.name != nil && [sc.name caseInsensitiveCompare:name] == NSOrderedSame )
            return sc;
    }
    for ( Shortcut * sc in _shortcutsUser )
    {
        if ( sc.name != nil && [sc.name caseInsensitiveCompare:name] == NSOrderedSame )
            return sc;
    }
    return nil;
}

- (void) newShortcut
{
    if (delegateUI && [delegateUI respondsToSelector:@selector(ShortcutsUIEditShortcut:shortcut:isNew:)])
    {
        Shortcut * sc = [[Shortcut alloc] initWithName:@"" shortcut:(WPSystemShortcut)([_shortcutsUser count] + 1 + kWPSysShortcutTotal)];
        if ( delegate != nil )
            [delegate ShortcutGetSelectedText:sc withGesture:GEST_NONE offset:sc.offset];
        [delegateUI ShortcutsUIEditShortcut:self shortcut:sc isNew:YES];
#if !__has_feature(objc_arc)
        [sc release];
#endif
    }
}

- (BOOL) process:(Shortcut *)sc
{
    BOOL	result = NO;
    
    if ( delegate == nil )
        return result;
    
    if ( sc.command > kWPSysShortcutTotal )
    {
        // user shortcut: simply insert the text at the current cursor location
        return [delegate ShortcutsRecognizedShortcut:sc withGesture:GEST_NONE offset:sc.offset];
    }
    
    // process system commands
    switch( sc.command )
    {
        case kWPSysShortcutCut :
            result = [delegate ShortcutsRecognizedShortcut:sc withGesture:GEST_CUT offset:sc.offset];
            break;
            
        case kWPSysShortcutCopy :
            result = [delegate ShortcutsRecognizedShortcut:sc withGesture:GEST_COPY offset:sc.offset];
            break;
            
        case kWPSysShortcutPaste :
            result = [delegate ShortcutsRecognizedShortcut:sc withGesture:GEST_PASTE offset:sc.offset];
            break;
            
        case kWPSysShortcutUndo :
            result = [delegate ShortcutsRecognizedShortcut:sc withGesture:GEST_UNDO offset:sc.offset];
            break;
            
        case kWPSysShortcutRedo :
            result = [delegate ShortcutsRecognizedShortcut:sc withGesture:GEST_REDO offset:sc.offset];
            break;
            
        case kWPSysShortcutDate :
            // get current date
            result = [delegate ShortcutsRecognizedShortcut:sc withGesture:GEST_NONE offset:sc.offset];
            break;
            
        case kWPSysShortcutTime :
            // get current time
            result = [delegate ShortcutsRecognizedShortcut:sc withGesture:GEST_NONE offset:sc.offset];
            break;
            
        case kWPSysShortcutDateTime :
            result = [delegate ShortcutsRecognizedShortcut:sc withGesture:GEST_NONE offset:sc.offset];
            break;
            
        case kWPSysShortcutSelectAll :
            result = [delegate ShortcutsRecognizedShortcut:sc withGesture:GEST_SELECTALL offset:sc.offset];
            break;
            
        case kWPSysShortcutSupport :
        case kWPSysShortcutCom :
        case kWPSysShortcutOrg :
        case kWPSysShortcutNet :
        case kWPSysShortcutWww :
        case kWPSysShortcutFtp :
            // simply insert sc.text
            result = [delegate ShortcutsRecognizedShortcut:sc withGesture:GEST_NONE offset:sc.offset];
            break;
            
        default:
            result = [delegate ShortcutsRecognizedShortcut:sc withGesture:(GEST_CUSTOIM+sc.command) offset:sc.offset];
            break;
    }
    return result;
}

- (BOOL) recognizeInkData:(INK_DATA_PTR)inkData
{
    if ( NULL == _recognizer )
        return NO;
    const UCHR * pText = HWR_RecognizeInkData( _recognizer, inkData, 0, -1, FALSE, FALSE, FALSE, FALSE );
    if ( pText == NULL || *pText == 0 )
        return NO;
    NSString * strName = [RecognizerManager stringFromUchr:pText];
    // find and execute the command
    Shortcut * sc = [self findByName:strName];
    if ( sc && sc.enabled )
    {
        // ignore the processing result
        [self performSelector:@selector(process:) withObject:sc afterDelay:0.2];
        // [self process:sc];
        return YES;
    }
    return NO;
}

-(unichar) getuchar:(FILE *)file
{
    unichar ch = 0;
    if ( fread( &ch, 1, 2, file ) < 1 )
        ch = 0;
    return ch;
}

-(void) putback:(FILE *)file
{
    fseek( file, -2, SEEK_CUR );
}


-(NSString *)getNextToken:(FILE *)file isEndOfRow:(BOOL *)endofrow isEndOfFile:(BOOL *)endoffile
{
    NSMutableString * strToken = [NSMutableString string];
    Boolean bQuotes = NO;
    *endofrow = NO;
    *endoffile = NO;
    unichar ch1, ch = 0;
    while ( (ch = [self getuchar:file]) )
    {
        if ( bQuotes )
        {
            if ( ch == '\r' )
                continue;
            else if ( ch == '\"' )
            {
                ch1 = [self getuchar:file];
                if ( ch1 == '\"' )
                {
                    [strToken appendString:@"\""];
                }
                else
                {
                    [self putback:file];
                    bQuotes = NO;
                }
            }
            else
            {
                [strToken appendString:[NSString stringWithCharacters:&ch length:1]];
            }
        }
        else
        {
            if ( ch == '\r' )
            {
                // ignore \r
            }
            else if ( ch == '\n' )
            {
                // end or row
                *endofrow = YES;
                break;
            }
            else if ( ch == '\"' )
                bQuotes = YES;
            else if ( ch == ',' )
                break;		// end of column
            else
                [strToken appendString:[NSString stringWithCharacters:&ch length:1]];
        }
    }
    if ( ch == 0 )
    {
        *endofrow = YES;
        *endoffile = YES;
    }
    return strToken;
}

enum {
    kUserShortcutName = 0,
    kUserShortcutText,
    kUserShortcutEnabled,
    kUserShortcutOffset,
    kUserShortcutMenu,
    kUserShortcutTotal
};


- (BOOL) loadUserShortcuts
{
    // loads user shortcuts from the file.
    FILE *	file = fopen( [_userFileName UTF8String], "r" );
    if ( NULL == file )
        return NO;
    
    // the file is UNICODE, skip first char
    [self getuchar:file];
    
    // read data
    BOOL		endofrow = NO;
    BOOL		endoffile = NO;
    NSInteger	column = 0;
    Shortcut *	sc = nil;
    
    [_shortcutsUser removeAllObjects];
    
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    while ( ! endoffile )
    {
        NSString * strToken = [self getNextToken:file isEndOfRow:&endofrow isEndOfFile:&endoffile];
        if ( strToken == nil )
        {
            break;
        }
        if ( [strToken length] > 0 )
        {
            switch( column )
            {
                case kUserShortcutName :
                    if ( sc == nil )
                    {
                        sc = [[Shortcut alloc] initWithName:strToken shortcut:(WPSystemShortcut)([_shortcutsUser count] + kWPSysShortcutTotal + 1)];
                    }
                    else
                    {
                        sc.name = strToken;
                    }
                    break;
                    
                case kUserShortcutText :
                    if ( nil != sc )
                        sc.text = strToken;
                    break;
                    
                case kUserShortcutEnabled :
                    if ( nil != sc )
                        sc.enabled = ([strToken caseInsensitiveCompare:@"YES"] == NSOrderedSame);
                    break;
                    
                case kUserShortcutMenu :
                    if ( nil != sc )
                        sc.addToMenu = ([strToken caseInsensitiveCompare:@"YES"] == NSOrderedSame);
                    break;
                    
                case kUserShortcutOffset :
                    if ( nil != sc )
                    {
                        NSNumber * num = [numberFormatter numberFromString:strToken];
                        if ( num != nil )
                            sc.offset = [num intValue];
                    }
                    break;
            }
        }
        column++;
        if ( endofrow )
        {
            if ( sc != nil && sc.name != nil && [sc.name length] > 0 && sc.text != nil && [sc.text length] > 0 )
            {
                [_shortcutsUser addObject:sc];
            }
#if !__has_feature(objc_arc)
            [sc release];
#endif
            sc = nil;
            column = 0;
        }
    }
    
#if !__has_feature(objc_arc)
    [numberFormatter release];
    if ( sc != nil )
        [sc release];
#endif
    fclose( file );
    
    // sort array in aphabetical order
    [_shortcutsUser sortUsingFunction:compareShortcuts context:nil];	
    modified = NO;
    return YES;
}

- (NSInteger) countUser
{
    return [_shortcutsUser count];
}

- (NSInteger) countSystem
{
    return [_shortcutsSys count];
}

- (NSInteger) countSysEnabled
{
    NSInteger result = 0;
    
    for ( Shortcut * s in _shortcutsSys )
    {
        if ( s.enabled )
            result++;
    }
    return result;
}

- (Shortcut *) userShortcutByIndex:(NSInteger)index
{
    if ( index >= 0 && index <  [_shortcutsUser count] )
        return [_shortcutsUser objectAtIndex:index];
    return nil;
}

- (Shortcut *) sysShortcutByIndex:(NSInteger)index
{
    if ( index >= 0 && index <  [_shortcutsSys count] )
        return [_shortcutsSys objectAtIndex:index];
    return nil;
}

- (BOOL) saveUserShortcuts
{
    if ( ! modified )
        return YES;
    // saves user-defined shortcuts as CSV file.
    NSUInteger	mult = 2;
    BOOL		bResult = NO;	
    
    FILE * file = fopen( [_userFileName UTF8String], "w+" );
    if ( file == nil )
        return NO;
    
    // write header
    NSUInteger  len = 10;
    NSUInteger	memLen = len * 10;
    NSUInteger	actualLen = 0;
    char *		buffer = malloc( memLen );
    if ( buffer == nil )
    {	
        fclose( file );
        return NO;
    }
    
    // write unicode header
    buffer[0] = '\377'; buffer[1] = '\376';
    if ( fwrite( buffer, 1, 2, file ) < actualLen )
        goto Err;
    
    // addnotes
    for ( Shortcut * sc in _shortcutsUser )
    {
        NSString * str = [sc shortcutToCsvString]; 
        len = mult * ([str length]+4);
        if ( len >= memLen )
        {
            memLen = 2 * len;
            buffer = realloc( buffer, memLen );
            if ( nil == buffer )
                goto Err;
        }
        
        actualLen = 0;
        [str getBytes:buffer maxLength:len usedLength:&actualLen encoding:NSUnicodeStringEncoding
              options:NSStringEncodingConversionAllowLossy range:NSMakeRange( 0, [str length]) remainingRange:nil];
        
        if ( fwrite( buffer, 1, actualLen, file ) < actualLen )
            goto Err;
        
    }
    bResult = YES;
    modified = NO;
    
Err:
    fclose( file );
    free( buffer );
    return bResult;
}

// Releases resouces when no longer needed.
-(void)dealloc
{
    if ( NULL != _recognizer )
    {
        HWR_FreeRecognizer( _recognizer, NULL, NULL, NULL );
        _recognizer = NULL;
    }
#if !__has_feature(objc_arc)
    [_shortcutsUser release];
    [_shortcutsSys release];
    [_userFileName release];
    [super dealloc];
#endif
}


@end
