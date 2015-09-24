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

using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
using System.Windows.Media;
using System.Windows.Shapes;

namespace WritePadSDK_WPFSample.SDK
{
	/// <summary>
	/// This class contains P/Invoke function definitions for WritePad SDK. Note that some of the functions are accessed through an intermediate layer (Windows_CPPLayer.dll).
	/// It keeps its own recognizer pointer in a static variable, so all recognizer API's should be called through it.
	/// </summary>
	public static class WritePadAPI
	{
        public struct CGTracePoint
        {
            public CGPoint pt;
            public int pressure;
        }
        
        public const int FLAG_SEPLET = 0x00000001;
	    public const int FLAG_USERDICT = 0x00000002;
	    public const int FLAG_MAINDICT = 0x00000004;
	    public const int FLAG_ONLYDICT = 0x00000008;
	    public const int FLAG_SEGMENT = 0x00000010;
	    public const int FLAG_SINGLEWORDONLY = 0x00000020;
	    public const int FLAG_INTERNATIONAL = 0x00000040;
	    public const int FLAG_SUGGESTONLYDICT = 0x00000080;
	    public const int FLAG_ANALYZER = 0x00000100;
	    public const int FLAG_CORRECTOR = 0x00000200;
	    public const int FLAG_SPELLIGNORENUM = 0x00000400;
	    public const int FLAG_SPELLIGNOREUPPER = 0x00000800;
	    public const int FLAG_NOSINGLELETSPACE = 0x00001000;
	    public const int FLAG_ENABLECALC = 0x00002000;
	    public const int FLAG_NOSPACE = 0x00004000;
	    public const int FLAG_ALTDICT = 0x00008000;
	    public const uint FLAG_ERROR = 0xFFFFFFFF;

	    // gestures
	    public const int GEST_NONE = 0x00000000;
	    public const int GEST_DELETE = 0x00000001;    //
	    public const int GEST_SCROLLUP = 0x00000002;
	    public const int GEST_BACK = 0x00000004;    //
	    public const int GEST_SPACE = 0x00000008;    //
	    public const int GEST_RETURN = 0x00000010;    //
	    public const int GEST_CORRECT = 0x00000020;
	    public const int GEST_SPELL = 0x00000040;
	    public const int GEST_SELECTALL = 0x00000080;
	    public const int GEST_UNDO = 0x00000100;    //
	    public const int GEST_SMALLPT = 0x00000200;
	    public const int GEST_COPY = 0x00000400;
	    public const int GEST_CUT = 0x00000800;
	    public const int GEST_PASTE = 0x00001000;
	    public const int GEST_TAB = 0x00002000;    //
	    public const int GEST_MENU = 0x00004000;
	    public const int GEST_LOOP = 0x00008000;
	    public const int GEST_REDO = 0x00010000;
	    public const int GEST_SCROLLDN = 0x00020000;
	    public const int GEST_SAVE = 0x00040000;
	    public const int GEST_SENDMAIL = 0x00080000;
	    public const int GEST_OPTIONS = 0x00100000;
	    public const int GEST_SENDTODEVICE = 0x00200000;
	    public const int GEST_BACK_LONG = 0x00400000;
	    public const int GEST_LEFTARC = 0x10000000;
	    public const int GEST_RIGHTARC = 0x20000000;
	    public const int GEST_ARCS = 0x30000000;

	    public const int GEST_ALL = 0x0FFFFFFF;
	    
	    public const int HW_MAXWORDLEN = 50;

	    public const int HW_SPELL_CHECK = 0x0000;
	    public const int HW_SPELL_LIST = 0x0001;
	    public const int HW_SPELL_USERDICT = 0x0002;
	    public const int HW_SPELL_USEALTDICT = 0x0004;
	    public const int HW_SPELL_IGNORENUM = 0x0008;
	    public const int HW_SPELL_IGNOREUPPER = 0x0010;

	    public const int MIN_RECOGNITION_WEIGHT = 51;
	    public const int MAX_RECOGNITION_WEIGHT = 100;

