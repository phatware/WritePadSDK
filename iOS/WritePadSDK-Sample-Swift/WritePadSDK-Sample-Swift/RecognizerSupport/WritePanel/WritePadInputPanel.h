/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    Copyright (c) 2008-2014 PhatWare(r) Corp. All rights reserved.                 * */
/* ************************************************************************************* */

/* ************************************************************************************* *
 *
 * WritePad SDK Sample
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

#import <UIKit/UIKit.h>
#import "RecognizerWrapper.h"

#define MAX_QUEUE_SIZE          512


@class WritePadInputView;
@class WritePadInputPanel;

/////////////////////////////////////////////////////////////////////////////

@interface InkObject : NSObject
{
	INK_DATA_PTR		inkData;
}

@property(nonatomic, assign) INK_DATA_PTR		inkData;

- (id)initWithInkData:(INK_DATA_PTR)initalData;
- (void) sortInk;

@end


@interface WPCurrentStrokeView : UIView
{
@private
    CGPoint                     _hoverPoint;
}

@property(nonatomic, weak) WritePadInputPanel *		panel;

- (void) setHoverLocation:(CGPoint)point;

@end


@interface WPInkView : UIView
{
}

@property(nonatomic, weak) WritePadInputPanel *		panel;

+ (void) _renderLine:(CGStroke)points pointCount:(int)count withWidth:(float)width withColor:(UIColor *)color;
+ (void) _renderLine:(CGStroke)points pointCount:(int)count inContext:(CGContextRef)context withWidth:(float)width withColor:(UIColor *)color;

@end

/////////////////////////////////////////////////////////////////////////////

@protocol WritePadInputPanelDelegate;

@interface WritePadInputPanel : UIView
{
	CGStroke			ptStroke;
	int					strokeLen;
	int					strokeMemLen;	
	Boolean				_firstTouch;
	CGPoint				_previousLocation;
	NSTimer *			_timerTouchAndHold;
	INK_DATA_PTR		inkData;
	GESTURE_TYPE		gesturesEnabledIfEmpty;
	GESTURE_TYPE		gesturesEnabledIfData;
	CGFloat				strokeWidth;
		
	CGPoint				_inkQueue[MAX_QUEUE_SIZE];
	int					_inkQueueGet, _inkQueuePut;
	
	NSCondition		*	_inkQueueCondition;
	Boolean				_runInkThread;
	Boolean				_bAsyncRecoEnabled;
	Boolean				_bAsyncInkCollector;
	NSLock *			_recoLock;
	NSCondition		*	_recoCondition;
	NSLock *			_inkLock;
	
	Boolean				_bSelectionMode;
	Boolean				_bAddStroke;
	Boolean				_bSendTouchToEdit;
	Boolean				_bShowingMenu;
	
	Boolean				_movingMarker;
    Boolean             _bStylusOffset;
    Boolean             _bStylusPressure;
    WPCurrentStrokeView * _currentStrokeView;
    WPInkView *         _inkView;
    Boolean             _bZeroPressure;
    int                 _lastPressure;
    BOOL                _iPenDown;
    int                 _nAdded;
    BOOL                _bPalmRest;
    BOOL                _isObserver;
    NSTimer *          _timerRecognizer;
}

@property(nonatomic, readwrite) CGFloat			strokeWidth;
@property(nonatomic, readonly)  UIColor *		strokeColor;
@property(nonatomic, readonly)  Boolean			asyncRecoEnabled;
@property(nonatomic, readonly)  Boolean			asyncInkCollector;
@property(nonatomic, weak)    WritePadInputView *	inputPanel;
@property(nonatomic, readonly)  INK_DATA_PTR		inkData;

@property(nonatomic, assign)    int					strokeLen;
@property(nonatomic, assign)    CGStroke			ptStroke;

- (void) reloadOptions;
- (void) empty;
- (BOOL) deleteLastStroke;
- (void) enableGestures:(GESTURE_TYPE)gestures whenEmpty:(BOOL)bEmpty;
- (BOOL) enableAsyncRecognizer:(BOOL)bEnable;
- (BOOL) enableAsyncInk:(BOOL)bEnable;
- (BOOL) startAsyncRecoThread;
- (void) stopAsyncRecoThread;
- (NSUInteger) strokeCount;

@property(assign) id<WritePadInputPanelDelegate> delegate;

@end

@protocol WritePadInputPanelDelegate<NSObject>
@optional

- (void) WritePadInputPanelResultReady:(WritePadInputPanel*)inkView theResult:(NSString*)string;
- (void) WritePadInputPanelAsyncResultReady:(WritePadInputPanel*)inkView theResult:(NSString*)string;
- (BOOL) WritePadInputPanelRecognizedGesture:(WritePadInputPanel*)inkView withGesture:(GESTURE_TYPE)gesture isEmpty:(BOOL)bEmpty;
- (void) WritePadInputPanelChangeLanguage:(WritePadInputPanel*)inkView;

@end
