/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                           * */
/* ************************************************************************************* */

/* ************************************************************************************* *
*
* Unauthorized distribution of this code is prohibited. For more information
* refer to the End User Software License Agreement provided with this
* software.
*
* This source code is distributed and supported by PhatWare Corp.
* http://www.phatware.com
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
* 530 Showers Drive Suite 7 #333 Mountain View, CA 94040
*
* ************************************************************************************* */

#include <stdio.h>

#include <string.h>
#include <string>
#include <stdlib.h>
#include <math.h>
#include <Windows.h>
#include "../../include/RecognizerWrapper.h"
#include "../../include/InkWrapper.h"
#include "LanguageManager.h"
#include <Objbase.h>

/// <summary>
/// Return a string to managed code which will be automatically released by the .net framework. 
/// </summary>

TCHAR* AllocString(const TCHAR* string)
{
	if (string == nullptr)
		string = L"<--->";
	size_t stSize = wcslen(string) + sizeof(TCHAR);
	TCHAR* pszReturn = NULL;

	pszReturn = (TCHAR*)::CoTaskMemAlloc(stSize*sizeof(TCHAR));
	wcscpy_s(pszReturn, stSize, string);
	return pszReturn;
}

static RECOGNIZER_PTR	_recognizer = NULL;
static INK_DATA_PTR		inkData = NULL;

static RECOGNIZER_PTR _recognizerSearch = NULL;
static TCHAR * _searchWord = NULL;


#define MIN(a,b)    (((a) < (b)) ? (a) : (b))

/// <summary>
/// kEmptyWord is returned when recognition fails.
/// </summary>
#undef kEmptyWord
#define kEmptyWord		L"<--->" 
#ifndef FALSE
#define FALSE 0
#endif
#ifndef TRUE
#define TRUE 1
#endif

static CLanguageManager languageManager(LANGUAGE_ENGLISH);
extern "C" __declspec(dllexport) int saveRecognizerDataOfType(int type);

extern "C" __declspec(dllexport) void releaseRecognizer()
{
	if (_recognizer == NULL)
		return;

	char strUserDict[_MAX_PATH];
	char strLearner[_MAX_PATH];
	char strCorrector[_MAX_PATH];

	sprintf_s(strUserDict, _MAX_PATH, "%s\\%s", languageManager.userPath(), languageManager.userFileNameOfType(USERDATA_DICTIONARY));
	sprintf_s(strLearner, _MAX_PATH, "%s\\%s", languageManager.userPath(), languageManager.userFileNameOfType(USERDATA_LEARNER));
	sprintf_s(strCorrector, _MAX_PATH, "%s\\%s", languageManager.userPath(), languageManager.userFileNameOfType(USERDATA_AUTOCORRECTOR));

	HWR_FreeRecognizer(_recognizer, strUserDict, strLearner, strCorrector);
	_recognizer = NULL;
}

/// <summary>
/// Enumeration callback for autocorrect dictionary. Generates a string of triples (word from, word to, flags) delimited by \x001 symbols.
/// </summary>

extern  int EnumWordListCallback(const UCHR * pszWordFrom, const UCHR * pszWordTo, int flags, void * pParam)
{
	((std::wstring*)pParam)->append((TCHAR*) pszWordFrom);
	((std::wstring*)pParam)->append(L"\x001");

	((std::wstring*)pParam)->append((TCHAR*) pszWordTo);
	((std::wstring*)pParam)->append(L"\x001");

	((std::wstring*)pParam)->append(std::to_wstring(flags));
	((std::wstring*)pParam)->append(L"\x001");

	return 1;
}

/// <summary>
/// Enumeration callback for user dictionary. Generates a string delimited by \x001 symbols.
/// </summary>

extern int EnumUserWordCallback(const UCHR * pszWord, const UCHR * szWordTo, int nFlags, void* pParam)
{
	((std::wstring*)pParam)->append((TCHAR*) pszWord);
	((std::wstring*)pParam)->append(L"\x001");

	return 1;
}

extern "C" __declspec(dllexport) void* getRecoHandle()
{
	return _recognizer;
}

extern "C" __declspec(dllexport) const TCHAR* getAutocorrectorWords()
{
	std::wstring pParam = L"";
	HWR_EnumWordList(_recognizer, (RECO_ONGOTWORDLIST*)EnumWordListCallback, &pParam);
	return AllocString(pParam.c_str());
}

