/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    Copyright (c) 2008-2015 PhatWare(r) Corp. All rights reserved.                 * */
/* ************************************************************************************* */

/* ************************************************************************************* *
 *
 * WritePad Input Panel Sample
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

#include <AudioToolbox/AudioToolbox.h>
#import "InkCollectorView.h"
#import "OptionKeys.h"
#import "UIConst.h"
#import "RectObject.h"
#import "LanguageManager.h"
#import "RecognizerManager.h"
#import "WritePadInputPanel.h"
#import "WPTextView.h"
#import "utils.h"

@implementation InkCurrentStrokeView

@synthesize inkView;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
		self.contentMode = UIViewContentModeRedraw;
		self.userInteractionEnabled = NO;
		self.clearsContextBeforeDrawing = NO;
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
	// draw the current stroke
	if ( inkView != nil && inkView.strokeLen > 0 && inkView.ptStroke != NULL )
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
		[WPInkView _renderLine:inkView.ptStroke pointCount:inkView.strokeLen inContext:context withWidth:inkView.strokeWidth withColor:inkView.strokeColor];
	}
}

@end

@interface InkCollectorView ()

- (void) updateDisplayInThread:(RectObject *)rObject;
- (void) killRecoTimer;
- (void) killHoldTimer;
- (BOOL) enableAsyncInk:(BOOL)bEnable;
- (int)  addPointPoint:(CGPoint)point;
- (void) addPointToQueue:(CGPoint)point;
- (void) processEndOfStroke:(BOOL)fromThread;
- (int) AddPixelsX:(int)x Y:(int)y pressure:(int)pressure IsLastPoint:(BOOL)bLastPoint;

@property (nonatomic, copy ) NSString * currentResult;

@end

static DummyInputView * sharedDummyInputView = nil;

@implementation DummyInputView

- (id)initWithFrame:(CGRect)frame
{
    frame.size.height = 0.5;
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
    }
    return self;
}

+ (DummyInputView *) sharedDummyInputPanel
{
	if ( sharedDummyInputView == nil )
	{
		CGRect f = CGRectNull;
		sharedDummyInputView = [[DummyInputView alloc] initWithFrame:f];
		sharedDummyInputView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        sharedDummyInputView.backgroundColor = [UIColor clearColor];
	}
	return sharedDummyInputView;
}

+ (void) destroySharedDummyInputPanel
{
	if ( sharedDummyInputView != nil )
	{
		sharedDummyInputView = nil;
	}
}

@end

@implementation InkCollectorView

@synthesize delegate;
@synthesize recognitionDelay;
@synthesize autoRecognize;
@synthesize strokeWidth;
@synthesize edit;
@synthesize backgroundReco;
@synthesize strokeColor;
@synthesize shortcuts;
@synthesize CurrPopover;
@synthesize asyncInkCollector = _bAsyncInkCollector;
@synthesize placeholder1;
@synthesize placeholder2;
@synthesize strokeLen;
@synthesize ptStroke;

@synthesize currentResult;

#define STROKE_FILTER_TIMEOUT		1.0
#define STROKE_FILTER_DISTANCE		200


+ (void) ensureDefaultSettings:(Boolean)force
{
	NSUserDefaults*	defaults = [NSUserDefaults standardUserDefaults];
	BOOL b = [defaults boolForKey:kRecoOptionsFirstStartKey];
	if ( b != YES || force )
	{
		// init default settings
		[defaults setBool:NO  forKey:kRecoOptionsSingleWordOnly];
		[defaults setBool:NO  forKey:kRecoOptionsSeparateLetters];
		[defaults setBool:NO  forKey:kRecoOptionsInternational];
		[defaults setBool:NO  forKey:kRecoOptionsDictOnly];
		[defaults setBool:NO  forKey:kRecoOptionsSuggestDictOnly];
		[defaults setBool:YES forKey:kRecoOptionsDrawGrid];
		[defaults setBool:NO  forKey:kRecoOptionsSpellIgnoreNum];
		[defaults setBool:NO  forKey:kRecoOptionsSpellIgnoreUpper];
		[defaults setBool:YES forKey:kRecoOptionsUseCorrector];
		[defaults setBool:YES forKey:kRecoOptionsUseUserDict];
		[defaults setBool:YES forKey:kRecoOptionsUseLearner];
		[defaults setBool:NO forKey:kRecoOptionsErrorVibrate];
		[defaults setBool:NO forKey:kEditOptionsAutocapitalize];
		[defaults setBool:NO forKey:kPhatPadOptionsPalmRest];
		[defaults setBool:NO forKey:kEditOptionsAutospace];
		[defaults setInteger:DEFAULT_BACKGESTURELEN forKey:kRecoOptionsBackstrokeLen];
		[defaults setFloat:DEFAULT_PENWIDTH forKey:kRecoOptionsInkWidth];
		[defaults setFloat:DEFAULT_RECODELAY forKey:kRecoOptionsTimerDelay];
		
		// init default settings
		[defaults setBool:NO forKey:kEditOptionsShowSuggestions];
		[defaults setBool:NO forKey:kEditEnableSpellChecker];
		[defaults setBool:YES forKey:kEditEnableTextAnalyzer];			
	}
}	

- (id) initWithFrame:(CGRect)frame
{	
	if((self = [super initWithFrame:frame])) 
	{		
		strokeLen = 0;
		strokeMemLen = DEFAULT_STROKE_LEN * sizeof( CGTracePoint );
		ptStroke = malloc( strokeMemLen );
		strokeWidth = DEFAULT_PENWIDTH;
		inkData = INK_InitData();	
		recognitionDelay = DEFAULT_RECODELAY;
		_timerRecognizer = nil;
		_timerTouchAndHold = nil;
		gesturesEnabledIfEmpty = GEST_NONE;
		gesturesEnabledIfData = GEST_NONE;
				
		_bAddStroke = YES;
		backgroundReco = YES;
		_firstTouch = NO;
		_bSendTouchToEdit = NO;
		self.multipleTouchEnabled = NO;
        _bSelectionMode = NO;
		_nAdded = 0;
		_bAsyncInkCollector = NO;
		_inkQueueCondition = [[NSCondition alloc] init];
		_inkLock = [[NSLock alloc] init];
        _useAsyncRecognizer = YES;      // TODO: this can be disabled, if not needed
        self.currentResult = nil;
		edit = nil;
        
        _currentStrokeView = [[InkCurrentStrokeView alloc] initWithFrame:[self bounds]];
        _currentStrokeView.inkView = self;
        _currentStrokeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_currentStrokeView];
        
		// default ink color
		self.strokeColor = [UIColor colorWithRed:0.5 green:0.2 blue:0.8 alpha:1.0];
				
		// init recognizer options
		NSUserDefaults*	defaults = [NSUserDefaults standardUserDefaults];
		BOOL b = [defaults boolForKey:kRecoOptionsFirstStartKey];
		if ( b != YES )
		{
			[InkCollectorView ensureDefaultSettings:YES];
		}
		else
		{
			strokeWidth = [defaults floatForKey:kRecoOptionsInkWidth];
			if ( strokeWidth < 1.0 )
				strokeWidth = DEFAULT_PENWIDTH;
			recognitionDelay = [defaults floatForKey:kRecoOptionsTimerDelay];
			if ( recognitionDelay < MIN_DELAY || recognitionDelay > 5 * DEFAULT_TOUCHANDHOLDDELAY )
			{
				recognitionDelay = DEFAULT_RECODELAY;
				[defaults setFloat:recognitionDelay forKey:kRecoOptionsTimerDelay];
			}
		}

        // placeholder
        self.placeholder1 = [NSString stringWithString:NSLocalizedString( @"Write anywhere", @"")];
        self.placeholder2 = [NSString stringWithString:NSLocalizedString( @"on the screen", @"")];
    		
		// Init shorctus
		shortcuts = [[Shortcuts alloc] init];
						
		self.multipleTouchEnabled = NO;
	}
	return self;
}

/*
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	SET_CURR_POPOVER( nil );
}
*/

