/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    Copyright (c) 2008-2015 PhatWare(r) Corp. All rights reserved.                 * */
/* ************************************************************************************* */

/* ************************************************************************************* *
 *
 * WritePad Android Sample
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

#include <jni.h>
#include <sys/time.h>
#include <time.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <android/log.h>
#include <math.h>

#include "InkWrapper.h"
#include "RecognizerWrapper.h"

#define MAX_PATH	260

#ifndef false
#define false	0
#endif
#ifndef true
#define true	1
#endif

#define USER_STATISTICS			"WritePad_Stat.lrn"
#define USER_CORRECTOR			"WritePad_Corr.cwl"
#define USER_DICTIONARY			"WritePad_User.dct"

#define MAX_STRING_BUFFER       2048

static INK_DATA_PTR _inkData = NULL;
static RECOGNIZER_PTR _recognizer = NULL;
static int _currentStroke = -1;
static char _szPath[MAX_PATH] = { 0 };

#define MAX_XU_CONVERTS 5

static int _iHexes[MAX_XU_CONVERTS] = { 0x08a, 0x08c, 0x09a, 0x09c, 0x09f };
static int _iUnicodes[MAX_XU_CONVERTS] = { 352, 338, 353, 339, 376 };

static int u_strlen(const unsigned short * str)
{
	register int i = 0;
	for (i = 0; str[i] != 0 && i < MAX_STRING_BUFFER; i++)
		;
	return i;
}

/* ************************************************************************** */
/* *   Convert char string to UNICODE                                       * */
/* ************************************************************************** */

INK_DATA_PTR getInkData()
{
	return _inkData;
}

RECOGNIZER_PTR getRecognizer()
{
	return _recognizer;
}


// JNI BUG: if the first character of the UTF-8 string has high bit set to 1 (ie char code > 127)
// JNI crashes in this implementation. One way to avoid it is to add an extra character in front
// which code is less than 128

/* ************************************************************************** */
/* *   Convert char string to UNICODE                                       * */
/* ************************************************************************** */

static int StrToUNICODE(unsigned short * tstr, const char * str, int cMax) {
	register int i, j;
    
	for (i = 0; i < cMax && str[i] != 0; i++)
    {
        
		tstr[i] = (unsigned short) (unsigned char) str[i];
	}
    
	tstr[i] = 0;
	return i;
}

/* ************************************************************************** */
/* *   Convert UNICODE string to char                                       * */
/* ************************************************************************** */

static int UNICODEtoStr(char * str, const unsigned short * tstr, int cMax)
{
	register int i, j;
    
	for (i = 0; i < cMax && tstr[i] != 0; i++)
    {
		if (tstr[i] < 0xff)
			str[i] = ((unsigned char) tstr[i]);
		else
			str[i] = '?';
	}
	str[i] = 0;
	return i;
}

static const unsigned short * UTF8ToUnicode(const unsigned char *Src) {
	if (Src == NULL || *Src == 0)
		return NULL;
    
	int i = 0;
	int outputlen = 0;
	int SrcLen = strlen((const char *) Src);
    
	// unicode will be the same or shorter
	int DestLen = SrcLen + 2;
	unsigned short * strDest = (unsigned short *) malloc(DestLen
                                                         * sizeof(unsigned short));
	if (NULL == strDest)
		return NULL;
    
	for (i = 0; i < SrcLen;) {
		if (outputlen >= DestLen - 1) {
			//overflow detected
			break;
		}
        
		else if ((0xe0 & Src[i]) == 0xe0) {
			strDest[outputlen++] = (unsigned short) ((((int) Src[i] & 0x0f)
                                                      << 12) | (((int) Src[i + 1] & 0x3f) << 6) | (Src[i + 2]
                                                                                                   & 0x3f));
			i += 3;
		} else if ((0xc0 & Src[i]) == 0xc0) {
			strDest[outputlen++] = (unsigned short) (((int) Src[i] & 0x1f) << 6
                                                     | (Src[i + 1] & 0x3f));
			i += 2;
		} else {
			strDest[outputlen++] = (unsigned short) Src[i];
			++i;
		}
	}
	strDest[outputlen] = '\0';
	return strDest;
}

static const unsigned char * UnicodeToUTF8(const unsigned short *Src) {
	if (Src == NULL || *Src == 0)
		return NULL;
    
	int i = 0;
	int outputlen = 0; /*bytes */
	int SrcLen = u_strlen(Src);
	int DstLen = 2 + 3 * SrcLen;
    
	unsigned char * strDest = (unsigned char *) malloc(DstLen);
	if (NULL == strDest)
		return NULL;
    
	for (i = 0; i < SrcLen; i++) {
		if (outputlen >= DstLen - 1) {
			//overflow detected
			break;
		}
        
		if (0x0800 <= Src[i]) {
			strDest[outputlen++] = (((Src[i] >> 12) & 0x0f) | 0xe0);
			strDest[outputlen++] = (((Src[i] >> 6) & 0x3f) | 0x80);
			strDest[outputlen++] = ((Src[i] & 0x3f) | 0x80);
		} else if (0x800 > Src[i] && 0x80 <= Src[i]) {
			strDest[outputlen++] = (((Src[i] >> 6) & 0x1f) | 0xc0);
			strDest[outputlen++] = ((Src[i] & 0x3f) | 0x80);
		} else if (0x80 > Src[i]) {
			strDest[outputlen++] = (unsigned char) Src[i];
		}
	}
	strDest[outputlen] = 0;
	return (const unsigned char *) strDest;
}

