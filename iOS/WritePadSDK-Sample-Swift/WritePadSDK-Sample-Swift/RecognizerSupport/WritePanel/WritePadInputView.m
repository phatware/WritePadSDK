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

#import "WritePadInputView.h"
#import "WritePadInputPanel.h"
#import "AsyncResultView.h"
#import "UIConst.h"
#import "RecognizerManager.h"
#import "OptionKeys.h"
#import "utils.h"


#define X_OFFSET			(IS_PHONE ? 5 : 8)
#define Y_OFFSET			(IS_PHONE ? 5 : 8)
#define TOP_OFFSET			(IS_PHONE ? 5 : 64)
#define RESULT_HEIGHT		(IS_PHONE ? 0 : 50)
#define X_LINE_OFFSET		(IS_PHONE ? 15 : 30)
#define BUTTON_SIZE			(IS_PHONE ? 25 : 50)
#define BUTTON_GAP			(IS_PHONE ? 5 : 8)
#define BUTTON_COUNT		4
#define RIGHT_OFFSET(n)		(Y_OFFSET + (BUTTON_SIZE + BUTTON_GAP) * (n))
#define TOP_LINE_OFFSET2	(TOP_OFFSET + (IS_PHONE ? 60 : 65))
#define TOP_LINE_OFFSET1	(TOP_OFFSET + (IS_PHONE ? 118 : 129))

#define MARKER_WIDTH        5.0
#define MARKER_HEIGHT       8.0

#define RADIUS              (IS_PHONE ? 5.0 : 8.0)

#define LETTER_WIDTH		((IS_PHONE) ? 30.0 : 40.0)
#define BAR_HEIGHT			5.0

#define kInitialKeyTimeout	0.6
#define kKeyTimeout			0.1

#undef kGridStep
#define kGridStep           16


@interface WritePadInputView(PrivateFunctions)

- (UIButton *)buttonWithTitle:(NSString *)title
					   target:(id)target
					 selector:(SEL)selector
						frame:(CGRect)frame
				darkTextColor:(BOOL)darkTextColor;
- (CGSize)createKeyBtn:(NSString *)strImage withTitle:(NSString *)title atPosition:(CGPoint)position;
- (UIButton *) createCommandButton:(NSString *)command atPosition:(CGPoint)position;

@end


static WritePadInputView * sharedInputPanel = nil;


@implementation UIResultsView

- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetLineWidth( context, 0.5 );
	
	// As a bonus, we'll combine arcs to create a round rectangle!
    
	// 2. draw the input panel
	
	// Drawing with a dark stroke color
	CGContextSetRGBStrokeColor(context, 0.2, 0.2, 0.2, 1.0);
	CGContextSetRGBFillColor(context, 239.0/255.0, 228.0/225.0, 110.0/225.0, 1.0);

    // 3. draw the input panel
    // Drawing with a white stroke color
    CGContextSetRGBStrokeColor(context, 0.3, 0.3, 0.3, 1.0);
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);

    CGRect      rrect = rect;
    CGFloat     radius = 6.0;
    
    rrect.origin.x += X_OFFSET;
    rrect.size.width -= (X_OFFSET + 1.0);
    rrect.origin.y = Y_OFFSET-1.0;
    rrect.size.height = RESULT_HEIGHT-1.0;
    // NOTE: At this point you may want to verify that your radius is no more than half
    // the width and height of your rectangle, as this technique degenerates for those cases.

    // In order to draw a rounded rectangle, we will take advantage of the fact that
    // CGContextAddArcToPoint will draw straight lines past the start and end of the arc
    // in order to create the path from the current position and the destination position.

    // In order to create the 4 arcs correctly, we need to know the min, mid and max positions
    // on the x and y lengths of the given rectangle.
	CGFloat minx = ceilf( CGRectGetMinX(rrect) ), midx = ceilf( CGRectGetMidX(rrect) ), maxx = ceilf( CGRectGetMaxX(rrect) );
	CGFloat miny = ceilf( CGRectGetMinY(rrect) ), midy = ceilf( CGRectGetMidY(rrect) ), maxy = ceilf( CGRectGetMaxY(rrect) );

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
}

@end



@implementation WritePadInputView

@synthesize inkCollector;
@synthesize resultView;
@synthesize placeholder;
@synthesize delegate;
@synthesize showMarker;
@synthesize cmdButton;
@synthesize penButton;

@synthesize drawGrid;


static NSMutableDictionary * wpColors = nil;

+ (UIColor *) colorForElement:(NSString *)element
{
    UIColor * color = [wpColors objectForKey:element];
    if ( color == nil )
        color = [UIColor whiteColor];
    return color;
}

+ (BOOL) flagForElement:(NSString *)element
{
    NSNumber * num = [wpColors objectForKey:element];
    if ( nil != num )
        return [num boolValue];
    return YES;
}

+ (CGFloat) floatForElement:(NSString *)element
{
    NSNumber * num = [wpColors objectForKey:element];
    if ( nil != num )
        return [num floatValue];
    return 0.0;
}