#pragma mark AsyncInkCollector

- (BOOL) enableAsyncInk:(BOOL)bEnable
{
	// can't disable async ink if async reco is enabled
	if ( (!bEnable) && _bAsyncInkCollector )
	{
		// terminate ink thread
		if ( ! [_inkLock tryLock] )
		{
			_runInkThread = NO;
			[self addPointToQueue:CGPointMake( 0,0 )];
			[_inkLock lock];
		}
		[_inkLock unlock];
		_bAsyncInkCollector = NO;
	}
	else if ( bEnable && (!_bAsyncInkCollector)  )
	{
		_runInkThread = YES;
		[NSThread detachNewThreadSelector:@selector(inkCollectorThread:) toTarget:self 
							   withObject:nil];		
		_bAsyncInkCollector = YES;
	}
	_inkQueueGet = _inkQueuePut = 0;
	_bAddStroke = YES;
	// [[NSUserDefaults standardUserDefaults] setBool:_bAsyncInkCollector forKey:kRecoOptionsAsyncInking];
	return _bAsyncInkCollector;
}

- (void)inkCollectorThread :(id)anObj 
{
    @autoreleasepool
    {
        [_inkLock lock];
        
        while( _runInkThread )
        {
            [_inkQueueCondition lock]; 
            while ( _inkQueueGet == _inkQueuePut ) 
            {
                [_inkQueueCondition wait]; 
            }
            [_inkQueueCondition unlock];
            
            if ( ! _runInkThread )
            {
                // [_inkQueueCondition unlock];
                break;
            }
            
            register int iGet = _inkQueueGet, iPut = _inkQueuePut;
            int nAdded = 0;
            
            while( (iGet = _inkQueueGet) != iPut )
            {
                // NSLog(@"new point x=%f y=%f", point.x, point.y );
                if ( iGet > iPut )
                {
                    // NSLog(@"*** Error iGet (%i) > iPut (%i)", iGet, iPut );	
                    while ( iGet < MAX_QUEUE_SIZE )
                    {
                        nAdded += [self addPointPoint:_inkQueue[iGet]];
                        iGet++;
                    }
                    iGet = 0;
                }
                while ( iGet < iPut )
                {
                    nAdded += [self addPointPoint:_inkQueue[iGet]];
                    iGet++;
                }
                _inkQueueGet = iPut;
            }
            
            if ( nAdded > 2 )
            {				
                NSInteger from = MAX( 0, strokeLen-1-nAdded );
                NSInteger to = MAX( 0, strokeLen-1 );
                if ( from < to )
                {
                    int penwidth = 2.0 + strokeWidth/2.0;
                    CGRect rect = CGRectMake( ptStroke[to].pt.x, ptStroke[to].pt.y, ptStroke[to].pt.x, ptStroke[to].pt.y );
                    for ( NSInteger i = from; i < to; i++ )
                    {
                        rect.origin.x = MIN( rect.origin.x, ptStroke[i].pt.x );
                        rect.origin.y = MIN( rect.origin.y, ptStroke[i].pt.y );
                        rect.size.width = MAX( rect.size.width, ptStroke[i].pt.x );
                        rect.size.height = MAX( rect.size.height, ptStroke[i].pt.y);
                    }
                    rect.size.width -= rect.origin.x;
                    rect.size.height -= rect.origin.y;
                    rect = CGRectInset( rect, -penwidth, -penwidth );
                    
                    RectObject * obj = [[RectObject alloc] initWithRect:rect];
                    [self performSelectorOnMainThread:@selector(updateDisplayInThread:) withObject:obj waitUntilDone:YES];
                    nAdded = 0;
                }
            }
        }
        [_inkLock unlock];
    }
}