extern "C" __declspec(dllexport) const TCHAR* getUserWords()
{
	std::wstring pParam = L"";
	HWR_EnumUserWords(_recognizer, (PRECO_ONGOTWORD) EnumUserWordCallback, &pParam);
	return AllocString(pParam.c_str());
}

/// <summary>
/// Initialize dictionary. This should be called before recognizing any strokes.
/// </summary>
extern "C" __declspec(dllexport) int initRecognizerForLanguage(int language, const char * userpath, const char* apppath, unsigned int recoflags)
{
	if (_recognizer != NULL)
	{
		if (language == languageManager.getLanguageID())
		{
			HWR_Reset(_recognizer);
			if (recoflags != 0)
				HWR_SetRecognitionFlags(_recognizer, recoflags);
			return 0;
		}
		releaseRecognizer();
	}

	languageManager.setUserPath(userpath);
	languageManager.setLanguage(language);

	char strUserDict[_MAX_PATH];
	char strLearner[_MAX_PATH];
	char strCorrector[_MAX_PATH];
	char strMainDictFullPath[_MAX_PATH];
	const char *	strMainDict = languageManager.mainDictionaryName();

	sprintf_s(strUserDict, _MAX_PATH, "%s\\%s", userpath, languageManager.userFileNameOfType(USERDATA_DICTIONARY));
	sprintf_s(strLearner, _MAX_PATH, "%s\\%s", userpath, languageManager.userFileNameOfType(USERDATA_LEARNER));
	sprintf_s(strCorrector, _MAX_PATH, "%s\\%s", userpath, languageManager.userFileNameOfType(USERDATA_AUTOCORRECTOR));
	sprintf_s(strMainDictFullPath, _MAX_PATH, "%s\\%s", apppath, strMainDict);

	int 	flags = 0;
	_recognizer = HWR_InitRecognizer(strMainDictFullPath, strUserDict, strLearner, strCorrector, language, &flags);
	if (NULL != _recognizer)
	{
		if ((flags & FLAG_CORRECTOR) == 0)
			printf("Warning: autocorrector did not initialize.\n");
		if ((flags & FLAG_ANALYZER) == 0)
			printf("Warning: statistical analyzer (learner) did not initialize.\n");
		if ((flags & FLAG_USERDICT) == 0)
			printf("Warning: user dictionary did not initialize.\n");
		if ((flags & FLAG_MAINDICT) == 0)
			printf("Warning: main dictionary did not initialize.\n");

		return (NULL != _recognizer) ? flags : -1;
	}
	return -1;
}


extern "C" __declspec(dllexport) int saveRecognizerDataOfType(int type)
{
	if (_recognizer == NULL)
		return 0;
	char strUserDict[_MAX_PATH];
	char strLearner[_MAX_PATH];
	char strCorrector[_MAX_PATH];

	if (0 != (type & USERDATA_AUTOCORRECTOR))
	{
		sprintf_s(strCorrector, _MAX_PATH, "%s\\%s", languageManager.userPath(), languageManager.userFileNameOfType(USERDATA_AUTOCORRECTOR));
		return HWR_SaveWordList(_recognizer, strCorrector);
	}
	if (0 != (type & USERDATA_LEARNER))
	{
		sprintf_s(strLearner, _MAX_PATH, "%s\\%s", languageManager.userPath(), languageManager.userFileNameOfType(USERDATA_LEARNER));
		return HWR_SaveLearner(_recognizer, strLearner);
	}
	if (0 != (type & USERDATA_DICTIONARY) || type == 0)
	{
		sprintf_s(strUserDict, _MAX_PATH, "%s\\%s", languageManager.userPath(), languageManager.userFileNameOfType(USERDATA_DICTIONARY));
		return HWR_SaveUserDict(_recognizer, strUserDict);
	}
	return 0;
}

extern "C" __declspec(dllexport) void modifyRecoFlags(unsigned int addFlags, unsigned int delFlags)
{
	if (NULL != _recognizer)
	{
		unsigned int	flags = HWR_GetRecognitionFlags(_recognizer);
		if (0 != delFlags)
			flags &= ~delFlags;
		if (0 != addFlags)
			flags |= addFlags;
		HWR_SetRecognitionFlags(_recognizer, flags);
	}
}