+ (void) initColorsWithStyle:(NSInteger)style
{
    UIColor * color;
    wpColors = [[NSMutableDictionary alloc] init];
    switch ( style )
    {
        case 1 :
            color = [UIColor colorWithRed:22.0/255.0 green:22.0/255.0 blue:222.0/255.0 alpha:0.5];
            [wpColors setObject:color forKey:@"GridColor"];
            color = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
            [wpColors setObject:color forKey:@"DarkStrokeColor"];
            color = [UIColor colorWithRed:155.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0];
            [wpColors setObject:color forKey:@"LinesColor"];
            color = [UIColor colorWithRed:239.0/255.0 green:238.0/255.0 blue:110.0/255.0 alpha:1.0];
            [wpColors setObject:color forKey:@"BackgroundColor"];
            color = [UIColor blueColor];
            [wpColors setObject:color forKey:@"InkColor"];
            [wpColors setObject:[NSNumber numberWithFloat:10.0] forKey:@"GridSpacing"];
            [wpColors setObject:[NSNumber numberWithBool:NO] forKey:@"ShowVertGrid"];
            [wpColors setObject:[NSNumber numberWithBool:NO] forKey:@"ShowHorzGrid"];
            [wpColors setObject:[NSNumber numberWithBool:YES] forKey:@"ShowLines"];
            return;

        case 2 :
            color = [[UIColor lightGrayColor] colorWithAlphaComponent:0.7];
            [wpColors setObject:color forKey:@"GridColor"];
            color = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
            [wpColors setObject:color forKey:@"DarkStrokeColor"];
            color = [UIColor colorWithRed:222.0/255.0 green:40.0/255.0 blue:40.0/255.0 alpha:1.0];
            [wpColors setObject:color forKey:@"LinesColor"];
            color = [UIColor colorWithRed:234.0/255.0 green:232.0/255.0 blue:176.0/255.0 alpha:1.0];
            [wpColors setObject:color forKey:@"BackgroundColor"];
            color = [UIColor blackColor];
            [wpColors setObject:color forKey:@"InkColor"];
            [wpColors setObject:[NSNumber numberWithFloat:28.0] forKey:@"GridSpacing"];
            [wpColors setObject:[NSNumber numberWithBool:NO] forKey:@"ShowVertGrid"];
            [wpColors setObject:[NSNumber numberWithBool:YES] forKey:@"ShowHorzGrid"];
            [wpColors setObject:[NSNumber numberWithBool:NO] forKey:@"ShowLines"];
            return;
            
        case 3 :
            color = [[UIColor lightGrayColor] colorWithAlphaComponent:0.7];
            [wpColors setObject:color forKey:@"GridColor"];
            color = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
            [wpColors setObject:color forKey:@"DarkStrokeColor"];
            color = [UIColor whiteColor]; // [UIColor colorWithRed:183.0/255.0 green:68.0/255.0 blue:109.0/255.0 alpha:1.0];
            [wpColors setObject:color forKey:@"LinesColor"];
            color = [UIColor colorWithRed:255.0/255.0 green:190.0/255.0 blue:198.0/255.0 alpha:1.0];
            [wpColors setObject:color forKey:@"BackgroundColor"];
            color = [UIColor colorWithRed:24.0/255.0 green:166.0/255.0 blue:151.0/255.0 alpha:1.0]; // colorWithRed:16.0/255.0 green:205.0/255.0 blue:144.0/255.0 alpha:1.0];
            [wpColors setObject:color forKey:@"InkColor"];
            [wpColors setObject:[NSNumber numberWithFloat:28.0] forKey:@"GridSpacing"];
            [wpColors setObject:[NSNumber numberWithBool:NO] forKey:@"ShowVertGrid"];
            [wpColors setObject:[NSNumber numberWithBool:NO] forKey:@"ShowHorzGrid"];
            [wpColors setObject:[NSNumber numberWithBool:YES] forKey:@"ShowLines"];
            return;

        case 4 :
            color = [[UIColor lightGrayColor] colorWithAlphaComponent:0.7];
            [wpColors setObject:color forKey:@"GridColor"];
            color = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
            [wpColors setObject:color forKey:@"DarkStrokeColor"];
            color = [UIColor colorWithRed:128.0/255.0 green:87.0/255.0 blue:36.0/255.0 alpha:1.0];
            [wpColors setObject:color forKey:@"LinesColor"];
            color = [UIColor colorWithRed:249.0/255.0 green:217.0/255.0 blue:176.0/255.0 alpha:1.0];
            [wpColors setObject:color forKey:@"BackgroundColor"];
            color = [UIColor colorWithRed:74.0/255.0 green:58.0/255.0 blue:39.0/255.0 alpha:1.0];
            [wpColors setObject:color forKey:@"InkColor"];
            [wpColors setObject:[NSNumber numberWithFloat:28.0] forKey:@"GridSpacing"];
            [wpColors setObject:[NSNumber numberWithBool:NO] forKey:@"ShowVertGrid"];
            [wpColors setObject:[NSNumber numberWithBool:NO] forKey:@"ShowHorzGrid"];
            [wpColors setObject:[NSNumber numberWithBool:YES] forKey:@"ShowLines"];
            return;

        case 5 :
            color = [[UIColor lightGrayColor] colorWithAlphaComponent:0.7];
            [wpColors setObject:color forKey:@"GridColor"];
            color = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
            [wpColors setObject:color forKey:@"DarkStrokeColor"];
            color = [UIColor colorWithRed:115.0/255.0 green:116.0/255.0 blue:25.0/255.0 alpha:1.0];
            [wpColors setObject:color forKey:@"LinesColor"];
            color = [UIColor colorWithRed:185.0/255.0 green:248.0/255.0 blue:191.0/255.0 alpha:1.0];
            [wpColors setObject:color forKey:@"BackgroundColor"];
            color = [UIColor blackColor];
            [wpColors setObject:color forKey:@"InkColor"];
            [wpColors setObject:[NSNumber numberWithFloat:28.0] forKey:@"GridSpacing"];
            [wpColors setObject:[NSNumber numberWithBool:NO] forKey:@"ShowVertGrid"];
            [wpColors setObject:[NSNumber numberWithBool:NO] forKey:@"ShowHorzGrid"];
            [wpColors setObject:[NSNumber numberWithBool:YES] forKey:@"ShowLines"];
            return;

        case 6 :
            color = [[UIColor blackColor] colorWithAlphaComponent:0.5];
            [wpColors setObject:color forKey:@"GridColor"];
            color = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
            [wpColors setObject:color forKey:@"DarkStrokeColor"];
            color = [UIColor colorWithRed:130.0/255.0 green:43.0/255.0 blue:181.0/255.0 alpha:1.0];
            [wpColors setObject:color forKey:@"LinesColor"];
            color = [UIColor colorWithRed:126.0/255.0 green:78.0/255.0 blue:225.0/255.0 alpha:0.5];
            [wpColors setObject:color forKey:@"BackgroundColor"];
            color = [UIColor blackColor];
            [wpColors setObject:color forKey:@"InkColor"];
            [wpColors setObject:[NSNumber numberWithFloat:30.0] forKey:@"GridSpacing"];
            [wpColors setObject:[NSNumber numberWithBool:NO] forKey:@"ShowVertGrid"];
            [wpColors setObject:[NSNumber numberWithBool:YES] forKey:@"ShowHorzGrid"];
            [wpColors setObject:[NSNumber numberWithBool:NO] forKey:@"ShowLines"];
            return;

        case 7 :
            color = [[UIColor yellowColor] colorWithAlphaComponent:0.75];
            [wpColors setObject:color forKey:@"GridColor"];
            color = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
            [wpColors setObject:color forKey:@"DarkStrokeColor"];
            color = [UIColor colorWithRed:235.0/255.0 green:25.0/255.0 blue:25.0/255.0 alpha:1.0];
            [wpColors setObject:color forKey:@"LinesColor"];
            color = [UIColor colorWithRed:60.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:1.0];
            [wpColors setObject:color forKey:@"BackgroundColor"];
            color = [UIColor redColor];
            [wpColors setObject:color forKey:@"InkColor"];
            [wpColors setObject:[NSNumber numberWithFloat:8.0] forKey:@"GridSpacing"];
            [wpColors setObject:[NSNumber numberWithBool:YES] forKey:@"ShowVertGrid"];
            [wpColors setObject:[NSNumber numberWithBool:YES] forKey:@"ShowHorzGrid"];
            [wpColors setObject:[NSNumber numberWithBool:NO] forKey:@"ShowLines"];
            return;
            
        case 8 :
            color = [[UIColor lightGrayColor] colorWithAlphaComponent:0.7];
            [wpColors setObject:color forKey:@"GridColor"];
            color = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
            [wpColors setObject:color forKey:@"DarkStrokeColor"];
            color = [UIColor redColor];
            [wpColors setObject:color forKey:@"LinesColor"];
            color = [UIColor blackColor];
            [wpColors setObject:color forKey:@"BackgroundColor"];
            color = [UIColor yellowColor];
            [wpColors setObject:color forKey:@"InkColor"];
            [wpColors setObject:[NSNumber numberWithFloat:28.0] forKey:@"GridSpacing"];
            [wpColors setObject:[NSNumber numberWithBool:NO] forKey:@"ShowVertGrid"];
            [wpColors setObject:[NSNumber numberWithBool:NO] forKey:@"ShowHorzGrid"];
            [wpColors setObject:[NSNumber numberWithBool:YES] forKey:@"ShowLines"];
            return;

        case 9 :
            color = [[UIColor lightGrayColor] colorWithAlphaComponent:0.7];
            [wpColors setObject:color forKey:@"GridColor"];
            color = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
            [wpColors setObject:color forKey:@"DarkStrokeColor"];
            color = [UIColor redColor];
            [wpColors setObject:color forKey:@"LinesColor"];
            color = [UIColor whiteColor];
            [wpColors setObject:color forKey:@"BackgroundColor"];
            color = [UIColor blackColor];
            [wpColors setObject:color forKey:@"InkColor"];
            [wpColors setObject:[NSNumber numberWithFloat:28.0] forKey:@"GridSpacing"];
            [wpColors setObject:[NSNumber numberWithBool:NO] forKey:@"ShowVertGrid"];
            [wpColors setObject:[NSNumber numberWithBool:NO] forKey:@"ShowHorzGrid"];
            [wpColors setObject:[NSNumber numberWithBool:YES] forKey:@"ShowLines"];
            return;
    }
    color = [UIColor colorWithRed:22.0/255.0 green:22.0/255.0 blue:222.0/255.0 alpha:0.5];
    [wpColors setObject:color forKey:@"GridColor"];
    color = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    [wpColors setObject:color forKey:@"DarkStrokeColor"];
    color = [UIColor colorWithRed:222.0/255.0 green:40.0/255.0 blue:40.0/255.0 alpha:1.0];
    [wpColors setObject:color forKey:@"LinesColor"];
    color = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:225.0/255.0 alpha:1.0];
    [wpColors setObject:color forKey:@"BackgroundColor"];
    color = [UIColor colorWithRed:42.0/255.0 green:42.0/255.0 blue:180.0/255.0 alpha:1.0];
    [wpColors setObject:color forKey:@"InkColor"];
    [wpColors setObject:[NSNumber numberWithFloat:16.0] forKey:@"GridSpacing"];
    [wpColors setObject:[NSNumber numberWithBool:YES] forKey:@"ShowVertGrid"];
    [wpColors setObject:[NSNumber numberWithBool:YES] forKey:@"ShowHorzGrid"];
    [wpColors setObject:[NSNumber numberWithBool:YES] forKey:@"ShowLines"];
}