-(void)addPointToQueue:(CGPoint)point
{
	[_inkQueueCondition lock]; 
	
	int iPut = _inkQueuePut;
	_inkQueue[iPut] = point;
	iPut++;
	if ( iPut >= MAX_QUEUE_SIZE )
		iPut = 0;
	_inkQueuePut = iPut;
	[_inkQueueCondition broadcast];
	
	[_inkQueueCondition unlock]; 
}

- (int)addPointPoint:(CGPoint)point
// this method called from inkCollectorThread
{
	// NSLog(@"new point x=%f y=%f", point.x, point.y );
	int nAdded = 0;
	if ( point.y == -1 )
	{
		[self processEndOfStroke:YES];
	}
	else
	{
		nAdded += [self AddPixelsX:point.x Y:point.y pressure:DEFAULT_PRESSURE IsLastPoint:FALSE];
	}
	return nAdded;	
}

-(void) updateDisplayInThread:(RectObject *)rObject
// This method is called when a updateDisplayInThread selector from main thread is called.
{
	if ( rObject == nil )
	{
        [_currentStrokeView setNeedsDisplay];
        if ( strokeLen == 0 )
            [self setNeedsDisplay];
	}
	else
	{
        [_currentStrokeView setNeedsDisplayInRect:rObject.rect];
        if ( strokeLen == 0 )
            [self setNeedsDisplayInRect:rObject.rect];
	}
}

-(void) strokeGestureInTread:(NSArray *)arr
// This method is called when a strokeGestureTread selector from main thread is called.
{
	GESTURE_TYPE	gesture = (GESTURE_TYPE)[(NSNumber *)[arr objectAtIndex:0] intValue];
	UInt32			nStrokeCount = [(NSNumber *)[arr objectAtIndex:1] unsignedIntValue];
	
	if ( gesture == GEST_LOOP && nStrokeCount > 0 && shortcuts != nil && [shortcuts isEnabled] )
	{
		// check if this is a correct 
		CGRect rData;
		if ( INK_GetDataRect( inkData, &rData, FALSE ) )
		{
			CGFloat left, right;
			CGFloat bottom, top;
			left = right =  ptStroke[0].pt.x;
			bottom = top =  ptStroke[0].pt.y;
			for( register int i = 1; i < strokeLen; i++ )
			{
				left = MIN( ptStroke[i].pt.x, left );
				right = MAX( ptStroke[i].pt.x, right );
				top =  MIN( ptStroke[i].pt.y, top );
				bottom =  MAX( ptStroke[i].pt.y, bottom );
			}
			CGFloat dx = rData.size.width/8;
			CGFloat dy = rData.size.height/8;
			if ( left < (rData.origin.x + dx) && top < (rData.origin.y + dy) && right > (rData.origin.x + rData.size.width - dx) &&
				bottom > (rData.origin.y + rData.size.height - dy) )
			{
				// check if it fits into the current stroke
				NSLog( @"Loop!" );
				// get name of the shortcut and see if it matches...
				_bAddStroke = (![shortcuts recognizeInkData:inkData]);
				if ( ! _bAddStroke )
				{
					// command was recognized; reset the recognizer and delete INK data
					if ( backgroundReco )
					{
						[[RecognizerManager sharedManager] reset];
					}
                    [self empty];
				}
			}
		}
	}
	else
	{
		if ([delegate respondsToSelector:@selector(InkCollectorRecognizedGesture:withGesture:isEmpty:)])
        {
			_bAddStroke = [delegate InkCollectorRecognizedGesture:self withGesture:gesture isEmpty:(nStrokeCount == 0)];
        }
    }
	if ( ! _bAddStroke )
		strokeLen = 0;
}

#pragma mark ReloadOptions

- (void)reloadOptions
{
	NSUserDefaults*	defaults = [NSUserDefaults standardUserDefaults];
    
    [self stopAsyncRecoThread];
    
	BOOL b = [defaults boolForKey:kRecoOptionsFirstStartKey];
	if ( b == YES )
	{
		strokeWidth = [defaults floatForKey:kRecoOptionsInkWidth];
		if ( strokeWidth < 1.0 )
		{
			strokeWidth = DEFAULT_PENWIDTH;
			[defaults setFloat:strokeWidth forKey:kRecoOptionsInkWidth];
		}
		recognitionDelay = [defaults floatForKey:kRecoOptionsTimerDelay];
		if ( recognitionDelay < MIN_DELAY || recognitionDelay > 5 * DEFAULT_TOUCHANDHOLDDELAY )
		{
			recognitionDelay = DEFAULT_RECODELAY;
			[defaults setFloat:recognitionDelay forKey:kRecoOptionsTimerDelay];
		}
		
		// [self enableAsyncInk:NO];

		if ( shortcuts && [shortcuts isEnabled] )
		{
			// reload shortcuts recognizer
			[shortcuts enableRecognizer:NO];
            [shortcuts enableRecognizer:YES];
		}

        if ( [self isInkData] && _useAsyncRecognizer )
        {
            [self startAsyncRecoThread];
        }
		[self setNeedsDisplay];
	}		
}

- (BOOL) shortcutsEnable:(BOOL)bEnable delegate:(id)del uiDelegate:(id)uiDel 
{
	if ( nil == shortcuts )
		return NO;
	shortcuts.delegate = del;
	shortcuts.delegateUI = uiDel;
	return [shortcuts enableRecognizer:bEnable];
}