static jstring StringAToJstring(JNIEnv* env, const char * string)
{
	jstring result = NULL;
	unsigned short * uResult;
    
	int len = strlen(string);
    uResult = (unsigned short *) malloc((len + 2) * sizeof(unsigned short));
	if (uResult == NULL)
		return NULL;
	StrToUNICODE(uResult, string, len);
	const char * utfResult = UnicodeToUTF8(uResult);
	free((void *) uResult);
    
	if (NULL != utfResult)
    {
		result = (*env)->NewStringUTF(env, utfResult);
		free((void *) utfResult);
	}
    else
    {
		result = (*env)->NewStringUTF( env, string);
	}
	return result;
}


static jstring StringToJstring(JNIEnv* env, const UCHR * string)
{
	jstring result = NULL;
	unsigned short * uResult;
    
#ifdef HW_RECINT_UNICODE
	const char * utfResult = UnicodeToUTF8(string);
#else
	int len = strlen(string);
    uResult = (unsigned short *) malloc((len + 2) * sizeof(unsigned short));
	if (uResult == NULL)
		return NULL;
	StrToUNICODE(uResult, string, len);
	const char * utfResult = UnicodeToUTF8(uResult);
	free((void *) uResult);
#endif  // HW_RECINT_UNICODE
    
	if (NULL != utfResult)
    {
		result = (*env)->NewStringUTF(env, utfResult);
		free((void *) utfResult);
	}
#ifndef HW_RECINT_UNICODE
    else
    {
		result = (*env)->NewStringUTF( env, string);
	}
#endif // HW_RECINT_UNICODE
	return result;
}

static const char * JstringToStringA(JNIEnv* env, jstring jstr)
{
    jboolean isCopy = JNI_FALSE;
	const char * string = (*env)->GetStringUTFChars(env, jstr, &isCopy );
	const char * result = NULL;
    
	const unsigned short * uString = UTF8ToUnicode((const unsigned char *)string);
	if (uString != NULL)
    {
		int len = u_strlen(uString);
		char * cString = (char *) malloc(len + 1);
		UNICODEtoStr(cString, uString, len);
		result = cString;
		free((void *) uString);
	}
    else
    {
		result = strdup(string);
	}
    if ( string && isCopy == JNI_TRUE)
        (*env)->ReleaseStringUTFChars(env, jstr, string);
	return result;
}

static const UCHR * JstringToString(JNIEnv* env, jstring jstr)
{
    jboolean isCopy = JNI_FALSE;
	const char *string = (*env)->GetStringUTFChars(env, jstr, &isCopy );
	const UCHR * result = NULL;
    
	const unsigned short * uString = UTF8ToUnicode((const unsigned char *)string);
#ifdef HW_RECINT_UNICODE
    result = (const UCHR *)uString;
#else
	if (uString != NULL)
    {
		int len = u_strlen(uString);
		char * cString = (char *) malloc(len + 1);
		UNICODEtoStr(cString, uString, len);
		result = cString;
		free((void *) uString);
	}
    else
    {
		result = strdup(string);
	}
#endif // HW_RECINT_UNICODE
    if ( string && isCopy == JNI_TRUE)
        (*env)->ReleaseStringUTFChars(env, jstr, string);
	return result;
}

static long _getTime(void) {
	struct timeval now;
    
	gettimeofday(&now, NULL);
	return (long) (now.tv_sec * 1000 + now.tv_usec / 1000);
}

static char userDict[MAX_PATH] = {0};
static char learner[MAX_PATH] = {0};
static char corrector[MAX_PATH] = {0};

