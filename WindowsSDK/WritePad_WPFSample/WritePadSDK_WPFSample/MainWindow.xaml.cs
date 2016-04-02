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
using System.ComponentModel;
using System.Linq;
using System.Runtime.InteropServices;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Shapes;
using WritePadSDK_WPFSample.SDK;

namespace WritePadSDK_WPFSample
{
    public partial class MainWindow
    {
        private Point _previousContactPt;
        private Point _currentContactPt;
        private double _x1;
        private double _y1;
        private double _x2;
        private double _y2;

        private const float GRID_GAP = 65;

        public MainWindow()
        {
            InitializeComponent();
        }

        public void DictionaryChanged()
        {
            var path = AppDomain.CurrentDomain.BaseDirectory;
            WritePadAPI.initRecognizerForLanguage((int)WritePadAPI.language, path, path, 0);
        }


        private void RecognizeAllClick(object sender, RoutedEventArgs e)
        {
            var strokes = (from object child in InkCanvas.Children select child as UIElement).ToList();
            var result = RecognizeStrokes(strokes, false);
            if (string.IsNullOrEmpty(result))
            {
                MessageBox.Show("Text could not be recognized.");
                result = "";
            }
            RecognizedTextBox.Text = result;           
        }

        private void DrawGrid()
        {
            for (float y = GRID_GAP; y < InkCanvas.ActualHeight; y += GRID_GAP)
            {
                var line = new Line
                {
                    Stroke = new SolidColorBrush(Colors.Red),
                    X1 = 0,
                    Y1 = y,
                    X2 = InkCanvas.ActualWidth,
                    Y2 = y
                };
                InkCanvas.Children.Add(line);
            }
        }

        private void MainWindow_OnLoaded(object sender, RoutedEventArgs e)
        {
            DrawGrid();
            LanguagesCombo.ItemsSource = new[] { "English", "English (UK)", "German", "French", "Spanish", "Portuguese", "Brazilian", "Dutch", "Italian", "Finnish", "Sweddish", "Norwegian", "Danish", "Indonesian" };
            DictionaryChanged();
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
                case WritePadAPI.LanguageType.id:
                    langIndex = 13;
                    break;

            }
            LanguagesCombo.SelectedIndex = langIndex;
        }