- (BOOL) isInkData
{
	return (INK_StrokeCount( inkData, FALSE ) > 0) ? YES : NO;
}

- (void) killRecoTimer
{
	if ( nil != _timerRecognizer )
	{
		[_timerRecognizer invalidate];
		_timerRecognizer = nil;
	}
}

-(void) strokeAdded:(NSObject *)object
// This method is called when a strokeAddedInTread selector from main thread is called.
{	
	if ( autoRecognize )
	{
		//Start recognition timer
		[self killRecoTimer];
		_timerRecognizer = [NSTimer scheduledTimerWithTimeInterval:recognitionDelay target:self 
														  selector:@selector(recognizerTimer) userInfo:nil repeats:NO];
	}
}

-(void) recognizeNow
// This method is called when a strokeAddedInTread selector from main thread is called.
{	
	//Start recognition timer
	[self killRecoTimer];
	_timerRecognizer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self
														  selector:@selector(recognizerTimer) userInfo:nil repeats:NO];
}

#pragma mark -- This code is used to automatically detect new line in handwritten text

- (BOOL) isNewLine:(CGRect)rLastWord previousWord:(CGRect)rPrevWord
{
    //  If the coordinates of the current word are below and to the left comparing to coordinates of the previous word
    // we assume that this is new line. Conditions can be changed, if needed
    if ( rLastWord.origin.y > rPrevWord.origin.y + rPrevWord.size.height && rPrevWord.size.width + rPrevWord.origin.x > rLastWord.origin.x )
        return YES;
    return NO;
}

- (NSString *) constructResultString
{
    NSMutableString * result = [[NSMutableString alloc] init];
    
	RECOGNIZER_PTR _reco = [RecognizerManager sharedManager].recognizer;
	NSInteger _wordCnt = HWR_GetResultWordCount( _reco );
	if ( _wordCnt < 1 )
        return nil;
    
	NSString *		word = nil;
	const UCHR *	chrWord = NULL;
    CGRect          rLastWord = CGRectNull, rPrevWord = CGRectNull;
		
    @autoreleasepool
    {
        for ( int iWord = 0; iWord < _wordCnt; iWord++ )
        {
            // int nAltCnt = HWR_GetResultAlternativeCount( _reco, iWord );
            // in this case, we are only interested in first alternative
            chrWord = HWR_GetResultWord( _reco, iWord, 0 );
            if ( NULL == chrWord || 0 == *chrWord )
            {
                NSLog( @"**** HWR_GetResultWord returnd error for first word; this should not happen" );
                return nil;
            }
            word = [RecognizerManager stringFromUchr:chrWord];
            // NSLog( @"Word %d: %@; alternatives %d", iWord, word, nAltCnt );
            
            // get coordinates of the current word in the current inkData object
            INK_SelectAllStrokes( inkData, FALSE );
            int * ids = NULL;
            int cnt = HWR_GetStrokeIDs( _reco, iWord, 0, (const int **)&ids );
            for ( int i = 0; i < cnt; i++ )
            {
                INK_SelectStroke( inkData, ids[i], TRUE );
            }
            INK_GetDataRect( inkData, &rLastWord, TRUE );
            
            // check if this is new line, then insert \n, otherwise insert sapce as words separator
            if ( CGRectIsNull( rPrevWord ) )
            {
                if ( [result length] > 0 )
                    [result appendString:@" "];
            }
            else
            {
                if ( [self isNewLine:rLastWord previousWord:rPrevWord] )
                {
                    // insert new line charactrer as words separator
                    [result appendString:@"\n"];
                }
                else
                {
                    // insert space character as words separator
                    [result appendString:@" "];
                }
            }
            rPrevWord = rLastWord;
            [result appendString:word];
        }
        if ( [[NSUserDefaults standardUserDefaults] boolForKey:kEditOptionsAutospace] )
            [result appendString:@" "];
    }
    // NSLog( @"Result:\n%@", result );
    return (NSString *)result;
}

#pragma mark -- 


- (BOOL) recognizeInk:(BOOL)bErase
{
	[self killRecoTimer];

    NSMutableString * strResult;
    if ( _useAsyncRecognizer )
    {
        strResult = [self.currentResult mutableCopy];
        self.currentResult = nil;
    }
    else
    {
        
        if ( (! [self isInkData]) )
            return NO;
        const UCHR * pText = [[RecognizerManager sharedManager] recognizeInkData:inkData background:backgroundReco async:NO selection:NO];
        if ( pText == NULL || *pText == 0 )
        {
            [[RecognizerManager sharedManager] reportError];
            return NO;
        }
        strResult = [[NSMutableString alloc] initWithString:[RecognizerManager stringFromUchr:pText]];
    }
	if ( [strResult length] > 1 && [strResult characterAtIndex:[strResult length] - 1] == ' ' && [[NSUserDefaults standardUserDefaults] boolForKey:kEditOptionsAutospace] )
	{
		[strResult deleteCharactersInRange:NSMakeRange( [strResult length] - 1, 1 )];
	}
	if ( bErase )
		[self empty];
	
	// NSComparisonResult comp = [strResult compare:kEmptyWord options:NSCaseInsensitiveSearch range:NSMakeRange( 0, 5 )];
	if ( [strResult rangeOfString:@kEmptyWord].location != NSNotFound || [strResult rangeOfString:@"*Error*"].location != NSNotFound )
	{
		// error...
        [[RecognizerManager sharedManager] reportError];
		return NO;
	}
    
	if ([delegate respondsToSelector:@selector(InkCollectorResultReady:theResult:)])
	{
		[delegate InkCollectorResultReady:self theResult:strResult];
	}
    return YES;
}

