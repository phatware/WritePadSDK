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

#import "ThumbImageView.h"
#import "ShapeAPI.h"

#define DRAG_THRESHOLD 10

float distanceBetweenPoints(CGPoint a, CGPoint b);

@implementation ThumbImageView
@synthesize delegate;
@synthesize home;
@synthesize index;
@synthesize touchLocation;

- (id)initWithLetter:(NSString *)str
{
    self = [super init];
    if (self)
	{
		letter = [[NSString alloc] initWithString:str];
        [self setUserInteractionEnabled:YES];
        [self setExclusiveTouch:YES];  // block other touches while dragging a thumb view
		[self setBackgroundColor:[UIColor clearColor]];
		selected = NO;
    }
    return self;
}

- (void) setSelected:(BOOL)s
{
	selected = s;
	[self setNeedsDisplay];
}

- (void) _drawRoundRect:(CGRect)rect
{
	CGRect rrect = CGRectInset( rect, 3, 3 );
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	// Drawing with a white stroke color
	CGContextSetLineWidth( context, 2.0 );
	CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
	if ( selected )
		CGContextSetRGBFillColor(context, 0.15, 0.5, 0.9, 0.95);
	else
		CGContextSetRGBFillColor(context, 0.7, 0.7, 0.7, 1.0);
	CGContextSetLineJoin(context, kCGLineJoinRound);
	CGContextSetLineCap(context, kCGLineCapRound);
	
	// If you were making this as a routine, you would probably accept a rectangle
	// that defines its bounds, and a radius reflecting the "rounded-ness" of the rectangle.
	CGFloat radius = 12;
	// NOTE: At this point you may want to verify that your radius is no more than half
	// the width and height of your rectangle, as this technique degenerates for those cases.
	
	// In order to draw a rounded rectangle, we will take advantage of the fact that
	// CGContextAddArcToPoint will draw straight lines past the start and end of the arc
	// in order to create the path from the current position and the destination position.
	
	// In order to create the 4 arcs correctly, we need to know the min, mid and max positions
	// on the x and y lengths of the given rectangle.
	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
	
	// Next, we will go around the rectangle in the order given by the figure below.
	//       minx    midx    maxx
	// miny    2       3       4
	// midy   1 9              5
	// maxy    8       7       6
	// Which gives us a coincident start and end point, which is incidental to this technique, but still doesn't
	// form a closed path, so we still need to close the path to connect the ends correctly.
	// Thus we start by moving to point 1, then adding arcs through each pair of points that follows.
	// You could use a similar tecgnique to create any shape with rounded corners.
	
	// Start at 1
	CGContextMoveToPoint(context, minx, midy);
	// Add an arc through 2 to 3
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	// Add an arc through 4 to 5
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	// Add an arc through 6 to 7
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	// Add an arc through 8 to 9
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	// Close the path
	CGContextClosePath(context);
	// Fill & stroke the path
	CGContextDrawPath(context, kCGPathFillStroke);
	// CGContextStrokePath( context );
	
	CGContextRestoreGState( context );
}

- (void)drawRect:(CGRect)rect 
{
	CGRect r = [self bounds];

	[self _drawRoundRect:r];
	
	if ( selected )
		[[UIColor whiteColor] setFill];
	else
		[[UIColor blackColor] setFill];
	
	int size = LETTER_STRIP_SIZE;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByClipping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary * attrib = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:size],
                               NSParagraphStyleAttributeName: paragraphStyle };
    
    [letter drawInRect:r withAttributes:attrib];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // store the location of the starting touch so we can decide when we've moved far enough to drag
    touchLocation = [[touches anyObject] locationInView:self];
    if ([delegate respondsToSelector:@selector(thumbImageViewStartedTracking:)])
        [delegate thumbImageViewStartedTracking:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // we want to establish a minimum distance that the touch has to move before it counts as dragging,
    // so that the slight movement involved in a tap doesn't cause the frame to move.
    
	/*
    CGPoint newTouchLocation = [[touches anyObject] locationInView:self];
    
    // if we're already dragging, move our frame
    if (dragging) 
	{
        float deltaX = newTouchLocation.x - touchLocation.x;
        float deltaY = newTouchLocation.y - touchLocation.y;
        [self moveByOffset:CGPointMake(deltaX, deltaY)];
    }
    
    // if we're not dragging yet, check if we've moved far enough from the initial point to start
    else if (distanceBetweenPoints(touchLocation, newTouchLocation) > DRAG_THRESHOLD) 
	{
        touchLocation = newTouchLocation;
        dragging = YES;
    }
	 */
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (dragging)
	{
        [self goHome];
        dragging = NO;
    }
	else if ([[touches anyObject] tapCount] == 1)
	{
        if ([delegate respondsToSelector:@selector(thumbImageViewWasTapped:)])
            [delegate thumbImageViewWasTapped:self];
    }
    
    if ([delegate respondsToSelector:@selector(thumbImageViewStoppedTracking:)]) 
        [delegate thumbImageViewStoppedTracking:self];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self goHome];
    dragging = NO;
    if ([delegate respondsToSelector:@selector(thumbImageViewStoppedTracking:)]) 
        [delegate thumbImageViewStoppedTracking:self];
}

- (void)goHome
{
    // distance is in pixels
    float distanceFromHome = distanceBetweenPoints([self frame].origin, [self home].origin);  
    // duration is in seconds, so each additional pixel adds only 1/1000th of a second.
    float animationDuration = 0.1 + distanceFromHome * 0.001; 
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [self setFrame:[self home]];
    [UIView commitAnimations];
}
    
- (void)moveByOffset:(CGPoint)offset 
{
    CGRect frame = [self frame];
    frame.origin.x += offset.x;
    frame.origin.y += offset.y;
    [self setFrame:frame];
    if ([delegate respondsToSelector:@selector(thumbImageViewMoved:)])
        [delegate thumbImageViewMoved:self];
}    

@end

float distanceBetweenPoints(CGPoint a, CGPoint b) 
{
    float deltaX = a.x - b.x;
    float deltaY = a.y - b.y;
    return sqrtf( (deltaX * deltaX) + (deltaY * deltaY) );
}
            