+ (WritePadInputView *) sharedInputPanel
{
	if ( sharedInputPanel == nil )
	{
        [WritePadInputView initColorsWithStyle:[[NSUserDefaults standardUserDefaults] integerForKey:kWritePanelStyle]];
		CGRect f = [[UIScreen mainScreen] bounds];
		sharedInputPanel = [[WritePadInputView alloc] initWithFrame:f];
		sharedInputPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth;	
	}
	return sharedInputPanel;
}

+ (void) destroySharedInputPanel
{
	if ( sharedInputPanel != nil )
	{
		sharedInputPanel.delegate = nil;
		sharedInputPanel = nil;
	}
}

- (id)initWithFrame:(CGRect)frame 
{
	frame.size.height = kInputPanelHeight;
    if ((self = [super initWithFrame:frame])) 
	{
		// Initialization code
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
		CGFloat colors[] =
		{
			200.0/255.0, 200.0/255.0, 200.0/255.0, 1.0,
			200.0/255.0, 200.0/255.0, 200.0/255.0, 1.0,
		};
		myGradient = CGGradientCreateWithColorComponents(rgb, colors, NULL,  2 );
		CGColorSpaceRelease(rgb);		
		
		if ( ! [[NSUserDefaults standardUserDefaults] boolForKey:kInputPanelWriteHere] )
		{
			self.placeholder = [NSString stringWithString:LOC( @"Write Here" )];
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kInputPanelWriteHere];

		}
		
		markerPosition = [[NSUserDefaults standardUserDefaults] floatForKey:kInputPanelMarkerPosition];
		
		self.contentMode = UIViewContentModeRedraw;
        
        if ( ! IS_PHONE )
        {
            // create buttons
            _buttons = [[NSMutableArray alloc] initWithCapacity:BUTTON_COUNT];
            CGPoint	pos = CGPointMake( frame.size.width - BUTTON_SIZE - X_OFFSET, Y_OFFSET - 1 );
            CGSize  sz = [self createKeyBtn:@"btn-return.png" withTitle:@"\n" atPosition:pos];
            pos.x -= (sz.width + BUTTON_GAP);
            sz = [self createKeyBtn:@"btn-back.png" withTitle:@"\b" atPosition:pos];
            pos.x -= (sz.width + BUTTON_GAP);
            sz = [self createKeyBtn:@"btn-dot.png" withTitle:@"." atPosition:pos];
            pos.x -= (sz.width + BUTTON_GAP);
            sz = [self createKeyBtn:@"btn-space.png" withTitle:@" " atPosition:pos];
            pos.x -= BUTTON_GAP;
            
            self.cmdButton = [self createCommandButton:@"cmd" atPosition:pos];
        }
        _showCmdButton = NO;
        

		// create ink collector
		CGRect rrect = frame;
		rrect.origin.x += X_OFFSET;
		rrect.size.width -= 2 * X_OFFSET;
		rrect.origin.y = TOP_OFFSET;
		rrect.size.height -= (TOP_OFFSET + Y_OFFSET);
		inkCollector = [[WritePadInputPanel alloc] initWithFrame:rrect];
		inkCollector.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		inkCollector.contentMode = UIViewContentModeRedraw;
		inkCollector.backgroundColor = [UIColor clearColor];
		inkCollector.inputPanel = self;
		[inkCollector reloadOptions];
		
		// only these gestures should be recognized when control is not empty
		// loop for shortcuts... Shortcuts is a simplified version of PenCommander
		// Return - to enter text, Cut to delete ink, Loop for shortcut
		[self addSubview:inkCollector];
		
        if ( ! IS_PHONE )
        {
            // create result view
            UIButton * btn = [_buttons objectAtIndex:(BUTTON_COUNT-1)];
            NSInteger btncnt = [btn isHidden] ? BUTTON_COUNT-1 : BUTTON_COUNT;

            rrect = frame;
            rrect.size.width -= (RIGHT_OFFSET(btncnt));
            
            rrect.size.height = RESULT_HEIGHT+Y_OFFSET;

            uiResultView = [[UIResultsView alloc] initWithFrame:rrect];
            uiResultView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            uiResultView.contentMode = UIViewContentModeRedraw;
            uiResultView.backgroundColor = [UIColor clearColor];
            uiResultView.opaque = NO;
            [self addSubview:uiResultView];
            
        
            rrect = frame;
            rrect.origin.x += 2 * X_OFFSET;
            rrect.size.width -= (3 * X_OFFSET + RIGHT_OFFSET(btncnt));
            rrect.origin.y = Y_OFFSET + 4;
            rrect.size.height = RESULT_HEIGHT - 8;
            resultView = [[AsyncResultView alloc] initWithFrame:rrect];
            [self addSubview:resultView];
        }
        else
        {
            resultView = [[AsyncResultView alloc] initWithFrame:CGRectZero];
            resultView.hidden = YES;
        }
        resultView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        resultView.contentMode = UIViewContentModeRedraw;
        resultView.inputPanel = self;
        resultView.backgroundColor = [UIColor clearColor];

        self.penButton = nil;
        self.drawGrid = YES;
		
        self.showMarker = NO;   //
		_markerSelected = NO;
		_bIgnoreActionKey = NO;
	}
    return self;
}

