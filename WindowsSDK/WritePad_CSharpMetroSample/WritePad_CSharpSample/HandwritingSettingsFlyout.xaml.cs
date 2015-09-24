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

using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Controls.Primitives;
using Windows.UI.ApplicationSettings;

namespace WritePad_CSharpSample
{
    public sealed partial class HandwritingSettingsFlyout
    {
        public HandwritingSettingsFlyout()
        {
            InitializeComponent();
        }

        private void MySettingsBackClicked(object sender, RoutedEventArgs e)
        {
            // First close our Flyout.
            var parent = Parent as Popup;
            if (parent != null)
            {
                parent.IsOpen = false;
            }

            // If the app is not snapped, then the back button shows the Settings pane again.
            if (Windows.UI.ViewManagement.ApplicationView.Value != Windows.UI.ViewManagement.ApplicationViewState.Snapped)
            {
                SettingsPane.Show();
            }
        }

        private void ManageUserDataClick(object sender, RoutedEventArgs e)
        {
            var mypane = new ManageUserDataFlyout { Width = MainPage.SettingsWidth, Height = MainPage.Current.WindowBounds.Height };

            MainPage.Current.SettingsPopup.Child = mypane;

            MainPage.Current.SettingsPopup.SetValue(Canvas.LeftProperty,
                                    SettingsPane.Edge == SettingsEdgeLocation.Right
                                        ? (MainPage.Current.WindowBounds.Width - MainPage.SettingsWidth)
                                        : 0);
            MainPage.Current.SettingsPopup.SetValue(Canvas.TopProperty, 0);
            MainPage.Current.SettingsPopup.IsOpen = true;
        }

        private void EditUserDictionaryClick(object sender, RoutedEventArgs e)
        {
            var mypane = new EditDictionaryListFlyout { Width = MainPage.SettingsWidth, Height = MainPage.Current.WindowBounds.Height };

            MainPage.Current.SettingsPopup.Child = mypane;

            MainPage.Current.SettingsPopup.SetValue(Canvas.LeftProperty,
                                    SettingsPane.Edge == SettingsEdgeLocation.Right
                                        ? (MainPage.Current.WindowBounds.Width - MainPage.SettingsWidth)
                                        : 0);
            MainPage.Current.SettingsPopup.SetValue(Canvas.TopProperty, 0);
            MainPage.Current.SettingsPopup.IsOpen = true;
        }
        
        private void EditAutoCorrectorListButtonClick(object sender, RoutedEventArgs e)
        {
            var mypane = new EditAutoCorrectorListFlyout { Width = MainPage.SettingsWidth, Height = MainPage.Current.WindowBounds.Height };

            MainPage.Current.SettingsPopup.Child = mypane;

            MainPage.Current.SettingsPopup.SetValue(Canvas.LeftProperty,
                                    SettingsPane.Edge == SettingsEdgeLocation.Right
                                        ? (MainPage.Current.WindowBounds.Width - MainPage.SettingsWidth)
                                        : 0);
            MainPage.Current.SettingsPopup.SetValue(Canvas.TopProperty, 0);
            MainPage.Current.SettingsPopup.IsOpen = true; 
        }
    }
}
