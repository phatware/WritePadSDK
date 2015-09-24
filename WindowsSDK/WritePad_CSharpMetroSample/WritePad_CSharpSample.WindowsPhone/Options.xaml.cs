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

using WritePad_CSharpSample.Common;
using System;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Navigation;

using WritePad_CSharpSample.SDK;

namespace WritePad_CSharpSample
{
    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class Options : Page
    {
        private NavigationHelper navigationHelper;
        private ObservableDictionary defaultViewModel = new ObservableDictionary();
        public static bool languageChanged = false;
        public Options()
        {
            this.InitializeComponent();

            this.navigationHelper = new NavigationHelper(this);
            this.navigationHelper.LoadState += this.NavigationHelper_LoadState;
            this.navigationHelper.SaveState += this.NavigationHelper_SaveState;
        }

        /// <summary>
        /// Gets the <see cref="NavigationHelper"/> associated with this <see cref="Page"/>.
        /// </summary>
        public NavigationHelper NavigationHelper
        {
            get { return this.navigationHelper; }
        }

        /// <summary>
        /// Gets the view model for this <see cref="Page"/>.
        /// This can be changed to a strongly typed view model.
        /// </summary>
        public ObservableDictionary DefaultViewModel
        {
            get { return this.defaultViewModel; }
        }

        /// <summary>
        /// Populates the page with content passed during navigation.  Any saved state is also
        /// provided when recreating a page from a prior session.
        /// </summary>
        /// <param name="sender">
        /// The source of the event; typically <see cref="NavigationHelper"/>
        /// </param>
        /// <param name="e">Event data that provides both the navigation parameter passed to
        /// <see cref="Frame.Navigate(Type, Object)"/> when this page was initially requested and
        /// a dictionary of state preserved by this page during an earlier
        /// session.  The state will be null the first time a page is visited.</param>
        private void NavigationHelper_LoadState(object sender, LoadStateEventArgs e)
        {
        }

        /// <summary>
        /// Preserves state associated with this page in case the application is suspended or the
        /// page is discarded from the navigation cache.  Values must conform to the serialization
        /// requirements of <see cref="SuspensionManager.SessionState"/>.
        /// </summary>
        /// <param name="sender">The source of the event; typically <see cref="NavigationHelper"/></param>
        /// <param name="e">Event data that provides an empty dictionary to be populated with
        /// serializable state.</param>
        private void NavigationHelper_SaveState(object sender, SaveStateEventArgs e)
        {
        }

        #region NavigationHelper registration

        /// <summary>
        /// The methods provided in this section are simply used to allow
        /// NavigationHelper to respond to the page's navigation methods.
        /// <para>
        /// Page specific logic should be placed in event handlers for the  
        /// <see cref="NavigationHelper.LoadState"/>
        /// and <see cref="NavigationHelper.SaveState"/>.
        /// The navigation parameter is available in the LoadState method 
        /// in addition to page state preserved during an earlier session.
        /// </para>
        /// </summary>
        /// <param name="e">Provides data for navigation methods and event
        /// handlers that cannot cancel the navigation request.</param>
        protected override void OnNavigatedTo(NavigationEventArgs e)
        {
            this.navigationHelper.OnNavigatedTo(e);
        }

        protected override void OnNavigatedFrom(NavigationEventArgs e)
        {
            this.navigationHelper.OnNavigatedFrom(e);
        }

        #endregion

        private uint recoFlags;

        private void Options_OnLoaded(object sender, RoutedEventArgs e)
        {

            recoFlags = WritePadAPI.HWR_GetRecognitionFlags(WritePadAPI.getRecoHandle());

            separate_letters.IsChecked = WritePadAPI.isRecoFlagSet(recoFlags, WritePadAPI.FLAG_SEPLET);
            single_word.IsChecked = WritePadAPI.isRecoFlagSet(recoFlags, WritePadAPI.FLAG_SINGLEWORDONLY);
            autocorrector.IsChecked = WritePadAPI.isRecoFlagSet(recoFlags, WritePadAPI.FLAG_CORRECTOR);
            autolearner.IsChecked = WritePadAPI.isRecoFlagSet(recoFlags, WritePadAPI.FLAG_ANALYZER);
            user_dictionary.IsChecked = WritePadAPI.isRecoFlagSet(recoFlags, WritePadAPI.FLAG_USERDICT);
            dict_words.IsChecked = WritePadAPI.isRecoFlagSet(recoFlags, WritePadAPI.FLAG_ONLYDICT);

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

        private void Separate_letters_OnClick(object sender, RoutedEventArgs e)
        {
            recoFlags = WritePadAPI.setRecoFlag(recoFlags, separate_letters.IsChecked??false, WritePadAPI.FLAG_SEPLET);
            WritePadAPI.HWR_SetRecognitionFlags(WritePadAPI.getRecoHandle(), recoFlags);
        }
        private void Single_word_OnClick(object sender, RoutedEventArgs e)
        {
            recoFlags = WritePadAPI.setRecoFlag(recoFlags, single_word.IsChecked ?? false, WritePadAPI.FLAG_SINGLEWORDONLY);
            WritePadAPI.HWR_SetRecognitionFlags(WritePadAPI.getRecoHandle(), recoFlags);
        }
        private void Autocorrector_OnClick(object sender, RoutedEventArgs e)
        {
            recoFlags = WritePadAPI.setRecoFlag(recoFlags, autocorrector.IsChecked ?? false, WritePadAPI.FLAG_CORRECTOR);
            WritePadAPI.HWR_SetRecognitionFlags(WritePadAPI.getRecoHandle(), recoFlags);
        }
        private void Autolearner_OnClick(object sender, RoutedEventArgs e)
        {
            recoFlags = WritePadAPI.setRecoFlag(recoFlags, autocorrector.IsChecked ?? false, WritePadAPI.FLAG_ANALYZER);
            WritePadAPI.HWR_SetRecognitionFlags(WritePadAPI.getRecoHandle(), recoFlags);
        }
        private void User_dictionary_OnClick(object sender, RoutedEventArgs e)
        {
            recoFlags = WritePadAPI.setRecoFlag(recoFlags, user_dictionary.IsChecked ?? false, WritePadAPI.FLAG_USERDICT);
            WritePadAPI.HWR_SetRecognitionFlags(WritePadAPI.getRecoHandle(), recoFlags);
        }
        private void Dict_words_OnClick(object sender, RoutedEventArgs e)
        {
            recoFlags = WritePadAPI.setRecoFlag(recoFlags, dict_words.IsChecked ?? false, WritePadAPI.FLAG_ONLYDICT);
            WritePadAPI.HWR_SetRecognitionFlags(WritePadAPI.getRecoHandle(), recoFlags);
        }

        private void LanguagesCombo_OnSelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            languageChanged = true;
            switch (LanguagesCombo.SelectedIndex)
            {
                case 0:
                    WritePadAPI.language = WritePadAPI.LanguageType.en;
                    break;
                case 1:
                    WritePadAPI.language = WritePadAPI.LanguageType.en_uk;
                    break;
                case 2:
                    WritePadAPI.language = WritePadAPI.LanguageType.de;
                    break;
                case 3:
                    WritePadAPI.language = WritePadAPI.LanguageType.fr;
                    break;
                case 4:
                    WritePadAPI.language = WritePadAPI.LanguageType.es;
                    break;
                case 5:
                    WritePadAPI.language = WritePadAPI.LanguageType.pt_PT;
                    break;
                case 6:
                    WritePadAPI.language = WritePadAPI.LanguageType.pt_BR;
                    break;
                case 7:
                    WritePadAPI.language = WritePadAPI.LanguageType.nl;
                    break;
                case 8:
                    WritePadAPI.language = WritePadAPI.LanguageType.it;
                    break;
                case 9:
                    WritePadAPI.language = WritePadAPI.LanguageType.fi;
                    break;
                case 10:
                    WritePadAPI.language = WritePadAPI.LanguageType.sv;
                    break;
                case 11:
                    WritePadAPI.language = WritePadAPI.LanguageType.nb;
                    break;
                case 12:
                    WritePadAPI.language = WritePadAPI.LanguageType.da;
                    break;
            }
        }
    }
}