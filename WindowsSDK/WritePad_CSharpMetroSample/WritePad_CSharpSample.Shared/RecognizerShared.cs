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
using System.Linq;
using System.Runtime.InteropServices;
using Windows.Devices.Input;
using Windows.Foundation;
using Windows.UI;
using Windows.UI.Input;
using Windows.UI.Popups;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Input;
using Windows.UI.Xaml.Media;
using Windows.UI.Xaml.Shapes;
using WritePad_CSharpSample.SDK;

namespace WritePad_CSharpSample
{
    public class RecognizerShared
    {
        public const float GRID_GAP = 65;

        public IntPtr InkData = IntPtr.Zero;

        private uint _currentPointerId;

        private Point _previousContactPt;
        private Point _currentContactPt;
        private double _x1;
        private double _y1;
        private double _x2;
        private double _y2;

        private readonly Polyline _currentStroke = new Polyline
        {
            StrokeStartLineCap = PenLineCap.Round,
            StrokeEndLineCap = PenLineCap.Round,
            StrokeLineJoin = PenLineJoin.Round
        };

        private void StartAddingStroke(Point pt, Canvas InkCanvas)
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
        public static double Distance(double x1, double y1, double x2, double y2)
        {
            return Math.Sqrt(Math.Pow((x2 - x1), 2) + Math.Pow((y2 - y1), 2));
        }

        public static void DrawGrid(Canvas InkCanvas)
        {
            for (float y = RecognizerShared.GRID_GAP; y < InkCanvas.ActualHeight; y += RecognizerShared.GRID_GAP)
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

        private void AddPixelToStroke(Canvas InkCanvas)
        {
            _x1 = _previousContactPt.X;
            _y1 = _previousContactPt.Y;
            _x2 = _currentContactPt.X;
            _y2 = _currentContactPt.Y;

            var color = Colors.Blue;
            var size = 10;

            if (RecognizerShared.Distance(_x1, _y1, _x2, _y2) > 2.0)
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

        /// <summary>
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
            var wordList = new List<List<RecognizerShared.WordAlternative>>();
            var defaultResultPtr = WritePadAPI.recognizeInkData(InkData, 0);
            var defaultResult = Marshal.PtrToStringUni(defaultResultPtr);
            resultStringList.Add(defaultResult);
            var wordCount = WritePadAPI.HWR_GetResultWordCount(WritePadAPI.getRecoHandle());
            for (var i = 0; i < wordCount; i++)
            {
                var wordAlternativesList = new List<RecognizerShared.WordAlternative>();
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


        public void ClearInk(Canvas InkCanvas)
        {
            if (InkData != IntPtr.Zero)
                WritePadAPI.INK_Erase(InkData);
            InkData = IntPtr.Zero;
            InkCanvas.Children.Clear();
            DrawGrid(InkCanvas);
        }

        public void FinishStrokeDraw(Canvas InkCanvas)
        {
            if (_currentStroke.Points.Count == 1)
            {
                var newPoint = _currentStroke.Points[0];
                _currentStroke.Points.Add(new Point(newPoint.X + 1, newPoint.Y));
            }
            if (_currentStroke.Points.Count > 0)
            {
                AddStroke(_currentStroke, InkCanvas);
            }
        }

        public void AddStroke(Polyline currentStroke, Canvas InkCanvas)
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
        
        public struct WordAlternative
        {
            public string Word;
            public int Weight;
        }

        public async void OnCanvasPointerReleased(object sender, PointerRoutedEventArgs e, Canvas InkCanvas, TextBox RecognizedTextBox)
        {
            if (e.Pointer.PointerId != _currentPointerId)
                return;
            if (e.GetCurrentPoint(null).Properties.PointerUpdateKind == PointerUpdateKind.RightButtonReleased)
                return;
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
                        var messageBox = new MessageDialog("Text could not be recognized.");
                        messageBox.Commands.Add(new UICommand("Close"));
                        await messageBox.ShowAsync();
                        result = "";
                    }
                    RecognizedTextBox.Text = result;
                    return;
                case WritePadAPI.GEST_CUT:
                    ClearInk(InkCanvas);
                    return;
            }
            FinishStrokeDraw(InkCanvas);
        }

        public void OnCanvasPointerMoved(object sender, PointerRoutedEventArgs e, Canvas InkCanvas)
        {
            if (e.Pointer.PointerId != _currentPointerId)
                return;
            var currentPoint = e.GetCurrentPoint(InkCanvas).Position;

            if (e.Pointer.PointerDeviceType == PointerDeviceType.Mouse)
            {
                var properties = e.GetCurrentPoint(null).Properties;
                if (properties.IsRightButtonPressed || properties.IsMiddleButtonPressed || !properties.IsLeftButtonPressed)
                {
                    return;
                }
            }

            if (!e.Pointer.IsInContact)
                return;

            _currentContactPt = currentPoint;
            AddPixelToStroke(InkCanvas);
        }

        public void OnCanvasPointerPressed(object sender, PointerRoutedEventArgs e, Canvas InkCanvas)
        {
            _currentPointerId = e.Pointer.PointerId;

            var pressPoint = e.GetCurrentPoint(InkCanvas).Position;
            StartAddingStroke(pressPoint, InkCanvas);
        }
    }
}
