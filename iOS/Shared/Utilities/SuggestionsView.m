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

#import "SuggestionsView.h"
#import "utils.h"
#import "LanguageManager.h"
#import "RecognizerManager.h"
#import "OptionKeys.h"

#define GAP				8

#define VIEW_HEIGHT		((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 36 : 40)

#define MAX_WORDS       14

#define kAnimationAlphaDuration 0.3
#define SUGGESTION_TIMEOUT      6.0

static SuggestionsView * g_sugestions = nil;

@interface SuggestionsView()
{
    BOOL        attachedToKeyboard;
    CGFloat     viewHeight;
    CGFloat     fontSize;
    BOOL        _isError;
}

@property (nonatomic, copy) NSString *      spellWord;
@property (nonatomic, retain) UIButton *    clearButton;

@end

@implementation SuggestionsView

@synthesize suggestions_delegate;
@synthesize spellWord;

@synthesize colorFirstResult;
@synthesize colorAlertResult;
@synthesize colorOtherResult;
@synthesize colorBackground;

+ (SuggestionsView *) sharedSuggestionsView
{
    if ( g_sugestions == nil )
        g_sugestions = [[SuggestionsView alloc] initWithFrame:CGRectMake( 0, 0, 300,  [SuggestionsView getHeight])];
    return g_sugestions;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) 
	{
        // Initialization code
		_words = [[NSMutableArray alloc] init];
		selectedWord = -1;
		self.hidden = YES;
		textLength = 0;
		self.backgroundColor = [UIColor clearColor];
        [self setClipsToBounds:YES];
        self.autoresizesSubviews = YES;
        self.clipsToBounds = YES;
        
        self.colorFirstResult = [UIColor whiteColor];
        self.colorAlertResult = [UIColor redColor];
        self.colorOtherResult = [UIColor yellowColor];
        self.colorBackground = [UIColor colorWithRed:0.28 green:0.26 blue:0.25 alpha:0.92];
        
        self.spellWord = nil;
        attachedToKeyboard = NO;
        viewHeight = frame.size.height;
        fontSize = frame.size.height - 14.0;
        _isError = NO;
    
        buttons = [[NSMutableArray alloc] initWithCapacity:MAX_WORDS];

        self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [self setCanCancelContentTouches:NO];
        self.showsHorizontalScrollIndicator = NO;
        self.delegate = self;
        
        hideTimer = nil;
        _lock = [[NSLock alloc] init];
#if !__has_feature(objc_arc)
        _font = [[UIFont systemFontOfSize:fontSize] retain];
        _italic = [[UIFont italicSystemFontOfSize:fontSize] retain];
#else
        _font = [UIFont systemFontOfSize:fontSize];
        _italic = [UIFont italicSystemFontOfSize:fontSize];
#endif
        // add delete button
        CGRect  rButton = CGRectMake( 2, 0, viewHeight, viewHeight-4 );
        
        UIButton *button = [[UIButton alloc] initWithFrame:rButton];
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
        [button setImage:[utils colorImageWithName:@"delete_word.png" color:self.colorFirstResult mode:(kCGBlendModeCopy)] forState:UIControlStateNormal];
        button.tag = -1;
        [button addTarget:self action:@selector(resultSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        button.backgroundColor = [UIColor clearColor];
        // [self addSubview:button];
        self.clearButton = button;
#if !__has_feature(objc_arc)
        [button release];
#endif
        for ( int i = 0; i <= MAX_WORDS; i++ )
        {
            UIButton * button = [[UIButton alloc] initWithFrame:rButton];
            button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            if ( i == 0 )
            {
                button.titleLabel.font = _italic;
                [button setTitleColor:self.colorFirstResult forState:UIControlStateNormal];
            }
            else
            {
                button.titleLabel.font = _font;
                [button setTitleColor:self.colorOtherResult forState:UIControlStateNormal];
            }
            [button addTarget:self action:@selector(resultSelected:) forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor = [UIColor clearColor];
            [buttons addObject:button];
#if !__has_feature(objc_arc)
            [button release];
#endif
        }
    }
    return self;
}

- (NSString * ) wordForIndex:(NSInteger)index
{
    if ( index >= 0 && index < [_words count] )
    {
        id object = [_words objectAtIndex:index];
        if ( [object isKindOfClass:[NSString class]] )
        {
            return (NSString *)object;
        }
        else if ( [object isKindOfClass:[NSDictionary class]] )
        {
            return (NSString *)[object objectForKey:@"word"];
        }
    }
    return nil;
}

- (NSAttributedString * ) attribwordForIndex:(int)index
{
    if ( index >= 0 && index < [_words count] )
    {
        id object = [_words objectAtIndex:index];
        if ( [object isKindOfClass:[NSDictionary class]] )
            return (NSAttributedString *)[object objectForKey:@"attrib_word"];
    }
    return nil;
}

- (NSAttributedString *) attribSuggestion:(NSString *)phrase words:(NSArray *)words
{
    NSMutableAttributedString * attribTitle = [[NSMutableAttributedString alloc] initWithString:phrase];
    NSInteger len = [attribTitle length];
    if ( len > 0 )
    {
        [attribTitle addAttribute:NSForegroundColorAttributeName value:self.colorOtherResult range:NSMakeRange(0,len)];
        [attribTitle addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0,len)];
    }
    for ( NSString * w in words )
    {
        NSRange r = [[attribTitle string] rangeOfString:w];
        if ( r.location != NSNotFound && r.length > 1 )
        {
            if ( [w rangeOfString:@" "].location == NSNotFound && (! [[RecognizerManager sharedManager] isDictionaryWord:w]) )
            {
                [attribTitle addAttribute:NSForegroundColorAttributeName
                                    value:self.colorAlertResult
                                    range:r];
            }
            continue;
        }
        // [attribTitle addAttribute:NSForegroundColorAttributeName value:self.colorOtherResult range:NSMakeRange(0,len)];
    }
#if !__has_feature(objc_arc)
    return [attribTitle autorelease];
#else
    return  attribTitle;
#endif
}

- (BOOL) isWordInArray:(NSString *)word
{
	for ( int i = 0; i < [_words count]; i++ )
	{
        NSString * w = [self wordForIndex:i];
        if ( nil != word && NSOrderedSame == [word compare:w] )
            return YES;
	}
	return NO;
}

+ (CGFloat)getHeight
{
	return VIEW_HEIGHT;
}

- (void) _hideDidEnd:(NSString*) ident finished:(NSNumber *)finished contextInfo:(void*)nothing
{
	self.hidden = YES;
	self.alpha = 1.0;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self resetHideTimer:NO];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self resetHideTimer:NO];
}

