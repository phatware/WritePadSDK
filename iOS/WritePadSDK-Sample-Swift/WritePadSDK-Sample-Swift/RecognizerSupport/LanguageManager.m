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

#import <UIKit/UIKit.h>
#import "LanguageManager.h"
#import "OptionKeys.h"

static LanguageManager *	gManager;


@interface LanguageManager (Private)


@end


@implementation LanguageManager

@synthesize currentLanguage;

+ (LanguageManager *) sharedManager
{
	@synchronized(self) 
	{	
		if ( nil == gManager )
		{
			gManager = [[LanguageManager alloc] init];
		}
	}
	return gManager;
}

- (id) init
{
	self = [super init];
	if (self != nil) 
	{
		textChecker = nil;
		currentLanguage = WPLanguageEnglishUS;
		NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
				
		if ( [defaults integerForKey:kGeneralOptionsCurrentLanguage] != WPLanguageUnknown )
		{
			currentLanguage = (WPLanguage)[defaults integerForKey:kGeneralOptionsCurrentLanguage];
		}
		else
		{
            currentLanguage = [self systemLanguage];
			[defaults setInteger:currentLanguage forKey:kGeneralOptionsCurrentLanguage];
		}
        NSString * theLanguage = [self languageCode];
		Boolean bFound = NO;
		for( NSString * str in [UITextChecker availableLanguages] )
		{
			if ( [str compare:theLanguage] == NSOrderedSame )
				bFound = YES;
			NSLog( @"Language %@", str );
		}
		if ( bFound )
			textChecker = [[UITextChecker alloc] init];
	}
	return self;
}

- (WPLanguage) systemLanguage
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSArray *	languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *	cLanguage = [languages objectAtIndex:0];
    WPLanguage  syslanguage = WPLanguageEnglishUS;
    
    if ( [cLanguage caseInsensitiveCompare:@"de"] == NSOrderedSame )
        syslanguage = WPLanguageGerman;
    else if ( [cLanguage caseInsensitiveCompare:@"fr"] == NSOrderedSame )
        syslanguage = WPLanguageFrench;
    else if ( [cLanguage caseInsensitiveCompare:@"es"] == NSOrderedSame )
        syslanguage = WPLanguageSpanish;
    else if ( [cLanguage caseInsensitiveCompare:@"it"] == NSOrderedSame )
        syslanguage = WPLanguageItalian;
    else if ( [cLanguage caseInsensitiveCompare:@"pt-PT"] == NSOrderedSame )
        syslanguage = WPLanguagePortuguese;
    else if ( [cLanguage caseInsensitiveCompare:@"pt"] == NSOrderedSame )
        syslanguage = WPLanguageBrazilian;
    else if ( [cLanguage caseInsensitiveCompare:@"nl"] == NSOrderedSame )
        syslanguage = WPLanguageDutch;
    else if ( [cLanguage caseInsensitiveCompare:@"en-GB"] == NSOrderedSame )
        syslanguage = WPLanguageEnglishUK;
    else if ( [cLanguage caseInsensitiveCompare:@"sv"] == NSOrderedSame )
        syslanguage = WPLanguageSwedish;
    else if ( [cLanguage caseInsensitiveCompare:@"da"] == NSOrderedSame )
        syslanguage = WPLanguageDanish;
    else if ( [cLanguage caseInsensitiveCompare:@"fi"] == NSOrderedSame )
        syslanguage = WPLanguageFinnish;
    else if ( [cLanguage caseInsensitiveCompare:@"nb"] == NSOrderedSame )
        syslanguage = WPLanguageNorwegian;
    else if ( [cLanguage caseInsensitiveCompare:@"id"] == NSOrderedSame )
        syslanguage = WPLanguageIndonesian;
    
    if ( ! HWR_IsLanguageSupported( [self getLanguageID] ) )
        syslanguage = WPLanguageEnglishUS;
    return syslanguage;
}

#pragma mark -- Spell Checker support

