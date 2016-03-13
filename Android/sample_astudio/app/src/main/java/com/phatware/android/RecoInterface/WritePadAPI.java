/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    Copyright (c) 1997-2015 PhatWare(r) Corp. All rights reserved.                 * */
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
 * 10414 W. Highway 2, Ste 4-121 Spokane, WA 99224
 *
 * ************************************************************************************* */

package com.phatware.android.RecoInterface;

import java.io.InputStream;

import android.content.Context;
import android.util.Log;

import com.phatware.android.IOUtils;
import com.phatware.android.WritePadManager;

public class WritePadAPI {
    static {
        System.loadLibrary("WritePadReco");
    }

    public static final int FLAG_SEPLET = 0x00000001;
    public static final int FLAG_USERDICT = 0x00000002;
    public static final int FLAG_MAINDICT = 0x00000004;
    public static final int FLAG_ONLYDICT = 0x00000008;
    public static final int FLAG_STATICSEGMENT = 0x00000010;
    public static final int FLAG_SINGLEWORDONLY = 0x00000020;
    public static final int FLAG_INTERNATIONAL = 0x00000040;
    public static final int FLAG_SUGGESTONLYDICT = 0x00000080;
    public static final int FLAG_ANALYZER = 0x00000100;
    public static final int FLAG_CORRECTOR = 0x00000200;
    public static final int FLAG_SPELLIGNORENUM = 0x00000400;
    public static final int FLAG_SPELLIGNOREUPPER = 0x00000800;
    public static final int FLAG_NOSINGLELETSPACE = 0x00001000;
    public static final int FLAG_ENABLECALC = 0x00002000;
    public static final int FLAG_NOSPACE = 0x00004000;
    public static final int FLAG_ALTDICT = 0x00008000;
    public static final int FLAG_ERROR = 0xFFFFFFFF;

    // gestures
    public static final int GEST_NONE = 0x00000000;
    public static final int GEST_DELETE = 0x00000001;    //
    public static final int GEST_SCROLLUP = 0x00000002;
    public static final int GEST_BACK = 0x00000004;    //
    public static final int GEST_SPACE = 0x00000008;    //
    public static final int GEST_RETURN = 0x00000010;    //
    public static final int GEST_CORRECT = 0x00000020;
    public static final int GEST_SPELL = 0x00000040;
    public static final int GEST_SELECTALL = 0x00000080;
    public static final int GEST_UNDO = 0x00000100;    //
    public static final int GEST_SMALLPT = 0x00000200;
    public static final int GEST_COPY = 0x00000400;
    public static final int GEST_CUT = 0x00000800;
    public static final int GEST_PASTE = 0x00001000;
    public static final int GEST_TAB = 0x00002000;    //
    public static final int GEST_MENU = 0x00004000;
    public static final int GEST_LOOP = 0x00008000;
    public static final int GEST_REDO = 0x00010000;
    public static final int GEST_SCROLLDN = 0x00020000;
    public static final int GEST_SAVE = 0x00040000;
    public static final int GEST_SENDMAIL = 0x00080000;
    public static final int GEST_OPTIONS = 0x00100000;
    public static final int GEST_SENDTODEVICE = 0x00200000;
    public static final int GEST_BACK_LONG = 0x00400000;
    public static final int GEST_LEFTARC = 0x10000000;
    public static final int GEST_RIGHTARC = 0x20000000;
    public static final int GEST_ARCS = 0x30000000;

    public static final int GEST_ALL = 0x0FFFFFFF;

    // language ID
    public static final int LANGUAGE_NONE = 0;
    public static final int LANGUAGE_ENGLISH = 1;
    public static final int LANGUAGE_FRENCH = 2;
    public static final int LANGUAGE_GERMAN = 3;
    public static final int LANGUAGE_SPANISH = 4;
    public static final int LANGUAGE_ITALIAN = 5;
    public static final int LANGUAGE_SWEDISH = 6;
    public static final int LANGUAGE_NORWEGIAN = 7;
    public static final int LANGUAGE_DUTCH = 8;
    public static final int LANGUAGE_DANISH = 9;
    public static final int LANGUAGE_PORTUGUESE = 10;
    public static final int LANGUAGE_PORTUGUESEB = 11;
    public static final int LANGUAGE_MEDICAL = 12;
    public static final int LANGUAGE_FINNISH = 13;
    public static final int LANGUAGE_INDONESIAN = 14;
    public static final int LANGUAGE_ENGLISHUK = 15;

    public static final int HW_MAXWORDLEN = 50;

    public static final int HW_SPELL_CHECK = 0x0000;
    public static final int HW_SPELL_LIST = 0x0001;
    public static final int HW_SPELL_USERDICT = 0x0002;
    public static final int HW_SPELL_USEALTDICT = 0x0004;
    public static final int HW_SPELL_IGNORENUM = 0x0008;
    public static final int HW_SPELL_IGNOREUPPER = 0x0010;

    public static final int MIN_RECOGNITION_WEIGHT = 51;
    public static final int MAX_RECOGNITION_WEIGHT = 100;

    public static final int RECMODE_GENERAL = 0;
    public static final int RECMODE_NUM = 1;
    public static final int RECMODE_CAPITAL = 2;
    public static final int RECMODE_INTERNET = 3;

