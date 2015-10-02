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

using System;
using System.Collections.Generic;
using System.Linq;
using Android.Content;
using Android.Graphics;
using Android.Runtime;
using Android.Util;
using Android.Views;
using Android.Widget;

namespace WritePadXamarinSample
{
    class InkView: View
    {
        private Path mPath;
        private int mCurrStroke;
        private Paint mPaint;
        private Paint mResultPaint;
		private Path gridpath;

        private LinkedList<Path> mPathList;
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
		private FPoint _lastPoint;
		private FPoint _previousLocation;

		private const int SEGMENT2 = 2;
		private const int SEGMENT3 = 3;

		private const float GRID_GAP = 65;
		private const int SEGMENT4 = 4;

		private const float  SEGMENT_DIST_1   = 3;
		private const float  SEGMENT_DIST_2   = 6;
		private const float  SEGMENT_DIST_3   = 12;
        private int AddPixelsXY( float X, float Y, bool bLastPoint )
		// this method called from inkCollectorThread
		{
			float	xNew, yNew, x1, y1;
			int		nSeg = SEGMENT3;

			if ( mCurrStroke < 0 )
				return 0;

			if  ( strokeLen < 1 )  
			{
				_lastPoint.X = _previousLocation.X = X;
				_lastPoint.Y = _previousLocation.Y = Y;
                WritePadAPI.recoAddPixel(mCurrStroke, X, Y);
                AddCurrentPoint(X, Y);
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
                AddCurrentPoint(X, Y);
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
                    AddCurrentPoint(X, Y);
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
                    AddCurrentPoint(X, Y);
                    strokeLen++;
					nPoints++;
				}
			}

			_previousLocation.X = X;
			_previousLocation.Y = Y;
			return nPoints;
		}


        protected override void OnDraw(Canvas canvas) 
        {
			// draw grid lines
			mPaint.Color = new Color(255, 0, 0);
			mPaint.StrokeWidth = 1;

			for ( float y = GRID_GAP; y < canvas.Height; y += GRID_GAP) 
			{
				gridpath.Reset ();
				gridpath.MoveTo (0, y);
				gridpath.LineTo (canvas.Width, y);
				canvas.DrawPath(gridpath, mPaint);
			}
			mPaint.Color = new Color(0, 0, 255);
			mPaint.StrokeWidth = 3;

			// draw strokes
            foreach(var aMPathList in mPathList) 
            {
                canvas.DrawPath(aMPathList, mPaint);
            }
            canvas.DrawPath(mPath, mPaint);
        }
        private void AddCurrentPoint(float mX, float mY)
        {
            var point = new WritePadAPI.CGTracePoint();
            point.pressure = WritePadAPI.DEFAULT_INK_PRESSURE;
            point.pt = new WritePadAPI.CGPoint();
            point.pt.x = mX;
            point.pt.y = mY;
            currentStroke.Add(point);
        }

        private void touch_start(float x, float y)
        {
            mPath.Reset();
            currentStroke = new List<WritePadAPI.CGTracePoint>();
            mPath.MoveTo(x, y);
            mX = x;
            mY = y;
            AddCurrentPoint(mX, mY);
            mMoved = false;
            mCurrStroke = WritePadAPI.recoNewStroke(3, 0xFFFF0000);
			strokeLen = 0;
			AddPixelsXY(mX, mY, false);
        }

        private void touch_move(float x, float y)
        {
            float dx = Math.Abs(x - mX);
            float dy = Math.Abs(y - mY);
            if (dx >= TOUCH_TOLERANCE || dy >= TOUCH_TOLERANCE)
            {
                mPath.QuadTo(mX, mY, (x + mX) / 2, (y + mY) / 2);
                mMoved = true;
                mX = x;
                mY = y;
                AddCurrentPoint(mX, mY);			
				AddPixelsXY(mX, mY, false);
            }
        }