- (void) setDelegate:(id)newDelegate
{
	delegate = newDelegate;
	inkCollector.delegate = newDelegate;
}

- (UIButton *)buttonWithTitle:(NSString *)title
					   target:(id)target
						frame:(CGRect)frame
				darkTextColor:(BOOL)darkTextColor
{	
	UIButton *button = [[UIButton alloc] initWithFrame:frame];	
	button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	
	[button setTitle:title forState:UIControlStateNormal];	
	if (darkTextColor)
	{
		[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	}
	else
	{
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	}
		
	[button addTarget:target action:@selector(actionKey:) forControlEvents:UIControlEventTouchUpInside];
	[button addTarget:target action:@selector(actionKeyDown:) forControlEvents:UIControlEventTouchDown];
	[button addTarget:target action:@selector(actionKeyCancel:) forControlEvents:UIControlEventTouchDragExit];
	[button addTarget:target action:@selector(actionKeyCancel:) forControlEvents:UIControlEventTouchUpOutside];
	[button addTarget:target action:@selector(actionKeyCancel:) forControlEvents:UIControlEventTouchCancel];
	
    // in case the parent view draws with a custom color or gradient, use a transparent color
	button.backgroundColor = [UIColor clearColor];
	
	return button;
}

- (UIButton *) createCommandButton:(NSString *)command atPosition:(CGPoint)position
{
    UIImage *   img = [UIImage imageNamed:@"btn-space.png"];
	UIImage *	image = [img stretchableImageWithLeftCapWidth:img.size.width/2.0 topCapHeight:0.0];
	CGRect		frame = CGRectMake( position.x, position.y, 0.0, img.size.height + 0.5 );
	UIButton *	button = [self buttonWithTitle:command
									   target:self
										frame:frame
								darkTextColor:YES];
    [button setBackgroundImage:image forState:UIControlStateNormal];
	button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	[self addSubview:button];
    button.tag = SHROTHAND_BUTTON_TAG;
    button.enabled = NO;
    return button;
}

- (void) showCommandButton:(BOOL)show withCommand:(NSString *)command
{
    if ( self.cmdButton == nil || ([command length] < 1 && show) )
        return;
    
    if ( _showCmdButton == show )
        return;
    
    UIButton *	button = self.cmdButton;
    
    CGRect uiResult = uiResultView.frame;
    CGRect rResult = resultView.frame;
    CGRect rButton = button.frame;
    if ( show )
    {
        CGSize sz = [command sizeWithAttributes:@{ NSFontAttributeName : button.titleLabel.font }];
        [button setTitle:command forState:UIControlStateNormal];
        button.enabled = YES;
        
        
        CGFloat width = sz.width + 16;
        if ( width > 112 )
            width = 112;
        if ( width < 48 )
            width = 48;
        CGFloat bw = width - rButton.size.width;
        uiResult.size.width -= (bw + BUTTON_GAP);
        rButton.size.width = width;
        rButton.origin.x -= bw;

        rResult.size.width -= (bw + BUTTON_GAP);
        resultView.frame = rResult;

        
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.15];        
        button.frame = rButton;
        uiResultView.frame = uiResult;
		[UIView commitAnimations];    
        _showCmdButton = YES;
    }
    else
    {
        // button.enabled = NO;
            
        CGFloat bw = rButton.size.width;
        uiResult.size.width += (bw + BUTTON_GAP);
        rButton.size.width = 0.0;
        rButton.origin.x += bw;

        rResult.size.width += (bw + BUTTON_GAP);
        resultView.frame = rResult;

		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.15];        
        button.frame = rButton;
        uiResultView.frame = uiResult;
		[UIView commitAnimations]; 
        
        _showCmdButton = NO;
    }
}

