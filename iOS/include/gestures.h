/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    Copyright (c) 2008-2015 PhatWare(r) Corp. All rights reserved.                 * */
/* ************************************************************************************* */

/* ************************************************************************************* *
 *
 * File: gestures.h
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

#include "recotypes.h"

#if defined(__cplusplus)
extern "C"
{
#endif

/************************************************/

typedef  enum  {
    GEST_NONE      = 0x00000000,
    GEST_DELETE    = 0x00000001,
    GEST_SCROLLUP  = 0x00000002,
    GEST_BACK      = 0x00000004,
    GEST_SPACE     = 0x00000008,
    GEST_RETURN    = 0x00000010,
    GEST_CORRECT   = 0x00000020,
    GEST_SPELL     = 0x00000040,
    GEST_SELECTALL = 0x00000080,
    GEST_UNDO      = 0x00000100,
    GEST_SMALLPT   = 0x00000200,
    GEST_COPY      = 0x00000400,
    GEST_CUT       = 0x00000800,
    GEST_PASTE     = 0x00001000,
    GEST_TAB       = 0x00002000,
    GEST_MENU      = 0x00004000,
    GEST_LOOP      = 0x00008000,
	GEST_REDO	   = 0x00010000,
	GEST_SCROLLDN  = 0x00020000,
	GEST_SAVE	   = 0x00040000,
	GEST_SENDMAIL  = 0x00080000,
	GEST_OPTIONS   = 0x00100000,
	GEST_SENDTODEVICE = 0x00200000,
	GEST_BACK_LONG = 0x00400000,
	
	GEST_LEFTARC   = 0x10000000,
	GEST_RIGHTARC  = 0x20000000,
	GEST_ARCS	   = 0x30000000,
    
    GEST_TIMEOUT   = 0x40000000,
    GEST_CUSTOIM   = 0x80000000,
	
    GEST_ALL       = 0x0FFFFFFF
}	
GESTURE_TYPE, *pGESTURE_TYPE;


#ifndef  TRACE_BREAK
#define  TRACE_BREAK  (-1)
#endif  //TRACE_BREAK

/************************************************/

GESTURE_TYPE HWR_CheckGesture( GESTURE_TYPE gtCheck, CGStroke stroke, int nPoints, int nScale, int nMinLen );

#if defined(__cplusplus)
}
#endif
