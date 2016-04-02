/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    Copyright (c) 2008-2014 PhatWare(r) Corp. All rights reserved.                 * */
/* ************************************************************************************* */

/* ************************************************************************************* *
 *
 * File: RecoTypes.h
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

#ifndef __RecoTypes_h__
#define __RecoTypes_h__

#include "recodefs.h"
#include "langid.h"

#ifndef __MACTYPES__

// define some types that are used for compatibility with MAC OS

typedef unsigned char   UInt8;
typedef signed char     SInt8;
typedef unsigned short  UInt16;
typedef signed short    SInt16;
typedef unsigned int    UInt32;
typedef signed int      SInt32;

typedef SInt16          OSErr;
typedef SInt32          OSStatus;

enum {
    noErr  = 0
};

#endif // __MACTYPES__

#ifndef CGGEOMETRY_H_

#if defined(__LP64__) && __LP64__
typedef double			CGFloat;
#else
typedef float			CGFloat;
#endif 

struct CGPoint {
    CGFloat x;
    CGFloat y;
};
typedef struct CGPoint CGPoint;

struct CGSize {
    CGFloat width;
    CGFloat height;
};
typedef struct CGSize CGSize;

struct CGRect {
    CGPoint origin;
    CGSize size;
};
typedef struct CGRect CGRect;

#endif // CGGEOMETRY_H_

typedef struct __tagTracePoint
{
    CGPoint	pt;
    int		pressure;
} CGTracePoint;

typedef CGTracePoint *  CGStroke;


#define RW_WEIGHTMASK		0x000000FF
#define RW_DICTIONARYWORD	0x00004000

// Autocorrector flags
#define WCF_IGNORECASE		0x0001
#define WCF_ALWAYS			0x0002
#define WCF_DISABLED		0x0004

/* ------------------------- Language ID ------------------------------------- */

#define DEFAULT_PRESSURE        150
#define MAX_PRESSURE            255
#define MIN_PRESSURE            5

typedef enum {
    SHAPE_UNKNOWN		= 0,
    SHAPE_TRIANGLE		= 0x0001,
    SHAPE_CIRCLE		= 0x0002,
    SHAPE_ELLIPSE		= 0x0004,
    SHAPE_RECTANGLE		= 0x0008,
    SHAPE_LINE			= 0x0010,
    SHAPE_ARROW			= 0x0020,
    SHAPE_SCRATCH		= 0x0040,
    SHAPE_ALL			= 0x00FF
} SHAPETYPE;


typedef UInt16			USHORT;
typedef unsigned char	UCHAR;
typedef unsigned short	UNCHAR;
typedef UNCHAR *		LPUSTR;
typedef const UNCHAR *	LPCUSTR;
typedef UInt32			COLORREF;

/// Type to represent a boolean value.
#if !defined(OBJC_HIDE_64) && TARGET_OS_IPHONE && __LP64__
typedef bool BOOL;
#else
typedef signed char BOOL;
// BOOL is explicitly signed so @encode(BOOL) == "c" rather than "C"
// even if -funsigned-char is used.
#endif

#define IMAGE_SUPPORT	1		// support image storage

#endif // __RecoTypes_h__
 