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
using WritePad_CSharpSample.SDK;
using WritePad_CSharpSample.ViewModel;

namespace WritePad_CSharpSample
{
    public sealed partial class EditDictionaryWordFlyout
    {
        public EditDictionaryWordFlyout()
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
                MainPage.Current.OnEditUserWordList();
            }
        }

        private void MySettingsBackClicked(object sender, RoutedEventArgs e)
        {
            if (MainPage.Current.EditDictionaryWord)
                EditUserWord();
            else
                SaveUserWord();
            GoBack();
        }

        private void EditUserWord()
        {
            var item = MainPage.Current.SelectedDictionaryItem;

            var settingsModel =
                (EditDictionaryListFlyout.Current.DataContext as HandwritingSettingsViewModel).
                    SettingsModel;
            var list = settingsModel.DictionaryList;

            var position = 0;
            foreach (var listItem in list)
            {
                if (listItem.Equals(item))
                {
                    list.Remove(listItem);
                    list.Insert(position, DictionaryWord.Text);

                    break;
                }

                position += 1;
            }
            WritePadAPI.HWR_NewUserDict(WritePadAPI.getRecoHandle());
            foreach (var listItem in list)
            {
                WritePadAPI.addWordToUserDictionary(listItem);
            }
            WritePadAPI.saveRecognizerDataOfType(WritePadAPI.USERDATA_DICTIONARY);
}

        private void SaveUserWord()
        {
            var word = DictionaryWord.Text;

            var settingsModel =
                (EditDictionaryListFlyout.Current.DataContext as HandwritingSettingsViewModel).
                    SettingsModel;
            var list = settingsModel.DictionaryList;
            list.Add(word);
            WritePadAPI.addWordToUserDictionary(word);
            WritePadAPI.saveRecognizerDataOfType(WritePadAPI.USERDATA_DICTIONARY);
}

        private void DeleteButton_OnClick(object sender, RoutedEventArgs e)
        {
            var item = MainPage.Current.SelectedDictionaryItem;

            var settingsModel =
                (EditDictionaryListFlyout.Current.DataContext as HandwritingSettingsViewModel).
                    SettingsModel;
            var list = settingsModel.DictionaryList;

            foreach (var listItem in list.Where(listItem => listItem.Equals(item)))
            {
                list.Remove(listItem);

                break;
            }

            WritePadAPI.HWR_NewUserDict(WritePadAPI.getRecoHandle());
            foreach (var listItem in list)
            {
                WritePadAPI.addWordToUserDictionary(listItem);
            }
            WritePadAPI.saveRecognizerDataOfType(WritePadAPI.USERDATA_DICTIONARY);

            GoBack();
        }

    }
}
