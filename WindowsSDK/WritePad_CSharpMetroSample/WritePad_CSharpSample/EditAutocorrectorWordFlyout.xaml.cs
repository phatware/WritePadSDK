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
using System.Linq;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls.Primitives;
using WritePad_CSharpSample.Model;
using WritePad_CSharpSample.SDK;
using WritePad_CSharpSample.ViewModel;

namespace WritePad_CSharpSample
{
    /// <summary>
    /// Code-behind for the Edit autocorrector word flyout
    /// </summary>
    public sealed partial class EditAutoCorrectorWordFlyout
    {
        public EditAutoCorrectorWordFlyout()
        {
            InitializeComponent();
        }

        private void GoBack()
        {
            var parent = Parent as Popup;
            if (parent != null)
            {
                parent.IsOpen = false;
            }

            if (Windows.UI.ViewManagement.ApplicationView.Value != Windows.UI.ViewManagement.ApplicationViewState.Snapped)
            {
                MainPage.Current.OnEditAutocorrectorList();
            }
        }

        private void MySettingsBackClicked(object sender, RoutedEventArgs e)
        {
            if (MainPage.Current.SelectedCorrectionStructure != null)
                EditAutoCorrectionWordClick();
            else
                SaveAutoCorrectionWordClick();
            GoBack();
        }


        private void SaveAutoCorrectionWordClick()
        {
            if (string.IsNullOrEmpty(AutoCorrectionFirstWord.Text) ||
                string.IsNullOrEmpty(AutoCorrectionSecondWord.Text))
            {
                return;
            }
            var firstWord = AutoCorrectionFirstWord.Text;
            var secondWord = AutoCorrectionSecondWord.Text;
            var isAlwaysReplace = AutoCorrectionAlwaysReplace.IsOn;
            var isIgnoreCase = AutoCorrectionIgnoreCase.IsOn;
            var isDisabled = AutoCorrectionDisabled.IsOn;

            var settingsModel =
                (EditAutoCorrectorListFlyout.Current.DataContext as HandwritingSettingsViewModel).SettingsModel;
            var list = settingsModel.AutoCorrectionList;
            list.Add(new HandwritingSettingsModel.CorrectionStructure
            {
                FirstWord = firstWord,
                SecondWord = secondWord,
                IsAlwaysReplace = isAlwaysReplace,
                IsDisabled = isDisabled,
                IsIgnoreCase = isIgnoreCase
            });
            var flags = 0;
            if (isIgnoreCase) flags |= WritePadAPI.FLAG_IGNORECASE;
            if (isAlwaysReplace) flags |= WritePadAPI.FLAG_ALWAYS_REPLACE;
            if (isDisabled) flags |= WritePadAPI.FLAG_DISABLED;
            WritePadAPI.HWR_AddWordToWordList(WritePadAPI.getRecoHandle(), firstWord, secondWord, flags, 0);
            WritePadAPI.saveRecognizerDataOfType(WritePadAPI.USERDATA_AUTOCORRECTOR);
            settingsModel.OnPropertyChanged("AutoCorrectionList");
        }

        private void EditAutoCorrectionWordClick()
        {
            if (string.IsNullOrEmpty(AutoCorrectionFirstWord.Text) ||
                string.IsNullOrEmpty(AutoCorrectionSecondWord.Text))
                return;
            var item = MainPage.Current.SelectedCorrectionStructure;

            var settingsModel =
                (EditAutoCorrectorListFlyout.Current.DataContext as HandwritingSettingsViewModel).SettingsModel;
            var list = settingsModel.AutoCorrectionList;

            WritePadAPI.HWR_EmptyWordList(WritePadAPI.getRecoHandle());

            var position = 0;
            foreach (var listItem in list)
            {
                if (listItem.Equals(item))
                {
                    list.Remove(listItem);
                    list.Insert(position, new HandwritingSettingsModel.CorrectionStructure
                    {
                        FirstWord = AutoCorrectionFirstWord.Text,
                        SecondWord = AutoCorrectionSecondWord.Text,
                        IsAlwaysReplace = AutoCorrectionAlwaysReplace.IsOn,
                        IsDisabled = AutoCorrectionDisabled.IsOn,
                        IsIgnoreCase = AutoCorrectionIgnoreCase.IsOn
                    });
                    var flags = 0;
                    if (AutoCorrectionIgnoreCase.IsOn) flags |= WritePadAPI.FLAG_IGNORECASE;
                    if (AutoCorrectionAlwaysReplace.IsOn) flags |= WritePadAPI.FLAG_ALWAYS_REPLACE;
                    if (AutoCorrectionDisabled.IsOn) flags |= WritePadAPI.FLAG_DISABLED;
                    break;
                }

                position += 1;
            }
            foreach (var listItem in list)
            {
                var flags = 0;
                if (listItem.IsIgnoreCase) flags |= WritePadAPI.FLAG_IGNORECASE;
                if (listItem.IsAlwaysReplace) flags |= WritePadAPI.FLAG_ALWAYS_REPLACE;
                if (listItem.IsDisabled) flags |= WritePadAPI.FLAG_DISABLED;
                WritePadAPI.HWR_AddWordToWordList(WritePadAPI.getRecoHandle(), listItem.FirstWord, listItem.SecondWord, flags, 0);
            }
            WritePadAPI.saveRecognizerDataOfType(WritePadAPI.USERDATA_AUTOCORRECTOR);
        }

        private void DeleteAutoCorrectionWordClick(object sender, RoutedEventArgs e)
        {
            var item = MainPage.Current.SelectedCorrectionStructure;

            var settingsModel =
                (EditAutoCorrectorListFlyout.Current.DataContext as HandwritingSettingsViewModel).SettingsModel;
            var list = settingsModel.AutoCorrectionList;

            WritePadAPI.HWR_EmptyWordList(WritePadAPI.getRecoHandle());
            foreach (var listItem in list.Where(listItem => listItem.Equals(item)))
            {
                list.Remove(listItem);

                break;
            }

            foreach (var listItem in list)
            {
                var flags = 0;
                if (listItem.IsIgnoreCase) flags |= WritePadAPI.FLAG_IGNORECASE;
                if (listItem.IsAlwaysReplace) flags |= WritePadAPI.FLAG_ALWAYS_REPLACE;
                if (listItem.IsDisabled) flags |= WritePadAPI.FLAG_DISABLED;
                WritePadAPI.HWR_AddWordToWordList(WritePadAPI.getRecoHandle(), listItem.FirstWord, listItem.SecondWord, flags, 0);
            }
            WritePadAPI.saveRecognizerDataOfType(WritePadAPI.USERDATA_AUTOCORRECTOR);
            settingsModel.OnPropertyChanged("AutoCorrectionList");
            GoBack();
        }
    }
}
