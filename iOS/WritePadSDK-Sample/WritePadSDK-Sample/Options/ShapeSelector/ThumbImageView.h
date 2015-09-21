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

@protocol ThumbImageViewDelegate;

#define THUMB_HEIGHT			102
#define THUMB_V_PADDING			10
#define THUMB_H_PADDING			10
#define AUTOSCROLL_THRESHOLD	30
#define MAX_FOLDER				15


@interface ThumbImageView : UIView
{
    NSString *	letter;
    
    /* ThumbImageViews have a "home," which is their location in the containing scroll view. Keeping this distinct */
    /* from their frame makes it easier to handle dragging and reordering them. We can change their relative       */
    /* positions by changing their homes, without having to worry about whether they have currently been dragged   */
    /* somewhere else. Also, we don't lose track of where they belong while they are being moved.                  */
    CGRect home;
	NSInteger index;
	BOOL	selected;
    
    BOOL	dragging;
    CGPoint touchLocation; // Location of touch in own coordinates (stays constant during dragging).
}

@property (nonatomic, weak) id <ThumbImageViewDelegate> delegate;
@property (nonatomic, assign) CGRect		home;
@property (nonatomic, assign) NSInteger		index;
@property (nonatomic, assign) CGPoint		touchLocation;


- (id) initWithLetter:(NSString *)str;
- (void) goHome;  // animates return to home location
- (void) moveByOffset:(CGPoint)offset; // change frame lo
- (void) setSelected:(BOOL)s;

@end



@protocol ThumbImageViewDelegate <NSObject>

@optional
- (void)thumbImageViewWasTapped:(ThumbImageView *)tiv;
- (void)thumbImageViewStartedTracking:(ThumbImageView *)tiv;
- (void)thumbImageViewMoved:(ThumbImageView *)tiv;
- (void)thumbImageViewStoppedTracking:(ThumbImageView *)tiv;

@end

