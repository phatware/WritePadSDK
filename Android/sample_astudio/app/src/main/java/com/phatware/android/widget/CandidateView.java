/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    Copyright (c) 1997-2012 PhatWare(r) Corp. All rights reserved.                 * */
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

package com.phatware.android.widget;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.text.Html;
import android.util.AttributeSet;
import android.util.Log;
import android.view.GestureDetector;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup.LayoutParams;
import android.widget.PopupWindow;
import android.widget.TextView;
import com.phatware.android.WritePadManager;
import com.phatware.android.recotest.R;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


public class CandidateView extends View {

    private static final int OUT_OF_BOUNDS = -1;
    private static final List<String> EMPTY_LIST = new ArrayList<String>();

//    private InputPanel mService;

    private List<String> mSuggestions = EMPTY_LIST;
    private boolean mShowingCompletions;
    private CharSequence mSelectedString;
    private int mTouchX = OUT_OF_BOUNDS;
    private final Drawable mSelectionHighlight;
    private boolean mTypedWordValid;

    private boolean mHaveMinimalSuggestion;

    private Rect mBgPadding;

    private final PopupWindow mPreviewPopup;


    private int mVerticalPadding;


    private static final int MAX_SUGGESTIONS = 32;
    private static final int SCROLL_PIXELS = 20;

    private final int[] mWordWidth = new int[MAX_SUGGESTIONS];
    private final int[] mWordX = new int[MAX_SUGGESTIONS];

    private static final int X_GAP = 10;

    private final int mColorNormal;
    private final int mColorRecommended;
    private final int mColorOther;
    private final int mColorRed;
    private final Paint mPaint;

    //will be used to determine if we are scrolling or selecting.
    private boolean mScrolled;
    //will tell us what is the target scroll X, so we know to stop
    private int mTargetScrollX;

    private int mTotalWidth;

    private final GestureDetector mGestureDetector;

    
    
    private int mScrollX;
    private static final String TAG = CandidateView.class.getSimpleName();

    
    public CandidateView(Context context, AttributeSet attrs) {
        super(context, attrs);
        mSelectionHighlight = context.getResources().getDrawable(R.drawable.highlight_pressed);

        LayoutInflater inflate = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        mPreviewPopup = new PopupWindow(context);
        final TextView mPreviewText = (TextView) inflate.inflate(R.layout.candidate_preview, null);
        mPreviewPopup.setWindowLayoutMode(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
        mPreviewPopup.setContentView(mPreviewText);
        mPreviewPopup.setBackgroundDrawable(null);
        mColorNormal = context.getResources().getColor(R.color.candidate_normal);
        mColorRecommended = context.getResources().getColor(R.color.candidate_recommended);
        mColorOther = context.getResources().getColor(R.color.candidate_other);

        mColorRed = context.getResources().getColor(R.color.candidate_red);
        mVerticalPadding = context.getResources().getDimensionPixelSize(R.dimen.candidate_vertical_padding);


        mPaint = new Paint();
        mPaint.setColor(mColorNormal);
        mPaint.setAntiAlias(true);//it is just MUCH better looking
        mPaint.setTextSize(mPreviewText.getTextSize());
        mPaint.setStrokeWidth(0);


        mGestureDetector = new GestureDetector(context, new GestureDetector.SimpleOnGestureListener() {
            @Override
            public boolean onScroll(MotionEvent e1, MotionEvent e2,
                                    float distanceX, float distanceY) {
                final int width = getWidth();
                mScrolled = true;
                mScrollX += (int) distanceX;
                if (mScrollX < 0) {
                    mScrollX = 0;
                }
                if (distanceX > 0 && mScrollX + width > mTotalWidth) {
                    mScrollX -= (int) distanceX;
                }
                //fixing the touchX too
                mTouchX += mScrollX;
                //it is at the target
                mTargetScrollX = mScrollX;
                scrollTo(mScrollX, getScrollY());
                requestLayout();
                invalidate();
                return true;
            }

        });
        setHorizontalFadingEdgeEnabled(true);
        setWillNotDraw(false);
        //I'm doing my own scroll icons.
        setHorizontalScrollBarEnabled(false);
        setVerticalScrollBarEnabled(false);
        mScrollX = 0;
    }




/*
    public void setService(InputPanel mService) {
        this.mService = mService;
    }
*/

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        int measuredWidth = resolveSize(50, widthMeasureSpec);

        // Get the desired height of the icon menu view (last row of items does
        // not have a divider below)
        Rect padding = new Rect();
        mSelectionHighlight.getPadding(padding);
        final int desiredHeight = ((int) mPaint.getTextSize()) + mVerticalPadding + padding.top + padding.bottom;

        // Maximum possible width and desired height
        setMeasuredDimension(measuredWidth, resolveSize(desiredHeight, heightMeasureSpec));
    }

