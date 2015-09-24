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
using System.Drawing;
using System.Linq;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using WritePadSDK_WPFSample.SDK;
using WritePad_WinFormsSample.SDK;

namespace WritePad_WinFormsSample
{
    
    public partial class Form1 : Form
    {
        public static Point _previousContactPt;
        public static Point _currentContactPt;

        public Form1()
        {
            InitializeComponent();
            DictionaryChanged();
        }

        public void DictionaryChanged()
        {
            var path = AppDomain.CurrentDomain.BaseDirectory;
            WritePadAPI.initRecognizerForLanguage((int)WritePadAPI.language, path, path, 0);
        }

        private void button1_Click(object sender, EventArgs e)
        {
            var result = RecognizeStrokes(polylineList, false);
            if (string.IsNullOrEmpty(result))
            {
                MessageBox.Show("Text could not be recognized.");
                result = "";
            }
            
            textBox1.Text = result;
            
        }

        private void ClearInk()
        {
            polylineList.Clear();
            if(panelCanvas != null)
                panelCanvas.Invalidate();
            if (InkData != IntPtr.Zero)
                WritePadAPI.INK_Erase(InkData);
            InkData = IntPtr.Zero;
        }

        public struct WordAlternative
        {
            public string Word;
            public int Weight;
        }

        private IntPtr InkData = IntPtr.Zero;

        /// <summary>n 
        /// Recognizes a collection of Polyline objects into text. Words are recognized with alternatives, eash weighted with probability. 
        /// </summary>
        /// <param name="strokes">Strokes to recognize</param>
        /// <returns></returns>
        public string RecognizeStrokes(List<List<Point>> strokes, bool bLearn)
        {
            WritePadAPI.HWR_Reset(WritePadAPI.getRecoHandle());
            
            if (InkData != IntPtr.Zero)
            {
                WritePadAPI.INK_Erase(InkData);
                InkData = IntPtr.Zero;
            }
            InkData = WritePadAPI.INK_InitData();

            foreach (var polyline in strokes)
            {
                WritePadAPI.AddStroke(InkData, polyline);
            }

            var res = "";
            var resultStringList = new List<string>();
            var wordList = new List<List<WordAlternative>>();
            var defaultResultPtr = WritePadAPI.recognizeInkData(InkData, 0);
            var defaultResult = Marshal.PtrToStringUni(defaultResultPtr);
            resultStringList.Add(defaultResult);
            var wordCount = WritePadAPI.HWR_GetResultWordCount(WritePadAPI.getRecoHandle());
            for (var i = 0; i < wordCount; i++)
            {
                var wordAlternativesList = new List<WordAlternative>();
                var altCount = WritePadAPI.HWR_GetResultAlternativeCount(WritePadAPI.getRecoHandle(), i);
                for (var j = 0; j < altCount; j++)
                {
                    var wordPtr = WritePadAPI.getResultWord(i, j);
                    var word = Marshal.PtrToStringUni(wordPtr);
                    if (word == "<--->")
                        word = "*Error*";
                    if (string.IsNullOrEmpty(word))
                        continue;
                    uint flags = WritePadAPI.HWR_GetRecognitionFlags(WritePadAPI.getRecoHandle());
                    var weight = WritePadAPI.HWR_GetResultWeight(WritePadAPI.getRecoHandle(), i, j);
                    if (weight == 0)
                    {
                        continue;
                    }
                    if (j == 0 && bLearn && weight > 75 && 0 != (flags & WritePadAPI.FLAG_ANALYZER))
                    {
                        // if learner is enabled, learn default word(s) when the Return gesture is used
                        WritePadAPI.recoLearnWord(word, weight);
                    }
                    if (wordAlternativesList.All(x => x.Word != word))
                    {
                        wordAlternativesList.Add(new WordAlternative
                        {
                            Word = word,
                            Weight = weight
                        }
                        );
                    }
                    while (resultStringList.Count < j + 2)
                    {
                        var emptyStr = "";
                        for (int k = 0; k < i; k++)
                        {
                            emptyStr += "\t";
                        }
                        resultStringList.Add(emptyStr);
                    }
                    if (resultStringList[j + 1].Length > 0)
                        resultStringList[j + 1] += "\t\t";
                    resultStringList[j + 1] += word + "\t[" + weight + "%]";
                }
                wordList.Add(wordAlternativesList);
            }

            foreach (var line in resultStringList)
            {
                if (string.IsNullOrEmpty(line))
                    continue;
                if (res.Length > 0)
                {
                    res += Environment.NewLine;
                }
                res += line;
            }

            return res;
        }


        public static List<Point> points = new List<Point>();
        public static List<List<Point>> polylineList = new List<List<Point>>(); 

        private void panel1_MouseMove(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                _currentContactPt = e.Location;
                panelCanvas.AddPixelToStroke();

                panelCanvas.Invalidate();
            }
        }

        private void panelCanvas_MouseDown(object sender, MouseEventArgs e)
        {
            polylineList.Add(new List<Point>());
        }

        private void panelCanvas_MouseUp(object sender, MouseEventArgs e)
        {
            var gesture = WritePadAPI.detectGesture(WritePadAPI.GEST_CUT | WritePadAPI.GEST_RETURN, polylineList[polylineList.Count - 1]);

            switch (gesture)
            {
                case WritePadAPI.GEST_RETURN:
                    polylineList.RemoveAt(polylineList.Count - 1);    
                    Refresh();
                    var result = RecognizeStrokes(polylineList, true);
                    if (string.IsNullOrEmpty(result))
                    {
                        MessageBox.Show("Text could not be recognized.");
                        result = "";
                    }
                    textBox1.Text = result;
                    return;
                case WritePadAPI.GEST_CUT:
                    ClearInk();
                    return;
            }
        }

