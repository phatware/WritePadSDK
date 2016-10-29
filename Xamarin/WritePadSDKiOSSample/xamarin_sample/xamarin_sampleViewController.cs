/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    Copyright (c) 2008-2015 PhatWare(r) Corp. All rights reserved.                 * */
/* ************************************************************************************* */

/* ************************************************************************************* *
 *
 * WritePad SDK Xamarin Sample for iOS
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

using System;
using CoreGraphics;
using Foundation;
using UIKit;
using System.Collections.Generic;
using BindingLibrary;

namespace xamarin_sample
{
	public class PickerModel : UIPickerViewModel
	{
		public IList<Object> values;

		public event EventHandler<PickerChangedEventArgs> PickerChanged;

		public PickerModel(IList<Object> values)
		{
			this.values = values;
		}

		public override nint GetComponentCount (UIPickerView picker)
		{
			return 1;
		}

		public override nint GetRowsInComponent (UIPickerView picker, nint component)
		{
			return values.Count;
		}

		public override string GetTitle (UIPickerView picker, nint row, nint component)
		{
			return values[(int)row].ToString ();
		}

		public override nfloat GetRowHeight (UIPickerView picker, nint component)
		{
			return 40f;
		}

		public override void Selected (UIPickerView picker, nint row, nint component)
		{
			if (this.PickerChanged != null)
			{
				this.PickerChanged(this, new PickerChangedEventArgs{SelectedValue = values[(int)row]});
			}
		}

		public class PickerChangedEventArgs : EventArgs
		{
			public object SelectedValue {get;set;}
		}
	}

	public partial class xamarin_sampleViewController : UIViewController
	{
		UILabel recognizedTextLabel;
		UITextView recognizedText;
		UIButton recognizeAllButton;
		UIButton clearButton;
		UIButton languageButton;
		UIButton optionsButton;
		InkView inkView;
		// OptionsViewControllerController optionsController;

		private const float button_width = 80;
		private const float button_gap = 2;
		private const float button_height = 36;
		private const float bottom_gap = 40;
		private const float header_height = 60;
		private const float button_font_size = 15;


		static bool UserInterfaceIdiomIsPhone 
		{
			get { return UIDevice.CurrentDevice.UserInterfaceIdiom == UIUserInterfaceIdiom.Phone; }
		}

		public xamarin_sampleViewController ()
			: base (UserInterfaceIdiomIsPhone ? "xamarin_sampleViewController_iPhone" : "xamarin_sampleViewController_iPad", null)
		{
		}

		public override void WillRotate(UIInterfaceOrientation toInterfaceOrientation, double duration)
		{
			float height = (float)View.Frame.Height;
			float width = (float)View.Frame.Width;
			if (toInterfaceOrientation == UIInterfaceOrientation.LandscapeLeft || toInterfaceOrientation == UIInterfaceOrientation.LandscapeRight) 
			{
				width = (float)View.Frame.Height;
				height = (float)View.Frame.Width;
			}
			inkView.Frame = new CGRect (button_gap, header_height + height/4 + button_gap, width - button_gap * 2, height - bottom_gap - button_gap - (height/4) - header_height - button_gap);
			recognizedText.Frame = new CGRect(button_gap, header_height, width - button_gap * 2, height/4);
			float x = (width - (button_width * 4 + button_gap * 3))/2;
			recognizeAllButton.Frame = new CGRect (x, height - bottom_gap, button_width, button_height);
			x += (button_gap + button_width);
			clearButton.Frame = new CGRect(x, height - bottom_gap, button_width, button_height);
			x += (button_gap + button_width);
			languageButton.Frame = new CGRect(x, height - bottom_gap, button_width, button_height);
			x += (button_gap + button_width);
			optionsButton.Frame = new CGRect(x, height - bottom_gap, button_width, button_height);
		}

		public override void DidReceiveMemoryWarning ()
		{
			// Releases the view if it doesn't have a superview.
			base.DidReceiveMemoryWarning ();
			
			// Release any cached data, images, etc that aren't in use.
		}

		public override void ViewDidAppear( bool animated )
		{
			base.ViewDidAppear( animated );
			UIInterfaceOrientation orientation = UIApplication.SharedApplication.StatusBarOrientation;
			WillRotate( orientation, 0.0 );
		}
			
		public override void ViewDidLoad ()
		{
			base.ViewDidLoad ();
			UIInterfaceOrientation orientation = UIApplication.SharedApplication.StatusBarOrientation;
			float width = (float)View.Frame.Width;

			float height = (float)View.Frame.Height;
			if (orientation == UIInterfaceOrientation.LandscapeLeft || orientation == UIInterfaceOrientation.LandscapeRight) 
			{
				width = (float)View.Frame.Height;
				height = (float)View.Frame.Width;
			}

			recognizedTextLabel = new UILabel (new CGRect(button_gap, 30, width, 20));
			recognizedTextLabel.Text = "Recognized Text:";
			View.Add (recognizedTextLabel);
			recognizedText = new UITextView (new CGRect (button_gap, header_height, width - button_gap * 2, height/4));
			recognizedText.Editable = false;
			recognizedText.Font = UIFont.FromName ("Courier", 18);
			recognizedText.Text = "";
			recognizedText.BackgroundColor = UIColor.Gray;
			recognizedText.TextColor = UIColor.White;
			View.Add (recognizedText);
			inkView = new InkView ();
			inkView.Frame = new CGRect (button_gap, header_height + height/4 + button_gap, width - button_gap * 2, height - bottom_gap - (height/4) - header_height - button_gap);
			inkView.ContentMode = UIViewContentMode.Redraw;
			View.Add (inkView);

			inkView.OnReturnGesture += () => recognizedText.Text = inkView.Recognize( true );
			inkView.OnReturnGesture += () => inkView.cleanView(true);
			inkView.OnCutGesture += () => inkView.cleanView(true);

			float x = (width - (button_width * 4 + button_gap * 3))/2;
			recognizeAllButton = new UIButton (UIButtonType.Custom);
			recognizeAllButton.Frame = new CGRect (x, height - bottom_gap, button_width, button_height);
			recognizeAllButton.SetTitle("Recognize", UIControlState.Normal);
			recognizeAllButton.Font = UIFont.SystemFontOfSize( button_font_size );
			recognizeAllButton.SetTitleColor (UIColor.Blue, UIControlState.Normal);
			recognizeAllButton.SetTitleColor (UIColor.White, UIControlState.Highlighted);
			recognizeAllButton.TouchUpInside += (object sender, EventArgs e) => 
			{
				recognizedText.Text = inkView.Recognize( false );
			};
			View.Add (recognizeAllButton);
			x += (button_gap + button_width);
			clearButton = new UIButton (UIButtonType.Custom);
			clearButton.Frame = new CGRect (x, height - bottom_gap, button_width, button_height);
			clearButton.SetTitle("Clear", UIControlState.Normal);
			clearButton.Font = UIFont.SystemFontOfSize( button_font_size );
			clearButton.SetTitleColor (UIColor.Blue, UIControlState.Normal);
			clearButton.SetTitleColor (UIColor.White, UIControlState.Highlighted);
			clearButton.TouchUpInside += (object sender, EventArgs e) => 
			{
				inkView.cleanView(true);
			};
			View.Add (clearButton);

			x += (button_gap + button_width);
			languageButton = new UIButton (UIButtonType.Custom);
			languageButton.Frame = new CGRect (x , height - bottom_gap, button_width, button_height);
			languageButton.SetTitle("Language", UIControlState.Normal);
			languageButton.Font = UIFont.SystemFontOfSize( button_font_size );
			languageButton.SetTitleColor (UIColor.Blue, UIControlState.Normal);
			languageButton.SetTitleColor (UIColor.White, UIControlState.Highlighted);
			languageButton.TouchUpInside += (object sender, EventArgs e) => 
			{
				var actionSheet = new UIActionSheet ("Select Language:", null, "Cancel", null, 
					new []{"English", "English UK", "German", "French", "Spanish", "Portuguese", "Brazilian", "Dutch", "Italian", "Finnish", "Swedish", "Norwegian", "Danish", "Indonesian"});
				actionSheet.Clicked += delegate(object a, UIButtonEventArgs b) {
					switch (b.ButtonIndex)
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
					WritePadAPI.recoFree();
					WritePadAPI.recoInit();
                    WritePadAPI.initializeFlags();
					inkView.cleanView(true);
					recognizedTextLabel.Text = "Language: "+ " (" + WritePadAPI.getLanguageName() + ")";           
				};
				actionSheet.ShowInView (View);
			};
			View.Add (languageButton);

			x += (button_gap + button_width);
			optionsButton = new UIButton (UIButtonType.Custom);
			optionsButton.Frame = new CGRect (x, height - bottom_gap, button_width, button_height);
			optionsButton.SetTitle("Options", UIControlState.Normal);
			optionsButton.Font = UIFont.SystemFontOfSize( button_font_size );
			optionsButton.SetTitleColor (UIColor.Blue, UIControlState.Normal);
			optionsButton.SetTitleColor (UIColor.White, UIControlState.Highlighted);
			optionsButton.TouchUpInside += (object sender, EventArgs e) => 
			{
				OptionsViewControllerController optionsController = new OptionsViewControllerController();
				UINavigationController navController = new UINavigationController(optionsController);
				navController.ModalPresentationStyle = UIModalPresentationStyle.FormSheet;
				PresentViewController(navController, true, null);

			};
			View.Add (optionsButton);

			recognizedTextLabel.Text = "Language: "+ " (" + WritePadAPI.getLanguageName() + ")";           
		}

	}
}

