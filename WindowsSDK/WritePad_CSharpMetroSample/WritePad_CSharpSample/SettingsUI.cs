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
using Windows.UI.ApplicationSettings;
using Windows.UI.Popups;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Controls.Primitives;
using Windows.UI.Xaml.Media.Animation;
using WritePad_CSharpSample.Model;
using WritePad_CSharpSample.SDK;
using WritePad_CSharpSample.ViewModel;

namespace WritePad_CSharpSample
{
    /// <summary>
    /// Handle application settings charm, including handwriting options.
    /// </summary>
    partial class MainPage
    {
        #region Settings
        private void OnCommandsRequested(SettingsPane sender, SettingsPaneCommandsRequestedEventArgs args)
        {
            var menuCommand = new SettingsCommand("handwritingSettings", "Handwriting options", OnHandwritingSettingsCommand);
            args.Request.ApplicationCommands.Add(menuCommand);
            menuCommand = new SettingsCommand("about", "About", OnAboutCommand);
            args.Request.ApplicationCommands.Add(menuCommand);
        }

        private void OnAboutCommand(IUICommand command)
        {
            SettingsPopup = new Popup();
            SettingsPopup.IsLightDismissEnabled = true;
            SettingsPopup.Width = SettingsWidth;
            SettingsPopup.Height = WindowBounds.Height;

            SettingsPopup.ChildTransitions = new TransitionCollection
                                                  {
                                                      new PaneThemeTransition
                                                          {
                                                              Edge = (SettingsPane.Edge == SettingsEdgeLocation.Right)
                                                                         ? EdgeTransitionLocation.Right
                                                                         : EdgeTransitionLocation.Left
                                                          }
                                                  };

            var mypane = new AboutFlyout { Width = SettingsWidth, Height = WindowBounds.Height };

            SettingsPopup.Child = mypane;

            SettingsPopup.SetValue(Canvas.LeftProperty,
                                    SettingsPane.Edge == SettingsEdgeLocation.Right
                                        ? (WindowBounds.Width - SettingsWidth)
                                        : 0);
            SettingsPopup.SetValue(Canvas.TopProperty, 0);
            SettingsPopup.IsOpen = true;
        }

        public bool EditDictionaryWord = false;
        public void ShowDictionaryPopup(bool isEdit, string item)
        {
            SelectedDictionaryItem = item;
            EditDictionaryWord = isEdit;
            var mypane = new EditDictionaryWordFlyout { Width = MainPage.SettingsWidth, Height = MainPage.Current.WindowBounds.Height };

            Current.SettingsPopup.Child = mypane;

            Current.SettingsPopup.SetValue(Canvas.LeftProperty,
                                    SettingsPane.Edge == SettingsEdgeLocation.Right
                                        ? (Current.WindowBounds.Width - SettingsWidth)
                                        : 0);
            Current.SettingsPopup.SetValue(Canvas.TopProperty, 0);

            if (isEdit)
            {
                mypane.DeleteButton.Visibility = Visibility.Visible;

                mypane.DictionaryWord.Text = item;
                mypane.Title.Text = "Edit word";
            }
            else
            {
                mypane.DeleteButton.Visibility = Visibility.Collapsed;

                mypane.DictionaryWord.Text = string.Empty;
                mypane.Title.Text = "Insert word";
            }
            Current.SettingsPopup.IsOpen = true;
        }

        public HandwritingSettingsModel.CorrectionStructure SelectedCorrectionStructure;

        public void ShowAutoCorrectionPopup(bool isEdit, HandwritingSettingsModel.CorrectionStructure correctionStructure)
        {
            var mypane = new EditAutoCorrectorWordFlyout { Width = MainPage.SettingsWidth, Height = MainPage.Current.WindowBounds.Height };

            Current.SettingsPopup.Child = mypane;

            Current.SettingsPopup.SetValue(Canvas.LeftProperty,
                                    SettingsPane.Edge == SettingsEdgeLocation.Right
                                        ? (MainPage.Current.WindowBounds.Width - MainPage.SettingsWidth)
                                        : 0);
            Current.SettingsPopup.SetValue(Canvas.TopProperty, 0);

            if (isEdit)
            {
                if (correctionStructure == null)
                    return;
                mypane.EditWordCorrectionTitle.Text = "Edit word pair";
                mypane.AutocorrectDeleteButton.Visibility = Visibility.Visible;

                mypane.AutoCorrectionAlwaysReplace.IsOn = correctionStructure.IsAlwaysReplace;
                mypane.AutoCorrectionDisabled.IsOn = correctionStructure.IsDisabled;
                mypane.AutoCorrectionIgnoreCase.IsOn = correctionStructure.IsIgnoreCase;
                mypane.AutoCorrectionFirstWord.Text = correctionStructure.FirstWord;
                mypane.AutoCorrectionSecondWord.Text = correctionStructure.SecondWord;
            }
            else
            {
                mypane.EditWordCorrectionTitle.Text = "New word pair";
                mypane.AutocorrectDeleteButton.Visibility = Visibility.Collapsed;

                mypane.AutoCorrectionAlwaysReplace.IsOn = true;
                mypane.AutoCorrectionDisabled.IsOn = false;
                mypane.AutoCorrectionIgnoreCase.IsOn = true;
                mypane.AutoCorrectionFirstWord.Text = string.Empty;
                mypane.AutoCorrectionSecondWord.Text = string.Empty;
            }
            SelectedCorrectionStructure = correctionStructure;
            Current.SettingsPopup.IsOpen = true;

        }

