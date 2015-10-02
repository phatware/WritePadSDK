/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    Copyright (c) 2008-2015 PhatWare(r) Corp. All rights reserved.                 * */
/* ************************************************************************************* */

/* ************************************************************************************* *
 *
 * File: RecognizerAPI.h
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


#ifndef __RecognizerAPI_h__
#define __RecognizerAPI_h__

#include "gestures.h"
#include "recotypes.h"

#ifndef WIN32
#define GetRValue(rgb)      ((float)((rgb)&0xFF)/255.0)
#define GetGValue(rgb)      ((float)(((rgb)>>8)&0xFF)/255.0)
#define GetBValue(rgb)      ((float)(((rgb)>>16)&0xFF)/255.0)
#endif // WIN32

#define GetAValue(rgb)      ((float)(((rgb)>>24)&0xFF)/255.0)
#define RGBA(r,g,b,a)       ((COLORREF)(((unsigned char)(r)|((unsigned int)((unsigned char)(g))<<8))|(((unsigned int)(unsigned char)(b))<<16)|(((unsigned int)(unsigned char)(a))<<24)))
#define CCTB(cc)			((unsigned char)(cc * (float)0xFF))


#define RECMODE_GENERAL			0          // Normal recognition -- all sybols allowed
#define RECMODE_CAPS			1          // All recognized text converted to capitals
#define RECMODE_NUM				2          // Numeric and Lex DB recognition mode
#define RECMODE_WWW				3          // internet address mode
#define RECMODE_NUMBERSPURE		4		   // pure numeric mode, no alpha or punctuation, recognizes 0123456789 only
#define RECMODE_CUSTOM			5		   // custom charset for numbers and punctuation, no alpha
#define RECMODE_ALPHAONLY		6		   // Alpha characters only, no punctuation or numbers
#define RECMODE_INVALID			(-1)

#define MAX_TRACE_LENGTH		4096
#define TRACE_BREAK_LENGTH		200

#define MAX_STRING_BUFFER		2048

#define FLAG_SEPLET				0x00000001
#define FLAG_USERDICT			0x00000002
#define FLAG_MAINDICT			0x00000004
#define FLAG_ONLYDICT			0x00000008
#define FLAG_STATICSEGMENT		0x00000010
#define FLAG_SINGLEWORDONLY		0x00000020
#define FLAG_INTERNATIONAL		0x00000040
#define FLAG_SUGGESTONLYDICT	0x00000080
#define FLAG_ANALYZER			0x00000100
#define FLAG_CORRECTOR			0x00000200
#define FLAG_SPELLIGNORENUM		0x00000400
#define FLAG_SPELLIGNOREUPPER	0x00000800
#define FLAG_NOSINGLELETSPACE	0x00001000
#define FLAG_ENABLECALC			0x00002000
#define FLAG_NOSPACE			0x00004000
#define FLAG_ALTDICT			0x00008000
#define FLAG_USECUSTOMPUNCT		0x00010000
#define FLAG_SMOOTHSTROKES      0x00020000

#define FLAG_ERROR				0xFFFFFFFF

#define READ_FLAG                   0x01
#define MEM_STREAM_FLAG             0x02
#define INK_FMT_MASK                0x3C

#define INK_RAW                     0x01
#define INK_CALCOMP                 0x02
#define INK_PWCOMP                  0x03
#define INK_JPEG                    0x04
#define INK_DATA                    0x05
#define INK_PNG                     0x06

#define IGNORE_LAST_STROKE          0x0001000
#define SORT_STROKES                0x0002000
#define SAVE_PRESSURE				0x0004000

#define MAKE_READ_FMT( dwDataFmt, bMemStream )  ( ((dwDataFmt) << 2L) | ((bMemStream)?MEM_STREAM_FLAG:0) | READ_FLAG )
#define MAKE_WRITE_FMT( dwDataFmt, bMemStream ) ( ((dwDataFmt) << 2L) | ((bMemStream)?MEM_STREAM_FLAG:0) )
#define INK_DATA_FMT( dwFlags )                 ( ((dwFlags) & INK_FMT_MASK) >> 2L )
#define INK_READ( dwFlags )                     ( (dwFlags) & READ_FLAG )
#define INK_WRITE( dwFlags )                    ( ((dwFlags) & READ_FLAG) == 0 )
#define IS_MEM_STREAM( dwFlags )                ( (dwFlags) & MEM_STREAM_FLAG )
#define IS_FILE_STREAM( dwFlags )               ( ((dwFlags) & MEM_STREAM_FLAG) == 0 )

#endif 