		private void touch_up(float x, float y)
		{
			var gesture = WritePadAPI.detectGesture(WritePadAPI.GEST_RETURN | WritePadAPI.GEST_CUT | WritePadAPI.GEST_BACK, currentStroke);
            
			AddPixelsXY(x, y, true);
            AddCurrentPoint(mX, mY);			
			mCurrStroke = -1;
			mMoved = false;

			if (!mMoved)
				mX++;
			mPath.LineTo(mX, mY);
			mPathList.AddLast(mPath);
			mPath = new Path();
			Invalidate();

			switch (gesture)
            {
                case WritePadAPI.GEST_RETURN:
                    if (OnReturnGesture != null)
                    {
                        mPathList.RemoveLast();
                        WritePadAPI.recoDeleteLastStroke();
                        Invalidate(); 
                        OnReturnGesture();  
						return;
                    }
                    break;
                case WritePadAPI.GEST_CUT:
                    if (OnCutGesture != null)
                    {
                        mPathList.RemoveLast();
                        WritePadAPI.recoDeleteLastStroke();
                        Invalidate(); 
                        OnCutGesture(); 
						return;
                    }
                    break;

				case WritePadAPI.GEST_BACK_LONG :
					mPathList.RemoveLast();
					WritePadAPI.recoDeleteLastStroke();
					if ( WritePadAPI.recoStrokeCount() > 0 )
					{
						mPathList.RemoveLast();
						WritePadAPI.recoDeleteLastStroke();
					}
					Invalidate(); 
					return;
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
            string defaultResult = WritePadAPI.recoInkData(count, false, false, false, false);
			// can also use the default result
            resultStringList.Add(defaultResult);
            var wordCount = WritePadAPI.recoResultColumnCount();
            for (var i = 0; i < wordCount; i++)
            {
				var wordAlternativesList = new List<WordAlternative>();
                var altCount = WritePadAPI.recoResultRowCount(i);
                for (var j = 0; j < altCount; j++)
                {
                    var word = WritePadAPI.recoResultWord(i, j);
                    if (word == "<--->")
                        word = "*Error*";
                    if (string.IsNullOrEmpty(word))
                        continue;
					var weight = WritePadAPI.recoResultWeight(i, j);
					var flags = WritePadAPI.recoGetFlags();
				
					if ( j == 0 && bLearn && weight > 75 && 0 != (flags & WritePadAPI.FLAG_ANALYZER) )
					{
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
                            resultStringList.Add("");
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
            return res;
        }
			
        public void cleanView(bool emptyAll)
        {
            WritePadAPI.recoResetInk();
            mCurrStroke = -1;
            mPathList.Clear();
            mPath.Reset();            
            Invalidate();
        }

        public override bool OnTouchEvent(MotionEvent ev) 
        {
            float x = ev.GetX();
            float y = ev.GetY();

            switch (ev.Action) 
            {
                case MotionEventActions.Down:
                    touch_start(x, y);
                    Invalidate();
                    break;

                case MotionEventActions.Move:
                    for (int i = 0, n = ev.HistorySize; i < n; i++) 
					{
						touch_move(ev.GetHistoricalX(i), ev.GetHistoricalY(i));
                    }
                    touch_move(x, y);
                    Invalidate();
                    break;

                case MotionEventActions.Up:
					touch_up(x, y);
                    Invalidate();
                    break;
            }
            return true;
        }

        protected InkView(IntPtr javaReference, JniHandleOwnership transfer) : base(javaReference, transfer)
        {
           
        }

        public InkView(Context context) : base(context)
        {
            
        }

        public InkView(Context context, IAttributeSet attrs) : base(context, attrs)
        {
            mPath = new Path();
            mPathList = new LinkedList<Path>();
            mCurrStroke = -1;
            mPaint = new Paint();
            mPaint.AntiAlias = true;
            mPaint.Dither = true;
            mPaint.Color = new Color(0, 0, 255);
            mPaint.SetStyle(Paint.Style.Stroke);
            mPaint.StrokeJoin = Paint.Join.Round;
            mPaint.StrokeCap = Paint.Cap.Round;
            mPaint.StrokeWidth = 3;

            mResultPaint = new Paint();
            mResultPaint.TextSize = 32;
            mResultPaint.AntiAlias = true;
            mResultPaint.SetARGB(0xff, 0x00, 0x00, 0x00);

			gridpath = new Path();
        }

        public InkView(Context context, IAttributeSet attrs, int defStyle) : base(context, attrs, defStyle)
        {
            
        }

        public event Action OnReturnGesture;
        public event Action OnCutGesture;
    }
}