/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    Copyright (c) 2008-2016 PhatWare(r) Corp. All rights reserved.                 * */
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
using System.Collections.Generic;
using System.Linq;
using UIKit;
using CoreGraphics;
using BindingLibrary;

namespace xamarin_sample
{
	public class InkView: UIView
	{
		private UIBezierPath mPath;
		private List<UIBezierPath> mPathList;
		private int mCurrStroke;
		private float mX, mY;
		private const float TOUCH_TOLERANCE = 2;
		private bool mMoved;
		private List<WritePadAPI.CGTracePoint> currentStroke;
		private int strokeLen = 0;

		struct FPoint
		{
			public float X;
			public float Y;
		};
		private  FPoint _lastPoint;
		private  FPoint _previousLocation;

		private const int SEGMENT2 = 2;
		private const int SEGMENT3 = 3;

		private const float GRID_GAP = 65;
		private const int SEGMENT4 = 4;

		private const float  SEGMENT_DIST_1   = 3;
		private const float  SEGMENT_DIST_2   = 6;
		private const float  SEGMENT_DIST_3   = 12;


		private int AddPixelsXY( float X, float Y, bool bLastPoint )
		{
			float		xNew, yNew, x1, y1;
			int		nSeg = SEGMENT3;

			if ( mCurrStroke < 0 )
				return 0;

			if  ( strokeLen < 1 )  
			{
				_lastPoint.X = _previousLocation.X = X;
				_lastPoint.Y = _previousLocation.Y = Y;
				WritePadAPI.recoAddPixel(mCurrStroke, X, Y); 
				AddCurrentPoint( X, Y );
				strokeLen = 1;
				return  1;
			}

			float dx = Math.Abs( X - _lastPoint.X );
			float dy = Math.Abs( Y - _lastPoint.Y );
			if  ( (dx + dy) < SEGMENT_DIST_1 )  
			{
				_lastPoint.X = _previousLocation.X = X;
				_lastPoint.Y = _previousLocation.Y  = Y;
				WritePadAPI.recoAddPixel(mCurrStroke, X, Y); 
				AddCurrentPoint( X, Y );
				strokeLen++;
				return  1;
			}

			if ( (dx + dy) < SEGMENT_DIST_2 )  
				nSeg = SEGMENT2;
			else if ( (dx + dy) < SEGMENT_DIST_3 )
				nSeg = SEGMENT3;
			else
				nSeg = SEGMENT4;
			int     nPoints = 0;
			for ( int i = 1; i < nSeg;  i++ )  
			{
				x1 = _previousLocation.X + ((X - _previousLocation.X)*i ) / nSeg;  //the point "to look at"
				y1 = _previousLocation.Y + ((Y - _previousLocation.Y)*i ) / nSeg;  //the point "to look at"

				xNew = _lastPoint.X + (x1 - _lastPoint.X) / nSeg;
				yNew = _lastPoint.Y + (y1 - _lastPoint.Y) / nSeg;

				if ( xNew != _lastPoint.X || yNew != _lastPoint.Y )
				{
					_lastPoint.X = xNew;
					_lastPoint.Y = yNew;
					WritePadAPI.recoAddPixel(mCurrStroke, xNew, yNew); 
					AddCurrentPoint( xNew, yNew );
					strokeLen++;
					nPoints++;
				}
			}

			if ( bLastPoint )  
			{
				// add last point
				if ( X != _lastPoint.X || Y != _lastPoint.Y )  
				{
					_lastPoint.X = X;
					_lastPoint.Y = Y;
					WritePadAPI.recoAddPixel(mCurrStroke, X, Y); 
					AddCurrentPoint( X, Y );
					strokeLen++;
					nPoints++;
				}
			}

			_previousLocation.X = X;
			_previousLocation.Y = Y;
			return nPoints;
		}


		public InkView ()
		{
			BackgroundColor = UIColor.Yellow;
			mPath = new UIBezierPath();
			mPathList = new List<UIBezierPath>();
			mPath.LineWidth = WritePadAPI.DEFAULT_INK_WIDTH;
			mPath.LineCapStyle = CGLineCap.Round;
			mPath.LineJoinStyle = CGLineJoin.Round;
			mCurrStroke = -1;
		}

		public override void Draw(CGRect rect)
		{
			base.Draw (rect); 
			using (CGContext g = UIGraphics.GetCurrentContext ()) 
			{
				// draw grid
				UIBezierPath path = new UIBezierPath();
				path.LineWidth = 1.0f;
				UIColor.Red.SetStroke ();
				for ( float y = GRID_GAP; y < rect.Height; y += GRID_GAP )
				{
					path.MoveTo( new CGPoint( 0, y ) );
					path.AddLineTo( new CGPoint( rect.Width, y ) );
					path.Stroke();
				}

				UIColor.Blue.SetStroke ();
				foreach(var aMPathList in mPathList) 
				{
					aMPathList.Stroke ();
				}
				mPath.Stroke ();
			}
		}

		private void AddCurrentPoint(float mX, float mY)
		{
			var point = new WritePadAPI.CGTracePoint ();
			point.pressure = WritePadAPI.DEFAULT_INK_PRESSURE;
			point.pt = new WritePadAPI.CGPoint ();
			point.pt.x = mX;
			point.pt.y = mY;
			currentStroke.Add (point);
		}

