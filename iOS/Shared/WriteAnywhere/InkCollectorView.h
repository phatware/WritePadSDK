/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    Copyright (c) 2008-2018 PhatWare(r) Corp. All rights reserved.                 * */
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
#import "Shortcuts.h"

#define MAX_QUEUE_SIZE		512

@class SoundEffect;
@class InkCollectorView;

enum {
	WritePadPopoverNone = 0,
	WritePadPopoverKeyboard = 1,
	WritePadPopoverSpell = 2,
	WritePadPopoverRecognizer = 3
};

@interface InkCurrentStrokeView : UIView
{
}

@property(nonatomic, weak) InkCollectorView * inkView;

@end

// dummy input view

@interface DummyInputView : UIInputView

+ (DummyInputView *) sharedDummyInputPanel;
+ (void) destroySharedDummyInputPanel;

@end

@class WPTextView;

@protocol InkCollectorViewDelegate;

@interface InkCollectorView : UIView <UIPopoverControllerDelegate>
{
@private
	CGStroke			ptStroke;
	int					strokeLen;
	int					strokeMemLen;	
	Boolean				_firstTouch;
	CGPoint				_previousLocation;
	Boolean				autoRecognize;
	Boolean				backgroundReco;
	NSTimer *			_timerRecognizer;
	NSTimer *			_timerTouchAndHold;
	INK_DATA_PTR		inkData;
	NSTimeInterval		recognitionDelay;
	GESTURE_TYPE		gesturesEnabledIfEmpty;
	GESTURE_TYPE		gesturesEnabledIfData;
	UIColor *			strokeColor;
	float				strokeWidth;	
	Shortcuts	*		shortcuts;
	
	Boolean				_bSelectionMode;
	Boolean				_bAddStroke;
	Boolean				_bSendTouchToEdit;
	NSInteger			CurrPopover;
	NSInteger			_nAdded;

    void *              cacheBitmap;
    CGContextRef        cacheContext;
    int                 countLines;

    InkCurrentStrokeView *  _currentStrokeView;
		
	CGPoint				_inkQueue[MAX_QUEUE_SIZE];
	int					_inkQueueGet, _inkQueuePut;
	NSCondition		*	_inkQueueCondition;
	Boolean				_runInkThread;
	Boolean				_bAsyncInkCollector;
	NSLock *			_inkLock;
    BOOL                _useAsyncRecognizer;

}

@property(nonatomic, readwrite) NSTimeInterval  recognitionDelay;
@property(nonatomic, readwrite) Boolean			autoRecognize;
@property(nonatomic, readwrite) float			strokeWidth;
@property(nonatomic, assign)    WPTextView * 	edit;
@property(nonatomic, retain)    UIColor *		strokeColor;
@property(nonatomic)			Boolean			backgroundReco;
@property(nonatomic)			NSInteger		CurrPopover;
@property(nonatomic, retain)    Shortcuts	*	shortcuts;
@property(nonatomic, readonly)  Boolean			asyncInkCollector;

@property(nonatomic, assign)    int				strokeLen;
@property(nonatomic, assign)    CGStroke		ptStroke;

@property(nonatomic, retain)    NSString *      placeholder1;
@property(nonatomic, retain)    NSString *      placeholder2;


+ (void) ensureDefaultSettings:(Boolean)force;

- (void) reloadOptions;
- (void) empty;
- (BOOL) deleteLastStroke;
- (void) enableGestures:(GESTURE_TYPE)gestures whenEmpty:(BOOL)bEmpty;
- (BOOL) shortcutsEnable:(BOOL)bEnable delegate:(id)del uiDelegate:(id)uiDel;
- (void) enterSelectionMode;
- (void) endSelectionMode;
- (void) recognizeNow;

@property(assign) id<InkCollectorViewDelegate> delegate;

@end

@protocol InkCollectorViewDelegate<NSObject>
@optional

- (void) InkCollectorResultReady:(InkCollectorView*)inkView theResult:(NSString*)string;
- (BOOL) InkCollectorRecognizedGesture:(InkCollectorView*)inkView withGesture:(GESTURE_TYPE)gesture isEmpty:(BOOL)bEmpty;
- (void) InkCollectorAsyncResultReady:(InkCollectorView*)inkView theResult:(NSString*)string;

@end
