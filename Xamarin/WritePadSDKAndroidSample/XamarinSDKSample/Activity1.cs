/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    Copyright (c) 2008-2015 PhatWare(r) Corp. All rights reserved.                 * */
/* ************************************************************************************* */

/* ************************************************************************************* *
 *
 * WritePad SDK Xamarin Sample for Android
 *
 * Unauthorized distribution of this code is prohibited. For more information
 * refer to the End User Software License Agreement provided with this
 * software.
 *
 * This source code is distributed and supported by PhatWare Corp.
 * http://www.phatware.com
 *
 * THIS SAMPLE CODE CAN BE USED  AS A REFERENCE AND, IN ITS BINARY FORM,
 * IN THE USER'S PROJECT WHICH IS INTEGRATED WITH THE WRITEPAD SDK.
 * ANY OTHER USE OF THIS CODE IS PROHIBITED.
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
 * 1314 S. Grand Blvd. Ste. 2-175 Spokane, WA 99202
 *
 * ************************************************************************************* */

using Android.App;
using Android.Text.Method;
using Android.Widget;
using Android.OS;

namespace WritePadXamarinSample
{
    [Activity(Label = "WritePadXamarinSample", MainLauncher = true, Icon = "@drawable/icon")]
    public class Activity1 : Activity
    {
        protected override void OnDestroy()
        {
            base.OnDestroy();
            WritePadAPI.recoFree();                    
        }
        
        protected override void OnCreate(Bundle bundle)
        {
            base.OnCreate(bundle);

            SetContentView(Resource.Layout.Main);

			WritePadAPI.recoInit(BaseContext);
            WritePadAPI.initializeFlags(BaseContext);    
            
            var button = FindViewById<Button>(Resource.Id.RecognizeButton);
            var inkView = FindViewById<InkView>(Resource.Id.ink_view);
            var readyText = FindViewById<TextView>(Resource.Id.ready_text);
            var readyTextTitle = FindViewById<TextView>(Resource.Id.ready_text_title);
            var languageBtn = FindViewById<Button>(Resource.Id.LanguageButton);
			var optionsBtn = FindViewById<Button>(Resource.Id.OptionsButton);

            readyText.MovementMethod = new ScrollingMovementMethod();
            readyTextTitle.Text = Resources.GetString(Resource.String.Title) + " (" + WritePadAPI.getLanguageName() + ")";           
                
            button.Click += delegate
            {
				readyText.Text = inkView.Recognize( false );               
            };

			optionsBtn.Click += delegate
			{
				// show options dialog
				StartActivity( typeof(WritePadOptions) );

			};

            languageBtn.Click += delegate
            {
                var builder = new AlertDialog.Builder(this);
                builder.SetTitle("Select language");
				var languages = new[]{"English", "English (UK)", "German", "French", "Spanish", "Portuguese", 
					"Portuguese (Brazilian)", "Dutch", "Italian", "Finnish", "Sweddish", "Norwegian", 
					"Danish", "Indonesian"};
                var selection = 0;
                switch (WritePadAPI.language)
                {
                    case WritePadAPI.LanguageType.en:
                        selection = 0;
                        break;
                    case WritePadAPI.LanguageType.en_uk:
                        selection = 1;
                        break;
                    case WritePadAPI.LanguageType.de:
                        selection = 2;
                        break;
                    case WritePadAPI.LanguageType.fr:
                        selection = 3;
                        break;
                    case WritePadAPI.LanguageType.es:
                        selection = 4;
                        break;
                    case WritePadAPI.LanguageType.pt_PT:
                        selection = 5;
                        break;
                    case WritePadAPI.LanguageType.pt_BR:
                        selection = 6;
                        break;
                    case WritePadAPI.LanguageType.nl:
                        selection = 7;
                        break;
                    case WritePadAPI.LanguageType.it:
                        selection = 8;
                        break;
                    case WritePadAPI.LanguageType.fi:
                        selection = 9;
                        break;
                    case WritePadAPI.LanguageType.sv:
                        selection = 10;
                        break;
                    case WritePadAPI.LanguageType.nb:
                        selection = 11;
                        break;
					case WritePadAPI.LanguageType.da:
						selection = 12;
						break;
					case WritePadAPI.LanguageType.id:
						selection = 13;
						break;
                }
                builder.SetSingleChoiceItems(languages, selection, (sender, args) =>
                {
                    WritePadAPI.recoFree();
                    switch (args.Which)
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
						case 13:
							WritePadAPI.language = WritePadAPI.LanguageType.id;
							break;                       
                    }
					WritePadAPI.recoInit(BaseContext);
                    WritePadAPI.initializeFlags(BaseContext);
                    inkView.cleanView(true);
                    readyTextTitle.Text = Resources.GetString(Resource.String.Title) + " (" + WritePadAPI.getLanguageName() + ")";           
                });
                var alert = builder.Create();
                alert.Show();               
            };
			inkView.OnReturnGesture += () => readyText.Text = inkView.Recognize( true );
			inkView.OnReturnGesture += () => inkView.cleanView(true);
            inkView.OnCutGesture += () => inkView.cleanView(true);
			var clearbtn = FindViewById<Button>(Resource.Id.ClearButton);
			clearbtn.Click += delegate
			{
				readyText.Text = "";
				inkView.cleanView(true);
			};
        }
    }
}