		public override void TouchesBegan (Foundation.NSSet touches, UIEvent evt)
		{
			base.TouchesBegan (touches, evt);
			currentStroke = new List<WritePadAPI.CGTracePoint> ();
			UITouch touch = (UITouch)touches.AnyObject;
			var location = touch.LocationInView (this);
			mPath.RemoveAllPoints ();
			mPath.MoveTo(new CGPoint(location.X, location.Y));
			mX = (float)location.X;
			mY = (float)location.Y;
			AddCurrentPoint (mX, mY);
			mMoved = false;
			strokeLen = 0;
			mCurrStroke = WritePadAPI.recoNewStroke( WritePadAPI.DEFAULT_INK_WIDTH, 0xFF0000FF);   
			AddPixelsXY( mX, mY, false );
		}

		public override void TouchesMoved (Foundation.NSSet touches, UIEvent evt)
		{
			base.TouchesMoved (touches, evt);
			UITouch touch = (UITouch)touches.AnyObject;
			var location = touch.LocationInView (this);

			float dx = (float)Math.Abs(location.X - mX);
			float dy = (float)Math.Abs(location.Y - mY);
			if (dx >= TOUCH_TOLERANCE || dy >= TOUCH_TOLERANCE)
			{
				mPath.AddQuadCurveToPoint(new CGPoint((location.X + mX) / 2f, (location.Y + mY) / 2f), new CGPoint(mX, mY));
				mMoved = true;
				mX = (float)location.X;
				mY = (float)location.Y;
				AddPixelsXY( mX, mY, false );
			}
			this.SetNeedsDisplay ();
		}

		public override void TouchesCancelled (Foundation.NSSet touches, UIEvent evt)
		{
			base.TouchesCancelled (touches, evt);
		}

		public override void TouchesEnded (Foundation.NSSet touches, UIEvent evt)
		{
			base.TouchesEnded (touches, evt);
			var gesture = WritePadAPI.detectGesture (WritePadAPI.GEST_CUT | WritePadAPI.GEST_RETURN, currentStroke);
			if (!mMoved)
				mX++;
			AddPixelsXY( mX, mY, true );

			mCurrStroke = -1;
			mMoved = false;
			strokeLen = 0;

			mPath.AddLineTo(new CGPoint(mX, mY));
			mPathList.Add(mPath);
			mPath = new UIBezierPath ();
			mPath.LineWidth = WritePadAPI.DEFAULT_INK_WIDTH;
			mPath.LineCapStyle = CGLineCap.Round;
			mPath.LineJoinStyle = CGLineJoin.Round;

			SetNeedsDisplay ();

			switch (gesture)
			{
				case WritePadAPI.GEST_RETURN:
					if (OnReturnGesture != null)
					{
						mPathList.RemoveAt(mPathList.Count - 1);
						WritePadAPI.recoDeleteLastStroke();
						SetNeedsDisplay ();
						OnReturnGesture();                    
					}
					break;
				case WritePadAPI.GEST_CUT:
					if (OnCutGesture != null)
					{
						mPathList.RemoveAt(mPathList.Count - 1);
						WritePadAPI.recoDeleteLastStroke();
						SetNeedsDisplay ();
						OnCutGesture();                    
					}
					break;
			}
		}


		public struct WordAlternative
		{
			public string Word;
			public int Weight;
		}


		public string Recognize( bool bLearn )
		{
			var res = "";
			var resultStringList = new List<string>();
			var wordList = new List<List<WordAlternative>>();
			var count = WritePadAPI.recoStrokeCount();
			string defaultResult = WritePadAPI.recoInkData(count,false,false,false,false);
			// can also use the default result
			resultStringList.Add(defaultResult);
			var wordCount = WritePadAPI.recoResultColumnCount();
			for (var i = 0; i < wordCount; i++)
			{
				var wordAlternativesList = new List<WordAlternative>();
				var altCount = WritePadAPI.recoResultRowCount(i);
				for (var j = 0; j < altCount; j++)
				{
					String word = WritePadAPI.recoResultWord(i, j);
					if (word == "<--->")			// note: when a word is not recognized, engine retiurns "<--->" instead
						word = "*Error*";
					if (string.IsNullOrEmpty(word))
						continue;
					uint flags = WritePadAPI.recoGetFlags();
					var weight = WritePadAPI.recoResultWeight(i, j);
					if ( j == 0 && bLearn && weight > 75 && 0 != (flags & WritePadAPI.FLAG_ANALYZER) )
					{
						// if learner is enabled, learn default word(s) when the Return gesture is used
						WritePadAPI.recoLearnWord( word, weight );
					}

					if (wordAlternativesList.All(x => x.Word != word))
					{
						wordAlternativesList.Add(new WordAlternative
						{
							Word = word,
							Weight = weight
						});
					}
					while (resultStringList.Count < j + 2) 
					{
						var emptyStr = "";
						for (int k = 0; k < i; k++) {
							emptyStr += "\t\t";
						}
						resultStringList.Add (emptyStr);
					}
					if (resultStringList[j+1].Length > 0)
						resultStringList[j+1] += "\t\t";
					resultStringList[j+1] += word + "\t[" + weight + "%]";

				}
				wordList.Add(wordAlternativesList);
			}
			foreach (var line in resultStringList)
			{
				if(string.IsNullOrEmpty(line))
					continue;                
				if (res.Length > 0)
				{
					res += Environment.NewLine;
				}
				res += line;                
			}
			// cleanView (true);
			return res;
		}
			
		public void cleanView(bool emptyAll)
		{
			WritePadAPI.recoResetInk();
			mCurrStroke = -1;
			mPathList.Clear();
			mPath.RemoveAllPoints ();      
			SetNeedsDisplay ();
		}


		public event Action OnReturnGesture;
		public event Action OnCutGesture;
	}
}