- (NSRange) badWordRange:(NSString *)str
{
    if ( [str length] > 1 )
    {
        NSRange		stringRange = NSMakeRange( 0, [str length] );
        return [textChecker rangeOfMisspelledWordInString:str range:stringRange
                                                                startingAt:0 wrap:NO language:[self languageCode]];
    }
    return NSMakeRange( NSNotFound, 0 );
}

- (BOOL) spellCheckerEnabled
{
	return (nil != textChecker);
}

- (NSArray *)supportedLanguages
{
    int * languages = NULL;
    int count = HWR_GetSupportedLanguages( &languages );
    NSMutableArray * array  = [NSMutableArray arrayWithCapacity:count];
    for ( int i = 0; i < count; i++ )
    {
        [array addObject:[NSNumber numberWithInt:languages[i]]];
    }
    return [NSArray arrayWithArray:array];
}

- (NSArray *) supportedLocalLanguages
{
    int * languages = NULL;
    int count = HWR_GetSupportedLanguages( &languages );
    NSMutableArray * array  = [NSMutableArray arrayWithCapacity:count];
    for ( int i = 0; i < count; i++ )
    {
        WPLanguage language = [self languageFromLanguageID:languages[i]];
        [array addObject:[NSNumber numberWithInt:language]];
    }
    return [NSArray arrayWithArray:array];
}

- (void) changeCurrentLanguageID:(int)languageID
{
    WPLanguage language = WPLanguageEnglishUS;
    
    switch( languageID )
    {
		case LANGUAGE_GERMAN :
			language = WPLanguageGerman;
			break;
			
        case LANGUAGE_ENGLISHUK :
            language = WPLanguageEnglishUK;
            break;
            
		case  LANGUAGE_FRENCH:
			language = WPLanguageFrench;
			break;
			
		case LANGUAGE_SPANISH :
			language = WPLanguageSpanish;
			break;
			
		case LANGUAGE_PORTUGUESE :
			language = WPLanguagePortuguese;
			break;
			
		case LANGUAGE_PORTUGUESEB :
			language = WPLanguageBrazilian;
			break;
			
		case LANGUAGE_DUTCH  :
			language = WPLanguageDutch;
			break;
			
		case LANGUAGE_ITALIAN  :
			language = WPLanguageItalian;
			break;
			
		case LANGUAGE_FINNISH :
			language = WPLanguageFinnish;
			break;
			
		case LANGUAGE_SWEDISH :
			language = WPLanguageSwedish;
			break;
			
		case LANGUAGE_NORWEGIAN  :
			language = WPLanguageNorwegian;
			break;
			
		case LANGUAGE_DANISH  :
			language = WPLanguageDanish;
			break;
            
        case LANGUAGE_INDONESIAN :
            language = WPLanguageIndonesian;
            break;
            
        default :
            break;
    }
    [self changeCurrentLanguage:language];    
}

- (void) changeCurrentLanguage:(WPLanguage)language
{
	if ( language == currentLanguage )
		return;

	textChecker = nil;
	currentLanguage = language;
	[[NSUserDefaults standardUserDefaults] setInteger:currentLanguage forKey:kGeneralOptionsCurrentLanguage];
	NSString * theLanguage = [self languageCode];
	Boolean bFound = NO;
	for( NSString * str in [UITextChecker availableLanguages] )
	{
		if ( [str compare:theLanguage] == NSOrderedSame )
			bFound = YES;
		NSLog( @"Language %@", str );
	}
	if ( bFound )
		textChecker = [[UITextChecker alloc] init];
}

- (NSArray *) spellCheckWord:(NSString *)strWord complete:(Boolean)complete
{
    NSArray *	guesses = nil;
	if ( textChecker != nil && [strWord length] > 1 )
	{
		NSString *	theLanguage = [self languageCode];
		NSString *	theText = strWord;
		NSRange		stringRange = NSMakeRange(0, theText.length);
		
		if ( complete )
		{
			guesses = [textChecker completionsForPartialWordRange:stringRange inString:theText language:theLanguage];
		}
		else
		{
			NSRange currentRange = [textChecker rangeOfMisspelledWordInString:theText range:stringRange
																   startingAt:0 wrap:NO language:theLanguage];
			if ( currentRange.location != NSNotFound && currentRange.length > 0 )
			{
				guesses = [textChecker guessesForWordRange:currentRange inString:theText language:theLanguage];
			}
		}
	}
	return guesses;
}