- (void) hide:(Boolean)animate
{
    [self resetHideTimer:NO];
    _isError = NO;
    if ( [self isHidden] || attachedToKeyboard )
        return;
    if ( suggestions_delegate && [suggestions_delegate respondsToSelector:@selector(suggestionsWillDissapear:)])
    {
        [suggestions_delegate suggestionsWillDissapear:self];
    }
	if ( animate )
	{
		[UIView beginAnimations:@"Hide" context:NULL];
		[UIView setAnimationDuration:kAnimationAlphaDuration];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(_hideDidEnd:finished:contextInfo:)];	
		self.alpha = 0.0;
		// Set the transform back to the identity, thus undoing the previous scaling effect.
		self.transform = CGAffineTransformIdentity;
		[UIView commitAnimations];	
	}
	else
	{
		self.hidden = YES;
	}
}

- (void) hideTimer
{
    [self resetHideTimer:NO];
    if ( suggestions_delegate && [suggestions_delegate respondsToSelector:@selector(suggestionsViewShouldTimeout:)])
    {
        if ( [suggestions_delegate suggestionsViewShouldTimeout:self] )
        {
            [self hide:YES];
        }
    }
    else
    {
        [self hide:YES];
    }
}

- (void) resetHideTimer:(BOOL)createNew
{
    if ( nil != hideTimer )
    {
        [hideTimer invalidate];
        hideTimer = nil;
    }
    if ( createNew )
    {
        hideTimer = [NSTimer scheduledTimerWithTimeInterval:SUGGESTION_TIMEOUT target:self
                                                        selector:@selector(hideTimer) userInfo:nil repeats:NO];
    }
}

