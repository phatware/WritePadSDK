/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    Copyright (c) 2008-2014 PhatWare(r) Corp. All rights reserved.                 * */
/* ************************************************************************************* */

/* ************************************************************************************* *
 *
 * File: recodefs.h
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


#ifndef __Reco_Defs_h__
#define __Reco_Defs_h__

/* ------------------------- Defines ---------------------------------------- */


#define HW_RECINT_ID_001		0x01000002  /* Rec Interface ID */
#define HW_MAX_SPELL_NUM_ALTS	10			/* How many variants will be out by the SpellCheck func */
#define HW_RECID_MAXLEN			32			/* Max length of the RecID string */
#define HW_MAX_FILENAME			128			/* Limit for filename buffer */

// Recognizer Control Falgs
#define HW_RECFL_NSEG			0x0001      /* Do not perform segmentation at all*/
#define HW_RECFL_NCSEG			0x0002      /* Do not allow segm not waiting for final stroke. (No results on the go) */
#define HW_RECFL_TTSEG			0x0004      /* Perform read-ahead of tentative segmented words */
#define HW_RECFL_INTL_CS		0x0010      /* Enables international charsets */
#define HW_RECFL_ALPHAONLY		0x0020      /* Enables international charsets */
#define HW_RECFL_CUSTOM_WITH_ALPHA	0x0040	/* Alpha with custom punctuation */
#define HW_RECFL_SEPLET			0x0100      /* Enables separate letter mode */
#define HW_RECFL_DICTONLY		0x0200      /* Restricts dictionary words only recognition */
#define HW_RECFL_NUMONLY		0x0400      /* NUMBERS only  */
#define HW_RECFL_CAPSONLY		0x0800      /* CAPITALS only */
#define HW_RECFL_PURE			0x1000      /* NUMBERS and CAPITALS modes do not use any other chars */
#define HW_RECFL_INTERNET		0x2000      /* Internet address mode */
#define HW_RECFL_STATICSEG		0x4000		/* Static segmentation */
#define HW_RECFL_CUSTOM			0x8000		/* use custom charset */

// Bits of recognizer capabilities

#define HW_CPFL_CURS			0x0001      /* Cursive capable */
#define HW_CPFL_TRNBL			0x0002      /* Training capable */
#define HW_CPFL_SPVSQ			0x0004      /* Speed VS Quality control capable */
#define HW_CPFL_INTER			0x0008      /* International support capable */

#define HW_MAXWORDLEN			50			/* maximum word length */

#define HW_SPELL_CHECK			0x0000      /* SpellCheck flag: do spell checking */
#define HW_SPELL_LIST			0x0001      /* SpellCheck flag: list continuations */
#define HW_SPELL_USERDICT		0x0002		/* SpellCheck flag: use user dictionary */
#define HW_SPELL_USEALTDICT		0x0004		/* SpellCheck flag: use alternative dictionary */
#define HW_SPELL_IGNORENUM		0x0008      /* SpellCheck flag: ignore words containing numbers */
#define HW_SPELL_IGNOREUPPER	0x0010      /* SpellCheck flag: ignore words in UPPER case */

#define HW_NUM_ANSWERS			1			/* Request to get number of recognized words */
#define HW_NUM_ALTS				2			/* Request number of alternatives for given word */
#define HW_ALT_WORD				3			/* Requestto get pointer to a given word alternative */
#define HW_ALT_WEIGHT			4			/* Request to get weight of a give word alternative */
#define HW_ALT_NSTR				5			/* Request to get number of strokes used for a given word alternative */
#define HW_ALT_STROKES			6			/* Request to get a pointer to a given word alternative stroke ids */

#define MIN_RECOGNITION_WEIGHT  51			/* Minimum recognition quality */
#define MAX_RECOGNITION_WEIGHT  100			/* Maximum recognition quality */
#define AVE_RECOGNITION_WEIGHT	((MIN_RECOGNITION_WEIGHT+MAX_RECOGNITION_WEIGHT)/2)

#define LRN_WEIGHTSBUFFER_SIZE	448
#define LRN_SETDEFWEIGHTS_OP	0			/* LEARN interface commands for RecoGetSetPictWghts func */
#define LRN_GETCURWEIGHTS_OP	1
#define LRN_SETCURWEIGHTS_OP	2

#define PM_ALTSEP               1			/* Recognized word list alternatives separator */
#define PM_LISTSEP              2			/* Recognized word list wordlist separator */
#define PM_LISTEND              0			/* Recognized word list end */

#define PM_NUMSEPARATOR			(-1)


#define HW_RECINT_UNICODE        1           // NOTE: define to use Unicode (UTF-16)


/* ------------------------- Structures ------------------------------------- */

typedef void * RECOCTX;						/* Type of handle of recognizer context */
typedef void * RECOHDICT;					/* Type of handle of user dictionary handle */


#ifdef HW_RECINT_UNICODE
typedef unsigned short UCHR;
typedef const unsigned short CUCHR;
#else  // HW_RECINT_UNICODE
typedef char UCHR;
typedef const char CUCHR;
#endif // HW_RECINT_UNICODE

typedef int (RECO_ONGOTWORD)( const UCHR * szWord, void * pParam );
typedef RECO_ONGOTWORD * PRECO_ONGOTWORD;

#endif // __Reco_Defs_h__
