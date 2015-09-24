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
using System.ComponentModel;
using Windows.Storage;
using System.Linq;
using WritePad_CSharpSample.SDK;

namespace WritePad_CSharpSample.Model
{

    public class HandwritingSettingsModel : INotifyPropertyChanged
    {
        public enum UserWordEditMode
        {
            None,
            NewWord,
            EditWord
        }

        private UserWordEditMode userWordEditMode = UserWordEditMode.None;
        
        public UserWordEditMode UserWordMode
        {
            get { return userWordEditMode; }
            set { userWordEditMode = value;
                OnPropertyChanged("UserWordEdited");
                OnPropertyChanged("UserWordMode");}
        }
        
        public event PropertyChangedEventHandler PropertyChanged;

        public void OnPropertyChanged(string name)
        {
            var handler = PropertyChanged;
            if (handler != null)
            {
                handler(this, new PropertyChangedEventArgs(name));
            }
        }

        public class CorrectionStructure
        {
            public string FirstWord { get; set; }
            public string SecondWord { get; set; }
            public bool IsAlwaysReplace { get; set; }
            public bool IsIgnoreCase { get; set; }
            public bool IsDisabled { get; set; }

            public bool Equals(CorrectionStructure item)
            {
                return item.FirstWord == FirstWord && item.SecondWord == SecondWord && item.IsAlwaysReplace == IsAlwaysReplace && item.IsDisabled == IsDisabled && item.IsIgnoreCase == IsIgnoreCase;
            }
        }

        public List<CorrectionStructure> AutoCorrectionList
        {
            get
            {
                var serializedList = WritePadAPI.getAutocorrectorWords();

                var separatedList = serializedList.Split('\x001');
                var res = new List<CorrectionStructure>();
                var counter = 0;
                var entry = new CorrectionStructure();
                foreach (var word in separatedList)
                {
                    if (string.IsNullOrEmpty(word)) continue;
                    if (counter == 0)
                    {
                        entry.FirstWord = word;
                    }
                    if (counter == 1)
                    {
                        entry.SecondWord = word;
                    }
                    if (counter == 2)
                    {
                        var flag = int.Parse(word);
                        var ignorecase = false;
                        var always = false;
                        var disabled = false;
                        if ((flag & WritePadAPI.FLAG_IGNORECASE) != 0)
                        {
                            ignorecase = true;
                        }
                        if ((flag & WritePadAPI.FLAG_ALWAYS_REPLACE) != 0)
                        {
                            always = true;
                        }
                        if ((flag & WritePadAPI.FLAG_DISABLED) != 0)
                        {
                            disabled = true;
                        }
                        res.Add(new CorrectionStructure
                                    {
                                        FirstWord =  entry.FirstWord,
                                        SecondWord = entry.SecondWord,
                                        IsAlwaysReplace =  always,
                                        IsDisabled = disabled,
                                        IsIgnoreCase = ignorecase
                                    }
                            );
                        counter = -1;
                    }
                    counter++;
                }
                res = (from x in res orderby x.FirstWord select x).ToList();
                
                return res;
            }
            
        }

        public List<string> DictionaryList
        {
            get
            {
                var serializedList = WritePadAPI.getUserWords();

                var separatedList = serializedList.Split('\x001');
                var res = new List<string>();
                foreach (var word in separatedList)
                {
                    if (string.IsNullOrEmpty(word)) continue;
                    res.Add(word);
                }
                res = (from x in res orderby x select x).ToList();
                return res;
            }
            set
            {
                OnPropertyChanged("DictionaryList");
            }
        }

        public bool AutoCorrector
        {
            get
            {
                var flags = WritePadAPI.HWR_GetRecognitionFlags(WritePadAPI.getRecoHandle());
                return WritePadAPI.isRecoFlagSet(flags, WritePadAPI.FLAG_CORRECTOR);                
            }
            set
            {
                var flags = WritePadAPI.HWR_GetRecognitionFlags(WritePadAPI.getRecoHandle());
                flags = WritePadAPI.setRecoFlag(flags, value, WritePadAPI.FLAG_CORRECTOR);
                WritePadAPI.HWR_SetRecognitionFlags(WritePadAPI.getRecoHandle(), flags);
            }           
        }

