/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    Copyright (c) 1997-2015 PhatWare(r) Corp. All rights reserved.                 * */
/* ************************************************************************************* */

/* ************************************************************************************* *
 *
 * WritePad Android Sample
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
 * 10414 W. Highway 2, Ste 4-121 Spokane, WA 99224
 *
 * ************************************************************************************* */

package com.phatware.android.recotest;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.phatware.android.DialogHelper;
import com.phatware.android.RecoInterface.WritePadAPI;
import com.phatware.android.WritePadManager;

import java.util.LinkedList;

public class InkView extends View implements RecoTest.OnInkViewListener {
    private Path mPath;
    private int mCurrStroke;
    private Paint mPaint;
    private Paint mResultPaint;
    private LinearLayout recognizedTextContainer;
    private TextView readyText;
    private LinkedList<Path> mPathList;
    private float mX, mY;
    private static final float TOUCH_TOLERANCE = 2;
    private boolean mMoved;
    private String lastResult = null;
    
	private Path  gridpath = new Path();
    
    private final float GRID_GAP = 65;

    // Define the Handler that receives messages from the thread and update the progress
    private final Handler mHandler = new Handler() {
        public void handleMessage(Message msg) {
            recognizedTextContainer.removeAllViews();
            Bundle b = msg.getData();
            lastResult = b.getString( "result" );
            int words = WritePadManager.recoResultColumnCount();
            for (int w = 0; w < words; w++) {
                int alternatives = WritePadManager.recoResultRowCount(w);
                if (alternatives > 0) {

                    final CharSequence[] alternativesCollection = new CharSequence[alternatives];
                    for (int a = 0; a < alternatives; a++) {
                        String word = WritePadManager.recoResultWord(w, a);
                        alternativesCollection[a] = word;
                    }

                    Button word = new Button(getContext());
                    word.setTransformationMethod(null);
                    word.setText(WritePadManager.recoResultWord(w, 0));
                    word.setOnClickListener(new OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            if (alternativesCollection.length > 0)
                                DialogHelper.createAlternativesDialog(getContext(), getWindowToken(), alternativesCollection).show();
                        }
                    });
                    recognizedTextContainer.addView(word);

                }
            }
        }
    };

    public void cleanView(boolean emptyAll) {
        WritePadManager.recoResetInk();
        mCurrStroke = -1;
        mPathList.clear();
        mPath.reset();
        recognizedTextContainer.removeAllViews();
        if (emptyAll) {
            readyText.setText("");
        }
        invalidate();
    }

    public Handler getHandler() {
        return mHandler;
    }

    public InkView(Context context) {
        this(context, null, 0);
    }

    public InkView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public InkView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);

        mPath = new Path();
        mPathList = new LinkedList<Path>();
        mCurrStroke = -1;
        mPaint = new Paint();
        mPaint = new Paint();
        mPaint.setAntiAlias(true);
        mPaint.setDither(true);
        mPaint.setColor(0xFF0000FF);
        mPaint.setStyle(Paint.Style.STROKE);
        mPaint.setStrokeJoin(Paint.Join.ROUND);
        mPaint.setStrokeCap(Paint.Cap.ROUND);
        mPaint.setStrokeWidth(3);

        mResultPaint = new Paint();
        mResultPaint.setTextSize(32);
        mResultPaint.setAntiAlias(true);
        mResultPaint.setARGB(0xff, 0x00, 0x00, 0x00);
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        mPaint.setColor(0xFFFF0000);
        mPaint.setStrokeWidth(1);

        for ( float y = GRID_GAP; y < canvas.getHeight(); y += GRID_GAP) 
		{
			gridpath.reset ();
			gridpath.moveTo (0, y);
			gridpath.lineTo (canvas.getWidth(), y);
			canvas.drawPath(gridpath, mPaint);
		}
        mPaint.setColor(0xFF0000FF);
        mPaint.setStrokeWidth(3);
    	
    	
        for (Path aMPathList : mPathList) {
            canvas.drawPath(aMPathList, mPaint);
        }
        canvas.drawPath(mPath, mPaint);
    }

    private void touch_start(float x, float y) {
        mPath.reset();
        mPath.moveTo(x, y);
        mX = x;
        mY = y;
        mMoved = false;
        mCurrStroke = WritePadManager.recoNewStroke(3.0f, 0xFF0000FF);
        if (mCurrStroke >= 0) {
            int res = WritePadManager.recoAddPixel(mCurrStroke, x, y);
            if (res < 1) {
                // TODO: error
            }
        }
    }
    

    private void touch_move(float x, float y) {
        float dx = Math.abs(x - mX);
        float dy = Math.abs(y - mY);
        if (dx >= TOUCH_TOLERANCE || dy >= TOUCH_TOLERANCE) {
            mPath.quadTo(mX, mY, (x + mX) / 2, (y + mY) / 2);
            mMoved = true;
            mX = x;
            mY = y;
            if (mCurrStroke >= 0) {
                int res = WritePadManager.recoAddPixel(mCurrStroke, x, y);
                if (res < 1) {
                    // TODO: error
                }
            }
        }
    }

    private void touch_up() {
        // stopRecognizer();

        mCurrStroke = -1;
        if (!mMoved)
            mX++;
        mMoved = false;
        mPath.lineTo(mX, mY);
        mPathList.add(mPath);
        mPath = new Path();
        invalidate();

        RecoTest rt = (RecoTest) getContext();
        int nStrokeCnt = WritePadManager.recoStrokeCount();
        if (nStrokeCnt == 1) {
            int gesturetype = WritePadAPI.GEST_DELETE + WritePadAPI.GEST_RETURN + WritePadAPI.GEST_SPACE +
                    WritePadAPI.GEST_TAB + WritePadAPI.GEST_BACK + WritePadAPI.GEST_UNDO;
            gesturetype = WritePadManager.recoGesture(gesturetype);
            if (gesturetype != WritePadAPI.GEST_NONE) {
                // TODO: process gesture
                WritePadManager.recoDeleteLastStroke();
                mPathList.removeLast();
                return;
            }
        } else if (nStrokeCnt > 1) {
            int gesturetype = WritePadAPI.GEST_CUT + WritePadAPI.GEST_BACK + WritePadAPI.GEST_RETURN;
            gesturetype = WritePadManager.recoGesture(gesturetype);
            if (gesturetype != WritePadAPI.GEST_NONE && gesturetype != WritePadAPI.GEST_BACK) {
                // TODO: process gesture
                WritePadManager.recoDeleteLastStroke();
                mPathList.removeLast();
                switch (gesturetype) {
                    // case WritePadAPI.GEST_BACK:
                    case WritePadAPI.GEST_BACK_LONG:
                        WritePadManager.recoDeleteLastStroke();
                        mPathList.removeLast();
                        if (WritePadManager.recoStrokeCount() < 1) {
                            recognizedTextContainer.removeAllViews();
                        }

                        rt.mBoundService.dataNotify(WritePadManager.recoStrokeCount());
                        return;

                    case WritePadAPI.GEST_CUT:
                        cleanView(false);
                        lastResult = null;
                        return;

                    case WritePadAPI.GEST_RETURN:
                        sendText();
                        cleanView(false);
                        lastResult = null;
                        return;
                        
                    default :
                    	break;
                }
            }
        }

        // notify recognizer thread about data availability
        rt.mBoundService.dataNotify(nStrokeCnt);
    }

    private void sendText() {
    	if ( lastResult == null )
    	{
	        int count = recognizedTextContainer.getChildCount();
	        StringBuilder stringBuilder = new StringBuilder();
	        for (int i = 0; i < count; i++) {
	            Button button = (Button) recognizedTextContainer.getChildAt(i);
	            stringBuilder.append(button.getText());
	            stringBuilder.append(" ");	
	        }
	        readyText.setText(String.format("%s%s", readyText.getText(), stringBuilder.toString()));
    	}
    	else
    	{
	        readyText.setText(String.format("%s %s", readyText.getText(), lastResult ));    		
    	}
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        float x = event.getX();
        float y = event.getY();

        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                touch_start(x, y);
                invalidate();
                break;

            case MotionEvent.ACTION_MOVE:
                for (int i = 0, n = event.getHistorySize(); i < n; i++) {
                    touch_move(event.getHistoricalX(i),
                            event.getHistoricalY(i));
                }
                touch_move(x, y);
                invalidate();
                break;

            case MotionEvent.ACTION_UP:
                touch_up();
                invalidate();
                break;
        }
        return true;
    }

    public void setRecognizedTextContainer(LinearLayout recognizedTextContainer) {
        this.recognizedTextContainer = recognizedTextContainer;
    }

    public void setReadyText(TextView readyText) {
        this.readyText = readyText;
    }
}