-(CGSize)createKeyBtn:(NSString *)strImage withTitle:(NSString *)title atPosition:(CGPoint)position
{
	UIImage *	image = [UIImage imageNamed:strImage];
	CGRect		frame = CGRectMake( position.x, position.y, image.size.width + 0.5, image.size.height + 0.5 );
	UIButton *	button = [self buttonWithTitle:title
									   target:self
										frame:frame
								darkTextColor:YES];
	[button setImage:image forState:UIControlStateNormal];
	button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	[self addSubview:button];
	[_buttons addObject:button];
	// [button release];
	return image.size;
}

- (Boolean) stopHoldTimer
{
	if ( holdTimer != nil )
	{
		[holdTimer invalidate];
		holdTimer = nil;
		return YES;
	}
	return NO;
}

- (void) startHoldTimer:(id)sender timeout:(NSTimeInterval)timeout
{
	[self stopHoldTimer];
	holdTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self 
											   selector:@selector(holdKeyTimer:) userInfo:sender repeats:NO];
}


- (void) holdKeyTimer:(NSTimer*)theTimer
{
	UIButton * button = theTimer.userInfo;
	if ( [button.titleLabel.text compare:@"."] == NSOrderedSame )
	{
        // SHOW KEYBOARD ONLY IF THERE IS NO PEN
		[self stopHoldTimer];
		_bIgnoreActionKey = YES;
		// show punctuation keyboard; do not restart timer
		if ( delegate && [delegate respondsToSelector:@selector(WritePadInputPanelRecognizedGesture:withGesture:isEmpty:)])
		{
			[delegate WritePadInputPanelRecognizedGesture:inkCollector withGesture:GEST_SPELL isEmpty:YES];	
		}		
		return;
	}
	if ( delegate && ([delegate respondsToSelector:@selector(writePadInputKeyPressed:keyText:withSender:)] ) )
	{
		[delegate writePadInputKeyPressed:self keyText:button.titleLabel.text withSender:theTimer.userInfo];
	}	
	[self startHoldTimer:theTimer.userInfo timeout:kKeyTimeout];
}