	    public const int RECMODE_GENERAL = 0;
	    public const int RECMODE_NUM = 1;
	    public const int RECMODE_CAPITAL = 2;
	    public const int RECMODE_INTERNET = 3;

	    //Autocorrector Flags
	    public const int FLAG_IGNORECASE = 0x0001;
	    public const int FLAG_ALWAYS_REPLACE = 0x0002;
	    public const int FLAG_DISABLED = 0x0004;
        public const String TAG = "WritePadAPI";
        public const int DEFAULT_INK_PRESSURE = 127;
        public const int DEFAULT_INK_WIDTH = 3;
        public const int LONG_STROKE_MINLENGTH = 200;

	    public enum SHAPETYPE
		{
			SHAPE_UNKNOWN = 0,
			SHAPE_TRIANGLE = 0x0001,
			SHAPE_CIRCLE = 0x0002,
			SHAPE_ELLIPSE = 0x0004,
			SHAPE_RECTANGLE = 0x0008,
			SHAPE_LINE = 0x0010,
			SHAPE_ARROW = 0x0020,
			SHAPE_SCRATCH = 0x0040,
			SHAPE_ALL = 0x00FF
		};

		public const int LANGUAGE_NONE = 0;
		public const int LANGUAGE_ENGLISH = 1;

		public const int LANGUAGE_FRENCH = 2;

		public const int LANGUAGE_GERMAN = 3;

		public const int LANGUAGE_SPANISH = 4;

		public const int LANGUAGE_ITALIAN = 5;

		public const int LANGUAGE_SWEDISH = 6;

		public const int LANGUAGE_NORWEGIAN = 7;

		public const int LANGUAGE_DUTCH = 8;

		public const int LANGUAGE_DANISH = 9;

		public const int LANGUAGE_PORTUGUESE = 10;

		public const int LANGUAGE_PORTUGUESEB = 11;

		public const int LANGUAGE_MEDICAL = 12;

		public const int LANGUAGE_FINNISH = 13;

		public const int LANGUAGE_ENGLISHUK = 14;

		public const int USERDATA_DICTIONARY = 0x0004;
		public const int USERDATA_AUTOCORRECTOR = 0x0001;
		public const int USERDATA_LEARNER = 0x0002;
		public const int USERDATA_ALL = 0x00FF;

        public enum LanguageType
        {
            da = 9,
            de = 3,
            nl = 8,
            en_uk = 14,
            en = 1,
            es = 4,
            fr = 2,
            it = 5,
            nb = 7,
            pt_BR = 11,
            pt_PT = 10,
            sv = 6,
            fi = 13
        }

        public static LanguageType language = LanguageType.en;

		[DllImport("WritePadReco.dll", CallingConvention = CallingConvention.Cdecl)]
		private static extern SHAPETYPE INK_RecognizeShape(CGStroke[] pStroke, int nStrokeCnt, SHAPETYPE inType);

		[DllImport("WritePadReco.dll", CallingConvention = CallingConvention.Cdecl)]
		public static extern bool INK_SetImageFrame(IntPtr pData, int nImageIndex, CGRect frame);
		
		[DllImport("WritePadReco.dll", CallingConvention = CallingConvention.Cdecl)]
		public static extern int INK_CountImages(IntPtr pData);

		[DllImport("WritePadReco.dll", CallingConvention = CallingConvention.Cdecl)]
		public static extern int INK_StrokeCount(IntPtr pData, UInt32 strokeCount);

		[DllImport("WritePadReco.dll", CallingConvention = CallingConvention.Cdecl)]
		public static extern int INK_CountTexts(IntPtr pData);

		[DllImport("WritePadReco.dll", CallingConvention = CallingConvention.Cdecl)]
		public static extern int INK_DeleteStroke(IntPtr pData, UInt32 nStroke);

		[DllImport("WritePadReco.dll", CallingConvention = CallingConvention.Cdecl)]
		public static extern bool INK_DeleteImage(IntPtr pData, UInt32 nImage);

		[DllImport("WritePadReco.dll", CallingConvention = CallingConvention.Cdecl)]
		public static extern bool INK_DeleteText(IntPtr pData, UInt32 nText);