- (NSString *) mainDictionaryPath
{
	NSString * theLanguage = @"English";
	switch ( currentLanguage )
	{
		case WPLanguageGerman :
			theLanguage = @"German";
			break;
			
		case WPLanguageFrench :
			theLanguage = @"French";
			break;
			
		case WPLanguageSpanish :
			theLanguage = @"Spanish";
			break;
			
		case WPLanguagePortuguese :
			theLanguage = @"Portuguese";
			break;
			
		case WPLanguageBrazilian :
			theLanguage = @"Brazilian";
			break;
			
		case WPLanguageDutch :
			theLanguage = @"Dutch";
			break;
			
		case WPLanguageItalian :
			theLanguage = @"Italian";
			break;
			
		case WPLanguageFinnish :
			theLanguage = @"Finnish";
			break;
			
		case WPLanguageSwedish :
			theLanguage = @"Swedish";
			break;
			
		case WPLanguageNorwegian :
			theLanguage = @"Norwegian";
			break;
            
        case WPLanguageIndonesian :
            theLanguage = @"Indonesian";
            break;
			
		case WPLanguageDanish :
			theLanguage = @"Danish";
			break;
			
		case WPLanguageMedicalUS :
		case WPLanguageMedicalUK :
			theLanguage = @"MedicalUS";
			break;
			
		case WPLanguageEnglishUK :
			theLanguage = @"EnglishUK";
			break;
        default :
            break;
	}
    NSString * str = [[NSString alloc] initWithString:[[NSBundle mainBundle] pathForResource:theLanguage ofType:@"dct"]];
#if !__has_feature(objc_arc)
    return [str autorelease];
#else
    return str;
#endif
}

- (NSString *) shortLanguageName
{
    NSString * theLanguage = @"EN";
    switch ( currentLanguage )
    {
        case WPLanguageGerman :
            theLanguage = @"DE";
            break;
            
        case WPLanguageFrench :
            theLanguage = @"FR";
            break;
            
        case WPLanguageSpanish :
            theLanguage = @"ES";
            break;
            
        case WPLanguageBrazilian :
            theLanguage = @"PT (BR)";
            break;
            
        case WPLanguagePortuguese :
            theLanguage = @"PT";
            break;
            
        case WPLanguageDutch :
            theLanguage = @"NL";
            break;
            
        case WPLanguageItalian :
            theLanguage = @"IT";
            break;
            
        case WPLanguageFinnish :
            theLanguage = @"FI";
            break;
            
        case WPLanguageSwedish :
            theLanguage = @"SV";
            break;
            
        case WPLanguageNorwegian :
            theLanguage = @"NO";
            break;
            
        case WPLanguageDanish :
            theLanguage = @"DA";
            break;
            
        case WPLanguageEnglishUK :
            theLanguage = @"EN (UK)";
            break;
            
        case WPLanguageIndonesian :
            theLanguage = @"ID";
            break;
            
        case WPLanguageMedicalUS :
            theLanguage = @"MED";
            break;
            
        default :
            break;
    }
    return theLanguage;
}


