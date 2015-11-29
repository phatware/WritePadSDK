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
#import "Shortcuts.h"

@class WritePadInputPanel;
@class AsyncResultView;

@protocol WritePadInputViewDelegate;

#define SHROTHAND_BUTTON_TAG    106

@interface UIResultsView : UIView 

@end

@interface WritePadInputView : UIView 
{
	WritePadInputPanel *	inkCollector;
	AsyncResultView *		resultView;
    UIResultsView *         uiResultView;
	NSString *				placeholder;
    
@private
	CGGradientRef			myGradient;
	Boolean					bHasInk;
	NSTimer *				holdTimer;
	Boolean					_bIgnoreActionKey;
	NSMutableArray *		_buttons;
	CGFloat                 markerPosition;
	Boolean					_markerSelected;
    BOOL                    _showCmdButton;

}

@property (nonatomic, retain, readonly) WritePadInputPanel *	inkCollector;
@property (nonatomic, retain, readonly) AsyncResultView *		resultView;
@property (nonatomic, retain) NSString *	placeholder;
@property (nonatomic, assign) id			delegate;
@property (nonatomic, assign) Boolean		showMarker;
@property (nonatomic, retain) UIButton *    cmdButton;
@property (nonatomic, retain) UIButton *    penButton;

@property (nonatomic, assign) BOOL drawGrid;

+ (WritePadInputView *) sharedInputPanel;
+ (void) destroySharedInputPanel;

+ (UIColor *) colorForElement:(NSString *)element;
+ (BOOL) flagForElement:(NSString *)element;
+ (void) initColorsWithStyle:(NSInteger)style;
+ (CGFloat) floatForElement:(NSString *)element;

- (void) empty;
- (void) setHasInk:(Boolean)bHasInk;
- (void) setMarkerPosition:(CGFloat)pos;
- (CGRect) getMarkerRect;
- (void) moveMarkerToLocation:(CGPoint)location  selected:(BOOL)sel;
- (CGFloat) getMarkerPosition;
- (void) showCommandButton:(BOOL)show withCommand:(NSString *)command;

@end


@protocol WritePadInputViewDelegate<NSObject>
@optional

- (void) writePadInputPanelSpeakEvent:(WritePadInputView*)panel didStart:(BOOL)start;
- (void) writePadInputKeyPressed:(WritePadInputView*)panel keyText:(NSString*)string withSender:(id)sender;
- (UIView *) writePadInputPanelPositionAltPopover:(CGRect *)pRect;

@end
