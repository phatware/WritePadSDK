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

#import "LetterShapesController.h"
#import "RecognizerManager.h"
#import "LetterGroupView.h"
#import "UIConst.h"

#define LETTERS_STRIP_HEIGHT		86

@implementation LetterShapesController

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

- (void)createThumbScrollView:(CGRect)rect
{
	thumbScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake( 0, 0, rect.size.width, rect.size.height)];
	thumbScrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	[thumbScrollView setCanCancelContentTouches:NO];
	[thumbScrollView setClipsToBounds:NO];
	
	// now place all the thumb views as subviews of the scroll view 
	// and in the course of doing so calculate the content width
	CGFloat xPosition = THUMB_H_PADDING;
	CGFloat xOffset = 0;
	NSString * chars = [LetterGroupView getCharSet];
	for ( NSInteger i = 0; i < [chars length]; i++ ) 
	{
		unichar ch = [chars characterAtIndex:i];
		NSString * strName = [NSString stringWithCharacters:&ch  length:1];
		if ( nil != strName ) 
		{
			ThumbImageView *thumbView = [[ThumbImageView alloc] initWithLetter:strName];
			[thumbView setDelegate:self];
			thumbView.userInteractionEnabled = YES;
			thumbView.index = i;
			CGRect frame = [thumbView frame];
			frame.origin.y = THUMB_V_PADDING;
			frame.origin.x = xPosition;
			frame.size.width = THUMB_HEIGHT - 2 * THUMB_V_PADDING;
			frame.size.height = THUMB_HEIGHT - 2 * THUMB_V_PADDING;
			[thumbView setFrame:frame];
			[thumbView setHome:frame];
			[thumbView setBackgroundColor:[UIColor clearColor]];
			[thumbScrollView addSubview:thumbView];
			xPosition += (frame.size.width + THUMB_H_PADDING);
			
			if ( i == selectedLetter )
			{
				[thumbView setSelected:YES];
				if ( xPosition > rect.size.width )
				{
					// scroll to the position
					xOffset = ((xPosition - rect.size.width) + THUMB_H_PADDING);
				}
			}
		}
	}
	[thumbScrollView setContentSize:CGSizeMake(xPosition, rect.size.height)];
	[thumbScrollView setContentOffset:CGPointMake( xOffset, 0 )];
}    

- (void)createSlideUpView:(CGRect)rect
{    
	[self createThumbScrollView:rect];
	
	//float thumbHeight = [thumbScrollView frame].size.height;
	
	// create container view that will hold scroll view and label
	//CGRect frame = CGRectMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds), bounds.size.width, thumbHeight);
	slideUpView = [[UIView alloc] initWithFrame:rect];
	slideUpView.autoresizesSubviews = YES;
	slideUpView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
	slideUpView.backgroundColor = [UIColor colorWithRed:217.0/255.0 green:220.0/255.0 blue:225.0/255.0 alpha:1.0];
	
	// [slideUpView setOpaque:NO];
	// [slideUpView setAlpha:1.0];
	
	[slideUpView addSubview:thumbScrollView];
	// add subviews to container view
	[[self view] addSubview:slideUpView];
}    


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView 
{
	[super loadView];
	
	selectedLetter = 0;
	
	CGRect rect = self.view.bounds;
    rect.origin.y = kToolbarHeight;
    if ( IS_PHONE )
        rect.origin.y += 20.0;
	rect.size.height -= (THUMB_HEIGHT);
	letterView = [[LetterGroupView alloc] initWithFrame:rect recognizer:[[RecognizerManager sharedManager] recognizer]];
	letterView.autoresizesSubviews = YES;
	letterView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	// letterView.backgroundColor = [UIColor clearColor];	// use the table view background color
	[letterView selectLetter:selectedLetter];
	[self.view addSubview:letterView];
	
	self.navigationItem.title = NSLocalizedString( @"Letter Shapes", @"" );
	
	rect.origin.y = rect.size.height;
	rect.size.height = THUMB_HEIGHT;
	
	[self createSlideUpView:rect];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (void) viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	[letterView saveShapes];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    // Overriden to allow any orientation.
    return YES;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[letterView setNeedsRecalcLayout];
}

- (void)didReceiveMemoryWarning 
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload 
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark ThumbImageViewDelegate methods

- (void)thumbImageViewWasTapped:(ThumbImageView *)tiv 
{
	if ( tiv.index != selectedLetter )
	{
		ThumbImageView * selView = [[thumbScrollView subviews] objectAtIndex:selectedLetter];
		if ( selView != nil )
		{
			[selView setSelected:NO];
		}
		selectedLetter = tiv.index;
		[letterView selectLetter:selectedLetter];
		[tiv setSelected:YES];
	}
}

- (void)thumbImageViewStartedTracking:(ThumbImageView *)tiv 
{
    // [thumbScrollView bringSubviewToFront:tiv];
}

- (void)thumbImageViewMoved:(ThumbImageView *)draggingThumb
{
}

- (void)thumbImageViewStoppedTracking:(ThumbImageView *)tiv 
{
}


@end