- (void) enableGestures:(GESTURE_TYPE)gestures whenEmpty:(BOOL)bEmpty;
{
	if ( bEmpty )
		gesturesEnabledIfEmpty = gestures;
	else
		gesturesEnabledIfData = gestures;
}

- (BOOL) deleteLastStroke
{
	BOOL bResult = INK_DeleteStroke( inkData, -1 );  // 
    
    if ( bResult && _useAsyncRecognizer )
    {
        [self startAsyncRecoThread];
    }
    else if ( bResult && backgroundReco )
	{
		[[RecognizerManager sharedManager] reset];
		if ( INK_StrokeCount( inkData, FALSE ) > 0 )
		{
			// restart background recognizer
			HWR_PreRecognizeInkData( [[RecognizerManager sharedManager] recognizer], inkData, 0, FALSE );	
			[self strokeAdded:nil];	// restart recognizer timer
		}
	}
    
	return bResult;
}

#pragma mark - Ink Collection support


- (GESTURE_TYPE)recognizeGesture:(GESTURE_TYPE)gestures withStroke:(CGStroke)points withLength:(int)count 
{
	if ( count < 5 )
		return GEST_NONE;
	
	int iLen = (int)[[NSUserDefaults standardUserDefaults] integerForKey:kRecoOptionsBackstrokeLen];
	if ( iLen < 200 )
		iLen = DEFAULT_BACKGESTURELEN;
	GESTURE_TYPE type = HWR_CheckGesture( gestures, points, count, 1, iLen );
	return type;
}

// this function is called from secondary thread
-(void) processEndOfStroke:(BOOL)fromThread
{
	if ( strokeLen < 2 )
	{
		strokeLen = 0;
		return;
	}
	
	GESTURE_TYPE	gesture = GEST_NONE;
	UInt32			nStrokeCount = INK_StrokeCount( inkData, FALSE );
	
	_bAddStroke = YES;
	if ( strokeLen > 5  && nStrokeCount > 0 && gesturesEnabledIfData != GEST_NONE )
	{
		// recognize gesture
		gesture = [self recognizeGesture:gesturesEnabledIfData withStroke:ptStroke withLength:strokeLen];
	}
	else if ( strokeLen > 5 && nStrokeCount == 0 && gesturesEnabledIfEmpty != GEST_NONE )
	{
		// recognize gesture
		gesture = [self recognizeGesture:gesturesEnabledIfEmpty withStroke:ptStroke withLength:strokeLen];
	}
	
	if ( gesture != GEST_NONE )
	{
		NSArray * arr = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:gesture], [NSNumber numberWithInt:nStrokeCount], nil];
		if ( fromThread )
		{
			// gesture recognized, notify main thread
			[self performSelectorOnMainThread:@selector(strokeGestureInTread:) withObject:arr waitUntilDone:YES];
		}
		else
		{
			[self strokeGestureInTread:arr];
		}
	}		
	
    CGRect rect = CGRectNull;
    
	if ( _bAddStroke )
	{
		if ( (!_useAsyncRecognizer) && backgroundReco && INK_StrokeCount( inkData, FALSE ) < 1 )
		{
			[[RecognizerManager sharedManager] reset];
		}
		// call up the app delegate
		COLORREF	 coloref = [utils _uiColorToColorRef:strokeColor];
		
		if ( INK_AddStroke( inkData, ptStroke, strokeLen, (int)strokeWidth, coloref ) )
		{
            if ( _useAsyncRecognizer )
            {
                [self startAsyncRecoThread];
            }
			else if ( backgroundReco )
			{
				HWR_RecognizerAddStroke( [[RecognizerManager sharedManager] recognizer], ptStroke, strokeLen );
			}
			if ( fromThread )
			{
				[self performSelectorOnMainThread:@selector(strokeAdded:) withObject:nil waitUntilDone:NO];
			}
			else
			{
				[self strokeAdded:nil];				
			}
            INK_GetStrokeRect( inkData, -1, &rect, TRUE );
		}
	}
	// else
	{
        strokeLen = 0;
		// MUST UPDATE THE ENTIRE VIEW
        if ( fromThread )
        {
            RectObject * obj = nil;
            if ( ! CGRectIsNull( rect ) )
                obj = [[RectObject alloc] initWithRect:rect];
            [self performSelectorOnMainThread:@selector (updateDisplayInThread:) withObject:obj waitUntilDone:YES];
        }
        else
        {
            [_currentStrokeView setNeedsDisplay];
            if ( CGRectIsNull( rect ) )
                [self setNeedsDisplay];
            else
                [self setNeedsDisplayInRect:rect];
        }
	}
}

// Releases resources when they are not longer needed.
- (void) dealloc
{
	[self killRecoTimer];
	[self killHoldTimer];

	// pressing home button in while in the options dialog does not save recognizer files
	if ( NULL != ptStroke )
		free( ptStroke );	
	ptStroke = NULL;
	INK_FreeData( inkData );
}

- (UIColor *) _colorRefToUiColor:(COLORREF)coloref 
{
	UIColor * color = [UIColor colorWithRed:GetRValue(coloref) green:GetGValue(coloref) blue:GetBValue(coloref) alpha:GetAValue(coloref)];
	return color;
}


