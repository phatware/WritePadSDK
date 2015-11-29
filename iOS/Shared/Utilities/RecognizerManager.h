//
//  RecognizerManager.h
//  WritePadEN
//
//  Created by Stanislav Miasnikov on 6/4/11.
//  Copyright 2011 PhatWare Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LanguageManager.h"

#define MAX_SUGGESTION_COUNT	20


#ifdef HW_RECINT_UNICODE
#define __T(x)      L ##x
#define _STRLEN     wcslen
#define _STRNCMP    wcsncmp
#else
#define __T(x)      x
#define _STRLEN     strlen
#define _STRNCMP    strncmp
#endif

#define kRecognizerDataWord     @"word"
#define kRecognizerDataWords    @"words"
#define kRecognizerDataWeight   @"weight"
#define kRecognizerDataWeights  @"weights"

extern NSString * const ackeyWordFrom;
extern NSString * const ackeyWordTo;
extern NSString * const ackeyFlags;

@interface RecognizedWord : NSObject
{
}

@property (nonatomic, retain) NSString * word;
@property (nonatomic, assign) NSInteger  prob;
@property (nonatomic, assign) NSInteger  row;
@property (nonatomic, assign) NSInteger  col;
@property (nonatomic, assign) BOOL       isDict;


@end


@interface RecognizerManager : NSObject 
{
	RECOGNIZER_PTR	_recognizer;
    BOOL _canRealoadRecognizer;
    
    // search for word paramters
    RECOGNIZER_PTR _recognizerSearch;
    NSString * _searchWord;
}

@property (nonatomic,readonly) RECOGNIZER_PTR	recognizer;
@property (nonatomic) BOOL canRealoadRecognizer;

+ (RecognizerManager *) sharedManager;
+ (void) restRecognizerOptions;

+ (NSString *) stringFromUchr:(CUCHR *)charstring;
+ (CUCHR *) uchrFromString:(NSString *)string;

+ (int) calcNextRecognitionMode;

- (void) saveRecognizerDataOfType:(NSInteger)type;
- (void) reloadRecognizerDataOfType:(NSInteger)type;
- (void) resetRecognizerDataOfType:(NSInteger)type;
- (void) reset;
- (void) setMode:(int)mode;
- (BOOL) isEnabled;
- (int) getMode;
- (void) modifyRecoFlags:(NSUInteger)addFlags deleteFlags:(NSUInteger)delFlags;
- (const UCHR *) recognizeInkData:(INK_DATA_PTR)inkData background:(BOOL)backgroundReco async:(BOOL)asyncReco selection:(BOOL)selection;
- (BOOL) isWordInDictionary:(const UCHR *)chrWord;
- (void) enableCalculator:(BOOL)bEnable;
- (BOOL) addWordToUserDict:(NSString *)strWord save:(BOOL)save filter:(BOOL)filter report:(BOOL)report;
- (BOOL) learnNewWord:(NSString *)strWord weight:(UInt16)weight;
- (BOOL) disable:(BOOL)save;
- (BOOL) enable;
- (BOOL) reloadSettings;
- (BOOL) matchWord:(NSString *)text;
- (int) getWordCount;
- (int) getAltCount:(int)word;
- (void) addStroke:(CGStroke)pts length:(int)len;
- (BOOL) recognize;
- (NSDictionary *) getAllWords:(unsigned int)recoFlags;
- (NSArray *) generateWordArray:(NSInteger)suggestionCount spellCheck:(BOOL)spellCheck;
- (NSArray *) spellCheckWord:(const UCHR *)chrWord flags:(int)flags addSpace:(BOOL)bAddSpace skipFirst:(BOOL)skipFirst;
- (NSArray *) spellCheckWord:(NSString *)word flags:(int)flags addSpace:(BOOL)bAddSpace;
- (BOOL) isDictionaryWord:(NSString *)word;
- (NSString *) calcString:(NSString *)strWord;
- (BOOL) findText:(NSString *)text inInk:(INK_DATA_PTR)inkData startFrom:(int)firstStroke selectedOnly:(BOOL)selected;
- (void) reportError;
- (NSString *) flipCase:(NSString *)word;
- (NSString *) ensureLower:(NSString *)word;
- (void) setFlags:(unsigned int)flags;
- (unsigned int) getFlags;
- (BOOL)replaceWord:(NSString *)wordFrom probability1:(USHORT)prob1 wordTo:(NSString *)wordTo probability2:(USHORT)prob2;
- (USHORT) getWeight:(int)word alternative:(int)alt;
- (BOOL) isStringInDictionary:(NSString *)theText;
- (NSString *) autocorrectedWord:(NSString *)word;

- (NSMutableArray *) getCorrectorWordList;
- (BOOL) newWordListFromWordList:(NSArray *)wordList;
- (BOOL) newUserDictFromWordList:(NSArray *)words;
- (NSMutableArray *) getUserWords;
- (void) reloadRecognizerForLanguage:(WPLanguage)language;


@end
