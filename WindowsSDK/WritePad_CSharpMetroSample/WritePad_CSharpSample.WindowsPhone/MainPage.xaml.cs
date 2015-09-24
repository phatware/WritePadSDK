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
using Windows.ApplicationModel;
using Windows.Storage;
using Windows.UI.Popups;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Input;
using Windows.UI.Xaml.Navigation;
using WritePad_CSharpSample.SDK;

namespace WritePad_CSharpSample
{
    public sealed partial class MainPage
    {
        private readonly RecognizerShared recognizerShared = new RecognizerShared();

        public MainPage()
        {
            InitializeComponent();

            NavigationCacheMode = NavigationCacheMode.Required;
        }

        /// <summary>
        /// Invoked when this page is about to be displayed in a Frame.
        /// </summary>
        /// <param name="e">Event data that describes how this page was reached.
        /// This parameter is typically used to configure the page.</param>
        protected override async void OnNavigatedTo(NavigationEventArgs e)
        {
            if (Options.languageChanged)
            {
                OnDictionaryChanged();
            }
        }

        private void MainPage_OnLoaded(object sender, RoutedEventArgs e)
        {
            RecognizerShared.DrawGrid(InkCanvas);
            OnDictionaryChanged();            
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

        private void ClearAllClick(object sender, RoutedEventArgs e)
        {
            recognizerShared.ClearInk(InkCanvas);
        }

        #endregion

        private async void OnDictionaryChanged()
        {
            StorageFolder userpath = null;
            WritePadAPI.resetRecognizer();
            try
            {
                userpath = await ApplicationData.Current.LocalFolder.CreateFolderAsync("Dictionaries");
            }
            catch (Exception)
            {
            }
            if (userpath == null)
            {
                userpath = await ApplicationData.Current.LocalFolder.GetFolderAsync("Dictionaries");
            }
            var flags = WritePadAPI.HWR_GetRecognitionFlags(WritePadAPI.getRecoHandle());
            WritePadAPI.initRecognizerForLanguage((int)WritePadAPI.language, userpath.Path, Package.Current.InstalledLocation.Path, flags);            
        }

        private void ButtonBase_OnClick(object sender, RoutedEventArgs e)
        {
            Frame.Navigate(typeof(Options));
        }
    }
}
