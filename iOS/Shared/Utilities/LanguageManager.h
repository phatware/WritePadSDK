//
//  LanguageManager.h
//  WritePadEN
//
//  Created by Stanislav Miasnikov on 6/4/11.
//  Copyright 2011 PhatWare Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UITextChecker.h>

#import "RecognizerWrapper.h"
#ifdef PERSISTENT_DATA
#import "WritePadPersistentData.h"
#endif // PERSISTENT_DATA

typedef enum
{
	WPLanguageUnknown = 0,
	WPLanguageEnglishUS = 1,
	WPLanguageEnglishUK,
    WPLanguageGerman,
	WPLanguageFrench,
	WPLanguageSpanish,
    WPLanguagePortuguese,
    WPLanguageBrazilian,
	WPLanguageItalian,
    WPLanguageDutch,
	WPLanguageDanish,
    WPLanguageSwedish,
	WPLanguageNorwegian,
	WPLanguageFinnish,
    WPLanguageIndonesian,
	WPLanguageMedicalUS,
	WPLanguageMedicalUK,
} WPLanguage;

#define USERDATA_DICTIONARY		0x0004
#define USERDATA_AUTOCORRECTOR	0x0001
#define USERDATA_LEARNER		0x0002
#define USERDATA_ALL			0x00FF


@interface LanguageManager : NSObject
{
@private
	WPLanguage	currentLanguage;
#ifdef PERSISTENT_DATA
	WritePadPersistentData * sharedUserData;
#endif // PERSISTENT_DATA
	UITextChecker *	textChecker;
}

+ (LanguageManager *) sharedManager;

- (NSString *) languageName:(WPLanguage)wplanguage;
- (NSArray *) spellCheckWord:(NSString *)strWord complete:(Boolean)complete;
- (NSString *) mainDictionaryPath;
- (NSString *) languageCode;
- (NSString *) infoPasteboardName;
- (int) getLanguageID;
- (void) changeCurrentLanguageID:(int)languageID;
- (void) changeCurrentLanguage:(WPLanguage)language;
- (NSRange) badWordRange:(NSString *)str;
- (BOOL) spellCheckerEnabled;
- (NSArray *) supportedLanguages;
- (UIImage *) languageImage;
- (NSString *) userFilePathOfType:(NSInteger)type;
- (WPLanguage) systemLanguage;
- (NSString *) shortLanguageName;
- (NSArray *) supportedLocalLanguages;

- (UIImage *) languageImageForLanguageID:(WPLanguage)languageID;
- (WPLanguage) languageIDFromLanguageCode:(int)languageID;
- (int) getLanguageIDWithLanguage:(WPLanguage)wpLanguage;
- (BOOL) isLanguageSupported:(WPLanguage)language;

@property (nonatomic,readonly) WPLanguage	currentLanguage;

#ifdef PERSISTENT_DATA
@property (nonatomic, retain,readonly) WritePadPersistentData * sharedUserData;
#endif // PERSISTENT_DATA

@end