- (void) show:(Boolean)animate
{
    [self resetHideTimer:YES];
    if ( ! [self isHidden] || attachedToKeyboard )
        return;
	if ( animate )
	{
		self.alpha = 0.0;
		self.hidden = NO;
		[UIView beginAnimations:@"Show" context:NULL];
		[UIView setAnimationDuration:kAnimationAlphaDuration];
		// [UIView setAnimationDelegate:self];
		// Set the center to the final postion
		self.alpha = 1.0;
		// Set the transform back to the identity, thus undoing the previous scaling effect.
		self.transform = CGAffineTransformIdentity;
		[UIView commitAnimations];	
	}
	else
	{
		self.hidden = NO;
	}
}

- (BOOL) removeAllButtons
{
    BOOL Refresh = NO;
    for ( UIButton * btn in buttons )
    {
        if ( btn.superview != nil )
        {
            [btn removeFromSuperview];
            Refresh = YES;
        }
    }
    [self.clearButton removeFromSuperview];
    return Refresh;
    // [buttons removeAllObjects];
}

- (void) setBarHeight:(CGFloat)height
{
    if ( height == viewHeight )
        return;
    
    viewHeight = height;
    fontSize = viewHeight - 14.0;
    
    CGSize sz = self.contentSize;
    sz.height = height;
    [self setContentSize:sz];
    
#if !__has_feature(objc_arc)
    _font = [[UIFont systemFontOfSize:fontSize] retain];
    _italic = [[UIFont italicSystemFontOfSize:fontSize] retain];
#else
    _font = [UIFont systemFontOfSize:fontSize];
    _italic = [UIFont italicSystemFontOfSize:fontSize];
#endif
    
    for ( UIButton * b in buttons )
    {
        if ( [buttons indexOfObject:b] == 0 )
        {
            b.titleLabel.font = _italic;
        }
        else
        {
            b.titleLabel.font = _font;
        }
        CGRect f = b.frame;
        f.size.height = height;
        b.frame = f;
    }
    CGRect f = self.frame;
    f.size.height = height;
    self.frame = f;

    if ( attachedToKeyboard )
        [self showResultsInRect:self.bounds inFrame:self.bounds];

}

- (BOOL) showResultsinKeyboard:(UIView *)keyboard inRect:(CGRect)rect
{
    if ( keyboard == nil )
    {
        // detouch
        attachedToKeyboard = NO;
        [self setBarHeight:VIEW_HEIGHT];
        self.hidden = YES;
        self.autoresizingMask = UIViewAutoresizingNone;
        [self removeFromSuperview];
        return YES;
    }
    attachedToKeyboard = YES;
    self.hidden = NO;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    rect.size.height = [SuggestionsView getHeight];
    self.frame = rect;
    [keyboard addSubview:self];
    
    return [self showResultsInRect:CGRectNull inFrame:rect];
}

#define MAX_ITTERATIONS     6