jint Java_com_phatware_android_RecoInterface_WritePadAPI_recognizerInit( JNIEnv* env, jobject thiz, jstring jpath, jint nLanguage ) 
{
	char userDict[MAX_PATH];
	char mainDict[MAX_PATH];
	char learner[MAX_PATH];
	char corrector[MAX_PATH];

    jboolean isCopy = JNI_FALSE;
	const jbyte * path = (*env)->GetStringUTFChars(env, jpath, &isCopy);

	userDict[0] = 0;
	learner[0] = 0;
	corrector[0] = 0;
	if (path != NULL) 
    {
		strcpy(_szPath, path);
		strcat(_szPath, "/");
		strcpy(userDict, _szPath);
		strcpy(learner, _szPath);
		strcpy(corrector, _szPath);
		// strcpy(mainDict, _szPath);
	}
	strcat(userDict, USER_DICTIONARY);
	strcat(learner, USER_STATISTICS);
	strcat(corrector, USER_CORRECTOR);

    
    if ( ! HWR_IsLanguageSupported( nLanguage ) )
        nLanguage = LANGUAGE_ENGLISH;
	/*
    strcpy( mainDict, "assets/" );
    switch ( nLanguage )
    {
    	default :
        case LANGUAGE_ENGLISH :
            strcat( mainDict, "English.dct" );
            break;
            
        case LANGUAGE_GERMAN :
            strcat( mainDict, "German.dct" );
            break;
            
        case LANGUAGE_FRENCH :
            strcat( mainDict, "French.dct" );
            break;
            
        case LANGUAGE_ITALIAN :
            strcat( mainDict, "Italian.dct" );
            break;
            
        case LANGUAGE_SPANISH :
            strcat( mainDict, "Spanish.dct" );
            break;
            
        case LANGUAGE_SWEDISH :
            strcat( mainDict, "Swedish.dct" );
            break;
            
        case LANGUAGE_NORWEGIAN :
            strcat( mainDict, "Norwegian.dct" );
            break;
            
        case LANGUAGE_DUTCH :
            strcat( mainDict, "Dutch.dct" );
            break;
            
        case LANGUAGE_DANISH :
            strcat( mainDict, "Danish.dct" );
            break;
            
        case LANGUAGE_PORTUGUESE :
            strcat( mainDict, "Portuguese.dct" );
            break;
            
        case LANGUAGE_PORTUGUESEB :
            strcat( mainDict, "Brazilian.dct" );
            break;
            
        case LANGUAGE_FINNISH :
            strcat( mainDict, "Finnish.dct" );
            break;

        case LANGUAGE_INDONESIAN :
            strcat( mainDict, "Indonesian.dct" );
            break;
    }
    */
    if ( isCopy == JNI_TRUE && path )
        (*env)->ReleaseStringUTFChars(env, jpath, path);

	int flags = -1;

	_recognizer = HWR_InitRecognizer(NULL, userDict, learner, corrector, nLanguage, &flags);
	if (NULL == _recognizer)
		return -1;

	_inkData = INK_InitData();
	if (NULL == _inkData)
		return -1;
	_currentStroke = -1;
	return flags;
}

jboolean  Java_com_phatware_android_RecoInterface_WritePadAPI_resetLearner( JNIEnv* env)
{
	if (_recognizer != NULL && _szPath[0] != 0 )
    {
		char learner[MAX_PATH];
		learner[0] = 0;
		strcpy(learner, _szPath);
		strcat(learner, USER_STATISTICS);
		return HWR_ResetLearner(_recognizer, learner);
	}
	return false;
}

jboolean  Java_com_phatware_android_RecoInterface_WritePadAPI_reloadLearner( JNIEnv* env)
{
	if (_recognizer != NULL  && _szPath[0] != 0 )
    {
		char learner[MAX_PATH];
		learner[0] = 0;
		strcpy(learner, _szPath);
		strcat(learner, USER_STATISTICS);
		return HWR_ReloadLearner(_recognizer, learner);
	}
	return false;
}

jboolean Java_com_phatware_android_RecoInterface_WritePadAPI_saveLearner( JNIEnv* env)
{
	if (_recognizer != NULL  && _szPath[0] != 0 )
    {
		char learner[MAX_PATH];
		learner[0] = 0;
		strcpy(learner, _szPath);
		strcat(learner, USER_STATISTICS);
		return HWR_SaveLearner(_recognizer, learner);
	}
	return false;
}


jboolean Java_com_phatware_android_RecoInterface_WritePadAPI_resetAutocorrector( JNIEnv* env) 
{
	if (_recognizer != NULL  && _szPath[0] != 0 )
    {
		char corrector[MAX_PATH];
		corrector[0] = 0;
		strcpy(corrector, _szPath);
		strcat(corrector, USER_CORRECTOR);
		return HWR_ResetAutoCorrector(_recognizer, corrector);
	}
	return false;
}


jboolean Java_com_phatware_android_RecoInterface_WritePadAPI_reloadAutocorrector( JNIEnv* env) 
{
	if (_recognizer != NULL && _szPath[0] != 0 )
    {
		char corrector[MAX_PATH];
		corrector[0] = 0;
		strcpy(corrector, _szPath);
		strcat(corrector, USER_CORRECTOR);
		return HWR_ReloadAutoCorrector(_recognizer, corrector);
	}
	return false;
}

jboolean Java_com_phatware_android_RecoInterface_WritePadAPI_saveWordList( JNIEnv* env)
{
	if (_recognizer != NULL && _szPath[0] != 0 )
    {
		char corrector[MAX_PATH];
		corrector[0] = 0;
		strcpy(corrector, _szPath);
		strcat(corrector, USER_CORRECTOR);

		return HWR_SaveWordList(_recognizer, corrector);
	}
	return false;
}

jboolean Java_com_phatware_android_RecoInterface_WritePadAPI_resetUserDict( JNIEnv* env) 
{
	if (_recognizer != NULL && _szPath[0] != 0 )
    {
		char userDict[MAX_PATH];
		userDict[0] = 0;
		strcpy(userDict, _szPath);
		strcat(userDict, USER_DICTIONARY);

		return HWR_ResetUserDict(_recognizer, userDict);
	}
	return false;
}


jboolean Java_com_phatware_android_RecoInterface_WritePadAPI_reloadUserDict( JNIEnv* env)
{
	if (_recognizer != NULL && _szPath[0] != 0 )
    {
		char userDict[MAX_PATH];
		userDict[0] = 0;
		strcpy(userDict, _szPath);
		strcat(userDict, USER_STATISTICS);
		return HWR_ReloadUserDict(_recognizer, userDict);
	}
	return false;
}