		[DllImport("WritePadReco.dll", CallingConvention = CallingConvention.Cdecl)]
		public static extern int INK_SelectStrokesInRect(IntPtr pData, CGRect rect);

		[DllImport("WritePadReco.dll", CallingConvention = CallingConvention.Cdecl)]
		public static extern void INK_SelectStroke(IntPtr pData, int nStroke, bool bSelect);
		
		[DllImport("WritePadReco.dll", CallingConvention = CallingConvention.Cdecl)]
		public static extern bool INK_IsStrokeSelected(IntPtr pData, int nStroke);

		[DllImport("WritePadReco.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
		public static extern IntPtr HWR_InitRecognizer(StringBuilder inDictionaryMain, StringBuilder inDictionaryCustom, StringBuilder inLearner, StringBuilder inAutoCorrect, int language, ref int pFlags);

		[DllImport("WritePadReco.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
		public static extern byte INK_Serialize(IntPtr pData, Int32 bWrite, IntPtr File, ref IntPtr data, ref int pcbSize, Int32 skipImages, Int32 savePressure);

		[DllImport("WritePadReco.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
		public static extern int INK_GetStroke(IntPtr pData, UInt32 nStroke, ref IntPtr ppoints, ref Int32 nWidth,
											   ref Int32 color);

		[DllImport("WritePadReco.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
		public static extern IntPtr INK_InitData();

		[DllImport("WritePadReco.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
		public static extern void INK_Erase(IntPtr pData);

        [DllImport("WritePadReco.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
        public static extern void INK_FreeData(IntPtr pData);

		[DllImport("WritePadReco.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
		public static extern void INK_EnableShapeRecognition(IntPtr pData, byte bEnable);

		[DllImport("WritePadReco.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
		public static extern byte INK_AddStroke(IntPtr inkData, [MarshalAs(UnmanagedType.LPArray)] CGStroke[] ptStroke, int nStrokeCnt, int iWidth,
												  UInt32 color);

		[DllImport("WritePadReco.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
		public static extern byte HWR_RecognizerAddStroke(IntPtr pRecognizer,
														   [MarshalAs(UnmanagedType.LPArray)] CGStroke[] pStroke,
														   int nStrokeCnt);

		[DllImport("WritePadReco.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
		public static extern byte INK_IsShapeRecognitionEnabled(IntPtr inkData);

		[DllImport("WritePadReco.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
		public static extern int INK_AddEmptyStroke(IntPtr pData, int iWidth, UInt32 color);

		[DllImport("WritePadReco.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
		public static extern int INK_ResizeStroke(IntPtr pData, int nStroke, float xOffset, float yOffset,
												float scaleX, float scaleY, byte bReset, ref CGRect pRect, Int32 recordUndo);

		[DllImport("WritePadReco.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
		public static extern int INK_MoveStroke(IntPtr pData, int nStroke, float xOffset, float yOffset,
												ref CGRect pRect, Int32 recordUndo);

		[DllImport("WritePadReco.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
		public static extern int INK_AddPixelToStroke(IntPtr pData, int nStroke, float x, float y);

		[DllImport("WritePadReco.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
		public static extern int INK_GetStrokeZOrder(IntPtr pData, int nStroke);

		[DllImport("WritePadReco.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
		public static extern bool INK_SetStrokeZOrder(IntPtr pData, int nStroke, int zOrder);

		[DllImport("WritePadReco.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
		public static extern byte INK_GetStrokeRect(IntPtr pData, UInt32 nStroke, ref CGRect rect);

		[DllImport("WritePadReco.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
		public static extern byte HWR_Recognize(IntPtr pRecognizer);

		[DllImport("WritePadReco.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
		public static extern IntPtr HWR_GetResult(IntPtr pRecognizer);

		[DllImport("WritePadReco.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
		public static extern byte INK_IsStrokeRecognizable(IntPtr pData, int nStroke);

		[DllImport("WritePadReco.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
		public static extern byte HWR_SetDictionaryData(IntPtr pRecognizer, [MarshalAs(UnmanagedType.LPArray)] byte[] pData, int nDictType);

		[DllImport("WritePadReco.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
		public static extern byte HWR_Reset(IntPtr pRecognizer);

        [DllImport("WritePadReco.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
        public static extern int HWR_GetLanguageID(IntPtr pRecognizer);

		[DllImport("WritePadReco.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
		public static extern byte INK_SetTextFrame(IntPtr pData, int nTextIndex, CGRect frame);

		[DllImport("WritePadReco.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
		public static extern byte HWR_IsWordInDict(IntPtr pData, StringBuilder word);

        [DllImport("WritePadReco.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
        public static extern int HWR_GetResultAlternativeCount(IntPtr recoHandle, int nWord);

        [DllImport("WritePadReco.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
        public static extern short HWR_GetResultWeight(IntPtr recoHandle, int nWord, int nALternative);

		[DllImport("Windows_CPPLayer.dll", CallingConvention = CallingConvention.Cdecl)]
		public static extern int initRecognizerForLanguage(int language, [MarshalAs(UnmanagedType.LPStr)] string userpath, [MarshalAs(UnmanagedType.LPStr)] string apppath, uint recoflags);

		[DllImport("Windows_CPPLayer.dll", CallingConvention = CallingConvention.Cdecl)]
		public static extern IntPtr recognizeInk();

		[DllImport("Windows_CPPLayer.dll", CallingConvention = CallingConvention.Cdecl)]
		public static extern IntPtr resetRecognizer();

		[DllImport("Windows_CPPLayer.dll", CallingConvention = CallingConvention.Cdecl)]
		[return: MarshalAs(UnmanagedType.LPStr)]
		public static extern string getAutocorrectorWords();

		[DllImport("Windows_CPPLayer.dll", CallingConvention = CallingConvention.Cdecl)]
		[return: MarshalAs(UnmanagedType.LPStr)]
		public static extern string getUserWords();

        [DllImport("WritePadReco.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern int HWR_GetResultWordCount(IntPtr recoHandle);

        [DllImport("WritePadReco.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern int HWR_AddWordToWordList(IntPtr recoHandle, [MarshalAs(UnmanagedType.LPStr)] string word1, [MarshalAs(UnmanagedType.LPStr)] string word2, int flags, int replace);

		[DllImport("Windows_CPPLayer.dll", CallingConvention = CallingConvention.Cdecl)]
		public static extern int addWordToUserDictionary([MarshalAs(UnmanagedType.LPStr)] string word);

        [DllImport("WritePadReco.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern int HWR_NewUserDict(IntPtr recoHandle);

		[DllImport("Windows_CPPLayer.dll", CallingConvention = CallingConvention.Cdecl)]
		public static extern int resetRecognizerDataOfType(int type);

		[DllImport("Windows_CPPLayer.dll", CallingConvention = CallingConvention.Cdecl)]
		public static extern int importUserDictionary(string path);

		[DllImport("Windows_CPPLayer.dll", CallingConvention = CallingConvention.Cdecl)]
		public static extern int importAutoCorrector(string path);

		[DllImport("Windows_CPPLayer.dll", CallingConvention = CallingConvention.Cdecl)]
		public static extern int exportUserDictionary(string path);

		[DllImport("Windows_CPPLayer.dll", CallingConvention = CallingConvention.Cdecl)]
		public static extern int exportAutocorrectorDictionary(string path);
		
		[DllImport("Windows_CPPLayer.dll", CallingConvention = CallingConvention.Cdecl)]
		public static extern int saveRecognizerDataOfType(int type);

        [DllImport("WritePadReco.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern int HWR_EmptyWordList(IntPtr recoHandle);

		[DllImport("Windows_CPPLayer.dll", CallingConvention = CallingConvention.Cdecl)]
		public static extern int spellCheck();

        [DllImport("Windows_CPPLayer.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr recognizeInkData(IntPtr inkData, int bSelOnly);

        [DllImport("Windows_CPPLayer.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern void releaseRecognizer();

        [DllImport("Windows_CPPLayer.dll", CallingConvention = CallingConvention.Cdecl)]
		public static extern IntPtr getResultWord(int nWord, int nAlternative);

        [DllImport("Windows_CPPLayer.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr getRecoHandle();

        [DllImport("WritePadReco.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern uint HWR_GetRecognitionFlags(IntPtr recoHandle);


        [DllImport("WritePadReco.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern void HWR_SetRecognitionFlags(IntPtr recoHandle, uint flags);

		[DllImport("WritePadReco.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
		public static extern SHAPETYPE INK_RecognizeShape(CGStroke pStroke, int nStrokeCnt, SHAPETYPE inType);

        [DllImport("WritePadReco.dll", CallingConvention = CallingConvention.Cdecl)]
        private static extern int HWR_LearnNewWord(IntPtr reco, IntPtr word, UInt16 weight);

        [DllImport("WritePadReco.dll", CallingConvention = CallingConvention.Cdecl)]
        private static extern int HWR_CheckGesture(int type, CGTracePoint[] stroke, int len, int nScale, int nMinLen);
		

        [StructLayout(LayoutKind.Sequential)]
		public struct CGStroke
		{
			public CGPoint pt;
			public int pressure;
		};

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

		[StructLayout(LayoutKind.Sequential)]
		public struct CGPoint
		{
			public float x;
			public float y;
		};

		public struct CGSize
		{
			public float width;
			public float height;
		};

		[StructLayout(LayoutKind.Sequential)]
		public struct CGRect
		{
			public CGPoint origin;
			public CGSize size;
		};

        public static bool recoLearnWord(String word, int weight)
        {
            bool result = false;
            IntPtr w = Marshal.StringToCoTaskMemUni(word);
            result = HWR_LearnNewWord(getRecoHandle(), w, (UInt16)weight) == 0 ? false : true;
            return result;
        }
       
		/// <summary>
		/// Add stroke to ink
		/// </summary>
		/// <param name="inkData">Pointer to ink data</param>
		/// <param name="currentStroke">Stroke as a polyline</param>
		/// <returns></returns>
		public static bool AddStroke(IntPtr inkData, Polyline currentStroke)
		{
			if (currentStroke.Points.Count == 0)
				return false;
			var pointArray = new CGStroke[currentStroke.Points.Count];
			for (var i = 0; i < currentStroke.Points.Count; i++)
			{
				pointArray[i].pressure = 127;
				pointArray[i].pt.x = (float)currentStroke.Points[i].X;
				pointArray[i].pt.y = (float)currentStroke.Points[i].Y;
			}
			INK_AddStroke(inkData, pointArray, pointArray.Length, (int)currentStroke.StrokeThickness - 1,
				ColorToCOLORREF(((SolidColorBrush)currentStroke.Stroke).Color));
			return false;
		}

		/// <summary>
		/// Translate Windows Color structure into COLORREF used by the library
		/// </summary>
		/// <param name="color"></param>
		/// <returns></returns>
		public static uint ColorToCOLORREF(Color color)
		{
			return color.R + (((uint)color.G) << 8) + (((uint)color.B) << 16) + ((uint)color.A << 24);
		}

        public static LanguageType getLanguage()
        {
            var langId = HWR_GetLanguageID(getRecoHandle());
            return (LanguageType) langId;
        }

	    public static int detectGesture(int type, PointCollection points)
	    {
            int result = GEST_NONE;
            if (points == null || points.Count == 0)
                return 0;

	        var currentStroke = new List<CGTracePoint>();
	        foreach (var point in points)
	        {
	            currentStroke.Add(new CGTracePoint
	            {
                    pressure = DEFAULT_INK_PRESSURE,
                    pt = new CGPoint
                    {
                        x = (float) point.X,
                        y = (float) point.Y
                    }
	            }
            );
	        }
            result = HWR_CheckGesture(type, currentStroke.ToArray(), currentStroke.Count, 1, LONG_STROKE_MINLENGTH);
            return result;
	    }
	}
}