- (BOOL) showResultsInRect:(CGRect)rPosition inFrame:(CGRect)inFrame
{
	selectedWord = -1;
    textLength = 0;
    self.spellWord = nil;
    _isError = NO;
    
    if ( (attachedToKeyboard && CGRectIsNull( rPosition )) )
    {
        if ( CGRectIsNull( inFrame ) )
        {
            // NSLog( @"showResultsInRect: HIDE!" );
            [_words removeAllObjects];
            if ( [self removeAllButtons] )
            {
                // [self setNeedsDisplay];
                [self setNeedsLayout];
            }
        }
        return NO;
    }
    
    if ( (!attachedToKeyboard) && CGRectIsNull( rPosition ) )
    {
        [self hide:YES];
        return NO;
    }

    unsigned int	recoFlags = HWR_GetRecognitionFlags( [RecognizerManager sharedManager].recognizer );
    NSDictionary * recoData = [[RecognizerManager sharedManager] getAllWords:recoFlags];
    if ( nil == recoData )
    {
        [_words removeAllObjects];
        if ( [self removeAllButtons] )
        {
            // [self setNeedsDisplay];
            [self setNeedsLayout];
        }
        if ( (!attachedToKeyboard) )
            [self hide:YES];
        return NO;
    }
    
    _isError = [[recoData objectForKey:@"error"] boolValue];
    
    __block BOOL bAddSpace = (![[NSUserDefaults standardUserDefaults] boolForKey:kEditOptionsAutospace] && [[RecognizerManager sharedManager] getMode] != RECMODE_WWW);
    
    dispatch_queue_t q_default;
    q_default = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(q_default, ^(void)
        {
            @autoreleasepool
            {
            NSInteger wordCnt = [[recoData objectForKey:@"count"] integerValue];
            NSMutableArray * words = [recoData objectForKey:@"words"];
            int iWord, prob, nWordsAdded;
            
                [self->_lock lock];
            
                [self->_words removeAllObjects];
            
            if ( wordCnt > 1 )
            {
                [words sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    RecognizedWord * w1 = (RecognizedWord *)obj1;
                    RecognizedWord * w2 = (RecognizedWord *)obj2;
                    NSComparisonResult result = NSOrderedSame;
                    if ( w1.prob > w2.prob )
                        result = NSOrderedAscending;
                    else if ( w1.prob < w2.prob )
                        result = NSOrderedDescending;
                    return result;
                }];
            }
            
            // limit to max of 6 itterations if there are too many words.
            for ( int m = 0; m < MAX_ITTERATIONS; m++ )
            {
                for ( RecognizedWord * word in words )
                {
                    nWordsAdded = 0;
                    prob = 0;
                    NSMutableString * phrase = [NSMutableString string];
                    NSMutableArray * probs = [NSMutableArray arrayWithCapacity:wordCnt];
                    NSMutableArray * wrds = [NSMutableArray arrayWithCapacity:wordCnt];
                    for ( iWord = 0; iWord < wordCnt; iWord++ )
                    {
                        if ( iWord == word.col && (word.isDict || (0 == (recoFlags & FLAG_SUGGESTONLYDICT))) )
                        {
                            if ( [phrase length] > 0 )
                                [phrase appendString:@" "];
                            [phrase appendString:word.word];
                            [wrds addObject:word.word];
                            [probs addObject:[NSNumber numberWithInteger:word.prob]];
                            nWordsAdded++;
                            prob += word.prob;
                        }
                        else
                        {
                            for ( RecognizedWord * word2 in words )
                            {
                                if ( (word2.col == iWord && word2.col != word.col) && (word.isDict || (0 == (recoFlags & FLAG_SUGGESTONLYDICT))) )
                                {
                                    if ( [phrase length] > 0 )
                                        [phrase appendString:@" "];
                                    [phrase appendString:word2.word];
                                    [wrds addObject:word2.word];
                                    [probs addObject:[NSNumber numberWithInteger:word2.prob]];
                                    prob += word2.prob;
                                    nWordsAdded++;
                                    break;
                                }
                            }
                        }
                    }
                    if ( bAddSpace && [phrase length] > 1 )
                        [phrase appendString:@" "];
                    if ( nWordsAdded == wordCnt )
                    {
                        if ( ! [self isWordInArray:phrase] )
                        {
                            NSAttributedString * attribPhrase = [self attribSuggestion:phrase words:wrds];
                            NSDictionary * dict = @{ @"word" : phrase, @"attrib_word" : attribPhrase,  @"words" : wrds, @"weights" : probs, @"total" : [NSNumber numberWithInt:prob] };
                            [self->_words addObject:dict];
                            if ( [self->_words count] >= MAX_WORDS )
                                break;
                        }
                    }
                }
                if ( [words count] < 2 * wordCnt || wordCnt < 2 || [self->_words count] >= MAX_WORDS )
                {
                    break;
                }
                
                NSLog( @"Words in array: %lu", (unsigned long)[words count] );
                int nDeleted = 0;
                for ( int j = 0; j < wordCnt; j++ )
                {
                    // remove words with highest probabolities from each coloums
                    for ( RecognizedWord * w in words )
                    {
                        if ( w.col == j )
                        {
                            [words removeObject:w];
                            nDeleted++;
                            break;
                        }
                    }
                }
                if ( nDeleted < wordCnt )
                {
                    // no more words in one of the columns, quit the loop
                    break;
                }
            }
            
            if ( wordCnt > 1 )
            {
                // re-sort the resuting array by total probability
                [self->_words sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    NSDictionary * d1 = (NSDictionary *)obj1;
                    NSDictionary * d2 = (NSDictionary *)obj2;
                    int prob1 = [[d1 objectForKey:@"total"] intValue];
                    int prob2 = [[d2 objectForKey:@"total"] intValue];
                    
                    NSComparisonResult result = NSOrderedSame;
                    if ( prob1 > prob2 )
                        result = NSOrderedAscending;
                    else if ( prob1 < prob2 )
                        result = NSOrderedDescending;
                    return result;
                }];
            }
            else if ( wordCnt == 1 )
            {
                RecognizedWord * word = [words firstObject];
                self->textLength = [word.word length];
                if ( self->textLength >= 3 )
                    [self generateWordList:word.word addSpace:bAddSpace spell:NO]; // TODO: test
            }
            
            dispatch_queue_t q_main = dispatch_get_main_queue();
            dispatch_sync(q_main, ^(void)
                {
                    [self removeAllButtons];
                    CGRect  rButton = CGRectMake( 2, 0, self->viewHeight, self->viewHeight );
                    if ( ! self->_isError )
                    {
                        [self addSubview:self.clearButton];
                        rButton.origin.x += rButton.size.width + GAP;
                    }
                    for ( int i = 0; i < [self->_words count] && i < [self->buttons count]; i++ )
                    {
                        NSString * title = [self wordForIndex:i];
                        NSAttributedString * attribTitle = nil;
                        rButton.size.width = [title sizeWithAttributes:@{ NSFontAttributeName : self->_font }].width + 2 * GAP;
                        UIButton *button;
                        button = [self->buttons objectAtIndex:i];
                        button.frame = rButton;
                        
                        if ( i > 0 )
                        {
                            attribTitle = [self attribwordForIndex:i];
                        }
                        if ( attribTitle != nil )
                        {
                            [button setAttributedTitle:attribTitle forState:UIControlStateNormal];
                            [button setTitle:nil forState:UIControlStateNormal];
                        }
                        else
                        {
                            [button setAttributedTitle:nil forState:UIControlStateNormal];
                            [button setTitle:title forState:UIControlStateNormal];
                        }
                        
                        button.tag = i;
                        [button removeTarget:self action:@selector(wordSelected:) forControlEvents:UIControlEventTouchUpInside];
                        [button addTarget:self action:@selector(resultSelected:) forControlEvents:UIControlEventTouchUpInside];

                        [self addSubview:button];
                        
                        rButton.origin.x += rButton.size.width + GAP;
                    }

                    if ( [self->buttons count] > 0 )
                    {
                        self.contentOffset = CGPointMake( 0, 0 );
                        [self setContentSize:CGSizeMake(rButton.origin.x, self->viewHeight)];
                        
                        if ( ! self->attachedToKeyboard )
                        {
                            int x = (int)(inFrame.origin.x + GAP);
                            CGFloat width = MIN( rButton.origin.x + 2 * GAP, inFrame.size.width - 2 * GAP );
                            if ( CGRectIsEmpty( rPosition ) )
                            {
                                if ( width < inFrame.size.width - 2 * GAP )
                                {
                                    x = (int)(inFrame.size.width - 2 * GAP - width)/2;
                                }
                                CGRect r = CGRectMake( (CGFloat)x, inFrame.size.height - self->viewHeight - GAP, width, self->viewHeight );
                                self.frame = r;
                            }
                            else
                            {
                                if ( width < inFrame.size.width - 2 * GAP && rPosition.origin.x > 5 * GAP )
                                {
                                    x = (int)((rPosition.origin.x - 5 * GAP) / 12) * 12;
                                    if ( x + width > inFrame.size.width - 2 * GAP )
                                        x = (int)(inFrame.size.width - 2 * GAP - width);
                                }
                                CGFloat y = rPosition.origin.y + rPosition.size.height + GAP/2;
                                if ( y < 0.0 )
                                    y = rPosition.size.height + GAP/2;
                                else if ( y + self->viewHeight > inFrame.size.height )
                                {
                                    if ( rPosition.origin.y < inFrame.size.height )
                                        y = rPosition.origin.y - self->viewHeight - GAP;
                                    else
                                        y = inFrame.size.height - self->viewHeight - GAP;
                                }
                                y += inFrame.origin.y;
                                CGRect r = CGRectMake( (CGFloat)x, y, width, self->viewHeight );
                                self.frame = r;
                            }
                            [self show:YES];
                        }
                    }
                    else
                    {
                        [self hide:NO];
                    }
                    // [self setNeedsDisplay];
                    [self setNeedsLayout];
                });
                [self->_lock unlock];
        }
    });
    return YES;
}

