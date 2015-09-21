/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    Copyright (c) 2008-2015 PhatWare(r) Corp. All rights reserved.                 * */
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

#import "utils.h"
#import "RecognizerAPI.h"
#import "RecognizerWrapper.h"
#import "LanguageManager.h"
#import "OptionKeys.h"
#include <sys/types.h>
#include <sys/sysctl.h>

extern NSString *	g_appName;
extern NSData *		g_deviceToken;

#define radians( degrees ) ( (degrees) * M_PI / 180.0 ) 

@implementation utils

+ (CGFloat) distanceFrom:(CGPoint)from toPoint:(CGPoint)to
{
    CGFloat cx = from.x - to.x;
    CGFloat cy = from.y - to.y;
    return sqrt( cx * cx + cy * cy );
}

+ (UInt32) _uiColorToColorRef:(UIColor *)color
{
    if ( nil != color )
    {
        CGColorRef	 colorref = [color CGColor];
        const CGFloat * colorComponents = CGColorGetComponents(colorref);
        UInt32	 coloref = RGBA( CCTB(colorComponents[0]), CCTB(colorComponents[1]), CCTB(colorComponents[2]), CCTB(colorComponents[3]) );
        return coloref;
    }
    return RGBA( 0xFF, 0xFF, 0xFF, 0xFF );
}

+ (CGFloat) _uiColorAlpha:(UIColor *)color
{
    CGColorRef	 colorref = [color CGColor];
    const CGFloat * colorComponents = CGColorGetComponents(colorref);
    return colorComponents[3];
}

+ (UIColor *) _uiColorRefToColor:(UInt32)coloref
{
    if ( coloref == 0 )
    {
        UIColor * color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        return color;
    }
    else
    {
        UIColor * color = [UIColor colorWithRed:GetRValue(coloref) green:GetGValue(coloref) blue:GetBValue(coloref) alpha:GetAValue(coloref)];
        return color;
    }
}


#define FMIN    0.5
#define FMAX    1.5

+ (CGFloat) calcWidth:(CGFloat)weight pressure:(int)pressure
{
    int p = pressure;
    if ( p <= 0 )
        p = DEFAULT_PRESSURE;
    else if ( p < MIN_PRESSURE )
        p = MIN_PRESSURE;
    else if ( p > MAX_PRESSURE )
        p = MAX_PRESSURE;
    if ( p == DEFAULT_PRESSURE )
        return weight;
    
    CGFloat f = (CGFloat)p/(CGFloat)DEFAULT_PRESSURE;
    if ( f < FMIN )
        f = FMIN;
    if ( f > FMAX )
        f = FMAX;
    return weight * f;
}


+ (NSString *)appNameAndVersionNumberDisplayString
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appDisplayName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    // NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    return [NSString stringWithFormat:@"%@ %@", appDisplayName, minorVersion];
}

+ (UIDeviceResolution)resolution
{
    UIDeviceResolution resolution = UIDeviceResolution_Unknown;
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGFloat scale = ([mainScreen respondsToSelector:@selector(scale)] ? mainScreen.scale : 1.0f);
    CGFloat pixelHeight = (CGRectGetHeight(mainScreen.bounds) * scale);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (scale == 2.0f)
        {
            if (pixelHeight == 960.0f)
                resolution = UIDeviceResolution_iPhoneRetina35;
            else if (pixelHeight == 1136.0f)
                resolution = UIDeviceResolution_iPhoneRetina4;
            
        }
        else if (scale == 1.0f && pixelHeight == 480.0f)
            resolution = UIDeviceResolution_iPhoneStandard;
        
    }
    else
    {
        if (scale == 2.0f && pixelHeight == 2048.0f)
        {
            resolution = UIDeviceResolution_iPadRetina;
            
        }
        else if (scale == 1.0f && pixelHeight == 1024.0f)
        {
            resolution = UIDeviceResolution_iPadStandard;
        }
    }
    
    return resolution;
}

+ (BOOL) isRetina
{
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGFloat scale = ([mainScreen respondsToSelector:@selector(scale)] ? mainScreen.scale : 1.0f);
    CGFloat pixelHeight = (CGRectGetHeight(mainScreen.bounds) * scale);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (scale == 2.0f)
        {
            return YES;
        }
    }
    else
    {
        if (scale == 2.0f && pixelHeight == 2048.0f)
        {
            return YES;
        }
    }
    return NO;
}



+ (NSInteger) getMajorOSVersion
{
    NSArray *versionCompatibility = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ( nil == versionCompatibility )
        return 0;
    return [[versionCompatibility objectAtIndex:0] intValue];
}


+ (NSString *) getFileType:(NSString *)filename
{
    NSString * type = nil;
    
    NSInteger  index = [filename rangeOfString:@"." options:(NSCaseInsensitiveSearch | NSBackwardsSearch)].location;
    if ( index != NSNotFound && index < [filename length] - 1 )
        type = [filename substringFromIndex:index];
    return type;
}

+ (NSString *)shortFileName:(NSString *)strFileName
{
	NSString * name;
	if ( [strFileName length] < 1 )
	{
		name = @"<filename>";
	}
	else
	{
		NSInteger  index = [strFileName rangeOfString:@"/" options:(NSCaseInsensitiveSearch | NSBackwardsSearch)].location;
		if ( index != NSNotFound && index < [strFileName length] - 1 )
			name = [strFileName substringFromIndex:(index+1)];
		else 
			name = strFileName;
	}
	return name;
}

+ (Boolean) isPhone
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
}

#pragma mark -- Image scaling

+ (UIImage *) colorImageWithName:(NSString *)name color:(UIColor *)col mode:(CGBlendMode)m
{
    UIImage * img = [UIImage imageNamed:name];
    if ( img == nil )
        return nil;
    
    return [utils colorImageWithImage:img color:col mode:m];
}

+ (UIImage *) colorImageWithImage:(UIImage *)img color:(UIColor *)col mode:(CGBlendMode)m
{
    /*
     if ( [utils isRetina] )
     {
     img = [UIImage imageNamed:[NSString stringWithFormat:@"%@@2x.png", [name substringToIndex:[name rangeOfString:@"."].location]]];
     }
     */
    // UIImage * img = [UIImage imageNamed:name];
    // img = [UIImage imageWithCGImage:img.CGImage scale:[img scale] orientation:UIImageOrientationRight];
    
    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContextWithOptions( img.size, NO, img.scale ); // [utils isRetina] ? 2 : 1 );
    // UIGraphicsBeginImageContext(img.size);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    if ( context == nil )
        return nil;
    
    // set the fill color
    [col setFill];
    
    CGContextSetShouldAntialias(context, YES );
    CGContextSetFlatness(context, 0.1);
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode to color burn, and the original image
    CGContextSetBlendMode(context, m);
    // CGContextSetAlpha(context, 0.9 );
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);
    
    
    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}


@end

