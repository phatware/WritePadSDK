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
- (BOOL) addWordToUserDict:(NSString *)strWord save:(BOOL)save filter:(BOOL)filter;
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

@end
