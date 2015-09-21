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

#import "Shortcut.h"
#import "OptionKeys.h"
#import "LanguageManager.h"

@implementation Shortcut

@synthesize		command;
@synthesize		name, text;
@synthesize		offset, enabled, addToMenu, comment, showInPanel;

- (id)initWithName:(NSString *)cmdName shortcut:(WPSystemShortcut)cmd
{
    self = [super init];
    if (self)
    {
        self.command = cmd;
        self.name = cmdName;
        self.text = nil;
        self.enabled = YES;
        self.showInPanel = NO;
        self.addToMenu = NO;
        self.offset = 0;
    }
    return self;
}

- (NSString *)text
{
    NSDate * date = [NSDate date];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    NSString * customFormat = [[NSUserDefaults standardUserDefaults] objectForKey:kTextEditCustomDateFomratString];
    NSInteger currentformat = [[NSUserDefaults standardUserDefaults] integerForKey:kTextEditDateFomratID];
    if ( currentformat < NSDateFormatterShortStyle )
        currentformat = NSDateFormatterMediumStyle;
    
    NSString * languageCode = [LanguageManager sharedManager].languageCode;
    NSLocale * loc = [NSLocale localeWithLocaleIdentifier:languageCode];
    if ( loc != nil )
        [dateFormatter setLocale:loc];
    
    // process current date
    switch( self.command )
    {
        case kWPSysShortcutDate :
            // get current date
            if ( currentformat > NSDateFormatterFullStyle && customFormat != nil )
            {
                [dateFormatter setDateFormat:customFormat];
            }
            else
            {
                [dateFormatter setDateStyle:currentformat];
                [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            }
            self.text = [NSString stringWithFormat:@"%@ ", [dateFormatter stringFromDate:date]];
            break;
            
        case kWPSysShortcutTime :
            // get current time
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            [dateFormatter setDateStyle:NSDateFormatterNoStyle];
            
            self.text = [NSString stringWithFormat:@"%@ ", [dateFormatter stringFromDate:date]];
            break;
            
        case kWPSysShortcutDateTime :
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            [dateFormatter setDateStyle:(currentformat > NSDateFormatterFullStyle) ? NSDateFormatterMediumStyle : currentformat];
            self.text = [NSString stringWithFormat:@"%@ ", [dateFormatter stringFromDate:date]];
            break;
            
        default:
            break;
    }
#if !__has_feature(objc_arc)
    [dateFormatter release];
#endif
    return text;
}

- (NSString *) shortcutToCsvString
{
    NSMutableString *	str = [[NSMutableString alloc] init];
    
    // name, text, enabled, offset
    
    [str appendFormat:@"\"%@\",", self.name];
    [str appendString:[self textToString:self.text returns:@"\n"]];
    [str appendString:@","];
    [str appendFormat:@"\"%@\",\"%ld\",", self.enabled ? @"YES" : @"NO", (long)self.offset];
    [str appendFormat:@"\"%@\"\n", self.addToMenu ? @"YES" : @"NO"];
#if !__has_feature(objc_arc)
    return [str autorelease];
#else
    return str;
#endif
}

- (void) insertShortcut:(id)sender
{
    NSLog( @"%@", self.text );
    
}

- (NSString *)textToString:(NSString *)strText returns:(NSString *)ret
{
    if ( strText == nil || [strText length] < 1 )
        return @"";
    NSMutableString *	str = [[NSMutableString alloc] initWithString:@"\""];
    
    for ( NSUInteger i = 0; i < [strText length]; i++ )
    {
        unichar chr = [strText characterAtIndex:i];
        if ( chr == '\"' )
        {
            [str appendString:@"\""];
        }
        else if ( chr == '\r' )
            continue;
        else if ( chr == '\n' )
        {
            [str appendString:ret];
            continue;
        }
        [str appendString:[NSString stringWithCharacters:&chr length:1]];
    }
    [str appendString:@"\""];
#if !__has_feature(objc_arc)
    return [str autorelease];
#else
    return str;
#endif //
}

#if !__has_feature(objc_arc)
-(void)dealloc
{
    [name release];
    [text release];
    [super dealloc];
}
#endif //


@end