- (NSString *) languageName:(WPLanguage)wplanguage
{
	NSString * theLanguage = @"English (United States)";
    if ( wplanguage == WPLanguageUnknown )
        wplanguage = currentLanguage;
	switch ( wplanguage )
	{
		case WPLanguageGerman :
			theLanguage = @"Deutsch";
			break;
			
		case WPLanguageFrench :
			theLanguage = @"Français";
			break;
			
		case WPLanguageSpanish :
			theLanguage = @"Español";
			break;
			
        case WPLanguageBrazilian :
            theLanguage = @"Português (Brasil)";
            break;

        case WPLanguagePortuguese :
			theLanguage = @"Português (Portugal)";
			break;

		case WPLanguageDutch :
			theLanguage = @"Nederlands";
			break;
			
		case WPLanguageItalian :
			theLanguage = @"Italiano";
			break;
			
		case WPLanguageFinnish :
			theLanguage = @"Suomi";
			break;
			
		case WPLanguageSwedish :
			theLanguage = @"Svenska";
			break;
			
		case WPLanguageNorwegian :
			theLanguage = @"Norsk";
			break;
			
        case WPLanguageIndonesian :
            theLanguage = @"Bahasa Indonesia";
            break;
            
		case WPLanguageDanish :
			theLanguage = @"Dansk";
			break;
            
        case WPLanguageEnglishUK :
            theLanguage = @"English (Great Britain)";
            break;
            
        case WPLanguageMedicalUS :
            theLanguage = @"Medical English (US)";
            break;
            
        default :
            break;
	}
	return theLanguage;
}

- (UIImage *) languageImage
{
    return [self languageImageForLanguageID:currentLanguage];
}

- (UIImage *) languageImageForLanguageID:(WPLanguage)languageID
{
    UIImage * theImage = nil;
    if ( languageID == WPLanguageUnknown )
        languageID = currentLanguage;
	switch ( languageID )
	{
		case WPLanguageGerman :
			theImage = [UIImage imageNamed:@"flag_germany.png"];
			break;
			
		case WPLanguageFrench :
			theImage = [UIImage imageNamed:@"flag_france.png"];
			break;
			
		case WPLanguageSpanish :
			theImage = [UIImage imageNamed:@"flag_spain.png"];
			break;
			
		case WPLanguagePortuguese :
			theImage = [UIImage imageNamed:@"flag_portugal.png"];
			break;
			
		case WPLanguageBrazilian :
			theImage = [UIImage imageNamed:@"flag_brazil.png"];
			break;
			
		case WPLanguageDutch :
			theImage = [UIImage imageNamed:@"flag_netherlands.png"];
			break;
			
		case WPLanguageItalian :
			theImage = [UIImage imageNamed:@"flag_italy.png"];
			break;
			
		case WPLanguageFinnish :
			theImage = [UIImage imageNamed:@"flag_finland.png"];
			break;
			
		case WPLanguageSwedish :
			theImage = [UIImage imageNamed:@"flag_sweden.png"];
			break;
			
		case WPLanguageNorwegian :
			theImage = [UIImage imageNamed:@"flag_norway.png"];
			break;
			
		case WPLanguageDanish :
			theImage = [UIImage imageNamed:@"flag_denmark.png"];
			break;
			
		case WPLanguageEnglishUS  :
			theImage = [UIImage imageNamed:@"flag_usa.png"];
			break;

        case WPLanguageIndonesian :
            theImage = [UIImage imageNamed:@"flag_indonesia.png"];
            break;
            
        case WPLanguageMedicalUS :
			theImage = [UIImage imageNamed:@"first_aid.png"];
			break;
			
		case WPLanguageEnglishUK :
			theImage = [UIImage imageNamed:@"flag_uk.png"];
			break;

        default :
            break;
	}
	return theImage;
}

- (NSString *) languageCode
{
	NSString *	theLanguage = @"en_US";
	switch ( currentLanguage )
	{
		case WPLanguageGerman :
			theLanguage = @"de_DE";
			break;
			
		case WPLanguageFrench :
			theLanguage = @"fr_FR";
			break;
			
		case WPLanguageSpanish :
			theLanguage = @"es_ES";
			break;
			
		case WPLanguagePortuguese :
			theLanguage = @"pt_PT";
			break;
			
		case WPLanguageBrazilian :
			theLanguage = @"pt_BR";
			break;
			
		case WPLanguageDutch :
			theLanguage = @"nl_NL";
			break;
			
		case WPLanguageItalian :
			theLanguage = @"it_IT";
			break;
			
        case WPLanguageIndonesian :
            theLanguage = @"id";
            break;

        case WPLanguageMedicalUK :
		case WPLanguageEnglishUK :
			theLanguage = @"en_GB";
			break;
			
		case WPLanguageFinnish :
			theLanguage = @"fi_FI";
			break;
			
		case WPLanguageSwedish :
			theLanguage = @"sv_SE";
			break;
			
		case WPLanguageNorwegian :
			theLanguage = @"nb_NO";
			break;
			
		case WPLanguageDanish :
			theLanguage = @"da_DK";
			break;
			
		case WPLanguageMedicalUS :
		case WPLanguageEnglishUS :
		default:
			theLanguage = @"en_US";
			break;
	}
	return theLanguage;
}