jboolean Java_com_phatware_android_RecoInterface_WritePadAPI_isPointStroke( JNIEnv* env, jobject thiz, jint nStroke )
{
	if ( _inkData != NULL )
	{
		CGRect rect = {0,0,0,0};
		if ( nStroke < 0 )
			nStroke = INK_StrokeCount( _inkData, false ) - 1;
		if ( nStroke < 0 )
			return false;
		if ( INK_GetStrokeRect( _inkData, nStroke, &rect, false) )
		{
			if ( rect.size.width <= 2 && rect.size.height <= 2 )
				return true;
		}
	}
	return false;
}

jint Java_com_phatware_android_RecoInterface_WritePadAPI_checkStrokeNewLine( JNIEnv* env, jobject thiz, jint nStroke )
{
	int result = GEST_NONE;
	if ( _inkData != NULL )
	{
		CGRect rect = {0,0,0,0};
		CGStroke pStroke = NULL;
		float		width = 2.0f;

		if ( nStroke < 0 )
			nStroke = INK_StrokeCount( _inkData, false ) - 1;
		if ( nStroke < 0 )
			return -1;
		if ( ! INK_GetStrokeRect( _inkData, nStroke, &rect, false) )
			return -1;
		int len = INK_GetStrokeP( _inkData, nStroke, &pStroke, &width, NULL);
		if (len > 5)
		{
			result = HWR_CheckGesture( GEST_DELETE, pStroke, len, 1, 5 );
		}
		if (pStroke != NULL)
			free((void *) pStroke);
		if ( result == GEST_DELETE )
			return 0;
		if ( rect.size.width < width && rect.size.height < width )
			return 0;
		if ( rect.size.width > 2.0f * rect.size.height && rect.size.height <= 2.0f * width )
			return 0;
		
		int xx = (int)rect.origin.x;
		int yy = (int)rect.origin.y;		
		return (jint)((xx & 0xffff) | ((yy << 16) &0xffff0000));
	}
	return 0;
}

jboolean Java_com_phatware_android_RecoInterface_WritePadAPI_saveUserDict( JNIEnv* env)
{
	if (_recognizer != NULL) {
		char userDict[MAX_PATH];
		userDict[0] = 0;
		strcpy(userDict, _szPath);
		strcat(userDict, USER_DICTIONARY);
		return HWR_SaveUserDict(_recognizer, userDict);
	}
	return false;
}


jboolean Java_com_phatware_android_RecoInterface_WritePadAPI_setDictionaryData(
		JNIEnv* env, jobject thiz, jbyteArray buff, jint flag ) 
{
	jbyte * data = NULL;
	jboolean result = false;
	if (_recognizer == NULL)
		return false;

    jboolean isCopy = JNI_FALSE;
	data = (*env)->GetByteArrayElements(env, buff, &isCopy);
	if (data != NULL)
    {
		result = HWR_SetDictionaryData(_recognizer, data, flag );
        if ( isCopy == JNI_TRUE )
            (*env)->ReleaseByteArrayElements(env, buff, data, JNI_ABORT);
	}
	return result;
}

void Java_com_phatware_android_RecoInterface_WritePadAPI_freeRecognizer( JNIEnv* env)
{
	if (_recognizer != NULL)
    {
        if ( _szPath[0] == 0 )
        {
            HWR_FreeRecognizer(_recognizer, NULL, NULL, NULL );
        }
        else
        {
            char userDict[MAX_PATH];
            char learner[MAX_PATH];
            char corrector[MAX_PATH];

            userDict[0] = 0;
            learner[0] = 0;
            corrector[0] = 0;
            strcpy(userDict, _szPath);
            strcpy(learner, _szPath);
            strcpy(corrector, _szPath);
            strcat(userDict, USER_DICTIONARY);
            strcat(learner, USER_STATISTICS);
            strcat(corrector, USER_CORRECTOR);

            HWR_FreeRecognizer(_recognizer, userDict, learner, corrector);
        }
		_recognizer = NULL;
	}
	if (_inkData != NULL)
    {
		INK_FreeData(_inkData);
		_inkData = NULL;
	}
	_currentStroke = -1;
}

jint  Java_com_phatware_android_RecoInterface_WritePadAPI_getRecognizerFlags( JNIEnv * env)
{
	jint result = 0;
	if (_recognizer != NULL) {
		result = HWR_GetRecognitionFlags(_recognizer);
	}
	return result;
}

void Java_com_phatware_android_RecoInterface_WritePadAPI_setRecognizerFlags( JNIEnv * env, jobject thiz, jint flags)
{
	if (_recognizer != NULL) {
            HWR_SetRecognitionFlags(_recognizer, (unsigned int) flags);
	}
}


jint Java_com_phatware_android_RecoInterface_WritePadAPI_getRecognizerMode( JNIEnv * env) 
{
	jint result = 0;
	if (_recognizer != NULL) {
		result = HWR_GetRecognitionMode(_recognizer);
	}
	return result;
}

void Java_com_phatware_android_RecoInterface_WritePadAPI_setRecognizerMode( JNIEnv * env, jobject thiz, jint mode)
{
	if (_recognizer != NULL) {
		HWR_SetRecognitionMode(_recognizer, mode);
	}
}

