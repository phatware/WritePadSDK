/***************************************************************************************
 *
 *  WRITEPAD(r): Handwriting Recognition Engine (HWRE) and components.
 *  Copyright (c) 2001-2017 PhatWare (r) Corp. All rights reserved.
 *
 *  Licensing and other inquires: <developer@phatware.com>
 *  Developer: Stan Miasnikov, et al. (c) PhatWare Corp. <http://www.phatware.com>
 *
 *  WRITEPAD HWRE is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  THE MATERIAL EMBODIED ON THIS SOFTWARE IS PROVIDED TO YOU "AS-IS"
 *  AND WITHOUT WARRANTY OF ANY KIND, EXPRESS, IMPLIED OR OTHERWISE,
 *  INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY OR
 *  FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL PHATWARE CORP.
 *  BE LIABLE TO YOU OR ANYONE ELSE FOR ANY DIRECT, SPECIAL, INCIDENTAL,
 *  INDIRECT OR CONSEQUENTIAL DAMAGES OF ANY KIND, OR ANY DAMAGES WHATSOEVER,
 *  INCLUDING WITHOUT LIMITATION, LOSS OF PROFIT, LOSS OF USE, SAVINGS
 *  OR REVENUE, OR THE CLAIMS OF THIRD PARTIES, WHETHER OR NOT PHATWARE CORP.
 *  HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH LOSS, HOWEVER CAUSED AND ON
 *  ANY THEORY OF LIABILITY, ARISING OUT OF OR IN CONNECTION WITH THE
 *  POSSESSION, USE OR PERFORMANCE OF THIS SOFTWARE.
 *  See the GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with WritePad.  If not, see <http://www.gnu.org/licenses/>.
 *
 **************************************************************************************/

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
#if !defined(OBJC_HIDE_64) && defined(TARGET_OS_IPHONE) && defined(__LP64__)
typedef bool BOOL;
#else
typedef signed char BOOL;
// BOOL is explicitly signed so @encode(BOOL) == "c" rather than "C"
// even if -funsigned-char is used.
#endif

#define IMAGE_SUPPORT	1		// support image storage

#endif // __RecoTypes_h__
 