- (IBAction) actionKeyDown:(id)sender
{
	_bIgnoreActionKey = NO;
	NSLog( @"buttons touch down" );
	// start touch and hold timer
	UIButton * button = sender;
	if ( [button.titleLabel.text compare:@"."] == NSOrderedSame || 
		(([button.titleLabel.text compare:@"\b"] == NSOrderedSame ||
		  [button.titleLabel.text compare:@" "] == NSOrderedSame || 
		  [button.titleLabel.text compare:@"\n"] == NSOrderedSame) && [inkCollector strokeCount] == 0) )
	{
		[self startHoldTimer:sender timeout:kInitialKeyTimeout];		
	}
}

- (IBAction) actionKeyCancel:(id)sender
{
	_bIgnoreActionKey = YES;
	NSLog( @"buttons touch cancel" );
	// stop touch and hold timer
	[self stopHoldTimer];
}


- (IBAction)actionKey:(id)sender
{
	[self stopHoldTimer];
	if ( ! _bIgnoreActionKey && [sender isKindOfClass:[UIButton class]] )
	{
		UIButton * button = sender;
		NSString * str = [button titleForState:UIControlStateNormal];
		NSLog( @"%@ Button was clicked", str );
        
        if ( button.tag == SHROTHAND_BUTTON_TAG )
        {
            [self empty];
        }        
		else if ( delegate && ([delegate respondsToSelector:@selector(writePadInputKeyPressed:keyText:withSender:)] ) )
		{
            [delegate writePadInputKeyPressed:self keyText:(NSString *)str withSender:sender];
		}
	}
	_bIgnoreActionKey = NO;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// 1. draw the background
    CGContextSaveGState( context );
	
	CGPoint myStartPoint, myEndPoint;
	myStartPoint.x = rect.size.width/2;
	myStartPoint.y = 0.0;
	myEndPoint.x = myStartPoint.x;
	myEndPoint.y = rect.size.height;
	if ( nil != myGradient )
		CGContextDrawLinearGradient (context, myGradient, myStartPoint, myEndPoint, 0);
	
	
	// draw the writing panel

	CGContextSetLineWidth( context, 0.5 );
	
	// As a bonus, we'll combine arcs to create a round rectangle!

	// 2. draw the input panel
	// Drawing with a dark stroke color
	CGContextSetStrokeColorWithColor(context, [WritePadInputView colorForElement:@"DarkStrokeColor"].CGColor );
	CGContextSetFillColorWithColor(context, [WritePadInputView colorForElement:@"BackgroundColor"].CGColor  );
    // CGContextSetRGBFillColor(context, 227.0/255.0, 205.0/255.0, 161.0/255.0, 1.0);
    
	CGRect rrect = rect;
    
	
	// If you were making this as a routine, you would probably accept a rectangle
	// that defines its bounds, and a radius reflecting the "rounded-ness" of the rectangle.
	CGFloat radius = 8.0;
	rrect.origin.x += X_OFFSET;
	rrect.size.width -= 2 * X_OFFSET;
	rrect.origin.y = TOP_OFFSET;
	rrect.size.height -= (TOP_OFFSET + Y_OFFSET);
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
	
	// 3. draw the input panel
	Boolean singleLine = YES;
	if ( inkCollector != nil && [[RecognizerManager sharedManager] isEnabled] )
		singleLine = (([[RecognizerManager sharedManager] getFlags] & FLAG_SEPLET) == 0) ? YES : NO;
	
	// Draw a single line from left to right
    if ( [WritePadInputView flagForElement:@"ShowLines"] )
    {
        CGContextSetShouldAntialias( context,false );
        CGContextSetLineWidth( context, 1.0 );
        CGContextSetStrokeColorWithColor(context, [WritePadInputView colorForElement:@"LinesColor"].CGColor );
        if ( singleLine )
        {
            CGContextMoveToPoint(context, X_LINE_OFFSET, TOP_LINE_OFFSET1 );
            CGContextAddLineToPoint(context, rect.size.width - X_LINE_OFFSET, TOP_LINE_OFFSET1 );
            CGContextStrokePath(context);
        }
        else
        {
            CGFloat width = rect.size.width - (2.0 * X_LINE_OFFSET);
            NSInteger nLet = (NSInteger)(0.25 + width/(LETTER_WIDTH + BAR_HEIGHT));
            width = X_LINE_OFFSET + nLet * (LETTER_WIDTH + BAR_HEIGHT);									  
            
            
            CGFloat pattern[] = { LETTER_WIDTH, BAR_HEIGHT };
            CGContextSetLineDash( context, 0.0, pattern, 2 );
            CGContextMoveToPoint(context, X_LINE_OFFSET, TOP_LINE_OFFSET1 );
            CGContextAddLineToPoint(context, width, TOP_LINE_OFFSET1 );
            
            for ( CGFloat x = X_LINE_OFFSET; x < width; )
            {
                CGContextMoveToPoint(context, x, TOP_LINE_OFFSET1-BAR_HEIGHT );
                CGContextAddLineToPoint(context, x, TOP_LINE_OFFSET1 );
                x += LETTER_WIDTH;
                CGContextMoveToPoint(context, x, TOP_LINE_OFFSET1-BAR_HEIGHT );
                CGContextAddLineToPoint(context, x, TOP_LINE_OFFSET1 );
                x += BAR_HEIGHT;
            }
            CGContextStrokePath(context);		
        }
        CGFloat pattern[] = { 6.0, 6.0 };
        CGContextSetLineWidth( context, 1.0 );
        CGContextSetLineDash( context, 0.0, pattern, 2 );
        CGContextMoveToPoint(context, X_LINE_OFFSET, TOP_LINE_OFFSET2 );
        CGContextAddLineToPoint(context, rect.size.width - X_LINE_OFFSET, TOP_LINE_OFFSET2 );
        CGContextStrokePath(context);
        CGContextDrawPath(context, kCGPathFillStroke);

        CGContextSetShouldAntialias( context, true );
    }

    if ( self.showMarker )
    {
        if ( markerPosition < 1.0 )
        {
            markerPosition = X_LINE_OFFSET + LETTER_WIDTH;
        }
        
        CGContextSetLineWidth( context, 1.0 );
        CGContextSetLineDash( context, 0.0, 0, 0 );
        CGContextSetStrokeColorWithColor(context, [WritePadInputView colorForElement:@"LinesColor"].CGColor );
        CGContextSetFillColorWithColor(context, [WritePadInputView colorForElement:@"LinesColor"].CGColor  );

        if ( [WritePadInputView flagForElement:@"ShowLines"] || _markerSelected )
        {
            CGContextMoveToPoint(context, markerPosition, TOP_LINE_OFFSET1+2 );
            CGContextAddLineToPoint(context, markerPosition + MARKER_WIDTH, TOP_LINE_OFFSET1+2+MARKER_HEIGHT );
            CGContextAddLineToPoint(context, markerPosition - MARKER_WIDTH, TOP_LINE_OFFSET1+2+MARKER_HEIGHT );
            CGContextClosePath(context);
            CGContextDrawPath(context, kCGPathFillStroke);
        }
        if ( (![WritePadInputView flagForElement:@"ShowLines"]) || _markerSelected )
        {
            CGContextMoveToPoint(context, markerPosition, rrect.origin.y + 10 );
            CGContextAddLineToPoint(context, markerPosition, rect.size.height - 16 );
            CGContextStrokePath(context);
        }
        if ( _markerSelected )
        {
            CGContextMoveToPoint(context, markerPosition, TOP_LINE_OFFSET2-2 );
            CGContextAddLineToPoint(context, markerPosition + MARKER_WIDTH, TOP_LINE_OFFSET2-2-MARKER_HEIGHT );
            CGContextAddLineToPoint(context, markerPosition - MARKER_WIDTH, TOP_LINE_OFFSET2-2-MARKER_HEIGHT );
            CGContextClosePath(context);
        }
        CGContextDrawPath(context, kCGPathFillStroke);
    }
    
    CGContextRestoreGState( context );

    BOOL vg = [WritePadInputView flagForElement:@"ShowVertGrid"];
    BOOL hg = [WritePadInputView flagForElement:@"ShowHorzGrid"];

    if ( hg || vg )
    {
        // draw grid
        CGFloat space = [WritePadInputView floatForElement:@"GridSpacing"];
        CGContextSetLineWidth( context, 0.5 );
        CGContextSetStrokeColorWithColor(context, [WritePadInputView colorForElement:@"GridColor"].CGColor );
        if ( vg )
        {
            CGFloat x = rrect.origin.x + space;
            while ( x < rrect.size.width + rrect.origin.x - 1.0 )
            {
                CGContextMoveToPoint(context, x, rrect.origin.y );
                CGContextAddLineToPoint(context, x, rect.size.height - 8.0 );
                x += space;
            }
        }
        if ( hg )
        {
            CGFloat y = rrect.origin.y + space;
            while ( y < rect.size.height - 8.0 )
            {
                CGContextMoveToPoint(context, rrect.origin.x, y );
                CGContextAddLineToPoint(context, rect.size.width - rrect.origin.x, y );
                y += space;
            }
        }
        CGContextStrokePath(context);
    }
			
	if ( placeholder != nil )
	{
		CGContextSetRGBFillColor(context, 0.2, 0.2, 0.2, 0.7 );
		CGRect rText = rect;
		rText.origin.y = IS_PHONE ? (TOP_LINE_OFFSET2-20) :  (TOP_LINE_OFFSET2-70);
		rText.size.height = IS_PHONE ? 80 : 150;
		rText.origin.x -= 15;	// this font needs a little offset to the left

        // draw the current stroke
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = NSLineBreakByClipping;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        NSDictionary * attrib = @{ NSFontAttributeName: [UIFont fontWithName:@"Zapfino" size:(IS_PHONE ? 36.0 : 60.0)], NSParagraphStyleAttributeName: paragraphStyle,
                                   NSForegroundColorAttributeName : [UIColor blueColor] };
        
		[placeholder drawInRect:rText withAttributes:attrib];
	}

    // display cuttent language image
    UIImage * langImage = [[LanguageManager sharedManager] languageImage];
    if ( nil != langImage )
    {
        CGPoint pt;
        pt.x = self.bounds.size.width - ((IS_PHONE) ? 52 : 80);
        pt.y = self.bounds.size.height - 42;
        [langImage drawAtPoint:pt blendMode:kCGBlendModeNormal alpha:0.75];
    }
}