- (NSString *) infoPasteboardName
{
	NSString *	name = @"EN_US";
	switch ( currentLanguage )
	{
		case WPLanguageGerman :
			name = @"DE";;
			break;
			
		case WPLanguageFrench :
			name = @"FR";
			break;
			
		case WPLanguageSpanish :
			name = @"ES";
			break;
			
		case WPLanguagePortuguese :
			name = @"PT";
			break;
			
		case WPLanguageBrazilian :
			name = @"BR";
			break;
			
		case WPLanguageDutch :
			name = @"DT";
			break;
			
		case WPLanguageItalian :
			name = @"IT";
			break;
						
		case WPLanguageFinnish :
			name = @"FIN";
			break;
			
		case WPLanguageSwedish :
			name = @"SW";
			break;
			
		case WPLanguageNorwegian :
			name = @"NW";
			break;
			
        case WPLanguageIndonesian :
            name = @"ID";
            break;
            
		case WPLanguageDanish :
			name = @"DN";
			break;
			
		case WPLanguageMedicalUK :
            name = @"MD_UK";
            break;

        case WPLanguageEnglishUK :
			name = @"EN_UK";
			break;

		case WPLanguageMedicalUS :
            name = @"MD_US";
            break;

        case WPLanguageEnglishUS :
		default:
            name = @"EN_US";
			break;
	}
	return name;
}

- (WPLanguage) languageFromLanguageID:(int)languageID
{
    WPLanguage language = WPLanguageEnglishUS;
    
    switch( languageID )
    {
        case LANGUAGE_GERMAN :
            language = WPLanguageGerman;
            break;
            
        case LANGUAGE_ENGLISHUK :
            language = WPLanguageEnglishUK;
            break;

        case  LANGUAGE_FRENCH:
            language = WPLanguageFrench;
            break;
            
        case LANGUAGE_SPANISH :
            language = WPLanguageSpanish;
            break;
            
        case LANGUAGE_PORTUGUESE :
            language = WPLanguagePortuguese;
            break;
            
        case LANGUAGE_PORTUGUESEB :
            language = WPLanguageBrazilian;
            break;
            
        case LANGUAGE_DUTCH  :
            language = WPLanguageDutch;
            break;
            
        case LANGUAGE_ITALIAN  :
            language = WPLanguageItalian;
            break;
            
        case LANGUAGE_FINNISH :
            language = WPLanguageFinnish;
            break;
            
        case LANGUAGE_SWEDISH :
            language = WPLanguageSwedish;
            break;
            
        case LANGUAGE_NORWEGIAN  :
            language = WPLanguageNorwegian;
            break;
            
        case LANGUAGE_DANISH  :
            language = WPLanguageDanish;
            break;
            
        case LANGUAGE_INDONESIAN :
            language = WPLanguageIndonesian;
            break;
            
        default :
            break;
    }
    return language;
}