-(void)drawRect:(CGRect)rect
{
	CGContextRef	context = UIGraphicsGetCurrentContext();
    
	// draw the current stroke
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByClipping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary * attrib = @{ NSFontAttributeName: [UIFont fontWithName:@"Zapfino" size:(IS_PHONE ? 40.0 : 60.0)], NSParagraphStyleAttributeName: paragraphStyle };

	if ( self.placeholder1 != nil )
	{
		CGContextSetRGBFillColor(context, 0.1, 0.1, 0.1, 0.6 );
		CGRect rText = rect;
		rText.origin.y = IS_PHONE ? 50 : 150;
		rText.size.height = IS_PHONE ? 100 : 160;
        rText.origin.x = -10;
		[self.placeholder1 drawInRect:rText withAttributes:attrib];
	}
	if ( self.placeholder2 != nil )
	{
		CGContextSetRGBFillColor(context, 0.1, 0.1, 0.1, 0.6 );
		CGRect rText = rect;
		rText.origin.y = IS_PHONE ? 170 : 350;
		rText.size.height = IS_PHONE ? 100 : 160;
        rText.origin.x = -10;
		[self.placeholder2 drawInRect:rText withAttributes:attrib];
	}
	
	register int		nStroke = 0;
	int			nStrokeLen = 0;
	int			nWidth = 1;
	CGStroke	points = NULL;
	COLORREF	coloref = 0;
	CGRect		rStroke = CGRectZero;
	
	while ( INK_GetStrokeRect( inkData, nStroke, &rStroke, FALSE ) )
	{
		if ( CGRectIntersectsRect( rStroke, rect ) )
		{
			nStrokeLen = INK_GetStrokeP( inkData, nStroke, &points, &nWidth, &coloref );
			if ( nStrokeLen < 1 || NULL == points )
				break;
			[WPInkView _renderLine:points pointCount:nStrokeLen inContext:context withWidth:(float)nWidth withColor:[utils _uiColorRefToColor:coloref]];
		}
		nStroke++;
	}
		
	if ( NULL != points )
		free( (void *)points );
}

-(void) empty
{
	[self killRecoTimer];
	[self killHoldTimer];
	INK_Erase( inkData );	
    [_currentStrokeView setNeedsDisplay];
	[self setNeedsDisplay];
}

#pragma mark - AddPixelToStroke

#define SEGMENT2            2
#define SEGMENT3            3
#define SEGMENT4            4

#define SEGMENT_DIST_1      3
#define SEGMENT_DIST_2      6
#define SEGMENT_DIST_3      12