    @Override
    public int computeHorizontalScrollRange() {
        return mTotalWidth;
    }

    /**
     * If the canvas is null, then only touch calculations are performed to pick the target
     * candidate.
     */
    @Override
    protected void onDraw(Canvas canvas) {
        if (canvas != null) {
            super.onDraw(canvas);
        }
        mTotalWidth = 0;
        if (mSuggestions == null) return;

        if (mBgPadding == null) {
            mBgPadding = new Rect(0, 0, 0, 0);
            if (getBackground() != null) {
                getBackground().getPadding(mBgPadding);
            }
        }
        int x = 0;
        final int count = mSuggestions.size();
        final int height = getHeight();
        final Rect bgPadding = mBgPadding;
        final Paint paint = mPaint;
        final int touchX = mTouchX;
        final int scrollX = mScrollX;
        final boolean scrolled = mScrolled;
        final boolean typedWordValid = mTypedWordValid;
        final int y = (int) (((height - mPaint.getTextSize()) / 2) - mPaint.ascent());

        for (int i = 0; i < count; i++) {
            String suggestion = Html.fromHtml(mSuggestions.get(i)).toString();
            float textWidth = paint.measureText(suggestion);
            final int wordWidth = (int) textWidth + X_GAP * 2;

            mWordX[i] = x;
            mWordWidth[i] = wordWidth;
            paint.setColor(mColorNormal);
            
            if (touchX != OUT_OF_BOUNDS && touchX + scrollX >= x && touchX + scrollX < x + wordWidth && !scrolled) {
                if (canvas != null) {
                    canvas.translate(x, 0);
                    mSelectionHighlight.setBounds(0, bgPadding.top, wordWidth, height);
                    mSelectionHighlight.draw(canvas);
                    canvas.translate(-x, 0);
                }
                mSelectedString = suggestion;
                // mSelectedIndex = i;
            }

            if (canvas != null) {
                if (mHaveMinimalSuggestion && ((i == 1 && !typedWordValid) || (i == 0 && typedWordValid))) {
                    paint.setFakeBoldText(true);
                    paint.setColor(mColorRecommended);
                } else if (i != 0) {
                    paint.setColor(mColorOther);
                }
                if ( (!mShowingCompletions) && (! WritePadManager.isDictionaryWord(suggestion, WritePadManager.recoGetFlags())) ) {
                	paint.setColor(mColorRed);
                }
                
                canvas.drawText(suggestion, x + X_GAP, y, paint);
                paint.setColor(mColorOther);
                canvas.drawLine(x + wordWidth + 0.5f, bgPadding.top,
                        x + wordWidth + 0.5f, height + 1, paint);
                paint.setFakeBoldText(false);
            }
            x += wordWidth;
        }
        mTotalWidth = x;
        if (mTargetScrollX != mScrollX) {
            scrollToTarget();
        }
    }