void Java_com_phatware_android_RecoInterface_WritePadAPI_stopRecognizer( JNIEnv* env)
{
	if (_recognizer != NULL) {
		HWR_StopAsyncReco(_recognizer);
	}
}

// Detect new line 

static BOOL isNewLine( CGRect rLastWord, CGRect rPrevWord )
{
    //  If the coordinates of the current word are below and to the left comparing to coordinates of the previous word
    // we assume that this is new line. Conditions can be changed, if needed
    if ( rLastWord.origin.y > rPrevWord.origin.y + rPrevWord.size.height && rPrevWord.size.width + rPrevWord.origin.x > rLastWord.origin.x )
        return true;
    return false;
}

// if bNewLine is true, new line will be automatically recognized in the handwritten text

jstring Java_com_phatware_android_RecoInterface_WritePadAPI_recognizeInkData(
	JNIEnv* env, jobject thiz, jint nDataLen, jboolean bAsync, jboolean bFlipY, jboolean bSort )
{
	jstring result = NULL;
	const UCHR * recognizedText = NULL;
	if (_recognizer == NULL || _inkData == NULL || INK_StrokeCount(_inkData, false) < 1)
		return NULL;
	INK_DATA_PTR inkCopy = NULL;
	if (bAsync)
    {
		// create ink copy before starting recognizer.
		inkCopy = INK_CreateCopy(_inkData);
	}
	recognizedText = HWR_RecognizeInkData(_recognizer,
                                          (inkCopy == NULL) ? _inkData : inkCopy,
                                          0, nDataLen, bAsync, bFlipY,
                                          bSort, false);
    if (NULL != inkCopy)
    {
		INK_FreeData(inkCopy);
		inkCopy = NULL;
	}
	if (recognizedText == NULL || *recognizedText == 0)
		return NULL;

	result = StringToJstring(env, recognizedText);
	if ((long) result == (-1))
		return NULL;
	return result;
}

jboolean Java_com_phatware_android_RecoInterface_WritePadAPI_preRecognizeInkData( JNIEnv* env, jobject thiz, jint nDataLen) 
{
	const char * recognizedText = NULL;
	if (_recognizer == NULL || _inkData == NULL || INK_StrokeCount(_inkData,
			false) < 1)
		return false;
	return HWR_PreRecognizeInkData(_recognizer, _inkData, nDataLen, false);
}

jboolean Java_com_phatware_android_RecoInterface_WritePadAPI_newStroke( JNIEnv * env, jobject thiz, jfloat width, jint color)
{
	jint result = -1;
	if (NULL != _inkData) {
		result = INK_AddEmptyStroke(_inkData, width, (COLORREF) color);
	}
	_currentStroke = (int) result;
	return result;
}


jint Java_com_phatware_android_RecoInterface_WritePadAPI_getStrokeCount( JNIEnv * env) 
{
	jint result = -1;
	if (NULL != _inkData) {
		result = INK_StrokeCount(_inkData, false);
	}
	return result;
}

jboolean Java_com_phatware_android_RecoInterface_WritePadAPI_deleteLastStroke( JNIEnv * env) 
{
	jboolean result = false;
	if (NULL != _inkData) {
		result = INK_DeleteStroke(_inkData, -1);
	}
	return result;
}


jboolean Java_com_phatware_android_RecoInterface_WritePadAPI_deleteStroke( JNIEnv * env, jobject thiz, jint nStroke )
{
	jboolean result = false;
	if (NULL != _inkData) {
		result = INK_DeleteStroke(_inkData, nStroke );
	}
	return result;
}

jint Java_com_phatware_android_RecoInterface_WritePadAPI_detectGesture( JNIEnv* env, jobject thiz, jint type) 
{
	jint result = GEST_NONE;

	if (NULL != _inkData) {
		int nCnt = INK_StrokeCount(_inkData, false);
		if (nCnt > 0) {
			CGStroke pStroke = NULL;
			int len = INK_GetStrokeP(_inkData, nCnt - 1, &pStroke, NULL, NULL);
			if (len > 5) {
				result = HWR_CheckGesture((GESTURE_TYPE) type, pStroke, len, 1, 160);
			}
			if (pStroke != NULL)
				free((void *) pStroke);
		}
	}
	return result;
}

jint Java_com_phatware_android_RecoInterface_WritePadAPI_addPixelToStroke(
                                JNIEnv * env, jobject thiz, jint stroke, jfloat x, jfloat y)
{
	jint result = -1;
	if (NULL != _inkData) {
        int pressure = DEFAULT_PRESSURE;
		result = INK_AddPixelToStroke(_inkData, stroke, x, y, pressure );
	}
	return result;
}


jboolean Java_com_phatware_android_RecoInterface_WritePadAPI_resetRecognizer(JNIEnv * env) 
{
	if (NULL != _recognizer) {
		HWR_Reset(_recognizer);
		return true;
	}
	return false;
}

jboolean Java_com_phatware_android_RecoInterface_WritePadAPI_resetInkData(JNIEnv * env)
{
	if (NULL != _inkData) {
		INK_Erase(_inkData);
		_currentStroke = -1;
		return true;
	}
	return false;
}

