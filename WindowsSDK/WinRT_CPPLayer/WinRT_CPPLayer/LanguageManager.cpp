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

#include "LanguageManager.h"
#include "../../include/recotypes.h"


CLanguageManager::CLanguageManager( int language )
{
	m_language = getLanguageWPID( language );
	m_userpath[0] = 0;
}


CLanguageManager::~CLanguageManager(void)
{
}

void CLanguageManager::setLanguage( int language )
{
	m_language = getLanguageWPID( language );
}

WPLanguage CLanguageManager::getLanguageWPID(int languageID )
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
		case LANGUAGE_MEDICAL:
			language = WPLanguageMedicalUS;
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
			
		default :
			break;
	}
	return language;
}

/// <summary>
/// Get dictionary filename for the current language
/// </summary>

const char* CLanguageManager::mainDictionaryName()
{
	const char * theLanguage = "English.dct";
	switch ( m_language )
	{
		case WPLanguageGerman :
			theLanguage = "German.dct";
			break;
			
		case WPLanguageFrench :
			theLanguage = "French.dct";
			break;
			
		case WPLanguageSpanish :
			theLanguage = "Spanish.dct";
			break;
			
		case WPLanguagePortuguese :
			theLanguage = "Portuguese.dct";
			break;
			
		case WPLanguageBrazilian :
			theLanguage = "Brazilian.dct";
			break;
			
		case WPLanguageDutch :
			theLanguage = "Dutch.dct";
			break;
			
		case WPLanguageItalian :
			theLanguage = "Italian.dct";
			break;
			
		case WPLanguageFinnish :
			theLanguage = "Finnish.dct";
			break;
			
		case WPLanguageSwedish :
			theLanguage = "Swedish.dct";
			break;
			
		case WPLanguageNorwegian :
			theLanguage = "Norwegian.dct";
			break;
			
		case WPLanguageDanish :
			theLanguage = "Danish.dct";
			break;
			
		case WPLanguageMedicalUS :
		case WPLanguageMedicalUK :
			theLanguage = "MedicalUS.dct";
			break;
			
		case WPLanguageEnglishUK :
			theLanguage = "EnglishUK.dct";
			break;
		default :
			break;
	}

	return theLanguage;
}

int  CLanguageManager::getLanguageID()
{
	int language = LANGUAGE_ENGLISH;
	switch ( m_language )
	{
		case WPLanguageGerman :
			language = LANGUAGE_GERMAN;
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
		default :
			break;
	}
	return language;
}

/// <summary>
/// Get user dictionary filename for the current language and user dictionary type.
/// </summary>

const char * CLanguageManager::userFileNameOfType( int type )
{
	const char *	name = NULL;
	switch ( m_language )
	{
		case WPLanguageGerman :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = "WritePad_CorrGER.cwl";
			else if ( type == USERDATA_LEARNER )
				name = "WritePad_StatGER.lrn";
			else
				name = "WritePad_UserGER.dct";
			break;
			
		case WPLanguageFrench :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = "WritePad_CorrFRN.cwl";
			else if ( type == USERDATA_LEARNER )
				name = "WritePad_StatFRN.lrn";
			else
				name = "WritePad_UserFRN.dct";
			break;
			
		case WPLanguageSpanish :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = "WritePad_CorrSPN.cwl";
			else if ( type == USERDATA_LEARNER )
				name = "WritePad_StatSPN.lrn";
			else
				name = "WritePad_UserSPN.dct";
			break;
			
		case WPLanguagePortuguese :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = "WritePad_CorrPRT.cwl";
			else if ( type == USERDATA_LEARNER )
				name = "WritePad_StatPRT.lrn";
			else
				name = "WritePad_UserPRT.dct";
			break;
			
		case WPLanguageBrazilian :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = "WritePad_CorrBRZ.cwl";
			else if ( type == USERDATA_LEARNER )
				name = "WritePad_StatBRZ.lrn";
			else
				name = "WritePad_UserBRZ.dct";
			break;
			
		case WPLanguageDutch :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = "WritePad_CorrDUT.cwl";
			else if ( type == USERDATA_LEARNER )
				name = "WritePad_StatDUT.lrn";
			else
				name = "WritePad_UserDUT.dct";
			break;
			
		case WPLanguageItalian :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = "WritePad_CorrITL.cwl";
			else if ( type == USERDATA_LEARNER )
				name = "WritePad_StatITL.lrn";
			else
				name = "WritePad_UserITL.dct";
			break;
			
		case WPLanguageFinnish :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = "WritePad_CorrFIN.cwl";
			else if ( type == USERDATA_LEARNER )
				name = "WritePad_StatFIN.lrn";
			else
				name = "WritePad_UserFIN.dct";
			break;
			
		case WPLanguageSwedish :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = "WritePad_CorrSWD.cwl";
			else if ( type == USERDATA_LEARNER )
				name = "WritePad_StatSWD.lrn";
			else
				name = "WritePad_UserSWD.dct";
			break;
			
		case WPLanguageNorwegian :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = "WritePad_CorrNRW.cwl";
			else if ( type == USERDATA_LEARNER )
				name = "WritePad_StatNRW.lrn";
			else
				name = "WritePad_UserNRW.dct";
			break;
			
		case WPLanguageDanish :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = "WritePad_CorrDAN.cwl";
			else if ( type == USERDATA_LEARNER )
				name = "WritePad_StatDAN.lrn";
			else
				name = "WritePad_UserDAN.dct";
			break;
			
		case WPLanguageMedicalUK :
		case WPLanguageEnglishUK :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = "WritePad_CorrUK.cwl";
			else if ( type == USERDATA_LEARNER )
				name = "WritePad_StatUK.lrn";
			else
				name = "WritePad_UserUK.dct";
			break;			
			
		case WPLanguageMedicalUS :
		case WPLanguageEnglishUS :
		default:
			if ( type == USERDATA_AUTOCORRECTOR )
				name = "WritePad_Corr.cwl";
			else if ( type == USERDATA_LEARNER )
				name = "WritePad_Stat.lrn";
			else
				name = "WritePad_User.dct";
			break;
	}
	return name;
}