        public bool SingleWordOnly
        {
            get
            {
                var flags = WritePadAPI.HWR_GetRecognitionFlags(WritePadAPI.getRecoHandle());
                return WritePadAPI.isRecoFlagSet(flags, WritePadAPI.FLAG_SINGLEWORDONLY);
            }
            set
            {
                var flags = WritePadAPI.HWR_GetRecognitionFlags(WritePadAPI.getRecoHandle());
                flags = WritePadAPI.setRecoFlag(flags, value, WritePadAPI.FLAG_SINGLEWORDONLY);
                WritePadAPI.HWR_SetRecognitionFlags(WritePadAPI.getRecoHandle(), flags);
            }         
        }

        public bool AutomaticLearner
        {
            get
            {
                var flags = WritePadAPI.HWR_GetRecognitionFlags(WritePadAPI.getRecoHandle());
                return WritePadAPI.isRecoFlagSet(flags, WritePadAPI.FLAG_ANALYZER);
            }
            set
            {
                var flags = WritePadAPI.HWR_GetRecognitionFlags(WritePadAPI.getRecoHandle());
                flags = WritePadAPI.setRecoFlag(flags, value, WritePadAPI.FLAG_ANALYZER);
                WritePadAPI.HWR_SetRecognitionFlags(WritePadAPI.getRecoHandle(), flags);
            }
        }

        public bool EnableAutocorrector
        {
            get
            {
                var flags = WritePadAPI.HWR_GetRecognitionFlags(WritePadAPI.getRecoHandle());
                return WritePadAPI.isRecoFlagSet(flags, WritePadAPI.FLAG_CORRECTOR);
            }
            set
            {
                var flags = WritePadAPI.HWR_GetRecognitionFlags(WritePadAPI.getRecoHandle());
                flags = WritePadAPI.setRecoFlag(flags, value, WritePadAPI.FLAG_CORRECTOR);
                WritePadAPI.HWR_SetRecognitionFlags(WritePadAPI.getRecoHandle(), flags);
            }
        }     

        public bool SeparateLetters
        {
            get
            {
                var flags = WritePadAPI.HWR_GetRecognitionFlags(WritePadAPI.getRecoHandle());
                return WritePadAPI.isRecoFlagSet(flags, WritePadAPI.FLAG_SEPLET);                
            }
            set
            {
                var flags = WritePadAPI.HWR_GetRecognitionFlags(WritePadAPI.getRecoHandle());
                flags = WritePadAPI.setRecoFlag(flags, value, WritePadAPI.FLAG_SEPLET);
                WritePadAPI.HWR_SetRecognitionFlags(WritePadAPI.getRecoHandle(), flags);
            }
        }

        public bool OnlyKnownWords
        {
            get
            {
                var flags = WritePadAPI.HWR_GetRecognitionFlags(WritePadAPI.getRecoHandle());
                return WritePadAPI.isRecoFlagSet(flags, WritePadAPI.FLAG_ONLYDICT);
            }
            set
            {
                var flags = WritePadAPI.HWR_GetRecognitionFlags(WritePadAPI.getRecoHandle());
                flags = WritePadAPI.setRecoFlag(flags, value, WritePadAPI.FLAG_ONLYDICT);
                WritePadAPI.HWR_SetRecognitionFlags(WritePadAPI.getRecoHandle(), flags);
            }
        }

        public bool UserDictionary
        {
            get
            {
                var flags = WritePadAPI.HWR_GetRecognitionFlags(WritePadAPI.getRecoHandle());
                return WritePadAPI.isRecoFlagSet(flags, WritePadAPI.FLAG_USERDICT);
            }
            set
            {
                var flags = WritePadAPI.HWR_GetRecognitionFlags(WritePadAPI.getRecoHandle());
                flags = WritePadAPI.setRecoFlag(flags, value, WritePadAPI.FLAG_USERDICT);
                WritePadAPI.HWR_SetRecognitionFlags(WritePadAPI.getRecoHandle(), flags);
            }           
        }

