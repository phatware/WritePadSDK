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
using System.Linq;
using Windows.Foundation;
using Windows.UI.ApplicationSettings;
using Windows.UI.Core;
using Windows.UI.Popups;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls.Primitives;
using Windows.UI.Xaml.Input;

namespace WritePad_CSharpSample
{
    /// <summary>
    /// Here, drawing on canvas and recognition is actually performed
    /// </summary>
    public sealed partial class MainPage
    {
        public Popup SettingsPopup;
        public Popup BrushPalettePopup;
        public const double SettingsWidth = 300;
        public Rect WindowBounds;
        public static MainPage Current;

        private readonly RecognizerShared recognizerShared = new RecognizerShared();

        public MainPage()
        {
            InitializeComponent();
            Current = this;
            
            SettingsPane.GetForCurrentView().CommandsRequested += OnCommandsRequested;
            WindowBounds = Window.Current.Bounds;
            Window.Current.SizeChanged += OnWindowSizeChanged;
        }

        
        private void MainPage_OnLoaded(object sender, RoutedEventArgs e)
        {
            RecognizerShared.DrawGrid(InkCanvas);
            DictionaryChanged();
        }

        private void ClearAllClick(object sender, RoutedEventArgs e)
        {
            recognizerShared.ClearInk(InkCanvas);
        }

        private void OnWindowSizeChanged(object sender, WindowSizeChangedEventArgs e)
        {
            WindowBounds = Window.Current.Bounds;
        }

        #region Canvas
        public void OnCanvasPointerReleased(object sender, PointerRoutedEventArgs e)
        {
            recognizerShared.OnCanvasPointerReleased(sender, e, InkCanvas, RecognizedTextBox);            
        }

        private void OnCanvasPointerMoved(object sender, PointerRoutedEventArgs e)
        {
            recognizerShared.OnCanvasPointerMoved(sender, e, InkCanvas);
        }

        public void OnCanvasPointerPressed(object sender, PointerRoutedEventArgs e)
        {
            recognizerShared.OnCanvasPointerPressed(sender, e, InkCanvas);            
        }

        private void InkCanvas_OnPointerExited(object sender, PointerRoutedEventArgs e)
        {
            OnCanvasPointerReleased(sender, e);
        }

        private void OnCanvasPointerCaptureLost(object sender, PointerRoutedEventArgs e)
        {
            OnCanvasPointerReleased(sender, e);
        }
        #endregion

        #region Recognition
        private async void RecognizeAllClick(object sender, RoutedEventArgs e)
        {
            var result = recognizerShared.RecognizeStrokes(InkCanvas.Children.ToList(), false);
            if (string.IsNullOrEmpty(result))
            {
                var messageBox = new MessageDialog("Text could not be recognized.");
                messageBox.Commands.Add(new UICommand("Close"));
                await messageBox.ShowAsync();
                result = "";
            }
            RecognizedTextBox.Text = result;
        }        
        #endregion
    } 
}
