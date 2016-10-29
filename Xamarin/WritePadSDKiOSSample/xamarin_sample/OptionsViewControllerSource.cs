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
using ObjCRuntime;
using BindingLibrary;

namespace xamarin_sample
{
	enum WritePadOptions {
		kWritePadOptionsSepLetters = 0,
		kWritePadOptionsSingleWord,
		kWritePadOptionsDictionaryOnly,
		kWritePadOptionsLearner,
		kWritePadOptionsAutcorrector,
		kWritePadOptionsUserDict,
		kWritePadOptionsTotal
	};



	public class OptionsViewControllerSource : UITableViewSource
	{
		public OptionsViewControllerSource ()
		{
		}

		public override nint NumberOfSections (UITableView tableView)
		{
			// return the actual number of sections
			return 1;
		}

		public override nint RowsInSection (UITableView tableview, nint section)
		{
			// return the actual number of items in the section
			return (int)WritePadOptions.kWritePadOptionsTotal;
		}

		public override string TitleForHeader (UITableView tableView, nint section)
		{
			return null;
		}

		public override string TitleForFooter (UITableView tableView, nint section)
		{
			return null;
		}
			
		public override UITableViewCell GetCell (UITableView tableView, NSIndexPath indexPath)
		{
			var cell = tableView.DequeueReusableCell (OptionsViewControllerCell.Key) as OptionsViewControllerCell;
			if (cell == null)
				cell = new OptionsViewControllerCell ();

			uint flags = WritePadAPI.recoGetFlags();
			var sw = new UISwitch();
			sw.ValueChanged += (object sender, EventArgs e) => {
				UISwitch swit = (UISwitch)sender;
				flags = WritePadAPI.recoGetFlags();
				switch( swit.Tag )
				{
					case (int)WritePadOptions.kWritePadOptionsSepLetters :
						flags = WritePadAPI.setRecoFlag( flags, swit.On, WritePadAPI.FLAG_SEPLET );
						break;
					case (int)WritePadOptions.kWritePadOptionsSingleWord :
                        flags = WritePadAPI.setRecoFlag(flags, swit.On, WritePadAPI.FLAG_SINGLEWORDONLY);
						break;
					case (int)WritePadOptions.kWritePadOptionsLearner :
                        flags = WritePadAPI.setRecoFlag(flags, swit.On, WritePadAPI.FLAG_ANALYZER);
						break;
					case (int)WritePadOptions.kWritePadOptionsAutcorrector :
                        flags = WritePadAPI.setRecoFlag(flags, swit.On, WritePadAPI.FLAG_CORRECTOR);
						break;
					case (int)WritePadOptions.kWritePadOptionsUserDict :
                        flags = WritePadAPI.setRecoFlag(flags, swit.On, WritePadAPI.FLAG_USERDICT);
						break;
					case (int)WritePadOptions.kWritePadOptionsDictionaryOnly :
						flags = WritePadAPI.setRecoFlag(flags, swit.On, WritePadAPI.FLAG_ONLYDICT);
						break;
				}
				WritePadAPI.recoSetFlags( flags );
			};
			sw.Tag = indexPath.Row;
			cell.AccessoryView = sw;
			switch( indexPath.Row )
			{
				case (int)WritePadOptions.kWritePadOptionsSepLetters :
                    sw.On = WritePadAPI.isRecoFlagSet(flags, WritePadAPI.FLAG_SEPLET);
					cell.TextLabel.Text = "Separate letters mode (PRINT)";
					break;
				case (int)WritePadOptions.kWritePadOptionsSingleWord :
                    sw.On = WritePadAPI.isRecoFlagSet(flags, WritePadAPI.FLAG_SINGLEWORDONLY);
					cell.TextLabel.Text = "Disable word segmentation (single word)";
					break;
				case (int)WritePadOptions.kWritePadOptionsLearner :
                    sw.On = WritePadAPI.isRecoFlagSet(flags, WritePadAPI.FLAG_ANALYZER);
					cell.TextLabel.Text = "Enable Automatic learner";
					break;
				case (int)WritePadOptions.kWritePadOptionsAutcorrector :
                    sw.On = WritePadAPI.isRecoFlagSet(flags, WritePadAPI.FLAG_CORRECTOR);
					cell.TextLabel.Text = "Enable Autocorrector";
					break;
				case (int)WritePadOptions.kWritePadOptionsUserDict :
                    sw.On = WritePadAPI.isRecoFlagSet(flags, WritePadAPI.FLAG_USERDICT);
					cell.TextLabel.Text = "Enable User Dictionary";
					break;
				case (int)WritePadOptions.kWritePadOptionsDictionaryOnly:
					sw.On = WritePadAPI.isRecoFlagSet(flags, WritePadAPI.FLAG_ONLYDICT);
					cell.TextLabel.Text = "Recognize Dictionary Words Only";
					break;
			}
					
			return cell;
		}
	}
}