-(int)AddPixelsX:(int)x Y:(int)y pressure:(int)pressure IsLastPoint:(BOOL)bLastPoint
// this method called from inkCollectorThread
{
    CGFloat		xNew, yNew, x1, y1;
    CGFloat		nSeg = SEGMENT3;
	
	if ( NULL == ptStroke )
		return 0;
	
    if  ( strokeLen < 1 )
    {
        ptStroke[strokeLen].pt.x = _previousLocation.x = x;
        ptStroke[strokeLen].pt.y = _previousLocation.y = y;
        ptStroke[strokeLen].pressure = pressure;
        strokeLen = 1;
        return  1;
    }
	
    CGFloat dx = fabs( x - ptStroke[strokeLen-1].pt.x );
    CGFloat dy = fabs( y - ptStroke[strokeLen-1].pt.y );
	
    if  ( dx + dy < 1.0f )
        return 0;
	
    if ( dx + dy > 100.0f * SEGMENT_DIST_2 )
        return 0;
	
	int nNewLen = (strokeLen + 2 * SEGMENT4 + 1) * sizeof( CGTracePoint );
	if ( nNewLen >= strokeMemLen )
	{
		strokeMemLen += DEFAULT_STROKE_LEN * sizeof( CGTracePoint );
		ptStroke = realloc( ptStroke, strokeMemLen );
		if ( NULL == ptStroke )
			return 0;
	}
	
    if  ( (dx + dy) < SEGMENT_DIST_1 )
    {
        ptStroke[strokeLen].pt.x = _previousLocation.x = x;
        ptStroke[strokeLen].pt.y = _previousLocation.y = y;
        ptStroke[strokeLen].pressure = pressure;
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
    for ( register int i = 1;  i < nSeg;  i++ )
    {
        x1 = _previousLocation.x + ((x - _previousLocation.x)*i ) / nSeg;  //the point "to look at"
        y1 = _previousLocation.y + ((y - _previousLocation.y)*i ) / nSeg;  //the point "to look at"
		
        xNew = ptStroke[strokeLen-1].pt.x + (x1 - ptStroke[strokeLen-1].pt.x) / nSeg;
        yNew = ptStroke[strokeLen-1].pt.y + (y1 - ptStroke[strokeLen-1].pt.y) / nSeg;
		
        if ( xNew != ptStroke[strokeLen-1].pt.x || yNew != ptStroke[strokeLen-1].pt.y )
        {
            ptStroke[strokeLen].pt.x = xNew;
            ptStroke[strokeLen].pt.y = yNew;
            ptStroke[strokeLen].pressure = pressure;
            strokeLen++;
            nPoints++;
        }
    }
	
    if ( bLastPoint )
    {
		// add last point
        if ( x != ptStroke[strokeLen-1].pt.x || y != ptStroke[strokeLen-1].pt.y )
        {
            ptStroke[strokeLen].pt.x = x;
            ptStroke[strokeLen].pt.y = y;
            ptStroke[strokeLen].pressure = pressure;
            strokeLen++;
            nPoints++;
        }
    }
	
	_previousLocation.x = x;
    _previousLocation.y = y;
    return nPoints;
}


#pragma mark - Main thread callback methods 

- (void) endSelectionMode
{
	_bSendTouchToEdit = NO;
	_bSelectionMode = NO;
}

- (void) enterSelectionMode
{
	_bSendTouchToEdit = YES;
	_bSelectionMode = YES;
}

- (void) recognizerTimer
{
	[self recognizeInk:YES];
}

- (void) touchAndHoldTimer
{
	[self killHoldTimer];
    int nStrokes = INK_StrokeCount( inkData, FALSE );
    if ( edit != nil && nStrokes  <  1 && _firstTouch )
        [edit processTouchAndHoldAtLocation:_previousLocation];
    else if (  edit != nil && nStrokes < 1 && strokeLen > 2 )
    {
		CGPoint	from = ptStroke[0].pt;
		CGPoint to = ptStroke[strokeLen-1].pt;
        [edit selectTextFromPosition:from toPosition:to];
    }

    strokeLen = 0;
    [_currentStrokeView setNeedsDisplay];
}

- (void)addPointAndDraw:(CGPoint)point IsLastPoint:(BOOL)isLastPoint
{
	int	lenSave = strokeLen-1;	
	if ( lenSave < 0 )
	{
		return;
	}
	
	// must not contain negative coordinates
	if ( point.x < 0 )
		point.x = 0;
	if ( point.y < 0 )
		point.y = 0;
	
	if ( isLastPoint )
	{
		// make sure last point is not too far
		if ( ABS( ptStroke[lenSave].pt.x - point.x ) > 20 || ABS( ptStroke[lenSave].pt.y - point.y ) > 20 )
		{
			point = ptStroke[lenSave].pt;
		}
	}
    
    // TODO: if pen pressure is supported, you may change DEFAULT_PRESSURE to actual pressure value,
    // The pressure is assumed to changes between 1 (min) and 255 (mac), 150 considered to be default.
    _nAdded += [self AddPixelsX:point.x Y:point.y pressure:DEFAULT_PRESSURE IsLastPoint:FALSE];
	if ( _nAdded > 0 )
	{
        NSInteger from = MAX( 0, strokeLen-1-_nAdded );
        NSInteger to = MAX( 0, strokeLen-1 );
        int penwidth = 2.0 + strokeWidth/2.0;
        CGRect rect = CGRectMake( ptStroke[to].pt.x, ptStroke[to].pt.y, ptStroke[to].pt.x, ptStroke[to].pt.y );
        for ( NSInteger i = from; i < to; i++ )
        {
            rect.origin.x = MIN( rect.origin.x, ptStroke[i].pt.x );
            rect.origin.y = MIN( rect.origin.y, ptStroke[i].pt.y );
            rect.size.width = MAX( rect.size.width, ptStroke[i].pt.x );
            rect.size.height = MAX( rect.size.height, ptStroke[i].pt.y);
        }
        rect.size.width -= rect.origin.x;
        rect.size.height -= rect.origin.y;
        rect = CGRectInset( rect, -penwidth, -penwidth );
		[_currentStrokeView setNeedsDisplayInRect:rect];
		_nAdded = 0;
	}	
}


#pragma mark - Touches Handles

-(void) killHoldTimer
{
	if ( nil != _timerTouchAndHold )
	{
		[_timerTouchAndHold invalidate];
		_timerTouchAndHold = nil;
	}	
}

// Handles the start of a touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch*	touch = nil;
	CGPoint		location;
	
	[self killHoldTimer];
	[edit becomeFirstResponder];
    
    // [edit hideSuggestions];
    	
    if ( self.placeholder1 != nil )
    {
        self.placeholder1 = nil;
        self.placeholder2 = nil;
    	[self setNeedsDisplay];
    }
    
    touch =  [touches anyObject];
    location = [touch locationInView:self];

	[self killRecoTimer];

    _nAdded = 0;
	_bSendTouchToEdit = _bSelectionMode;
	strokeLen = 0;
    _firstTouch = YES;

	_previousLocation = location;
    
    if ( nil != edit )
	{
        // TODO: this is optional, if you do not need to send touch events to undelying views, this code can be disabled.
		if ( edit.selectedRange.length > 0 )
		{
            // TODO: you may try to handle selection mode by forwarding touche events to the edit view
		}
		else if ( _bSendTouchToEdit )
		{
            // TODO: you may change the way you forward events to other views depending on your application interface
			[edit touchesBegan:touches withEvent:event];
			return;
		}
        if ( INK_StrokeCount( inkData, FALSE )  <  1 )
        {
            _timerTouchAndHold = [NSTimer scheduledTimerWithTimeInterval:DEFAULT_TOUCHANDHOLDDELAY target:self
															selector:@selector(touchAndHoldTimer) userInfo:nil repeats:NO];
        }
	}
    
	if ( _bAsyncInkCollector )
	{
		if ( _inkQueueGet == _inkQueuePut )
			_inkQueueGet = _inkQueuePut = 0;
		[self addPointToQueue:location];
	}
	else
	{	
        ptStroke[0].pressure = DEFAULT_PRESSURE;
		ptStroke[0].pt = _previousLocation;
		strokeLen = 1;
        _nAdded = 1;
	}
}

// Handles the continuation of a touch. 
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{  
    UITouch  *touch =  [touches anyObject];
    if ( touch == nil )
        return;
    
    if ( [[UIMenuController sharedMenuController] isMenuVisible] || strokeLen == 0 )
    {
        strokeLen = 0;
        return;
    }

    CGPoint		location = [touch locationInView:self];
    
    CGFloat		dy = location.y - _previousLocation.y;
    CGFloat		dx = location.x - _previousLocation.x;
    if ( dx*dx + dy*dy <= 2.0 )
        return;
    
	if ( _firstTouch )
	{
		if ( dx*dx + dy*dy > 36 )
		{
            [self killHoldTimer];
			_firstTouch = NO;
		}
	}
    else
    {
        [self killHoldTimer];
    }
    
    if ( _bSendTouchToEdit && edit != nil )
    {
        [edit touchesMoved:touches withEvent:event];
        return;
    }
    
    if ( nil != edit && INK_StrokeCount( inkData, FALSE )  <  1 && (!_firstTouch) )
    {
        // this is for selection
        _timerTouchAndHold = [NSTimer scheduledTimerWithTimeInterval:DEFAULT_TOUCHANDHOLDDELAY target:self 
                                                            selector:@selector(touchAndHoldTimer) userInfo:nil repeats:NO];
    }
    if ( _bAsyncInkCollector  )
    {
        [self addPointToQueue:location];
    }
    else if ( (location.y != _previousLocation.y || location.x != _previousLocation.x) && NULL != ptStroke )
    {		
        // if this is the first stroke, re-enable the touch timer
        [self addPointAndDraw:location IsLastPoint:FALSE];
        
    }	
}