- (int) getLanguageID
{
	int language = LANGUAGE_ENGLISH;
	switch ( currentLanguage )
	{
		case WPLanguageGerman :
			language = LANGUAGE_GERMAN;
			break;
			
        case WPLanguageEnglishUK :
            language = LANGUAGE_ENGLISHUK;
            break;
            
		case WPLanguageFrench :
			language = LANGUAGE_FRENCH;
			break;
			
		case WPLanguageSpanish :
			language = LANGUAGE_SPANISH;
			break;
			
		case WPLanguagePortuguese :
			language = LANGUAGE_PORTUGUESE;
			break;
			
		case WPLanguageBrazilian :
			language = LANGUAGE_PORTUGUESEB;
			break;
			
		case WPLanguageDutch :
			language = LANGUAGE_DUTCH;
			break;
			
		case WPLanguageItalian :
			language = LANGUAGE_ITALIAN;
			break;
			
		case WPLanguageFinnish :
			language = LANGUAGE_FINNISH;
			break;
			
		case WPLanguageSwedish :
			language = LANGUAGE_SWEDISH;
			break;
			
		case WPLanguageNorwegian :
			language = LANGUAGE_NORWEGIAN;
			break;
			
		case WPLanguageDanish :
			language = LANGUAGE_DANISH;
			break;
            
        case WPLanguageIndonesian :
            language = LANGUAGE_INDONESIAN;
            break;
            
        default :
            break;
	}
	return language;
}

- (NSString *) userFilePathOfType:(NSInteger)type
{
	NSArray *	paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *	name = nil;
	switch ( currentLanguage )
	{
		case WPLanguageGerman :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadCorrGER.cwl"];
			else if ( type == USERDATA_LEARNER )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadStatGER.lrn"];
			else
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadUserGER.dct"];
			break;
			
		case WPLanguageFrench :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadCorrFRN.cwl"];
			else if ( type == USERDATA_LEARNER )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadStatFRN.lrn"];
			else
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadUserFRN.dct"];
			break;
			
		case WPLanguageSpanish :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadCorrSPN.cwl"];
			else if ( type == USERDATA_LEARNER )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadStatSPN.lrn"];
			else
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadUserSPN.dct"];
			break;
			
		case WPLanguagePortuguese :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadCorrPRT.cwl"];
			else if ( type == USERDATA_LEARNER )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadStatPRT.lrn"];
			else
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadUserPRT.dct"];
			break;
			
		case WPLanguageBrazilian :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadCorrBRZ.cwl"];
			else if ( type == USERDATA_LEARNER )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadStatBRZ.lrn"];
			else
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadUserBRZ.dct"];
			break;
			
		case WPLanguageDutch :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadCorrDUT.cwl"];
			else if ( type == USERDATA_LEARNER )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadStatDUT.lrn"];
			else
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadUserDUT.dct"];
			break;
			
		case WPLanguageItalian :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadCorrITL.cwl"];
			else if ( type == USERDATA_LEARNER )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadStatITL.lrn"];
			else
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadUserITL.dct"];
			break;
			
		case WPLanguageFinnish :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadCorrFIN.cwl"];
			else if ( type == USERDATA_LEARNER )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadStatFIN.lrn"];
			else
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadUserFIN.dct"];
			break;
			
		case WPLanguageSwedish :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadCorrSWD.cwl"];
			else if ( type == USERDATA_LEARNER )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadStatSWD.lrn"];
			else
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadUserSWD.dct"];
			break;
			
		case WPLanguageNorwegian :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadCorrNRW.cwl"];
			else if ( type == USERDATA_LEARNER )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadStatNRW.lrn"];
			else
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadUserNRW.dct"];
			break;
			
		case WPLanguageDanish :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadCorrDAN.cwl"];
			else if ( type == USERDATA_LEARNER )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadStatDAN.lrn"];
			else
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadUserDAN.dct"];
			break;
			
        case WPLanguageIndonesian :
            if ( type == USERDATA_AUTOCORRECTOR )
                name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadCorrIND.cwl"];
            else if ( type == USERDATA_LEARNER )
                name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadStatIND.lrn"];
            else
                name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadUserIND.dct"];
            break;

        case WPLanguageMedicalUK :
		case WPLanguageEnglishUK :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadCorrUK.cwl"];
			else if ( type == USERDATA_LEARNER )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadStatUK.lrn"];
			else
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadUserUK.dct"];
			break;			
			
		case WPLanguageMedicalUS :
		case WPLanguageEnglishUS :
		default:
			if ( type == USERDATA_AUTOCORRECTOR )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadCorrUS.cwl"];
			else if ( type == USERDATA_LEARNER )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadStatUS.lrn"];
			else
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePadUserUS.dct"];
			break;
	}
	return name;
}

@end