extern "C" __declspec(dllexport) int resetRecognizerDataOfType(int type)
{
	if (_recognizer == NULL)
		return 0;
	char strUserDict[_MAX_PATH];
	char strLearner[_MAX_PATH];
	char strCorrector[_MAX_PATH];

	if (0 != (type & USERDATA_AUTOCORRECTOR))
	{
		sprintf_s(strCorrector, _MAX_PATH, "%s\\%s", languageManager.userPath(), languageManager.userFileNameOfType(USERDATA_AUTOCORRECTOR));
		return HWR_ResetAutoCorrector(_recognizer, strCorrector);
	}
	if (0 != (type & USERDATA_LEARNER))
	{
		sprintf_s(strLearner, _MAX_PATH, "%s\\%s", languageManager.userPath(), languageManager.userFileNameOfType(USERDATA_LEARNER));
		return HWR_ResetLearner(_recognizer, strLearner);
	}
	if (0 != (type & USERDATA_DICTIONARY) || type == 0)
	{
		sprintf_s(strUserDict, _MAX_PATH, "%s\\%s", languageManager.userPath(), languageManager.userFileNameOfType(USERDATA_DICTIONARY));
		return HWR_ResetUserDict(_recognizer, strUserDict);
	}
	return 0;
}

extern "C" __declspec(dllexport) int reloadRecognizerDataOfType(int type)
{
	if (_recognizer == NULL)
		return 0;
	char strUserDict[_MAX_PATH];
	char strLearner[_MAX_PATH];
	char strCorrector[_MAX_PATH];

	if (0 != (type & USERDATA_AUTOCORRECTOR))
	{
		sprintf_s(strCorrector, _MAX_PATH, "%s\\%s", languageManager.userPath(), languageManager.userFileNameOfType(USERDATA_AUTOCORRECTOR));
		return HWR_ReloadAutoCorrector(_recognizer, strCorrector);
	}
	if (0 != (type & USERDATA_LEARNER))
	{
		sprintf_s(strLearner, _MAX_PATH, "%s\\%s", languageManager.userPath(), languageManager.userFileNameOfType(USERDATA_LEARNER));
		return HWR_ReloadLearner(_recognizer, strLearner);
	}
	if (0 != (type & USERDATA_DICTIONARY) || type == 0)
	{
		sprintf_s(strUserDict, _MAX_PATH, "%s\\%s", languageManager.userPath(), languageManager.userFileNameOfType(USERDATA_DICTIONARY));
		return HWR_ReloadUserDict(_recognizer, strUserDict);
	}
	return 0;
}

extern "C" __declspec(dllexport) void resetRecognizer()
{
	if (_recognizer)
		HWR_Reset(_recognizer);
}


extern "C" __declspec(dllexport) int isWordInDictionary(const UCHR * chrWord)
{
	// add here
	if (NULL != _recognizer)
	{
		if (HWR_IsWordInDict(_recognizer, chrWord))
			return 1;
	}
	return 0;
}

extern "C" __declspec(dllexport) int addWordToUserDict(const TCHAR * chrWord)
{
	// add word to the user dictionary
	int result = 0;
	if (NULL != _recognizer)
	{
		result = HWR_AddUserWordToDict(_recognizer, (UCHR*) chrWord, TRUE);
		saveRecognizerDataOfType(USERDATA_DICTIONARY);
	}
	return result;
}


extern "C" __declspec(dllexport) int initSearchInstanceForWord(TCHAR * searchword)
{
	if (searchword == NULL || wcslen(searchword) < 1)
		return 0;

	if (NULL != _recognizerSearch)
	{
		if (_searchWord == NULL || _wcsicmp(_searchWord, searchword) != 0)
		{
			HWR_FreeRecognizer(_recognizerSearch, NULL, NULL, NULL);
			_recognizerSearch = NULL;
			if (_searchWord)
				free((void *) _searchWord);
			_searchWord = NULL;

		}
	}

	if (NULL == _recognizerSearch)
	{
		char strLearner[_MAX_PATH];
		sprintf_s(strLearner, _MAX_PATH, "%s\\%s", languageManager.userPath(), languageManager.userFileNameOfType(USERDATA_LEARNER));

		_recognizerSearch = HWR_InitRecognizer(NULL, NULL,
			strLearner, NULL, languageManager.getLanguageID(), NULL);
		if (_recognizerSearch == NULL)
			return 0;
		HWR_SetDefaultShapes(_recognizerSearch);

		// set recognizer options
		unsigned int	flags = HWR_GetRecognitionFlags(_recognizerSearch);
		flags = FLAG_USERDICT | FLAG_ANALYZER;
		HWR_SetRecognitionFlags(_recognizerSearch, flags);
		_searchWord = _wcsdup(searchword);

		HWR_NewUserDict(_recognizerSearch);
		HWR_AddUserWordToDict(_recognizerSearch, (const UCHR*) searchword, FALSE);

	}
	return 1;
}

