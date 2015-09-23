/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    Copyright (c) 2008-2014 PhatWare(r) Corp. All rights reserved.                 * */
/* ************************************************************************************* */

/* ************************************************************************************* *
 *
 * File: RecognizerWrapper.h
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


#ifndef __RecognizerWrapper_h__
#define __RecognizerWrapper_h__

#include "RecognizerApi.h"
#include "InkWrapper.h"


#if defined(__cplusplus)
extern "C"
{
#endif
	
typedef void * RECOGNIZER_PTR;
	
// #define RecoStringEncoding	    NSUnicodeStringEncoding
#define RecoStringEncoding		NSWindowsCP1252StringEncoding // NSISOLatin1StringEncoding
    
#define USER_SHORTCUT_FILE		"usershortcuts.csv"
#define DICTIONARY_EXT          "dct"
#define kEmptyWord				"<--->"
	
	enum  {
		kDictionaryType_Main = 0,
		kDictionaryType_Alternative,
		kDictionaryType_User
	};
	
	typedef int (RECO_ONGOTWORDLIST)( const UCHR * szWordFrom, const UCHR * szWordTo, unsigned int nFlags, void * pParam );
	typedef RECO_ONGOTWORDLIST * PRECO_ONGOTWORDLIST;
	
	// recognizer library language ID
	int				HWR_GetLanguageID( RECOGNIZER_PTR pRecognizer );
	const char *	HWR_GetLanguageName( RECOGNIZER_PTR pRecognizer );
    BOOL            HWR_IsLanguageSupported( int langID );
	int             HWR_GetSupportedLanguages( int ** languages );
    
	// recognition API
	RECOGNIZER_PTR	HWR_InitRecognizer( const char * inDictionaryMain, const char * inDictionaryCustom, const char * inLearner, const char * inAutoCorrect, int language, int * pFlags );
	RECOGNIZER_PTR  HWR_InitRecognizerFromMemory( const char * inDictionaryMain, const char * inDictionaryCustom, const char * inLearner, const char * inAutoCorrect, int language, int * pFlags );

	void			HWR_FreeRecognizer( RECOGNIZER_PTR pRecognizer, const char * inDictionaryCustom, const char * inLearner, const char * inWordList );
	BOOL			HWR_RecognizerAddStroke( RECOGNIZER_PTR pRecognizer, CGStroke pStroke, int nStrokeCnt );
	BOOL			HWR_Recognize( RECOGNIZER_PTR pRecognizer );
	BOOL			HWR_Reset( RECOGNIZER_PTR pRecognizer );
    const UCHR *    HWR_RecognizeInkData( RECOGNIZER_PTR pRecognizer, INK_DATA_PTR pInkData, int nFirstStroke, int nLastStroke, BOOL bAsync, BOOL bFlipY, BOOL bSort, BOOL bSelOnly  );
    BOOL			HWR_PreRecognizeInkData( RECOGNIZER_PTR pRecognizer, INK_DATA_PTR pInkData, int nDataLen, BOOL bFlipY );
	const UCHR *	HWR_GetResult( RECOGNIZER_PTR pRecognizer );
	USHORT			HWR_GetResultWeight( RECOGNIZER_PTR pRecognizer, int nWord, int nAlternative );
	const UCHR *	HWR_GetResultWord( RECOGNIZER_PTR pRecognizer, int nWord, int nAlternative );
	int 			HWR_GetResultStrokesNumber( RECOGNIZER_PTR pRecognizer, int nWord, int nAlternative );
	int				HWR_GetResultWordCount( RECOGNIZER_PTR pRecognizer );
	int				HWR_GetResultAlternativeCount( RECOGNIZER_PTR pRecognizer, int nWord );
	int				HWR_SetRecognitionMode( RECOGNIZER_PTR pRecognizer, int nNewMode );
	int				HWR_GetRecognitionMode( RECOGNIZER_PTR pRecognizer );
    int             HWR_GetStrokeIDs( RECOGNIZER_PTR pRecognizer, int word, int altrnative, const int ** strokes );
	unsigned int	HWR_SetRecognitionFlags( RECOGNIZER_PTR pRecognizer, unsigned int newFlags );
	unsigned int	HWR_GetRecognitionFlags( RECOGNIZER_PTR pRecognizer );
	void			HWR_StopAsyncReco( RECOGNIZER_PTR pRecognizer );
	void			HWR_SetCustomCharset( RECOGNIZER_PTR pRecognizer, const UCHR * pCustomNum, const UCHR  * pCustPunct );
    BOOL            HWR_RecognizeSymbol( RECOGNIZER_PTR pRecognizer, INK_DATA_PTR pInkData, int base, int charsize );

	// simple calculator functions
	BOOL			HWR_EnablePhatCalc( RECOGNIZER_PTR pRecognizer, BOOL bEnable );
	const UCHR *	HWR_CalculateString( RECOGNIZER_PTR pRecognizer, const UCHR * pszString );
	
	// autocorrector functions
	BOOL			HWR_SaveWordList( RECOGNIZER_PTR pRecognizer, const char * inWordListFile );
	int				HWR_EnumWordList( RECOGNIZER_PTR pRecognizer, RECO_ONGOTWORDLIST callback, void * pParam );
	BOOL			HWR_EmptyWordList( RECOGNIZER_PTR pRecognizer );
	BOOL			HWR_AddWordToWordList( RECOGNIZER_PTR pRecognizer, const UCHR * pszWord1, const UCHR * pszWord2, int dwFlags, BOOL bReplace );
	BOOL			HWR_ResetAutoCorrector( RECOGNIZER_PTR pRecognizer, const char * inWordListFile );
	const UCHR *	HWR_AutocorrectWord( RECOGNIZER_PTR pRecognizer, const UCHR * pszWord );
	BOOL			HWR_ReloadAutoCorrector( RECOGNIZER_PTR pRecognizer, const char * inWordListFile );
	BOOL			HWR_ImportWordList( RECOGNIZER_PTR pRecognizer, const char * inImportFile );
	BOOL			HWR_ExportWordList( RECOGNIZER_PTR pRecognizer, const char * inExportFile );
	int				HWR_GetAutocorrectorData( RECOGNIZER_PTR pRecognizer, char **ppData );
	BOOL			HWR_SetAutocorrectorData( RECOGNIZER_PTR pRecognizer, const char *pData );

	// learner functions
	BOOL			HWR_ResetLearner( RECOGNIZER_PTR pRecognizer, const char * inLearnerFile );
	BOOL			HWR_AnalyzeWordList( RECOGNIZER_PTR pRecognizer, const UCHR *pszWordList, UCHR *pszResult );
	BOOL			HWR_LearnNewWord( RECOGNIZER_PTR pRecognizer, const UCHR * pszWord, USHORT nWeight );
	BOOL			HWR_ReplaceWord( RECOGNIZER_PTR pRecognizer, const UCHR * pszWord1, USHORT nWeight1, const UCHR * pszWord2, USHORT nWeight2 );
	BOOL			HWR_ReloadLearner( RECOGNIZER_PTR pRecognizer, const char * inDictionaryCustom );
	BOOL			HWR_SaveLearner( RECOGNIZER_PTR pRecognizer, const char * pszFileName );
	int				HWR_GetLearnerData( RECOGNIZER_PTR pRecognizer, char **ppData );
	BOOL			HWR_SetLearnerData( RECOGNIZER_PTR pRecognizer, const char *pData );	

	// dictionary functions
	const UCHR *	HWR_WordFlipCase( RECOGNIZER_PTR pRecognizer, const UCHR * pszWord );
    const UCHR *    HWR_WordEnsureLowerCase( RECOGNIZER_PTR pRecognizer, const UCHR * pszWord );
	int				HWR_EnumUserWords( RECOGNIZER_PTR pRecognizer, PRECO_ONGOTWORD callback, void * pParam );
	BOOL			HWR_NewUserDict( RECOGNIZER_PTR pRecognizer );
	BOOL			HWR_SaveUserDict( RECOGNIZER_PTR pRecognizer, const char * inDictionaryCustom );
	BOOL			HWR_IsWordInDict( RECOGNIZER_PTR pRecognizer, const UCHR * pszWord );
	BOOL			HWR_AddUserWordToDict( RECOGNIZER_PTR pRecognizer, const UCHR * pszWord, BOOL filter );
	int				HWR_SpellCheckWord( RECOGNIZER_PTR pRecognizer, const UCHR *pszWord, UCHR *pszAnswer, int cbSize, int flags );
	BOOL			HWR_SetDictionaryData( RECOGNIZER_PTR pRecognizer, const char *pData, int nDictType );
	int				HWR_GetDictionaryData( RECOGNIZER_PTR pRecognizer, char ** ppData, int nDictType );
	BOOL			HWR_HasDictionaryChanged( RECOGNIZER_PTR pRecognizer, int nDictType );
	int				HWR_GetDictionaryLength( RECOGNIZER_PTR pRecognizer, int nDictType );
	BOOL			HWR_ResetUserDict( RECOGNIZER_PTR pRecognizer, const char * inDictionaryCustom );
	BOOL			HWR_ExportUserDictionary( RECOGNIZER_PTR pRecognizer, const char * inExportFile );
	BOOL			HWR_ImportUserDictionary( RECOGNIZER_PTR pRecognizer, const char * inImportFile );
	BOOL			HWR_ReloadUserDict( RECOGNIZER_PTR pRecognizer, const char * inDictionaryCustom );
	BOOL			HWR_LoadAlternativeDict( RECOGNIZER_PTR pRecognizer, const char * inDictionaryAlt );
	
	// letter shapes (added in version 5)
	BOOL			HWR_SetDefaultShapes( RECOGNIZER_PTR pRecognizer );
	BOOL			HWR_SetLetterShapes( RECOGNIZER_PTR pRecognizer, const unsigned char * pShapes );
	const unsigned char *	HWR_GetLetterShapes( RECOGNIZER_PTR pRecognizer );
	
	// external resource set function
	BOOL			HWR_SetExternalResource( int lang, const void* data );

#if defined(__cplusplus)
}
#endif

#endif
