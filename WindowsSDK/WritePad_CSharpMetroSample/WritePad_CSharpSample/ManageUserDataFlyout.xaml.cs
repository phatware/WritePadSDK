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
using Windows.Storage.Pickers;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls.Primitives;
using WritePad_CSharpSample.SDK;

namespace WritePad_CSharpSample
{
    public sealed partial class ManageUserDataFlyout
    {
        public ManageUserDataFlyout()
        {
            InitializeComponent();
        }

        private void MySettingsBackClicked(object sender, RoutedEventArgs e)
        {
            var parent = Parent as Popup;
            if (parent != null)
            {
                parent.IsOpen = false;
            }

            if (Windows.UI.ViewManagement.ApplicationView.Value != Windows.UI.ViewManagement.ApplicationViewState.Snapped)
            {
                MainPage.Current.OnHandwritingSettings();
            }
        }

        private async void ExportDictionaryButtonClick(object sender, RoutedEventArgs e)
        {
            var fileSavePicker = new FileSavePicker();
            fileSavePicker.FileTypeChoices.Add(".txt", new List<string> { ".txt" });
            fileSavePicker.SettingsIdentifier = "picker1";
            
            var fileToSave = await fileSavePicker.PickSaveFileAsync();
            if (fileToSave == null) return;
            WritePadAPI.exportUserDictionary(fileToSave.Path);
        }

        private async void ImportDictionaryButtonClick(object sender, RoutedEventArgs e)
        { 
            var filePicker = new FileOpenPicker();
            filePicker.FileTypeFilter.Add(".txt");
            filePicker.ViewMode = PickerViewMode.Thumbnail;
            filePicker.SuggestedStartLocation = PickerLocationId.DocumentsLibrary;
            filePicker.SettingsIdentifier = "picker1";
            filePicker.CommitButtonText = "Import user dictionary";

            var files = await filePicker.PickSingleFileAsync();
            if (files == null) return;
            WritePadAPI.importUserDictionary(files.Path);
        }

        private async void ExportWordLisButtonClick(object sender, RoutedEventArgs e)
        {
            var fileSavePicker = new FileSavePicker();
            fileSavePicker.FileTypeChoices.Add(".csv", new List<string> { ".csv" });
            fileSavePicker.SettingsIdentifier = "picker1";

            var fileToSave = await fileSavePicker.PickSaveFileAsync();
            if (fileToSave == null) return;
            WritePadAPI.exportAutocorrectorDictionary(fileToSave.Path);
        }

        private async void ImportWordListButtonClick(object sender, RoutedEventArgs e)
        {
            var filePicker = new FileOpenPicker();
            filePicker.FileTypeFilter.Add(".csv");
            filePicker.ViewMode = PickerViewMode.Thumbnail;
            filePicker.SuggestedStartLocation = PickerLocationId.DocumentsLibrary;
            filePicker.SettingsIdentifier = "picker1";
            filePicker.CommitButtonText = "Import autocorrector";

            var file = await filePicker.PickSingleFileAsync();
            if (file == null) return;
            WritePadAPI.importUserDictionary(file.Path);
        }

        private void ResetUserDictionaryButtonClick(object sender, RoutedEventArgs e)
        {
            WritePadAPI.resetRecognizerDataOfType(WritePadAPI.USERDATA_DICTIONARY);
        }

        private void ResetAutocorrectorListButtonClick(object sender, RoutedEventArgs e)
        {
            WritePadAPI.resetRecognizerDataOfType(WritePadAPI.USERDATA_AUTOCORRECTOR);
        }
    }
}