- (void) generateWordList:(NSString * )text addSpace:(BOOL)bAddSpace spell:(BOOL)spell
{
    int flags = (spell) ? HW_SPELL_CHECK : HW_SPELL_LIST;
    
    NSArray * spellWords = [[RecognizerManager sharedManager] spellCheckWord:text flags:flags addSpace:bAddSpace];
    if ( nil != spellWords )
    {
        for ( NSString * w in spellWords )
        {
            if ( (spell || [w length] > textLength) && (! [self isWordInArray:w]) )
            {
                [_words addObject:w];
            }
            if ( [_words count] >= MAX_WORDS )
                break;
        }
    }
}

- (void)updateWordList:(NSString *)text inFrame:(CGRect)inFrame posiiton:(CGFloat)position spellCheck:(BOOL)spell
{
	[_words removeAllObjects];
    [self removeAllButtons];
    
    NSLog( @"updateWordList:%@", text );

    _isError = NO;
	selectedWord = -1;
	textLength = [text length];
    self.spellWord = spell ? text : nil;

	if ( text == nil || textLength < 2 || textLength >= HW_MAXWORDLEN-1 )
	{
        if ( attachedToKeyboard )
        {
            // [self setNeedsDisplay];
            [self setNeedsLayout];
        }
        else
        {
            [self hide:YES];
        }
		return;
	}
    
    [self generateWordList:text addSpace:NO spell:spell];
    
	// get suggestions from the apple spell checker
	NSArray * appleSpell = [[LanguageManager sharedManager] spellCheckWord:text complete:(!spell)];
	if ( nil != appleSpell && [appleSpell count] > 0 && [_words count] < MAX_WORDS )
	{
		for ( NSString * aWord in appleSpell )
		{
            if ( (spell || [aWord length] > textLength) && [aWord compare:text] != NSOrderedSame && (! [self isWordInArray:aWord]) )
            {
                [_words addObject:aWord];
                if ( [_words count] > MAX_WORDS )
                    break;
            }
		}
	}
    
    if ( [_words count] < 1 )
    {
        if ( attachedToKeyboard )
        {
            // [self setNeedsDisplay];
            [self setNeedsLayout];
        }
        else
        {
            [self hide:YES];
        }
		return;
    }
    
    if ( spell )
    {
        [_words insertObject:text atIndex:0];
    }
    
    CGRect  rButton = CGRectMake( 2, 0, viewHeight, viewHeight );
    if ( ! attachedToKeyboard )
    {
        [self addSubview:self.clearButton];
        rButton.origin.x += rButton.size.width + GAP;
    }
    
    for ( int i = 0; i < [_words count] && i < [buttons count]; i++ )
    {
        NSString * title = [self wordForIndex:i];
        rButton.size.width = [title sizeWithAttributes:@{ NSFontAttributeName : _font }].width + 3 * GAP;
        UIButton * button = [buttons objectAtIndex:i];
        button.frame = rButton;
        NSMutableAttributedString * attribTitle = [[NSMutableAttributedString alloc] initWithString:title];
        if ( spell && i == 0 )
        {
            [attribTitle addAttribute:NSForegroundColorAttributeName value:self.colorAlertResult range:NSMakeRange(0,[title length])];
        }
        else if ( textLength < [title length] && (!spell) )
        {
            [attribTitle addAttribute:NSForegroundColorAttributeName value:self.colorFirstResult range:NSMakeRange(0,textLength)];
            [attribTitle addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0,textLength)];
            [attribTitle addAttribute:NSForegroundColorAttributeName value:self.colorOtherResult range:NSMakeRange(textLength, [title length]-textLength)];
            [attribTitle addAttribute:NSFontAttributeName value:_italic range:NSMakeRange(textLength, [title length]-textLength)];
        }
        else
        {
            [attribTitle addAttribute:NSForegroundColorAttributeName value:self.colorFirstResult range:NSMakeRange(0,[title length])];
        }
        [button setTitle:@"" forState:UIControlStateNormal];
        [button setAttributedTitle:attribTitle forState:UIControlStateNormal];
         button.tag = i;
        [button removeTarget:self action:@selector(resultSelected:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(wordSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
#if !__has_feature(objc_arc)
        [attribTitle release];
#endif
        rButton.origin.x += rButton.size.width + GAP;
    }
    
    if ( [buttons count] > 0 )
    {
        self.contentOffset = CGPointMake( 0, 0 );
        [self setContentSize:CGSizeMake(rButton.origin.x, viewHeight)];

        if ( ! attachedToKeyboard )
        {
            int x = (int)(inFrame.origin.x + GAP);
            CGFloat width = MIN( rButton.origin.x + 2 * GAP, inFrame.size.width - 2 * GAP );
            if ( width < inFrame.size.width - 2 * GAP && position > 5 * GAP )
            {
                x = (int)((position - 5 * GAP) / 12) * 12;
                if ( x + width > inFrame.size.width - 2 * GAP )
                    x = (int)(inFrame.size.width - 2 * GAP - width);
            }
            self.frame = CGRectMake( (CGFloat)x, inFrame.size.height - (viewHeight - GAP/2), width, viewHeight );
            [self show:YES];
        }
    }
    else
    {
        [self hide:NO];
    }
    // [self setNeedsDisplay];
	[self setNeedsLayout];
}

- (void) resultSelected:(UIButton *)sender
{
    selectedWord = sender.tag;
    int saveFile = 0;
    if ( _isError )
        return;
    if ( suggestions_delegate && [suggestions_delegate respondsToSelector:@selector(suggestionsWordSelected:theResult:spellWord:)] )
    {
        if ( selectedWord >= 0 && selectedWord < [_words count] )
        {
            NSString * result = [self wordForIndex:selectedWord];
            [suggestions_delegate suggestionsWordSelected:self theResult:result spellWord:nil];
            
            // learn the selected phrase
            if ( [[NSUserDefaults standardUserDefaults] boolForKey:kRecoOptionsUseLearner] )
            {
                NSArray * oldResult = [[self wordForIndex:0] componentsSeparatedByString:@" "];
                NSArray * newResult = [result componentsSeparatedByString:@" "];
                
                id id_word = [_words objectAtIndex:selectedWord];
                if ( [id_word isKindOfClass:[NSString class]] )
                {
                    for ( NSString * newWord in newResult )
                    {
                        if ( [newWord length] > 2 )
                        {
                            // learn word and add to dictionary, if needed
                            saveFile |= ([[RecognizerManager sharedManager] learnNewWord:newWord weight:0] ? USERDATA_LEARNER : 0);
                            saveFile |= ([[RecognizerManager sharedManager] addWordToUserDict:newWord save:NO filter:YES report:NO] ? USERDATA_DICTIONARY : 0);
                        }
                    }
                }
                else if ( [id_word isKindOfClass:[NSDictionary class]] )
                {
                    NSDictionary * dict = (NSDictionary *)id_word;
                    NSArray * weights = [dict objectForKey:@"weights"];
                    
                    for ( NSString * newWord in newResult )
                    {
                        if ( [newWord length] > 2 )
                        {
                            USHORT w = 0;
                            NSInteger i = [newResult indexOfObject:newWord];
                            if ( nil != weights && i < [weights count] )
                                w = (USHORT)([[weights objectAtIndex:i] integerValue]);
                            saveFile |= ([[RecognizerManager sharedManager] learnNewWord:newWord weight:w] ? USERDATA_LEARNER : 0);
                            saveFile |= ([[RecognizerManager sharedManager] addWordToUserDict:newWord save:NO filter:YES report:NO] ? USERDATA_DICTIONARY : 0);
                        }
                    }
                    if ( selectedWord > 0 )
                    {
                        NSDictionary * dict0 = [_words objectAtIndex:0];
                        NSArray * weights0 = [dict0 objectForKey:@"weights"];
                        
                        for ( int i = 0; i < [oldResult count]; i++ )
                        {
                            if ( i >= [newResult count] )
                                break;
                            NSString * sword1 = [oldResult objectAtIndex:i];
                            NSString * sword2 = [newResult objectAtIndex:i];
                            if ( [sword1 length] > 1 && [sword2 length] > 1 )
                            {
                                if ( NSOrderedSame != [sword1 caseInsensitiveCompare:sword2] )
                                {
                                    USHORT w1 = 0, w2 = 0;
                                    if ( nil != weights && i < [weights count] )
                                        w2 = (USHORT)([[weights objectAtIndex:i] integerValue]);
                                    if ( nil != weights0 && i < [weights0 count] )
                                        w1 = (USHORT)([[weights0 objectAtIndex:i] integerValue]);
                                    saveFile |= ([[RecognizerManager sharedManager] replaceWord:sword1 probability1:w1 wordTo:sword2 probability2:w2] ? USERDATA_LEARNER : 0);
                                }
                            }
                        }
                    }
                }
            }
        }
        else if ( sender.tag == -1 && [_words count] )
        {
            [suggestions_delegate suggestionsWordSelected:self theResult:@"" spellWord:nil];
        }
    }
    
    [[RecognizerManager sharedManager] saveRecognizerDataOfType:saveFile];
    [self hide:YES];
    [_words removeAllObjects];
    [self removeAllButtons];
    selectedWord = -1;
}

- (void) wordSelected:(UIButton *)sender
{
    selectedWord = sender.tag;
    if ( selectedWord >= 0 && selectedWord < [_words count] )
    {
        NSString * word = [self wordForIndex:selectedWord];
        if ( [word length] > 3 )
        {
            [[RecognizerManager sharedManager] learnNewWord:word weight:0];
        }
        if ( suggestions_delegate && [suggestions_delegate respondsToSelector:@selector(suggestionsWordSelected:theResult:spellWord:)] )
        {
            [suggestions_delegate suggestionsWordSelected:self theResult:word spellWord:self.spellWord];
        }
    }
    [self hide:YES];
    [_words removeAllObjects];
    [self removeAllButtons];
    selectedWord = -1;
}


#define RADIUS  4.0

- (void)dealloc
{
    self.colorFirstResult = nil;
    self.colorAlertResult = nil;
    self.colorOtherResult = nil;
    self.colorBackground = nil;
    self.clearButton = nil;
    self.spellWord = nil;
    [self resetHideTimer:NO];
    [self removeAllButtons];
#if !__has_feature(objc_arc)
    [_lock release];
    [_italic release];
    [_font release];
    [buttons release];
	[_words release];
    [super dealloc];
#endif
}


@end