jstring Java_com_phatware_android_RecoInterface_WritePadAPI_languageName(JNIEnv* env, jobject thiz) 
{
	jstring result = NULL;
    if (NULL != _recognizer) {
        result = (*env)->NewStringUTF(env, HWR_GetLanguageName(_recognizer));
    }
	return result;
}

jint Java_com_phatware_android_RecoInterface_WritePadAPI_languageID( JNIEnv * env) 
{
    if (NULL != _recognizer) {
        return HWR_GetLanguageID(_recognizer);
    }
    return 0;
}

                                                          
jboolean Java_com_phatware_android_RecoInterface_WritePadAPI_newUserDict(JNIEnv * env) 
{
	if (NULL != _recognizer) {
		return HWR_NewUserDict(_recognizer);
	}
	return false;
}


jboolean Java_com_phatware_android_RecoInterface_WritePadAPI_addWordToUserDict( JNIEnv * env, jobject thiz, jstring jword) 
{
	jboolean result = false;
	if (NULL != _recognizer)
    {
		const UCHR * strWord = JstringToString(env, jword);
		if (strWord != NULL) {
			result = HWR_AddUserWordToDict(_recognizer, strWord, true);
			free((void *) strWord);
		}
	}
	return result;
}


jboolean Java_com_phatware_android_RecoInterface_WritePadAPI_resetResult( JNIEnv * env, jobject thiz)
{
	jboolean result = false;
	if (NULL != _recognizer) {
		result = HWR_EmptyWordList(_recognizer);
	}
	return result;
}

jboolean Java_com_phatware_android_RecoInterface_WritePadAPI_isWordInDict(JNIEnv * env, jobject thiz, jstring jword) 
{
	jboolean result = false;
	if (_recognizer != NULL) {
		const UCHR * word = JstringToString(env, jword);
		if (word != NULL) {
			result = HWR_IsWordInDict(_recognizer, word);
			free((void *) word);
		}
	}
	return result;
}

jint Java_com_phatware_android_RecoInterface_WritePadAPI_getResultColumnCount(JNIEnv * env, jobject thiz) 
{
	jint result = 0;
	if (NULL != _recognizer) {
		result = HWR_GetResultWordCount(_recognizer);
	}
	return result;
}
                                                                
jint Java_com_phatware_android_RecoInterface_WritePadAPI_getResultRowCount(JNIEnv * env, jobject thiz, jint col) 
{
	jint result = 0;
	if (NULL != _recognizer) {
		result = HWR_GetResultAlternativeCount(_recognizer, col);
	}
	return result;
}


jstring Java_com_phatware_android_RecoInterface_WritePadAPI_getRecognizedWord(JNIEnv * env, jobject thiz, jint col, jint row) 
{
	jstring result = NULL;
	if (NULL != _recognizer)
    {
		const UCHR * word = HWR_GetResultWord(_recognizer, col, row);
		if (word != NULL)
        {
			result = StringToJstring(env, word);
			if ((long) result == (-1))
			{
			    result = NULL;
			}
		}
	}
	return result;
}




jstring Java_com_phatware_android_RecoInterface_WritePadAPI_getAutocorrectorWord( JNIEnv * env, jobject thiz, jstring inWord)
{
	jstring result = NULL;
	if (_recognizer != NULL)
    {
		const UCHR * word = JstringToString(env, inWord);
		if (word != NULL)
        {
			const UCHR * outWord = HWR_AutocorrectWord(_recognizer, word);
			if (NULL != outWord)
            {
				result = StringToJstring(env, outWord);
				if ((long) result == (-1))
					result = NULL;
			}
			free((void *) word);
		}
	}
	return result;
}

jint Java_com_phatware_android_RecoInterface_WritePadAPI_getRecognizedWeight( JNIEnv * env, jobject thiz, jint col, jint row)
{
	jint result = 0;
	if (NULL != _recognizer) {
		result = HWR_GetResultWeight(_recognizer, col, row);
	}
	return result;
}

jint Java_com_phatware_android_RecoInterface_WritePadAPI_getResultStrokesNumber( JNIEnv * env, jobject thiz, jint col, jint row)
{
	jint result = 0;
	if (NULL != _recognizer) {
		result = HWR_GetResultStrokesNumber(_recognizer, col, row);
	}
	return result;
}

jboolean Java_com_phatware_android_RecoInterface_WritePadAPI_learnerAddNewWord( JNIEnv * env, jobject thiz, jstring jword, jint weight) 
{
	jboolean result = false;
	if (NULL != _recognizer) {
		const UCHR * word = JstringToString(env, jword);
		if (word != NULL) {
			result = HWR_LearnNewWord(_recognizer, word, weight);
			free((void *) word);
		}
	}
	return result;
}


jboolean Java_com_phatware_android_RecoInterface_WritePadAPI_learnerReplaceWord( 
        JNIEnv * env, jobject thiz, jstring jword1, jint weight1, jstring jword2, jint weight2) 
{
	jboolean result = false;
	if (NULL != _recognizer) {
		const UCHR * word1 = JstringToString(env, jword1);
		const UCHR * word2 = JstringToString(env, jword2);
		if (word1 != NULL && word2 != NULL) {
			result = HWR_ReplaceWord(_recognizer, word1, weight1, word2,
					weight2);
			free((void *) word1);
			free((void *) word2);
		}
	}
	return result;
}