// Handles the end of a touch event when the touch is a tap.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self killHoldTimer];
    
    if ( [[UIMenuController sharedMenuController] isMenuVisible] || strokeLen == 0 )
    {
        strokeLen = 0;
        return;
    }
    
    if ( [touches count] > 1 )
    {
        // do not emulate touch if there are multiple touches in the queue
        _firstTouch = NO;
	}
    
	UInt32		nStrokeCount = INK_StrokeCount( inkData, FALSE );
	UITouch  *	touch =  [touches anyObject];

	if ( touch == nil )
    {
         _firstTouch = NO;
		return;
    }
	
	CGPoint		location = [touch locationInView:self];
	
	if ( _bSendTouchToEdit )
	{
		if ( edit != nil )
		{
			[edit touchesEnded:touches withEvent:event];
		}
		_firstTouch = NO;
		return;
	}
	
	if ( _firstTouch )
	{
		_firstTouch = NO;
		if ( nStrokeCount < 1  )
		{
			if ( nil != edit )
				[edit tapAtLocation:touches withEvent:event];
            if ( strokeLen > 0 )
            {
                strokeLen = 0;
                
                CGRect rect;
                rect.origin.x = MIN( location.x, ptStroke[0].pt.x ) - strokeWidth * 2;
                rect.origin.y = MIN( location.y, ptStroke[0].pt.y ) - strokeWidth * 2;
                rect.size.width = (MAX( location.x, ptStroke[0].pt.x ) + strokeWidth * 4) - rect.origin.x;
                rect.size.height = (MAX( location.y, ptStroke[0].pt.y ) + strokeWidth * 4) - rect.origin.y;
                [_currentStrokeView setNeedsDisplayInRect:rect];
            }
			return;
		}
		else
		{
			location.x++;			
		}
	}
	if ( nStrokeCount < 1 && strokeLen < 4 )
	{
		if ( nil != edit )
        {
			[edit tapAtLocation:touches withEvent:event];
        }
		if ( strokeLen > 0 )
		{
			strokeLen = 0;

			CGRect rect;
			rect.origin.x = MIN( location.x, ptStroke[0].pt.x ) - strokeWidth * 2;
			rect.origin.y = MIN( location.y, ptStroke[0].pt.y ) - strokeWidth * 2;
			rect.size.width = (MAX( location.x, ptStroke[0].pt.x ) + strokeWidth * 4) - rect.origin.x;
			rect.size.height = (MAX( location.y, ptStroke[0].pt.y ) + strokeWidth * 4) - rect.origin.y;
			[_currentStrokeView setNeedsDisplayInRect:rect];
		}
		return;
	}

	if ( _bAsyncInkCollector )
	{
		[self addPointToQueue:location];
		[self addPointToQueue:CGPointMake( 0, -1 )];
	}
	else
	{
		[self addPointAndDraw:location IsLastPoint:TRUE];
		
		// process the new stroke
		[self processEndOfStroke:NO];
		// _strokeFilterTimeout = [[NSDate date] timeIntervalSinceReferenceDate];
	}
}

// Handles the end of a touch event.
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	_firstTouch = NO;
	
    // cancel current stroke
    strokeLen = 0;
    [_currentStrokeView setNeedsDisplay];
    // [self setNeedsDisplay];
}

#pragma mark - Asyncronous Recognizer Thread

-(BOOL) startAsyncRecoThread
{
    if ( ! _useAsyncRecognizer )
        return NO;
    // make sure another recognizer thread is not already running
    [self stopAsyncRecoThread];
    
    self.currentResult = nil;
    if ( [[RecognizerManager sharedManager] isEnabled] &&  [self isInkData] )
    {
        InkObject * ink = [[InkObject alloc] initWithInkData:inkData];
        // create a new async recognizer thread
        [NSThread detachNewThreadSelector:@selector(asyncRecoThread:) toTarget:self withObject:ink];
        return YES;
    }
    return NO;
}

-(void) stopAsyncRecoThread
{
    if ( _useAsyncRecognizer )
    {
        HWR_StopAsyncReco( [[RecognizerManager sharedManager] recognizer] );
    }
}

-(void) showAsyncRecoResult:(NSString *)strResult
{
    if ([delegate respondsToSelector:@selector(InkCollectorAsyncResultReady:theResult:)])
    {
        [delegate InkCollectorAsyncResultReady:self theResult:strResult];
    }
}

-(void) asyncRecoThread:(id)obj
{
    @autoreleasepool
    {
        [NSThread setThreadPriority:0.2];
        InkObject * ink = obj;
        if ( ink.inkData != NULL )
        {
            const UCHR * pText = NULL;
            @synchronized( self )
            {
                pText = [[RecognizerManager sharedManager] recognizeInkData:ink.inkData background:NO async:YES selection:NO];
                if ( pText != NULL )
                {
                    // send result to main thread
                    NSString * strText = [RecognizerManager stringFromUchr:pText];
                    self.currentResult = strText;
                }
            }
            if ( [self.currentResult length] > 0 )
                [self performSelectorOnMainThread:@selector(showAsyncRecoResult:) withObject:self.currentResult waitUntilDone:YES];
            // exit thread, recognition completed
        }
    }
}


@end
