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

using System.Windows;
using WritePadSDK_WPFSample.SDK;

namespace WritePadSDK_WPFSample
{
    public partial class Options
    {
        public Options()
        {
            InitializeComponent();
        }

        private uint flags;

        private void Options_OnLoaded(object sender, RoutedEventArgs e)
        {
            flags = WritePadAPI.HWR_GetRecognitionFlags(WritePadAPI.getRecoHandle());
            SeparateLetters.IsChecked = WritePadAPI.isRecoFlagSet(flags, WritePadAPI.FLAG_SEPLET);
            DisableSegmentation.IsChecked = WritePadAPI.isRecoFlagSet(flags, WritePadAPI.FLAG_SINGLEWORDONLY);
            AutoLearner.IsChecked = WritePadAPI.isRecoFlagSet(flags, WritePadAPI.FLAG_ANALYZER);
            AutoCorrector.IsChecked = WritePadAPI.isRecoFlagSet(flags, WritePadAPI.FLAG_CORRECTOR);
            UserDictionary.IsChecked = WritePadAPI.isRecoFlagSet(flags, WritePadAPI.FLAG_USERDICT);
            DictionaryOnly.IsChecked = WritePadAPI.isRecoFlagSet(flags, WritePadAPI.FLAG_ONLYDICT);
        }

        private void SeparateLetters_OnClick(object sender, RoutedEventArgs e)
        {
            flags = WritePadAPI.setRecoFlag(flags, SeparateLetters.IsChecked??false, WritePadAPI.FLAG_SEPLET);
            WritePadAPI.HWR_SetRecognitionFlags(WritePadAPI.getRecoHandle(), flags);
        }

        private void DisableSegmentation_OnClick(object sender, RoutedEventArgs e)
        {
            flags = WritePadAPI.setRecoFlag(flags, DisableSegmentation.IsChecked ?? false, WritePadAPI.FLAG_SINGLEWORDONLY);
            WritePadAPI.HWR_SetRecognitionFlags(WritePadAPI.getRecoHandle(), flags);
        }

        private void AutoLearner_OnClick(object sender, RoutedEventArgs e)
        {
            flags = WritePadAPI.setRecoFlag(flags, AutoLearner.IsChecked ?? false, WritePadAPI.FLAG_ANALYZER);
            WritePadAPI.HWR_SetRecognitionFlags(WritePadAPI.getRecoHandle(), flags);
        }

        private void AutoCorrector_OnClick(object sender, RoutedEventArgs e)
        {
            flags = WritePadAPI.setRecoFlag(flags, AutoCorrector.IsChecked ?? false, WritePadAPI.FLAG_CORRECTOR);
            WritePadAPI.HWR_SetRecognitionFlags(WritePadAPI.getRecoHandle(), flags);
        }

        private void UserDictionary_OnClick(object sender, RoutedEventArgs e)
        {
            flags = WritePadAPI.setRecoFlag(flags, UserDictionary.IsChecked ?? false, WritePadAPI.FLAG_USERDICT);
            WritePadAPI.HWR_SetRecognitionFlags(WritePadAPI.getRecoHandle(), flags);
        }

        private void DictionaryOnly_OnClick(object sender, RoutedEventArgs e)
        {
            flags = WritePadAPI.setRecoFlag(flags, DictionaryOnly.IsChecked ?? false, WritePadAPI.FLAG_ONLYDICT);
            WritePadAPI.HWR_SetRecognitionFlags(WritePadAPI.getRecoHandle(), flags);
        }
    }
}