        private void LanguagesCombo_OnSelectionChanged(object sender, SelectionChangedEventArgs e)
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
                case 13:
                    language = WritePadAPI.LanguageType.id;
                    break;
            }
            var flags = WritePadAPI.HWR_GetRecognitionFlags(WritePadAPI.getRecoHandle());
            ClearInk();
            WritePadAPI.releaseRecognizer();
            WritePadAPI.language = language;
            DictionaryChanged();
            WritePadAPI.HWR_SetRecognitionFlags(WritePadAPI.getRecoHandle(), flags);
        }

        private void ClearAllClick(object sender, RoutedEventArgs e)
        {
            ClearInk();
        }

        private void ClearInk()
        {
            if(InkData != IntPtr.Zero)
                WritePadAPI.INK_Erase(InkData);
            InkData = IntPtr.Zero;
            InkCanvas.Children.Clear();
            DrawGrid();
        }

        private void OptionsClick(object sender, RoutedEventArgs e)
        {
            new Options
            {
                Owner = this
            }.ShowDialog();
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
        public string RecognizeStrokes(List<UIElement> strokes, bool bLearn)
        {
            WritePadAPI.HWR_Reset(WritePadAPI.getRecoHandle());
            if (InkData != IntPtr.Zero)
            {
                WritePadAPI.INK_Erase(InkData);
                InkData = IntPtr.Zero;
            }
            InkData = WritePadAPI.INK_InitData();

            foreach (var polyline in strokes.Where(x => x as Polyline != null).Select(x => x as Polyline))
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

#region Canvas
        private void StartAddingStroke(Point pt)
        {
            _previousContactPt = pt;

            _currentStroke.Points.Clear();
            var points = _currentStroke.Points;
            PixelAdder.AddPixels(pt.X, pt.Y, false, ref points);
            _currentStroke.Points = points;

            _currentStroke.StrokeThickness = 5;
            _currentStroke.Stroke = new SolidColorBrush(Colors.Blue);
            _currentStroke.Opacity = 1;
            InkCanvas.Children.Add(_currentStroke);
        }
        
        private void OnCanvasPointerPressed(object sender, MouseButtonEventArgs e)
        {
            var pressPoint = e.GetPosition(InkCanvas);
            StartAddingStroke(pressPoint);
        }

        private void OnCanvasPointerMoved(object sender, MouseEventArgs e)
        {
            if (e.LeftButton != MouseButtonState.Pressed)
                return;
            var currentPoint = e.GetPosition(InkCanvas);

            _currentContactPt = currentPoint;
            AddPixelToStroke();
        }

        private void PointerReleased()
        {
            var gesture = WritePadAPI.detectGesture(WritePadAPI.GEST_CUT | WritePadAPI.GEST_RETURN, _currentStroke.Points);

            switch (gesture)
            {
                case WritePadAPI.GEST_RETURN:
                    InkCanvas.Children.Remove(_currentStroke);
                    _currentStroke.Points.Clear();
                    var strokes = (from object child in InkCanvas.Children select child as UIElement).ToList();
                    var result = RecognizeStrokes(strokes, true);
                    if (string.IsNullOrEmpty(result))
                    {
                        MessageBox.Show("Text could not be recognized.");
                        result = "";
                    }
                    RecognizedTextBox.Text = result;        
                return;
                case WritePadAPI.GEST_CUT:
                    ClearInk();
                    return;
            }

            FinishStrokeDraw();            
        }

        private void OnCanvasPointerReleased(object sender, MouseButtonEventArgs e)
        {
            PointerReleased();
        }

        private void InkCanvas_OnMouseLeave(object sender, MouseEventArgs e)
        {
            PointerReleased();
        }

        public static double Distance(double x1, double y1, double x2, double y2)
        {
            return Math.Sqrt(Math.Pow((x2 - x1), 2) + Math.Pow((y2 - y1), 2));
        }

        private readonly Polyline _currentStroke = new Polyline
        {
            StrokeStartLineCap = PenLineCap.Round,
            StrokeEndLineCap = PenLineCap.Round,
            StrokeLineJoin = PenLineJoin.Round
        };

        public void FinishStrokeDraw()
        {
            if (_currentStroke.Points.Count == 1)
            {
                var newPoint = _currentStroke.Points[0];
                _currentStroke.Points.Add(new Point(newPoint.X + 1, newPoint.Y));
            }
            if (_currentStroke.Points.Count > 0)
            {
                AddStroke(_currentStroke);
            }
        }

        public void AddStroke(Polyline currentStroke)
        {
            var points = new PointCollection();
            foreach (var point in currentStroke.Points)
            {
                points.Add(point);
            }
            var polyline = new Polyline
            {
                Stroke = currentStroke.Stroke,
                StrokeThickness = currentStroke.StrokeThickness,
                Points = points,
                StrokeStartLineCap = PenLineCap.Round,
                StrokeEndLineCap = PenLineCap.Round,
                StrokeLineJoin = PenLineJoin.Round
            };

            InkCanvas.Children.Add(polyline);
            InkCanvas.Children.Remove(currentStroke);
            currentStroke.Points.Clear();
        }

        private void AddPixelToStroke()
        {
            _x1 = _previousContactPt.X;
            _y1 = _previousContactPt.Y;
            _x2 = _currentContactPt.X;
            _y2 = _currentContactPt.Y;

            var color = Colors.Blue;
            var size = 10;

            if (Distance(_x1, _y1, _x2, _y2) > 2.0)
            {
                if (_currentStroke.Points.Count == 0)
                {
                    _currentStroke.StrokeThickness = size;
                    _currentStroke.Stroke = new SolidColorBrush(color);
                    try
                    {
                        InkCanvas.Children.Remove(_currentStroke);
                    }
                    catch (Exception)
                    {
                    }
                    try
                    {
                        InkCanvas.Children.Add(_currentStroke);
                    }
                    catch (Exception)
                    {
                    }
                }
                var points = _currentStroke.Points;
                PixelAdder.AddPixels(_x2, _y2, false, ref points);
                _currentStroke.Points = points;

                _previousContactPt = _currentContactPt;
            }
        }
#endregion

        private void MainWindow_OnClosing(object sender, CancelEventArgs e)
        {
            if (InkData != IntPtr.Zero)
            {
                WritePadAPI.INK_Erase(InkData);
                WritePadAPI.INK_FreeData(InkData);
            }
            WritePadAPI.releaseRecognizer();
        }
    }
}