jboolean Java_com_phatware_android_RecoInterface_WritePadAPI_autocorrectorLearnWord(
            JNIEnv * env, jobject thiz, jstring jword1, jstring jword2, jint flags, jboolean bReplace) 
{
	jboolean result = false;
	if (NULL != _recognizer) {
		const UCHR * word1 = JstringToString(env, jword1);
		const UCHR * word2 = JstringToString(env, jword2);
		if (word1 != NULL && word2 != NULL) {
			result = HWR_AddWordToWordList(_recognizer, word1, word2, flags,
					bReplace);
			free((void *) word1); 
			free((void *) word2);
		}
	}
	return result;
}


jstring Java_com_phatware_writepad_WritePadAPI_spellCheckWord(JNIEnv * env, jobject thiz, jstring jword, jboolean showlist )
{
    const UCHR * strWord = JstringToString(env, jword);
    if (strWord == NULL)
    {
        return jword;
    }
	jstring newWordFrom = NULL;
	UCHR * pWordList = malloc( MAX_STRING_BUFFER );
    if ( NULL != pWordList )
    {
        memset( pWordList, 0, MAX_STRING_BUFFER );
        
        int flag = (showlist) ? HW_SPELL_LIST : 0;
        if ( HWR_SpellCheckWord( _recognizer, strWord, pWordList, MAX_STRING_BUFFER - 1, flag ) == 0 )
        {
            newWordFrom = StringToJstring(env, &pWordList[0]);
        }
        free( (void *) pWordList );
        free((void *) strWord);
    }
    if ( newWordFrom == NULL )
        return jword;
    return newWordFrom;
}

jboolean  Java_com_phatware_android_RecoInterface_WritePadAPI_exportWordList(JNIEnv* env, jobject thiz, jstring pExportFile)
{
    jboolean result = false;
	if (_recognizer != NULL)
    {
        jboolean isCopy = JNI_FALSE;
    	const char *fileName = (*env)->GetStringUTFChars(env, pExportFile, &isCopy);
		result = HWR_ExportWordList(_recognizer, fileName);
        if ( fileName && isCopy == JNI_TRUE)
            (*env)->ReleaseStringUTFChars(env, pExportFile, fileName);
	}
	return result;
}

jboolean Java_com_phatware_android_RecoInterface_WritePadAPI_exportUserDictionary(JNIEnv* env, jobject thiz, jstring pExportFile)
{
    jboolean result = false;
	if (_recognizer != NULL)
    {
        jboolean isCopy = JNI_FALSE;
    	const char *fileName = (*env)->GetStringUTFChars(env, pExportFile, &isCopy );
		result = HWR_ExportUserDictionary(_recognizer, fileName);
        if ( fileName && isCopy == JNI_TRUE)
            (*env)->ReleaseStringUTFChars(env, pExportFile, fileName);
	}
	return result;
}

jboolean Java_com_phatware_android_RecoInterface_WritePadAPI_importWordList(JNIEnv* env, jobject thiz, jstring pImportFile)
{
    jboolean result = false;
	if (_recognizer != NULL)
    {
        jboolean isCopy = JNI_FALSE;
    	const char *fileName = (*env)->GetStringUTFChars(env, pImportFile, &isCopy);
		result = HWR_ImportWordList(_recognizer, fileName);
        if ( fileName && isCopy == JNI_TRUE)
            (*env)->ReleaseStringUTFChars(env, pImportFile, fileName);
	}
	return result;
}

jboolean Java_com_phatware_android_RecoInterface_WritePadAPI_importUserDictionary(JNIEnv* env, jobject thiz, jstring pImportFile)
{
    jboolean result = false;
	if (_recognizer != NULL)
    {
        jboolean isCopy = JNI_FALSE;
    	const char *fileName = (*env)->GetStringUTFChars( env, pImportFile, &isCopy);
		result = HWR_ImportUserDictionary(_recognizer, fileName);
        if ( fileName && isCopy == JNI_TRUE)
            (*env)->ReleaseStringUTFChars(env, pImportFile, fileName);
	}
	return result;
}

/* ************************************************************************** */
/* *   JNI SUPPORT FUNCTIONS                                                * */
/* ************************************************************************** */

static const char *kInterfacePath = "com/phatware/android/RecoInterface/WritePadAPI";
static JavaVM* gJavaVM = NULL;
static jobject gInterfaceObject = NULL;

static int status = -1;
static int isAttached = 0;

static jclass interfaceClass = NULL;
static jmethodID method = NULL;

