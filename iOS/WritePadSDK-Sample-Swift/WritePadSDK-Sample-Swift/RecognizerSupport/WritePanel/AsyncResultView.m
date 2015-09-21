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

#import "AsyncResultView.h"
#import "RecognizerWrapper.h"
#import "WritePadInputPanel.h"
#import "UIConst.h"
#import "LanguageManager.h"
#import "RecognizerManager.h"
#import "utils.h"
#import "OptionKeys.h"

@implementation AsyncResultView

@synthesize inputPanel;
@synthesize text;
@synthesize words;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) 
	{
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
		self.contentMode = UIViewContentModeRedraw;
		text = nil;
		font = [UIFont fontWithName:@"Verdana" size:(IS_PHONE ? 16 : 30)];
		fontError = [UIFont fontWithName:@"Verdana-Italic" size:(IS_PHONE ? 16 : 30)];
		selectedWord = -1;
		resultError = NO;
    }
    return self;
}

- (void) empty
{
	self.text = nil;
	self.words = nil;
}

- (void) setText:(NSString *)newText
{
	text = newText;
	if ( newText != nil )
		resultError = ([newText rangeOfString:@kEmptyWord].location == NSNotFound) ? NO : YES;
	else
		resultError = NO;
    if ( resultError )
    {
        [[RecognizerManager sharedManager] reportError];
    }
	self.words = nil;
	selectedWord = -1;
	[self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect 
{
	CGRect	bounds = [self bounds];
	CGRect	rText = bounds;
    // Drawing code
    
	CGContextRef	context = UIGraphicsGetCurrentContext();
	// CGContextSetRGBFillColor( context, 1.0, 1.0, 1.0, 0.9 );
	// CGContextFillRect( context, bounds );
	
	
	if ( resultError )
	{
		NSString * word = LOC( @"Input Error" );
		[[UIColor redColor] set];
		CGSize size = [word sizeWithAttributes:@{ NSFontAttributeName : fontError }];
		rText.size.width = size.width;
		[word drawInRect:rText withAttributes:@{ NSFontAttributeName : fontError }];
		return;
	}
	
	[[UIColor blackColor] set];
	if ( words && [words count] > 0 )
	{
		for ( NSInteger wordIndex = 0; wordIndex < [words count]; wordIndex++ )
		{
			NSArray *	_words = [words objectAtIndex:wordIndex];
			if ( [_words count] > 0 )
			{
				NSString *	word = [[_words objectAtIndex:0] objectForKey:@"word"];
				if ( word != nil )
				{
                    word = [[RecognizerManager sharedManager] calcString:word];
					CGSize size = [word sizeWithAttributes:@{ NSFontAttributeName : font }];
					rText.size.width = size.width;
					if ( rText.size.width + rText.origin.x > bounds.size.width )
						break;
                    
					if ( wordIndex == selectedWord )
					{
						CGContextSaveGState(context);
						CGContextSetRGBFillColor( context, 0.0, 0.2, 0.9, 0.4 );
						CGContextFillRect( context, rText );
						[[UIColor whiteColor] set];
						[word drawInRect:rText withAttributes:@{ NSFontAttributeName : font }];
						CGContextRestoreGState(context);
					}
					else
					{
						[word drawInRect:rText withAttributes:@{ NSFontAttributeName : font }];
					}
					[word drawInRect:rText withAttributes:@{ NSFontAttributeName : font }];
					rText.origin.x += (rText.size.width + [@" " sizeWithAttributes:@{ NSFontAttributeName : font }].width);
				}
			}
		}
	}
	else if ( text != nil && [text length] > 0 )
	{
		[text drawInRect:rect withAttributes:@{ NSFontAttributeName : font }];
	}		
}

#pragma mark - generate recognizer word array


// we only need to do it if user taps on the word
- (NSInteger) generateWordArray
{
	words = [[[RecognizerManager sharedManager] generateWordArray:MAX_SUGGESTION_COUNT spellCheck:YES] mutableCopy];
	return [words count];
}

- (NSInteger) learnNewWords
{
	NSInteger result = 0;
    if ( [[NSUserDefaults standardUserDefaults] boolForKey:kRecoOptionsUseLearner] )
    {
        if ( words == nil )
        {
            result = [self generateWordArray];
        }
        else 
        {
            result = [words count];
        }
        if ( result > 0 )
        {
            int saveFile = 0;
            for ( NSArray * _words in words )
            {
                NSString * word = [[_words objectAtIndex:0] objectForKey:@"word"];
                USHORT weight = [[[_words objectAtIndex:0] objectForKey:@"weight"] unsignedShortValue];
                saveFile |= ([[RecognizerManager sharedManager] learnNewWord:word weight:weight] ? USERDATA_LEARNER : 0);
                saveFile |= ([[RecognizerManager sharedManager] addWordToUserDict:word save:NO filter:YES] ? USERDATA_DICTIONARY : 0);
            }
            [[RecognizerManager sharedManager] saveRecognizerDataOfType:saveFile];
            result = (saveFile!=0);
        }
    }
	return result;
}


- (BOOL) isWordInDictionary:(NSString *)strWord
{
	RECOGNIZER_PTR _reco = [RecognizerManager sharedManager].recognizer;
	register const UCHR * pText = [RecognizerManager uchrFromString:strWord];
	if ( HWR_IsWordInDict( _reco, pText ) )
		return YES;	
	return NO;
}

#pragma mark - Touches Handles

- (NSInteger) processTouch:(CGPoint)location showPopover:(BOOL)showPopover
{
	CGRect	bounds = [self bounds];
	CGRect	rText = bounds;
	
	selectedWord = -1;
	if ( nil == words )
	{
		if ( [self generateWordArray] < 1 )
			return selectedWord;
	}

	for ( NSInteger wordIndex = 0; wordIndex < [words count]; wordIndex++ )
	{
		NSMutableArray *	_words = [words objectAtIndex:wordIndex];
		if ( [_words count] > 0 )
		{
			NSString *	word = [[_words objectAtIndex:0] objectForKey:@"word"];
			if ( word != nil )
			{
				CGSize size = [word sizeWithAttributes:@{ NSFontAttributeName : font }];
				rText.size.width = size.width;
				if ( rText.size.width + rText.origin.x > bounds.size.width )
					break;
				if ( CGRectContainsPoint( rText, location ) )
				{
					selectedWord = wordIndex;
					
					if ( showPopover && (!IS_PHONE) )
					{
                        // TODO: process word selection if needed
					}
					return selectedWord;
				}
				rText.origin.x += (rText.size.width + [@" " sizeWithAttributes:@{ NSFontAttributeName : font }].width);
			}
		}
	}
	return selectedWord;
}

// Handles the start of a touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch*	touch = [[event touchesForView:self] anyObject];
	CGPoint		location = [touch locationInView:self];
	
	if ( resultError || nil == self.text )
		return;

	if ( [self processTouch:location showPopover:YES] >= 0 )
	{
		NSLog( @"Selected word %ld", (long)selectedWord );

		// redraw
		[self setNeedsDisplay];
	}
}

// Handles the continuation of a touch. 
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{  
	//UITouch*	touch = [[event touchesForView:self] anyObject];
	//CGPoint		location = [touch locationInView:self];
}

// Handles the end of a touch event when the touch is a tap.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{	
	//UITouch*	touch = [[event touchesForView:self] anyObject];
	//CGPoint		location = [touch locationInView:self];	
}

// Handles the end of a touch event.
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}


@end