        private void buttonClear_Click(object sender, EventArgs e)
        {
            ClearInk();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            var langId = WritePadAPI.getLanguage();
            UpdateSelectedLanguage(langId);
        }

        private void UpdateSelectedLanguage(WritePadAPI.LanguageType langId)
        {
            var langIndex = 0;
            switch (langId)
            {
                case WritePadAPI.LanguageType.en:
                    langIndex = 0;
                    break;
                case WritePadAPI.LanguageType.en_uk:
                    langIndex = 1;
                    break;
                case WritePadAPI.LanguageType.de:
                    langIndex = 2;
                    break;
                case WritePadAPI.LanguageType.fr:
                    langIndex = 3;
                    break;
                case WritePadAPI.LanguageType.es:
                    langIndex = 4;
                    break;
                case WritePadAPI.LanguageType.pt_PT:
                    langIndex = 5;
                    break;
                case WritePadAPI.LanguageType.pt_BR:
                    langIndex = 6;
                    break;
                case WritePadAPI.LanguageType.nl:
                    langIndex = 7;
                    break;
                case WritePadAPI.LanguageType.it:
                    langIndex = 8;
                    break;
                case WritePadAPI.LanguageType.fi:
                    langIndex = 9;
                    break;
                case WritePadAPI.LanguageType.sv:
                    langIndex = 10;
                    break;
                case WritePadAPI.LanguageType.nb:
                    langIndex = 11;
                    break;
                case WritePadAPI.LanguageType.da:
                    langIndex = 12;
                    break;
            }
            LanguagesCombo.SelectedIndex = langIndex;
        }

        private void LanguagesCombo_SelectedIndexChanged(object sender, EventArgs e)
        {
            var selIndex = (sender as ComboBox).SelectedIndex;
            var language = WritePadAPI.LanguageType.en;
            switch (selIndex)
            {
                case 0:
                    language = WritePadAPI.LanguageType.en;
                    break;
                case 1:
                    language = WritePadAPI.LanguageType.en_uk;
                    break;
                case 2:
                    language = WritePadAPI.LanguageType.de;
                    break;
                case 3:
                    language = WritePadAPI.LanguageType.fr;
                    break;
                case 4:
                    language = WritePadAPI.LanguageType.es;
                    break;
                case 5:
                    language = WritePadAPI.LanguageType.pt_PT;
                    break;
                case 6:
                    language = WritePadAPI.LanguageType.pt_BR;
                    break;
                case 7:
                    language = WritePadAPI.LanguageType.nl;
                    break;
                case 8:
                    language = WritePadAPI.LanguageType.it;
                    break;
                case 9:
                    language = WritePadAPI.LanguageType.fi;
                    break;
                case 10:
                    language = WritePadAPI.LanguageType.sv;
                    break;
                case 11:
                    language = WritePadAPI.LanguageType.nb;
                    break;
                case 12:
                    language = WritePadAPI.LanguageType.da;
                    break;
            }
            var flags = WritePadAPI.HWR_GetRecognitionFlags(WritePadAPI.getRecoHandle());
            ClearInk();
            WritePadAPI.releaseRecognizer();
            WritePadAPI.language = language;
            DictionaryChanged();
            WritePadAPI.HWR_SetRecognitionFlags(WritePadAPI.getRecoHandle(), flags);
        }

        private void buttonOptions_Click(object sender, EventArgs e)
        {
            new Options().ShowDialog(this);
        }

        private void Form1_Deactivate(object sender, EventArgs e)
        {
            if (InkData != IntPtr.Zero)
            {
                WritePadAPI.INK_Erase(InkData);
                WritePadAPI.INK_FreeData(InkData);
            }
            WritePadAPI.releaseRecognizer();
        }
    }
    public class CustomPanel : Panel
    {
        private const int GRID_GAP = 65;
        public CustomPanel()
        {
            DoubleBuffered = true;
        }

        public static double Distance(double x1, double y1, double x2, double y2)
        {
            return Math.Sqrt(Math.Pow((x2 - x1), 2) + Math.Pow((y2 - y1), 2));
        }

        public void AddPixelToStroke()
        {
            var _x1 = Form1._previousContactPt.X;
            var _y1 = Form1._previousContactPt.Y;
            var _x2 = Form1._currentContactPt.X;
            var _y2 = Form1._currentContactPt.Y;
            var currentStroke = Form1.polylineList[Form1.polylineList.Count - 1];

            if (Distance(_x1, _y1, _x2, _y2) > 2.0)
            {
                PixelAdder.AddPixels(_x2, _y2, false, ref currentStroke);
                Form1._previousContactPt = Form1._currentContactPt;
            }
        }
        protected override void OnPaint(PaintEventArgs e)
        {
            // Call the OnPaint method of the base class.
            base.OnPaint(e);
            var bluePen = new Pen(Color.Blue) {Width = 3.0F};
            e.Graphics.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.None;

            // Call methods of the System.Drawing.Graphics object.
            foreach (var polyline in Form1.polylineList.Where(polyline => polyline.Count > 2))
            {
                e.Graphics.DrawLines(bluePen, polyline.ToArray());
            }
            for (int y = GRID_GAP; y < Height; y += GRID_GAP)
            {
                var gridLine = new[]{new Point(0, y), new Point(Width, y) };
                e.Graphics.DrawLines(Pens.Red, gridLine.ToArray());
            }
        }
    }
}