        public List<string> Dictionaries
        {
            get
            {
                return new List<string>
                {
                    "Brazilian",
                    "Danish",
                    "Dutch",
                    "English",
                    "English UK",
                    "Finnish",
                    "French",
                    "German",
                    "Italian",
                    "Medical US",
                    "Norwegian",
                    "Portuguese",
                    "Spanish",
                    "Swedish"
                };
            }
        }

        public string CurrentDictionaryFile
        {
            get
            {
                switch (CurrentDictionary)
                {
                    case "Brazilian":
                        return "Brazilian.dct";
                    case "Danish":
                        return "Danish.dct";
                    case "Dutch":
                        return "Dutch.dct";
                    case "English UK":
                        return "EnglishUK.dct";
                    case "Finnish":
                        return "Finnish.dct";
                    case "French":
                        return "French.dct";
                    case "German":
                        return "German.dct";
                    case "Medical US":
                        return "MedicalUS.dct";
                    case "Norwegian":
                        return "Norwegian.dct";
                    case "Portuguese":
                        return "Portuguese.dct";
                    case "Spanish":
                        return "Spanish.dct";
                    case "Swedish":
                        return "Swedish.dct";
                }
                return "English.dct";
            }
        }

        public string CurrentDictionary
        {
            get
            {
                try
                {
                    var res = (string)ApplicationData.Current.LocalSettings.Values["CurrentDictionary"];
                    if(!string.IsNullOrEmpty(res))
                        return res;
                }
                catch (Exception)
                {
                    
                }

                var language = Windows.Globalization.Language.CurrentInputMethodLanguageTag;
                if (language.Contains("en-GB"))
                    return "English UK";
                if (language.Contains("en"))
                    return "English";
                if (language.Contains("da"))
                    return "Danish";
                if (language.Contains("br"))
                    return "Brazilian";
                if (language.Contains("nl"))
                    return "Dutch";
                if (language.Contains("fi"))
                    return "Finnish";
                if (language.Contains("fr"))
                    return "French";
                if (language.Contains("de"))
                    return "German";
                if (language.Contains("it"))
                    return "Italian";
                if (language.Contains("nb"))
                    return "Norwegian";
                if (language.Contains("pt"))
                    return "Portuguese";
                if (language.Contains("es"))
                    return "Spanish";
                if (language.Contains("sv"))
                    return "Swedish";

                return "English";
            }
            set
            {
                ApplicationData.Current.LocalSettings.Values["CurrentDictionary"] = value;
                OnPropertyChanged("CurrentDictionary");
                MainPage.Current.DictionaryChanged(); 
            }
        }
                
        public int CurrentLanguage
        {
            get
            {
                switch (CurrentDictionary)
                {
                    case "Brazilian":
                        return WritePadAPI.LANGUAGE_PORTUGUESEB;
                    case "Danish":
                        return WritePadAPI.LANGUAGE_DANISH;
                    case "Dutch":
                        return WritePadAPI.LANGUAGE_DUTCH;
                    case "English UK":
                        return WritePadAPI.LANGUAGE_ENGLISHUK;
                    case "Finnish":
                        return WritePadAPI.LANGUAGE_FINNISH;
                    case "French":
                        return WritePadAPI.LANGUAGE_FRENCH;
                    case "German":
                        return WritePadAPI.LANGUAGE_GERMAN;
                    case "Medical US":
                        return WritePadAPI.LANGUAGE_MEDICAL;
                    case "Norwegian":
                        return WritePadAPI.LANGUAGE_NORWEGIAN;
                    case "Portuguese":
                        return WritePadAPI.LANGUAGE_PORTUGUESE;
                    case "Spanish":
                        return WritePadAPI.LANGUAGE_SPANISH;
                    case "Swedish":
                        return WritePadAPI.LANGUAGE_SWEDISH;
                }
                return WritePadAPI.LANGUAGE_ENGLISH;
            }
        }

        public bool UserWordEdited
        {
            get { return UserWordMode != UserWordEditMode.None; }
        }
    }
}
