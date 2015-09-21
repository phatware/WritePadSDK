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

#import "LetterGroupView.h"
#import "OptionKeys.h"
#import "LanguageManager.h"

@interface LetterGroupView (Private)

- (void) _renderLine:(CGPoint *)points pointCount:(int)count inContext:(CGContextRef)context withWidth:(float)width withColor:(UIColor *)color;
- (void) _drawSelectionRect:(const LILayoutType *)inLayout;
- (void) _drawSingleLetter:(const LIVarType *)inLetV box:(const LIRectType *)inBBox screen:(const LIRectType *)inScreenRect;
- (void) _drawLetterImage:(const LIVarType *)inLetV destRect:(const LIRectType *)inDestRect state:(enum E_LI_LETSTATE)inLetState;
- (void) _drawLetterLayout:(const LILayoutType *)inLayout rect:(const LIRectType *)inUpdateRect;
- (void) _drawLetterState:(const LIRectType *)inDestRect state:(enum E_LI_LETSTATE)inLetState;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Winvalid-source-encoding"


// static const UCHR * recoCharsINT = "ABCDEFGHIJKLMNOPQRSTUVWXYZÇß1234567890!@#$%^&*([{-+_=.<«?/|£©";
static const char * recoCharsGR = "ABCDEFGHIJKLMNOPQRSTUVWXYZß1234567890!@#$%^&*([{-+_=.<«?/|£©";
static const char * recoCharsFR = "ABCDEFGHIJKLMNOPQRSTUVWXYZÇ1234567890!@#$%^&*([{-+_=.<«?/|£©";
static const char * recoCharsSP = "ABCDEFGHIJKLMNOPQRSTUVWXYZÇ1234567890!@#$%^&*([{-+_=.<«?/|£©";
static const char * recoCharsPT = "ABCDEFGHIJKLMNOPQRSTUVWXYZÇ1234567890!@#$%^&*([{-+_=.<«?/|£©";
static const char * recoCharsNL = "ABCDEFGHIJKLMNOPQRSTUVWXYZÇß1234567890!@#$%^&*([{-+_=.<«?/|£©";
static const char * recoCharsIT = "ABCDEFGHIJKLMNOPQRSTUVWXYZÇß1234567890!@#$%^&*([{-+_=.<«?/|£©";
static const char * recoCharsEN = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%^&*([{-+_=.<«?/|£©";
static const char * recoChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%^&*([{-+_=.<«?/|£©";

#pragma clang diagnostic pop

@implementation LetterGroupView

- (id)initWithFrame:(CGRect)frame recognizer:(RECOGNIZER_PTR)recognizer
{    
    self = [super initWithFrame:frame];
    if (self) 
	{
        // Initialization code.
        int langID = HWR_GetLanguageID(recognizer );
		_lidb = LIGetLetterDB(  langID  );
        recoChars = recoCharsEN;
        switch ( langID )
        {
            case LANGUAGE_DUTCH :
                recoChars = recoCharsNL;
                break;
            case LANGUAGE_GERMAN :
                recoChars = recoCharsGR;
                break;
            case LANGUAGE_FRENCH :
                recoChars = recoCharsFR;
                break;
            case LANGUAGE_PORTUGUESE :
            case LANGUAGE_PORTUGUESEB :
                recoChars = recoCharsPT;
                break;
            case LANGUAGE_ITALIAN :
                recoChars = recoCharsIT;
                break;
            case LANGUAGE_SPANISH :
                recoChars = recoCharsSP;
                break;                
        }
    	_selchar = recoChars[0];
		_recognizer = recognizer;
		const unsigned char * shapes = HWR_GetLetterShapes( _recognizer );
		if ( NULL != shapes )
			memcpy( _groupstates, shapes, LIG_STATES_SIZE );
        memset( &_lidraw, 0, sizeof( _lidraw ) );
		_color = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
		_width = LETTER_PEN_SIZE;
		self.multipleTouchEnabled = NO;
		needRecalcLayout = YES;
		self.contentMode = UIViewContentModeRedraw;
		[self setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:220.0/255.0 alpha:1.0]];
    }
    return self;
}

+ (NSString *) getCharSet
{
	return [[NSString alloc] initWithCString:recoChars encoding:RecoStringEncoding];
}

- (void) selectLetter:(NSInteger)index
{
	if ( index >= 0 && index < strlen( recoChars ) )
	{
		_selchar = recoChars[index];
		needRecalcLayout = YES;
		[self setNeedsDisplay];
	}
}

- (void) saveShapes
{
	if ( HWR_SetLetterShapes( _recognizer, _groupstates ) )
	{
		NSData * data = [NSData dataWithBytes:_groupstates length:LIG_STATES_SIZE];
		[[NSUserDefaults standardUserDefaults] setObject:data forKey:[NSString stringWithFormat:@"%@_%d", kRecoOptionsLetterShapes, [LanguageManager sharedManager].currentLanguage]];
	}
}

// Drawings a line onscreen based on where the user touches
- (void) _renderLine:(CGPoint *)points pointCount:(int)count inContext:(CGContextRef)context withWidth:(float)width withColor:(UIColor *)color
{
	CGContextSaveGState(context);
	// Drawing lines with a white stroke color
	CGContextSetLineJoin(context, kCGLineJoinRound);
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetInterpolationQuality( context, kCGInterpolationHigh );	
	CGContextSetStrokeColorWithColor(context, [color CGColor] );	
	// Set the line width so that the join is visible
	CGContextSetLineWidth( context, width );	
	// Line join round
	//Allocate vertex array buffer	
	if ( count == 1 )
	{
		CGPoint pts[2];
		pts[0] = pts[1] = points[0];
		pts[1].y += 1.0;
		CGContextAddLines( context, pts, 2 );
	}
	else
	{		
		CGContextAddLines( context, points, count );
	}
	CGContextStrokePath( context );
	CGContextRestoreGState(context);
}

- (void) _drawSelectionRect:(const LILayoutType *)inLayout
{
	if ( inLayout->selectedGroupIndex < 0) 
	{
		return;
	}
	
	LIRectType r = inLayout->groupRect[inLayout->selectedGroupIndex];
	CGRect rrect = CGRectMake( r.left, r.top, r.right - r.left, r.bottom - r.top );
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	// Drawing with a white stroke color
	CGContextSetLineWidth( context, 1.5 );
	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
	CGContextSetLineJoin(context, kCGLineJoinRound);
	CGContextSetLineCap(context, kCGLineCapRound);
	
	// If you were making this as a routine, you would probably accept a rectangle
	// that defines its bounds, and a radius reflecting the "rounded-ness" of the rectangle.
	CGFloat radius = inLayout->selOvalSize;
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
	CGContextStrokePath( context );
	
	CGContextRestoreGState( context );
}

- (void) _drawLetterState:(const LIRectType *)inDestRect state:(enum E_LI_LETSTATE)inLetState
{
	if ( inLetState == LI_OFTEN )
		return;
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	// Drawing with a white stroke color
	CGContextSetLineWidth( context, 4.0 );
	CGContextSetRGBStrokeColor(context, 0.7, 0.1, 0.1, 0.95);
	CGContextSetLineJoin(context, kCGLineJoinRound);
	CGContextSetLineCap(context, kCGLineCapRound);
	
	CGRect rect = CGRectMake( inDestRect->right - 30, inDestRect->bottom - 30, 26, 26 );
	// CGRect rect = CGRectMake( inDestRect->right, inDestRect->top, inDestRect->right - inDestRect->left, inDestRect->bottom - inDestRect->top );
	CGContextAddEllipseInRect( context, rect );

	CGContextMoveToPoint( context, rect.origin.x + 5, rect.origin.y + rect.size.height - 5 );
	CGContextAddLineToPoint( context, rect.origin.x + rect.size.width - 5, rect.origin.y + 5 );
	
	if ( inLetState == LI_RARE )
	{
		CGContextMoveToPoint( context, rect.origin.x + 5, rect.origin.y + 5 );
		CGContextAddLineToPoint( context, rect.origin.x + rect.size.width - 5, rect.origin.y + rect.size.height - 5  );
	}
		
	CGContextStrokePath( context );
	CGContextRestoreGState( context );
}

// drawing functions
- (void) _drawSingleLetter:(const LIVarType *)inLetV box:(const LIRectType *)inBBox screen:(const LIRectType *)inScreenRect          
{
	int nstrk = LIGetNumStrokes(inLetV);
	for ( int i = 0; i < nstrk; i++) 
	{   
		const LIStokeType * lets;
		if ( (lets = LIGetStrokeInfo( _lidb, inLetV, i)) == 0 )
		{
			return;
		}
		int npts = LIGetNumPoints(lets);
		CGPoint * pts = (CGPoint * )malloc( sizeof( CGPoint ) * (npts+1) );
		for ( int j = 0; j < npts; j++) 
		{
			LIPointType pt;
			if ((pt.x = (int)LIGetPointX(lets,j)) < 0 ||
				(pt.y = (int)LIGetPointY(lets,j)) < 0 ||
				ConvertToScreenCoord( &pt, inBBox, inScreenRect) == LIError) 
			{
				return;
			}
			pts[j].x = (CGFloat)pt.x;
			pts[j].y = (CGFloat)pt.y;
		}
		[self _renderLine:pts pointCount:npts inContext:UIGraphicsGetCurrentContext() withWidth:_width withColor:_color];
		free( (void *)pts );		
	}
	return;
}
	
- (void) _drawLetterImage:(const LIVarType *)inLetV destRect:(const LIRectType *)inDestRect state:(enum E_LI_LETSTATE)inLetState
{
	LIRectType  bbox;	
	LIRectType  dest;
	LIRectType  screenRect;
	LIRectType  baseLineRect;
	LIPointType pt = { 0,0 };
	
	if ( inLetV == 0 || LIGetVariantBBox( _lidb, inLetV, &bbox ) == LIError) 
	{
		return;
	}

	
	dest = *inDestRect;
	dest.left   += _width;
	dest.top    += _width;
	dest.right  -= _width;
	dest.bottom -= _width;
	if (CalculateScreenRect( &bbox, &dest, &screenRect ) == LIError ||
		LIGetVariantBaseLine( _lidb, inLetV, &baseLineRect ) == LIError) 
	{
		return;
	}
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGContextSetLineWidth( context, 1.0 );
	CGFloat pattern[] = { 1, 1 };
	CGContextSetLineDash( context, 0.0, pattern, 2 );
	CGContextSetRGBStrokeColor(context, 155.0/255.0, 34.0/225.0, 34.0/225.0, 1.0);
	
	pt.y = baseLineRect.top;
	if (ConvertToScreenCoord( &pt, &bbox, &screenRect) != LIError) 
	{
		CGContextMoveToPoint(context, inDestRect->left, pt.y );
		CGContextAddLineToPoint(context, inDestRect->right, pt.y );
	}
	
	pt.y = baseLineRect.bottom;
	if (ConvertToScreenCoord( &pt, &bbox, &screenRect ) != LIError)
	{
		CGContextMoveToPoint(context, inDestRect->left, pt.y );
		CGContextAddLineToPoint(context, inDestRect->right, pt.y );
	}
	CGContextStrokePath( context );
	CGContextRestoreGState(context);
	
	[self _drawSingleLetter:inLetV box:&bbox screen:&screenRect];
	[self _drawLetterState:inDestRect state:inLetState];
}

- (void) setNeedsRecalcLayout
{
	needRecalcLayout = YES;
	[self setNeedsDisplay];
}

- (void) _drawLetterLayout:(const LILayoutType *)inLayout rect:(const LIRectType *)inUpdateRect
{
	const LIInfoType *leti;
	const LIVarType	 *letv;
	register int      k;
	
	if ((leti = LIGetLetterInfo( _lidb, inLayout->letter)) == 0)
	{
        /* no such letter */
		return; 
	}
	
	[self _drawSelectionRect:inLayout];
	
	for ( k = 0; k < inLayout->numVar; k++) 
	{
		if ( inUpdateRect != (const LIRectType*)0 &&
			!LIIntersectRect(inLayout->letterRect + k, inUpdateRect) ) 
		{
			continue;
		}
		if ((letv = LIGetVariantInfo( _lidb, leti, inLayout->letterVar[k])) == 0)
		{
			return;
		}
		
		// draw letter image
		[self _drawLetterImage:letv destRect:&(inLayout->letterRect[k]) state:inLayout->letState[k]];
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // store the location of the starting touch so we can decide when we've moved far enough to drag
    CGPoint touchLocation = [[touches anyObject] locationInView:self];
	int		k, i, group = -1;
	LILayoutType * layout;
	for ( i = 0, layout = _lidraw.letimg;  i < LI_ARRAY_LENGTH(_lidraw.letter) && _lidraw.letter[i] != 0; i++, layout++) 
    {
		if ( (group = LIHitTestLetterLayout( layout, (int)touchLocation.x, (int)touchLocation.y, 1)) >= 0 ) 
        {
			break;
		}
	}
	
	if ( group >= 0 )
	{
		if ( group == LIGetSelectedGroup( layout ) ) 
		{
			int letter = -1;
			if ( (letter = LIHitTestLetterLayout( layout, (int)touchLocation.x, (int)touchLocation.y, 0)) >= 0 ) 
			{
				SelectNextGroupDtate( _lidb, &_lidraw, &_groupstates );
				[self setNeedsDisplay];
			}
		}
		else
		{
			LILayoutType   *unsellt;
			for ( k = 0, unsellt = _lidraw.letimg;
				 k < LI_ARRAY_LENGTH(_lidraw.letter) && _lidraw.letter[k] != 0; k++, unsellt++) 
			{
				if (LIGetSelectedGroup(unsellt) >= 0) 
				{
					LISelelectGroup(unsellt, -1);
					break;
				}
			}
			LISelelectGroup( layout, group );
			[self setNeedsDisplay];
		}
	}
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect 
{
	LIRectType	ur, lr;

	// calculate letter layout
	CGRect	bounds = [self bounds];
	lr.left = bounds.origin.x;
	lr.top = bounds.origin.y;
	lr.right = bounds.origin.x + bounds.size.width;
	lr.bottom = bounds.origin.y + bounds.size.height;
	lr.left = ORIGIN_LEFT(lr) + LI_LET_IMG_X;
	lr.right -= LI_LET_IMG_X_FROM_RIGHT;
	lr.top = LI_LET_IMG_Y;
	
	if ( needRecalcLayout )
	{
		CalcLetterLayout( &lr, _selchar, &_lidraw, _lidb, (const LIGStatesType *)&_groupstates );
		needRecalcLayout = NO;
	}
    // Drawing code.	
	ur.left = rect.origin.x;
	ur.top = rect.origin.y;
	ur.right = rect.origin.x + rect.size.width;
	ur.bottom = rect.origin.y + rect.size.height;
	
	CGRect r;
	r.origin.x = _lidraw.framerect.left;
	r.size.width = LI_LET_IMG_LEFT_OFFSET;		
	for ( int i = 0; i < LI_ARRAY_LENGTH(_lidraw.letter) && _lidraw.letter[i] != 0; i++ ) 
	{
		if ( i == 1 )
		{
			CGContextRef context = UIGraphicsGetCurrentContext();
			CGContextSaveGState(context);
			CGContextSetLineWidth( context, 2.0 );
			CGContextSetRGBStrokeColor(context, 155.0/255.0, 155.0/225.0, 155.0/225.0, 0.9);
			CGContextMoveToPoint(context, _lidraw.sepline[0].x, _lidraw.sepline[0].y );
			CGContextAddLineToPoint(context, _lidraw.sepline[1].x, _lidraw.sepline[1].y );
			CGContextStrokePath( context );
			CGContextRestoreGState(context);		
		}
		
		char ch[3] = {0,')',0};
		ch[0] = (char)_lidraw.letter[i];
		
		NSString * sLetter = [NSString stringWithCString:ch encoding:RecoStringEncoding];
		r.origin.y = (i == 0) ? _lidraw.framerect.top :
		_lidraw.sepline[0].y + LI_PAIRED_LET_V_SPACE / 2;
		r.origin.y += (LI_LET_SELL_HEIGHT + LI_LET_SEL_OVAL_SIZE) / 2;
		r.origin.y -= LETTER_NAME_SIZE / 2;
		r.size.height = 2 * LETTER_NAME_SIZE;
		
		[sLetter drawInRect:r withAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:LETTER_NAME_SIZE]}];
		
		// draw text, etc.
		[self _drawLetterLayout:&_lidraw.letimg[i] rect:&ur];
	}
}

@end
