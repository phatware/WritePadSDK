/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    Copyright (c) 2008-2016 PhatWare(r) Corp. All rights reserved.                 * */
/* ************************************************************************************* */

/* ************************************************************************************* *
 *
 * WritePad SDK Xamarin Sample for Android
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



using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using Android.Content;
using System.IO;

namespace WritePadXamarinSample
{
    public static class WritePadAPI
    {        
        public struct CGPoint
        {
            public double x;
            public double y;
        };

        public struct CGTracePoint
        {
            public CGPoint pt;
            public int pressure;
        }

		// recognizer flags
        public  const int FLAG_SEPLET = 0x00000001;
        public  const int FLAG_USERDICT = 0x00000002;
        public  const int FLAG_MAINDICT = 0x00000004;
        public  const int FLAG_ONLYDICT = 0x00000008;
        public  const int FLAG_SEGMENT = 0x00000010;
        public  const int FLAG_SINGLEWORDONLY = 0x00000020;
        public  const int FLAG_INTERNATIONAL = 0x00000040;
        public  const int FLAG_SUGGESTONLYDICT = 0x00000080;
        public  const int FLAG_ANALYZER = 0x00000100;
        public  const int FLAG_CORRECTOR = 0x00000200;
        public  const int FLAG_SPELLIGNORENUM = 0x00000400;
        public  const int FLAG_SPELLIGNOREUPPER = 0x00000800;
        public  const int FLAG_NOSINGLELETSPACE = 0x00001000;
        public  const int FLAG_ENABLECALC = 0x00002000;
        public  const int FLAG_NOSPACE = 0x00004000;
        public  const int FLAG_ALTDICT = 0x00008000;
        public  const uint FLAG_ERROR = 0xFFFFFFFF;

        // gestures
        public  const int GEST_NONE = 0x00000000;
        public  const int GEST_DELETE = 0x00000001;    //
        public  const int GEST_SCROLLUP = 0x00000002;
        public  const int GEST_BACK = 0x00000004;    //
        public  const int GEST_SPACE = 0x00000008;    //
        public  const int GEST_RETURN = 0x00000010;    //
        public  const int GEST_CORRECT = 0x00000020;
        public  const int GEST_SPELL = 0x00000040;
        public  const int GEST_SELECTALL = 0x00000080;
        public  const int GEST_UNDO = 0x00000100;    //
        public  const int GEST_SMALLPT = 0x00000200;
        public  const int GEST_COPY = 0x00000400;
        public  const int GEST_CUT = 0x00000800;
        public  const int GEST_PASTE = 0x00001000;
        public  const int GEST_TAB = 0x00002000;    //
        public  const int GEST_MENU = 0x00004000;
        public  const int GEST_LOOP = 0x00008000;
        public  const int GEST_REDO = 0x00010000;
        public  const int GEST_SCROLLDN = 0x00020000;
        public  const int GEST_SAVE = 0x00040000;
        public  const int GEST_SENDMAIL = 0x00080000;
        public  const int GEST_OPTIONS = 0x00100000;
        public  const int GEST_SENDTODEVICE = 0x00200000;
        public  const int GEST_BACK_LONG = 0x00400000;
        public  const int GEST_LEFTARC = 0x10000000;
        public  const int GEST_RIGHTARC = 0x20000000;
        public  const int GEST_ARCS = 0x30000000;

        public  const int GEST_ALL = 0x0FFFFFFF;

        // language ID
        public  const int LANGUAGE_NONE = 0;
        public  const int LANGUAGE_ENGLISH = 1;
        public  const int LANGUAGE_FRENCH = 2;
        public  const int LANGUAGE_GERMAN = 3;
        public  const int LANGUAGE_SPANISH = 4;
        public  const int LANGUAGE_ITALIAN = 5;
        public  const int LANGUAGE_SWEDISH = 6;
        public  const int LANGUAGE_NORWEGIAN = 7;
        public  const int LANGUAGE_DUTCH = 8;
        public  const int LANGUAGE_DANISH = 9;
        public  const int LANGUAGE_PORTUGUESE = 10;
        public  const int LANGUAGE_PORTUGUESEB = 11;
        public  const int LANGUAGE_MEDICAL = 12;
        public  const int LANGUAGE_FINNISH = 13;
		public  const int LANGUAGE_INDONESIAN = 14;
		public  const int LANGUAGE_ENGLISHUK = 15;

        public  const int HW_MAXWORDLEN = 50;

		// spell checker flags
        public  const int HW_SPELL_CHECK = 0x0000;
        public  const int HW_SPELL_LIST = 0x0001;
        public  const int HW_SPELL_USERDICT = 0x0002;
        public  const int HW_SPELL_USEALTDICT = 0x0004;
        public  const int HW_SPELL_IGNORENUM = 0x0008;
        public  const int HW_SPELL_IGNOREUPPER = 0x0010;

        public  const int MIN_RECOGNITION_WEIGHT = 51;
        public  const int MAX_RECOGNITION_WEIGHT = 100;

        public  const int RECMODE_GENERAL = 0;
        public  const int RECMODE_NUM = 1;
        public  const int RECMODE_CAPITAL = 2;
        public  const int RECMODE_INTERNET = 3;

		public  const int kDictionaryType_Main = 0;
		public  const int kDictionaryType_Alternative = 1;
		public  const int kDictionaryType_User = 2;


        //Autocorrector Flags
        public  const int FLAG_IGNORECASE = 0x0001;
        public  const int FLAG_ALWAYS_REPLACE = 0x0002;
        public  const int FLAG_DISABLED = 0x0004;
        public  const String TAG = "WritePadAPI";
        public const int DEFAULT_INK_PRESSURE = 127;
        public const float DEFAULT_INK_WIDTH = 3;
        public const int LONG_STROKE_MINLENGTH = 200;

        [DllImport("libWritePadReco.so", EntryPoint = "HWR_RecognizeInkData")]
        private static extern IntPtr HWR_RecognizeInkData(IntPtr reco, IntPtr pIinkData, int nFirstStroke, int nLastStroke, bool bAsync, bool bFlipY, bool bSort, bool bSelOnly);

        [DllImport("libWritePadReco.so", EntryPoint = "INK_Erase")]
        private static extern int INK_Erase(IntPtr pIinkData);

        [DllImport("libWritePadReco.so", EntryPoint = "INK_StrokeCount")]
        private static extern int INK_StrokeCount(IntPtr pIinkData, bool selectedOnly);

        [DllImport("libWritePadReco.so", EntryPoint = "INK_AddPixelToStroke")]
        private static extern int INK_AddPixelToStroke(IntPtr pIinkData, int stroke, float x, float y, int pressure);

        [DllImport("libWritePadReco.so", EntryPoint = "INK_InitData")]
        private static extern IntPtr INK_InitData();

        [DllImport("libWritePadReco.so", EntryPoint = "INK_DeleteStroke")]
        private static extern bool INK_DeleteStroke(IntPtr pIinkData, int nStroke);

        [DllImport("libWritePadReco.so", EntryPoint = "INK_AddEmptyStroke")]
        private static extern int INK_AddEmptyStroke(IntPtr pIinkData, float width, uint color);

        [DllImport("libWritePadReco.so", EntryPoint = "HWR_GetResultWordCount")]
        private static extern int HWR_GetResultWordCount(IntPtr reco);

        [DllImport("libWritePadReco.so", EntryPoint = "HWR_GetResultWord")]
        private static extern IntPtr HWR_GetResultWord(IntPtr reco, int nWord, int nAlternative);

        [DllImport("libWritePadReco.so", EntryPoint = "HWR_GetLanguageName")]
        private static extern IntPtr HWR_GetLanguageName(IntPtr reco);

        [DllImport("libWritePadReco.so", EntryPoint = "HWR_GetResultWeight")]
        private static extern UInt16 HWR_GetResultWeight(IntPtr reco, int nWord, int nAlternative);

        [DllImport("libWritePadReco.so", EntryPoint = "HWR_GetResultAlternativeCount")]
        private static extern int HWR_GetResultAlternativeCount(IntPtr reco, int nWord);

        [DllImport("libWritePadReco.so", EntryPoint = "HWR_SetRecognitionFlags")]
        private static extern uint HWR_SetRecognitionFlags(IntPtr reco, uint flags);

        [DllImport("libWritePadReco.so", EntryPoint = "HWR_SetRecognitionFlags")]
        private static extern uint HWR_FreeRecognizer(IntPtr reco, string inDictionaryCustom, string inLearner, string inWordList);

        [DllImport("libWritePadReco.so", EntryPoint = "HWR_GetRecognitionFlags")]
        private static extern uint HWR_GetRecognitionFlags(IntPtr reco);

        [DllImport("libWritePadReco.so", EntryPoint = "INK_GetStrokeP")]
		private static extern int INK_GetStrokeP(IntPtr pIinkData, int nStroke, ref IntPtr stroke, float [] width, IntPtr color);

        [DllImport("libWritePadReco.so", EntryPoint = "HWR_CheckGesture")]
        private static extern int HWR_CheckGesture(int type, CGTracePoint[] stroke, int len, int nScale, int nMinLen);

        [DllImport("libWritePadReco.so", EntryPoint = "HWR_InitRecognizer")]
        private static extern IntPtr HWR_InitRecognizer(string inDictionaryMain, string inDictionaryCustom, string inLearner, string inAutoCorrect, int nLanguage, ref int pFlags);

        [DllImport("libWritePadReco.so", EntryPoint = "HWR_LearnNewWord")]
		private static extern int HWR_LearnNewWord(IntPtr reco, IntPtr word, UInt16 weight);

		[DllImport("libWritePadReco.so", EntryPoint = "HWR_SetDictionaryData")]
		private static extern int HWR_SetDictionaryData(IntPtr reco, byte [] data, int nDictType);

		private static IntPtr recoHandle = IntPtr.Zero;
        private static IntPtr inkData = IntPtr.Zero;

        public static int detectGesture(int type, List<CGTracePoint> currentStroke)
        {
            int result = GEST_NONE;
            if (currentStroke == null || currentStroke.Count == 0)
                return 0;

            result = HWR_CheckGesture(type, currentStroke.ToArray(), currentStroke.Count, 4, LONG_STROKE_MINLENGTH);
            return result;
        }

        public static bool recoLearnWord(String word, int weight)
        {
            bool result = false;
			IntPtr w = Marshal.StringToCoTaskMemUni(word);
            result = HWR_LearnNewWord(recoHandle, w, (UInt16)weight) == 0 ? false : true;
            return result;
        }

        public static int recoResultColumnCount()
        {
            return HWR_GetResultWordCount(recoHandle);
        }

        public static int recoResultRowCount(int col)
        {
            return HWR_GetResultAlternativeCount(recoHandle, col);
        }

        public static String recoInkData(int nDataLen, bool bAsync, bool bFlipY, bool bSort, bool bNewLine)
        {
			return Marshal.PtrToStringUni(HWR_RecognizeInkData(recoHandle,
                inkData,
                0, nDataLen, bAsync, bFlipY,
                bSort, false));
        }

        public static int recoStrokeCount()
        {
            return INK_StrokeCount(inkData, false);
        }

        public static uint recoGetFlags()
        {
            return HWR_GetRecognitionFlags(recoHandle);
        }

        public static void recoSetFlags(uint flags)
        {
            HWR_SetRecognitionFlags(recoHandle, flags);
        }

        public static int recoNewStroke(float width, uint color)
        {
            return INK_AddEmptyStroke(inkData, width, color);
        }

        public static int recoAddPixel(int stroke, float x, float y)
        {
            return INK_AddPixelToStroke(inkData, stroke, x, y, DEFAULT_INK_PRESSURE);
        }

        public static void recoFree()
        {
            INK_Erase(inkData);
            HWR_FreeRecognizer(recoHandle, userDict, learner, corrector);
        }

        private static string userDict = null;
        private static string learner = null;
        private static string corrector = null;

		private static byte[] ReadAllBytes(Stream stream)
		{
			using (var ms = new MemoryStream())
			{
				stream.CopyTo(ms);
				return ms.ToArray();
			}
		}

		public static void recoInit(Context context)
        {
            int pFlags = -1;
			int nLanguage = (int)language;

            string mainDict = "Assets/";
            string langName = "English";

			switch (language)
            {
                case LanguageType.en:
                    langName = "English";
                    break;

				case LanguageType.en_uk:
					langName = "EnglishUK";
					break;

                case LanguageType.de:
                    langName = "German";
                    break;

                case LanguageType.fr:
                    langName = "French";
                    break;

                case LanguageType.it:
                    langName = "Italian";
                    break;

                case LanguageType.es:
                    langName = "Spanish";
                    break;

                case LanguageType.sv:
                    langName = "Swedish";
                    break;

                case LanguageType.nb:
                    langName = "Norwegian";
                    break;

                case LanguageType.nl:
                    langName = "Dutch";
                    break;

                case LanguageType.da:
                    langName = "Danish";
                    break;

                case LanguageType.pt_PT:
                    langName = "Portuguese";
                    break;

                case LanguageType.pt_BR:
                    langName = "Brazilian";
                    break;

                case LanguageType.fi:
                    langName = "Finnish";
                    break;

				case LanguageType.id:
					langName = "Indonesian";
					break;
			}

			mainDict += langName + ".dct";

			var documents = Environment.GetFolderPath (Environment.SpecialFolder.MyDocuments);
			userDict = "WritePad_User_" + langName + ".dct";
			learner = "WritePad_Stat_" + langName + ".lrn";
			corrector = "WritePad_Corr_" + langName + ".cwl";
			userDict = Path.Combine( documents, userDict );
			learner = Path.Combine( documents, learner );
			corrector = Path.Combine( documents, corrector );

			recoHandle = HWR_InitRecognizer( null, userDict, learner, corrector, (int)nLanguage, ref pFlags);
			// Load main dictionary from assets
			var fileName = String.Format("{0}.dct", langName);
			using (var dictionary = context.Assets.Open(fileName)) 
			{
				try
				{
					var bytes = ReadAllBytes(dictionary);
					HWR_SetDictionaryData(recoHandle, bytes, kDictionaryType_Main );
				}
				catch
				{ 
				}
			}
            inkData = INK_InitData();
            return;
        }

        public static String recoResultWord(int column, int row)
        {
			return Marshal.PtrToStringUni(HWR_GetResultWord(recoHandle, column, row));
        }

        public static String getLanguageName()
        {
			return Marshal.PtrToStringAuto(HWR_GetLanguageName(recoHandle));
        }

        public static int recoResultWeight(int column, int row)
        {
            return (int)HWR_GetResultWeight(recoHandle, column, row);
        }

        public static void recoResetInk()
        {
            INK_Erase(inkData);
        }

        public static bool recoDeleteLastStroke()
        {
            return INK_DeleteStroke(inkData, -1);
        }		

        public static void initializeFlags(Context context)
        {
            var flags = recoGetFlags();
            flags = setRecoFlag(flags, true, FLAG_CORRECTOR);
            flags = setRecoFlag(flags, false, FLAG_SEPLET);
            flags = setRecoFlag(flags, false, FLAG_ONLYDICT);
            flags = setRecoFlag(flags, false, FLAG_SINGLEWORDONLY);
            flags = setRecoFlag(flags, true, FLAG_USERDICT);
            flags = setRecoFlag(flags, false, FLAG_ANALYZER);
            flags = setRecoFlag(flags, false, FLAG_NOSPACE);
            recoSetFlags(flags);
        }

        public static bool isRecoFlagSet(uint flags, uint flag)
        {
            return (flags & flag) == 0 ? false : true;
        }

        public static uint setRecoFlag(uint flags, bool value, uint flag)
        {
            bool isEnabled = 0 != (flags & flag);
            if (value && !isEnabled)
            {
                flags |= flag;
            }
            else if (!value && isEnabled)
            {
                flags &= ~flag;
            }
            return flags;
        }
			
        public enum LanguageType
        {
			da = LANGUAGE_DANISH,
			de = LANGUAGE_GERMAN,
			nl = LANGUAGE_DUTCH,
			en_uk = LANGUAGE_ENGLISHUK,
			en = LANGUAGE_ENGLISH,
			es = LANGUAGE_SPANISH,
			fr = LANGUAGE_FRENCH,
			it = LANGUAGE_ITALIAN,
			nb = LANGUAGE_NORWEGIAN,
			pt_BR = LANGUAGE_PORTUGUESEB,
			pt_PT = LANGUAGE_PORTUGUESE,
			sv = LANGUAGE_SWEDISH,
			fi = LANGUAGE_FINNISH,
			id = LANGUAGE_INDONESIAN
        }

        public class Language
        {
            private bool init;
            private LanguageType id;

            public Language()
            {
                init = false;
            }

            public Language(LanguageType id)
            {
                this.id = id;
            }

            public LanguageType getId()
            {
                return id;
            }

            public bool isInit()
            {
                return init;
            }

            public void setInit(bool init)
            {
                this.init = init;
            }
        }

        public static LanguageType language = LanguageType.en;
    }
}