- (void) moveMarkerToLocation:(CGPoint)location selected:(BOOL)sel
{
	
	[self setMarkerPosition:location.x];
	_markerSelected = sel;
	[self setNeedsDisplay];
}

- (CGFloat) getMarkerPosition
{
	return markerPosition;
}

- (CGRect) getMarkerRect
{
	if ( markerPosition < 1.0 )
	{
		markerPosition = self.bounds.size.width/7.0;
	}		
	CGRect result = CGRectMake( markerPosition - MARKER_WIDTH, TOP_LINE_OFFSET1 - 2, MARKER_WIDTH * 2, MARKER_HEIGHT + 4 );
	return result;
}

- (void) setMarkerPosition:(CGFloat)pos
{
	pos += MARKER_WIDTH/2;
	if ( pos < X_LINE_OFFSET )
		pos = X_LINE_OFFSET;
	if ( pos > (self.bounds.size.width/2 + X_LINE_OFFSET) )
		pos = (self.bounds.size.width/2 + X_LINE_OFFSET);
	if ( markerPosition != pos )
	{
		markerPosition = pos;
		[[NSUserDefaults standardUserDefaults] setFloat:markerPosition forKey:kInputPanelMarkerPosition];	
	}
}

- (void) setHasInk:(Boolean)hasInk
{
	bHasInk = hasInk;
}

- (void) empty
{
	_markerSelected = NO;
    [self showCommandButton:NO withCommand:nil];
	[inkCollector empty];
	[resultView empty];
    self.penButton = nil;
}

- (void)dealloc 
{
    self.penButton = nil;
    self.cmdButton = nil;
	if ( nil != myGradient )
		CGGradientRelease(myGradient);
}


@end