extern "C" __declspec(dllexport) void releaseSearchRecognizer()
{
	if (NULL != _recognizerSearch)
	{
		HWR_FreeRecognizer(_recognizerSearch, NULL, NULL, NULL);
		_recognizerSearch = NULL;
	}
	if (NULL != _searchWord)
		free((void *) _searchWord);
	_searchWord = NULL;
}

extern "C" __declspec(dllexport) TCHAR* getResultWord(int nWord, int nAlternative)
{
	UCHR* word = (UCHR*)HWR_GetResultWord(_recognizer, nWord, nAlternative);
	return AllocString((TCHAR*) word);
}


extern "C" __declspec(dllexport) BOOL findText(TCHAR* searhtext, INK_DATA_PTR inkData, int firstStroke, int selected)
{
	if (0 == initSearchInstanceForWord(searhtext))
		return 0;

	HWR_Reset(_recognizerSearch);

	const TCHAR * pText = (TCHAR*) HWR_RecognizeInkData(_recognizerSearch, inkData, firstStroke, -1, FALSE, FALSE, FALSE, selected);

	INK_SelectAllStrokes(inkData, FALSE);

	if (NULL != pText)
	{
		for (int word = 0; word < HWR_GetResultWordCount(_recognizerSearch); word++)
		{
			int altCnt = MIN(4, HWR_GetResultAlternativeCount(_recognizerSearch, word));
			for (int alt = 0; alt < altCnt; alt++)
			{
				const TCHAR * pWord = (TCHAR*) HWR_GetResultWord(_recognizerSearch, word, alt);
				if (pWord != NULL)
				{
					if (wcsstr(pWord, (TCHAR*) searhtext) != NULL)
					{
						// select strokes that belong to the found word
						int * ids = NULL;
						int cnt = HWR_GetStrokeIDs(_recognizerSearch, word, alt, (const int **) &ids);
						for (int i = 0; i < cnt; i++)
						{
							INK_SelectStroke(inkData, firstStroke + ids[i], TRUE);
						}
						return 1;
					}
				}
			}
		}
	}
	return 0;
}

extern "C" __declspec(dllexport) const TCHAR * recognizeInk(CGStroke strokeArray, int cnt)
{
	const TCHAR * pText = NULL;
	if (HWR_Recognize(_recognizer))
	{
		pText = (TCHAR*) HWR_GetResult(_recognizer);
		if (pText == NULL || *pText == 0)
		{
			return kEmptyWord;
		}

		if (wcscmp(pText, kEmptyWord) == 0)
		{
			return kEmptyWord;
		}
	}
	return AllocString(pText);
}

extern "C" __declspec(dllexport) const TCHAR * recognizeInkData(void* inkData, BOOL bSelected)
{
	const TCHAR * pText = NULL;

	if (_recognizer == NULL)
		return NULL;

	// HWR_RecognizeInkData function does not return until all ink is recognized and may take a long time.
	// It is recommended to call HWR_RecognizeInkData from a background thread.
	// you can terminate recognizer by calling HWR_StopAsyncReco function.
	// YOU CANNOT CALL HWR_RecognizeInkData and HWR_StopAsyncReco functions FROM THE SANME THREAD.

	pText = (TCHAR*) HWR_RecognizeInkData(_recognizer, inkData, 0, -1, FALSE, FALSE, FALSE, bSelected);
	if (pText == NULL || *pText == 0)
	{
		return L"*Error*";
	}
	if (wcscmp(pText, kEmptyWord) == 0)
	{
		return L"*Error*";
	}

	return AllocString(pText);
}