    private void scrollToTarget() {
        int sx = getScrollX();
        if (mTargetScrollX > sx) {
            sx += SCROLL_PIXELS;
            if (sx >= mTargetScrollX) {
                sx = mTargetScrollX;
                requestLayout();
            }
        } else {
            sx -= SCROLL_PIXELS;
            if (sx <= mTargetScrollX) {
                sx = mTargetScrollX;
                requestLayout();
            }
        }
        mScrollX = sx;
        scrollTo(sx, getScrollY());
        invalidate();
    }

    public void setSuggestions(List<String> suggestions, boolean completions, boolean typedWordValid, boolean haveMinimalSuggestion) {
        clear();
        if (suggestions != null) {
            mSuggestions = new ArrayList<String>(suggestions);
        }
        mShowingCompletions = completions;
        mTypedWordValid = typedWordValid;
        mScrollX = 0;
        mTargetScrollX = 0;
        mHaveMinimalSuggestion = haveMinimalSuggestion;
        // Compute the total width

        onDraw(null);
        invalidate();
        requestLayout();
    }

    public void scrollPrev() {
        updateScrollPosition(getmScrollX() - (int) (0.75 * getWidth()));
    }

    public void scrollNext() {
        updateScrollPosition(getmScrollX() + (int) (0.75 * getWidth()));
    }

    private void updateScrollPosition(int targetX) {
        if (targetX < 0) {
            targetX = 0;
        }
        if (targetX > (mTotalWidth - 50)) {
            targetX = (mTotalWidth - 50);
        }

        if (targetX != getmScrollX()) {
            mTargetScrollX = targetX;
            requestLayout();
            invalidate();
            mScrolled = true;
        }
    }

    public void clear() {
        mSuggestions = EMPTY_LIST;
        mTouchX = OUT_OF_BOUNDS;
        mSelectedString = null;
        // mSelectedIndex = OUT_OF_BOUNDS;
        invalidate();
        Arrays.fill(mWordWidth, 0);
        Arrays.fill(mWordX, 0);
        if (mPreviewPopup.isShowing()) {
            mPreviewPopup.dismiss();
        }
    }

    @Override
    public boolean onTouchEvent(MotionEvent me) {

        try {
            if (mGestureDetector.onTouchEvent(me)) {
                return true;
            }

            int action = me.getAction();
            int x = (int) me.getX();
            int y = (int) me.getY();
            mTouchX = x;

            switch (action) {
                case MotionEvent.ACTION_DOWN:
                    mScrolled = false;
                    invalidate();
                    break;
                case MotionEvent.ACTION_MOVE:
                    if (y <= 0) {
                        // Fling up!?
                        if (mSelectedString != null) {
                            if (!mShowingCompletions) {
                                // TODO TEMP DISABLED TextEntryState.acceptedSuggestion(mSuggestions.get(0), mSelectedString);
                            }
//                            mService.pickSuggestionManually(mSelectedIndex, mSelectedString);
                            mSelectedString = null;
                            // mSelectedIndex = OUT_OF_BOUNDS;
                        }
                    }
                    invalidate();
                    break;
                case MotionEvent.ACTION_UP:
                    if (!mScrolled) {
                        if (mSelectedString != null) {
                            if (!mShowingCompletions) {
                                // TODO TEMP DISABLED TextEntryState.acceptedSuggestion(mSuggestions.get(0),                                mSelectedString);
                            }
//                            mService.pickSuggestionManually(mSelectedIndex, mSelectedString);
                        }
                    }
                    mSelectedString = null;
                    // mSelectedIndex = OUT_OF_BOUNDS;
                    removeHighlight();
                    requestLayout();
                    mScrolled = false;
                    break;
            }
        } catch (RuntimeException e) {
            Log.e(TAG, e.getMessage(), e);
        }
        return true;
    }


    private void removeHighlight() {
        mTouchX = OUT_OF_BOUNDS;
        invalidate();
    }


    public int getmScrollX() {
        return mScrollX;
    }
}
