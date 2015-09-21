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

#pragma once

#import <UIKit/UIKit.h>

#define CFSafeRelease( x )  if (NULL!=x) {CFRelease(x); x = NULL;}
#define NSStringReplace(str,find,replace) [str replaceOccurrencesOfString:find withString:replace options:NSLiteralSearch range:NSMakeRange(0,[str length])]

#ifdef __IPHONE_4_0
#define	SET_DELEGATE(del)	del
#else
#define SET_DELEGATE(del)
#endif // __IPHONE_4_0

enum
{
    UIDeviceResolution_Unknown          = 0,
    UIDeviceResolution_iPhoneStandard   = 1,    // iPhone 1,3,3GS Standard Display  (320x480px)
    UIDeviceResolution_iPhoneRetina35   = 2,    // iPhone 4,4S Retina Display 3.5"  (640x960px)
    UIDeviceResolution_iPhoneRetina4    = 3,    // iPhone 5 Retina Display 4"       (640x1136px)
    UIDeviceResolution_iPadStandard     = 4,    // iPad 1,2 Standard Display        (1024x768px)
    UIDeviceResolution_iPadRetina       = 5     // iPad 3 Retina Display            (2048x1536px)
};

typedef NSUInteger UIDeviceResolution;

#define SET_CURR_POPOVER(pop)			[utils setCurrPopover:(pop)];
#define HIDE_CURR_POPOVER				[utils dismissCurrentPopover];

#define IS_PHONE                        (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define NSLocalizedTableTitle( str )    [NSString stringWithFormat:@"   %@", NSLocalizedString( str, @"" )]
#define LOC( str )                      NSLocalizedString( str, @"" )
#define LOCT( str )                     NSLocalizedTableTitle( str )

/////////////////////////////////////////////////////////////////////////////

@interface utils : NSObject
{

}

+ (NSString *) appNameAndVersionNumberDisplayString;
+ (NSString *) shortFileName:(NSString *)fileName;
+ (Boolean) isPhone;
+ (UInt32) _uiColorToColorRef:(UIColor *)color;
+ (UIColor *) _uiColorRefToColor:(UInt32)rgb;
+ (CGFloat) _uiColorAlpha:(UIColor *)color;
+ (CGFloat) calcWidth:(CGFloat)weight pressure:(int)pressure;
+ (NSInteger) getMajorOSVersion;
+ (UIDeviceResolution)resolution;

+ (BOOL) isRetina;

+ (CGFloat) distanceFrom:(CGPoint)from toPoint:(CGPoint)to;

+ (UIImage *) colorImageWithImage:(UIImage *)img color:(UIColor *)col mode:(CGBlendMode)m;
+ (UIImage *) colorImageWithName:(NSString *)name color:(UIColor *)col mode:(CGBlendMode)m;

@end

