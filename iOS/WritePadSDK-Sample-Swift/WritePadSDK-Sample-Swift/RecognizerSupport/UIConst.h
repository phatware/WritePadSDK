/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    Copyright (c) 2008-2015 PhatWare(r) Corp. All rights reserved.                 * */
/* ************************************************************************************* */

/* ************************************************************************************* *
 *
 * WritePad Input Panel Sample
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

#define kInsertValue				8.0
#define kUIRowHeight				50.0
#define kUIRowLabelHeight			22.0
#define kFolderRowHeight			72.0
#define kSwitchButtonWidth			98.0
#define kCellLeftOffset				8.0
#define kCellTopOffset				12.0
#define kTextFieldHeight			31.0
#define kToolbarHeight				44.0
#define kNewWordCellHeight			56.0
#define kWordCellHeight				44.0
#define kTextFieldWidth				260.0	// initial width, but the table cell will dictact the actual width
#define kSwitchButtonHeight			30.0

#ifdef _DEVICE_IPAD_
#define DEFAULT_BACKGESTURELEN		300
#define MIN_BACKGESTURELEN			200
#define MAX_BACKGESTURELEN			500
#else
#define DEFAULT_BACKGESTURELEN		200
#define MIN_BACKGESTURELEN			100
#define MAX_BACKGESTURELEN			300
#endif // _DEVICE_IPAD_
#define DEFAULT_PENWIDTH			3.0
#define DEFAULT_RECODELAY			1.5
#define MIN_DELAY					0.2

#define IS_PHONE                    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define kInputPanelHeight			(IS_PHONE ? 190.0 : 280.0)
#define kBottomOffset				22

#define DEFAULT_STROKE_LEN          1000
#define DEFAULT_TOUCHANDHOLDDELAY	0.6
#define kGridStep					85.0