int EnumWordListCallback(const UCHR * szWordFrom, const UCHR * szWordTo, unsigned int nFlags, void * pParam)
{
	JNIEnv *env;
	isAttached = 0;

	status = (*gJavaVM)->GetEnv(gJavaVM, (void **) &env, JNI_VERSION_1_4);
	if (status < 0) {
		status = (*gJavaVM)->AttachCurrentThread(gJavaVM, &env, NULL);
		if (status < 0) {
			return;
		}
		isAttached = 1;
	}
    if (interfaceClass  == NULL){
	    interfaceClass = (*env)->GetObjectClass(env, gInterfaceObject);
	}

	if (!interfaceClass) {
		// __android_log_print(ANDROID_LOG_INFO, "callback_handler"," failed to get class reference");
		if (isAttached == 1)
			(*gJavaVM)->DetachCurrentThread(gJavaVM);
		return;
	}
	/* Find the callBack method ID */

	if (method == NULL)
	{
	    method = (*env)->GetStaticMethodID(env, interfaceClass, "onEnumWord", "(Ljava/lang/String;Ljava/lang/String;I)V");
	}

	if (!method) {
		// __android_log_print(ANDROID_LOG_INFO, "callback_handler"," failed to get method ID");
		if (isAttached == 1) {
			(*gJavaVM)->DetachCurrentThread(gJavaVM);
		}
		return;
	}

    jstring newWordFrom = StringToJstring(env, szWordFrom);
    jstring newWordTo = StringToJstring(env, szWordTo);

    (*env)->CallStaticVoidMethod(env, interfaceClass, method, newWordFrom, newWordTo, nFlags);
    (*env)->DeleteLocalRef(env, newWordFrom);
    (*env)->DeleteLocalRef(env, newWordTo);

	if (isAttached == 1) {
		(*gJavaVM)->DetachCurrentThread(gJavaVM);
	}

	return 1;
}

int EnumUserWordsCallback(const UCHR * szWord, void * pParam)
{
	JNIEnv *env;
	isAttached = 0;

	status = (*gJavaVM)->GetEnv(gJavaVM, (void **) &env, JNI_VERSION_1_4);
	if (status < 0) {
		// __android_log_print(ANDROID_LOG_INFO, "callback_handler: failed to get JNI environment, assuming native thread");
		status = (*gJavaVM)->AttachCurrentThread(gJavaVM, &env, NULL);
		if (status < 0) {
			// __android_log_print(ANDROID_LOG_INFO, "callback_handler: failed to attach ", "current thread");
			return;
		}
		isAttached = 1;
	}
    if (interfaceClass == NULL){
	    interfaceClass = (*env)->GetObjectClass(env, gInterfaceObject);
	}

	if (!interfaceClass) {
		// __android_log_print(ANDROID_LOG_INFO, "callback_handler"," failed to get class reference");
		if (isAttached == 1)
			(*gJavaVM)->DetachCurrentThread(gJavaVM);
		return;
	}

	if (method == NULL)
	{
	    method = (*env)->GetStaticMethodID(env, interfaceClass, "onEnumUserWords", "(Ljava/lang/String;)V");
	}

	if (!method) {
		// __android_log_print(ANDROID_LOG_INFO, "callback_handler"," failed to get method ID");
		if (isAttached == 1) {
			(*gJavaVM)->DetachCurrentThread(gJavaVM);
		}
		return;
	}

    jstring newWord = StringToJstring(env, szWord);
    (*env)->CallStaticVoidMethod(env, interfaceClass, method, newWord);
    (*env)->DeleteLocalRef(env, newWord);

	if (isAttached == 1) {
		(*gJavaVM)->DetachCurrentThread(gJavaVM);
	}

	return 1;
}

jint Java_com_phatware_android_RecoInterface_WritePadAPI_getEnumUserWordsList( JNIEnv * env, jobject thiz, void * param) 
{
	jint result = 0;
	if (NULL != _recognizer) {
        interfaceClass = NULL;
        method = NULL;
		result = HWR_EnumUserWords(_recognizer, EnumUserWordsCallback, param);
	}
	return result;
}

jint Java_com_phatware_android_RecoInterface_WritePadAPI_getEnumWordList( JNIEnv * env, jobject thiz, void * param) 
{
	jint result = 0;
	if (NULL != _recognizer) {
        interfaceClass = NULL;
        method = NULL;
		result = HWR_EnumWordList(_recognizer, EnumWordListCallback, param);
	}
	return result;
}

void initClassHelper(JNIEnv *env, const char *path, jobject *objptr) {
	jclass cls = (*env)->FindClass(env, path);
	if (!cls) {
		// __android_log_print(ANDROID_LOG_INFO, "initClassHelper: failed to get %s class reference", path);
		return;
	}
	jmethodID constr = (*env)->GetMethodID(env, cls, "<init>", "()V");
	if (!constr) {
		// __android_log_print(ANDROID_LOG_INFO, "initClassHelper: failed to get %s constructor", path);
		return;
	}
	jobject obj = (*env)->NewObject(env, cls, constr);
	if (!obj) {
		// __android_log_print(ANDROID_LOG_INFO, "initClassHelper: failed to create a %s object", path);
		return;
	}
	(*objptr) = (*env)->NewGlobalRef(env, obj);
}

jint JNI_OnLoad(JavaVM* vm, void* reserved)
{
	JNIEnv *env;
	gJavaVM = vm;
	if ((*vm)->GetEnv(vm, (void**) &env, JNI_VERSION_1_4) != JNI_OK)
    {
		// __android_log_print(ANDROID_LOG_INFO, "(Failed"," to get the environment using GetEnv()");
		return -1;
	}

	initClassHelper(env, kInterfacePath, &gInterfaceObject);
	return JNI_VERSION_1_4;
}



