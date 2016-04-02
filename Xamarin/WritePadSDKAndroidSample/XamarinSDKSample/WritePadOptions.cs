/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    Copyright (c) 2008-2016 PhatWare(r) Corp. All rights reserved.                 * */
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
using Android.OS;
using Android.Widget;

namespace WritePadXamarinSample
{
	[Activity (Label = "WritePad Options")]	

	public class WritePadOptions : Activity
	{

		protected override void OnCreate (Bundle bundle)
		{
			base.OnCreate (bundle);

			SetContentView(Resource.Layout.Options);

			var seplet = FindViewById<CheckBox>(Resource.Id.separate_letters);
			var singleword = FindViewById<CheckBox>(Resource.Id.single_word);
			var corrector = FindViewById<CheckBox>(Resource.Id.autocorrector);
			var learner = FindViewById<CheckBox>(Resource.Id.autolearner);
			var userdict = FindViewById<CheckBox>(Resource.Id.user_dictionary);
			var dictwords = FindViewById<CheckBox>(Resource.Id.dict_words);

			var recoFlags = WritePadAPI.recoGetFlags();
            seplet.Checked = WritePadAPI.isRecoFlagSet(recoFlags, WritePadAPI.FLAG_SEPLET);
            singleword.Checked = WritePadAPI.isRecoFlagSet(recoFlags, WritePadAPI.FLAG_SINGLEWORDONLY);
            learner.Checked = WritePadAPI.isRecoFlagSet(recoFlags, WritePadAPI.FLAG_ANALYZER);
            userdict.Checked = WritePadAPI.isRecoFlagSet(recoFlags, WritePadAPI.FLAG_USERDICT);
            dictwords.Checked = WritePadAPI.isRecoFlagSet(recoFlags, WritePadAPI.FLAG_ONLYDICT);
            corrector.Checked = WritePadAPI.isRecoFlagSet(recoFlags, WritePadAPI.FLAG_CORRECTOR);

			seplet.Click += (o, e) => {
                recoFlags = WritePadAPI.setRecoFlag(recoFlags, seplet.Checked, WritePadAPI.FLAG_SEPLET);
				WritePadAPI.recoSetFlags( recoFlags );
			};
			singleword.Click += (o, e) => {
                recoFlags = WritePadAPI.setRecoFlag(recoFlags, singleword.Checked, WritePadAPI.FLAG_SINGLEWORDONLY);
				WritePadAPI.recoSetFlags( recoFlags );
			};
			learner.Click += (o, e) => {
                recoFlags = WritePadAPI.setRecoFlag(recoFlags, learner.Checked, WritePadAPI.FLAG_ANALYZER);
				WritePadAPI.recoSetFlags( recoFlags );
			};
			userdict.Click += (o, e) => {
                recoFlags = WritePadAPI.setRecoFlag(recoFlags, userdict.Checked, WritePadAPI.FLAG_USERDICT);
				WritePadAPI.recoSetFlags( recoFlags );
			};
			dictwords.Click += (o, e) => {
                recoFlags = WritePadAPI.setRecoFlag(recoFlags, dictwords.Checked, WritePadAPI.FLAG_ONLYDICT);
				WritePadAPI.recoSetFlags( recoFlags );
			};
			corrector.Click += (o, e) => {
                recoFlags = WritePadAPI.setRecoFlag(recoFlags, corrector.Checked, WritePadAPI.FLAG_CORRECTOR);
				WritePadAPI.recoSetFlags( recoFlags );
			};
		}
	}
}