        public void OnEditUserWordList()
        {
            var mypane = new EditDictionaryListFlyout() { Width = SettingsWidth, Height = WindowBounds.Height };

            SettingsPopup.Child = mypane;

            SettingsPopup.SetValue(Canvas.LeftProperty,
                                    SettingsPane.Edge == SettingsEdgeLocation.Right
                                        ? (WindowBounds.Width - SettingsWidth)
                                        : 0);
            SettingsPopup.SetValue(Canvas.TopProperty, 0);
            SettingsPopup.IsOpen = true;
        }

        public void OnEditAutocorrectorList()
        {
            var mypane = new EditAutoCorrectorListFlyout { Width = SettingsWidth, Height = WindowBounds.Height };

            SettingsPopup.Child = mypane;

            SettingsPopup.SetValue(Canvas.LeftProperty,
                                    SettingsPane.Edge == SettingsEdgeLocation.Right
                                        ? (WindowBounds.Width - SettingsWidth)
                                        : 0);
            SettingsPopup.SetValue(Canvas.TopProperty, 0);
            SettingsPopup.IsOpen = true;
        }

        public string SelectedDictionaryItem;

        private void SaveAutoCorrectionWordClick(object sender, RoutedEventArgs e)
        {
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
            AddAutoCorrectionWordLightDismissAnimatedPopup.IsOpen = false;
        }

        private void DeleteAutoCorrectionWordClick(object sender, RoutedEventArgs e)
        {
            var item = SelectedCorrectionStructure;

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
            AddAutoCorrectionWordLightDismissAnimatedPopup.IsOpen = false;

        }

        private void EditAutoCorrectionWordClick(object sender, RoutedEventArgs e)
        {
            var item = SelectedCorrectionStructure;

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
                    if (AutoCorrectionIgnoreCase.IsOn)
                    {
                    }
                    if (AutoCorrectionAlwaysReplace.IsOn)
                    {
                    }
                    if (AutoCorrectionDisabled.IsOn)
                    {
                    }

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

            AddAutoCorrectionWordLightDismissAnimatedPopup.IsOpen = false;
            settingsModel.OnPropertyChanged("AutoCorrectionList");
        }

        public void OnHandwritingSettingsCommand(IUICommand command)
        {
            OpenSettingsPopup();
            var mypane = new HandwritingSettingsFlyout { Width = SettingsWidth, Height = WindowBounds.Height };

            SettingsPopup.Child = mypane;

            SettingsPopup.SetValue(Canvas.LeftProperty,
                                    SettingsPane.Edge == SettingsEdgeLocation.Right
                                        ? (WindowBounds.Width - SettingsWidth)
                                        : 0);
            SettingsPopup.SetValue(Canvas.TopProperty, 0);
            SettingsPopup.IsOpen = true;
        }

        public void OnHandwritingSettings()
        {
            var mypane = new HandwritingSettingsFlyout { Width = SettingsWidth, Height = WindowBounds.Height };

            SettingsPopup.Child = mypane;

            SettingsPopup.SetValue(Canvas.LeftProperty,
                                    SettingsPane.Edge == SettingsEdgeLocation.Right
                                        ? (WindowBounds.Width - SettingsWidth)
                                        : 0);
            SettingsPopup.SetValue(Canvas.TopProperty, 0);
            SettingsPopup.IsOpen = true;
        }

        public void OpenSettingsPopup()
        {
            SettingsPopup = new Popup
                {
                    IsLightDismissEnabled = true,
                    Width = SettingsWidth,
                    Height = WindowBounds.Height,
                    ChildTransitions = new TransitionCollection
                        {
                            new PaneThemeTransition
                                {
                                    Edge = (SettingsPane.Edge == SettingsEdgeLocation.Right)
                                               ? EdgeTransitionLocation.Right
                                               : EdgeTransitionLocation.Left
                                }
                        }
                };
        }

        public async void DictionaryChanged()
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
            WritePadAPI.initRecognizerForLanguage(new HandwritingSettingsModel().CurrentLanguage, userpath.Path, Package.Current.InstalledLocation.Path, flags);
        }

        #endregion
    }
}