    //Autocorrector Flags
    public static final int FLAG_IGNORECASE = 0x0001;
    public static final int FLAG_ALWAYS_REPLACE = 0x0002;
    public static final int FLAG_DISABLED = 0x0004;
    public static final String TAG = "WritePadAPI";


    private static native int recognizerInit(String sDir, int languageId, byte[] letterGroupStates, String pUserDict, String pLearner, String pCorrector);

    private static native int getRecognizerFlags();

    private static native void setRecognizerFlags(int flags);

    private static native void freeRecognizer(String pUserDict, String pLearner, String pCorrector);

    public static native boolean reloadAutocorrector();

    private static native boolean reloadUserDict();

    private static native boolean reloadLearner();

    private static native boolean setDictionaryData( byte[] buffer, int flag );

    private static native String recognizeInkData(int nDataLen, boolean bAsync, boolean bFlipY, boolean bSort );

    private static native int stopRecognizer();

    private static native int newStroke(float width, int color);

    private static native int addPixelToStroke(int stroke, float x, float y);

    private static native int getStrokeCount();

    private static native void resetInkData();

    private static native int detectGesture(int type);

    private static native boolean deleteLastStroke();

    private static native boolean isWordInDict(String word, int flags);

    private static native String languageName();

    private static native boolean resetResult();

    private static native int getResultColumnCount();

    private static native int getResultRowCount(int column);

    private static native String getRecognizedWord(int column, int row);

    public boolean recoResetResult() {
        return resetResult();
    }

    public int recoResultColumnCount() {
        return getResultColumnCount();
    }

    public int recoResultRowCount(int column) {
        return getResultRowCount(column);
    }


    public String recoResultWord(int column, int row) {
        return getRecognizedWord(column, row);
    }


    public boolean isDictionaryWord(String word, int flags) {
        return isWordInDict(word, flags);
    }


    public String getLanguageName() {
        return languageName();
    }


    public boolean recoReloadAutocorrector() {
        return reloadAutocorrector();
    }

    public boolean recoReloadUserDict() {
        return reloadUserDict();
    }

    public boolean recoReloadLearner() {
        return reloadLearner();
    }

    public boolean recoSetDict(byte[] buffer) {
        return setDictionaryData(buffer, 0 );
    }


    public int recoGesture(int type) {
        return detectGesture(type);
    }

    public boolean recoDeleteLastStroke() {
        return deleteLastStroke();
    }

    public int recoStrokeCount() {
        return getStrokeCount();
    }

    public int recoAddPixel(int stroke, float x, float y) {
        return addPixelToStroke(stroke, x, y);
    }

    public void recoResetInk() {
        resetInkData();
    }

    public int recoNewStroke(float width, int color) {
        return newStroke(width, color);
    }

    public int recoGetFlags() {
        return getRecognizerFlags();
    }

    public void recoSetFlags(int flags) {
        setRecognizerFlags(flags);
    }

    public int recoStop() {
        return stopRecognizer();
    }

    public String recoInkData(int nDataLen, boolean bAsync, boolean bFlipY, boolean bSort) {
        return recognizeInkData(nDataLen, bAsync, bFlipY, bSort);
    }

    String userDictTemplate = "WritePad_User%s.dct";
    String learnerTemplate = "WritePad_Stat%s.lrn";
    String correctorTemplate = "WritePad_Corr%s.cwl";

    public int recoInit(String sDir, WritePadManager.Language language, byte[] letterGroupStates) {
        String langAbbreviation = "";
        langAbbreviation = getLangAbbreviation(language);

        String userDict = String.format(userDictTemplate, langAbbreviation);
        String learner = String.format(learnerTemplate, langAbbreviation);
        String corrector = String.format(correctorTemplate, langAbbreviation);

        return recognizerInit(sDir, language.getId(), letterGroupStates, userDict, learner, corrector);
    }


    private String getLangAbbreviation(WritePadManager.Language language) {
        String langAbbreviation = "";
        switch (language) {
            case da:
                langAbbreviation = "DAN";
                break;
            case de:
                langAbbreviation = "GER";
                break;
            case nl:
                langAbbreviation = "DUT";
                break;
            case en_uk:
                langAbbreviation = "ENG";
                break;
            case en:
                langAbbreviation = "ENU";
                break;
            case es:
                langAbbreviation = "SPN";
                break;
            case fr:
                langAbbreviation = "FRN";
                break;
            case it:
                langAbbreviation = "ITL";
                break;
            case nb:
                langAbbreviation = "NRW";
                break;
            case pt_BR:
                langAbbreviation = "PRB";
                break;
            case pt_PT:
                langAbbreviation = "PRT";
                break;
            case sv:
                langAbbreviation = "SWD";
                break;
            case fi:
                langAbbreviation = "FIN";
                break;
            case ind:
                langAbbreviation = "IND";
                break;
        }
        return langAbbreviation;
    }


    public void recoFree(WritePadManager.Language language) {
        String langAbbreviation = getLangAbbreviation(language);
        String userDict = String.format(userDictTemplate, langAbbreviation);
        String learner = String.format(learnerTemplate, langAbbreviation);
        String corrector = String.format(correctorTemplate, langAbbreviation);

        freeRecognizer(userDict, learner, corrector);
    }
}
