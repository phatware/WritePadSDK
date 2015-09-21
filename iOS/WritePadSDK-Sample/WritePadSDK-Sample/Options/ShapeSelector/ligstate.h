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

#ifndef __LISTATE_H
#define __LISTATE_H

typedef enum __E_LIG_STATE {
	LIG_STATE_UNDEF  = 0,
	LIG_STATE_OFTEN  = 1,
	LIG_STATE_RARELY = 2,
	LIG_STATE_NEVER  = 3
}E_LIG_STATE;


#define LIG_FIRST_LETTER 0x20
#define LIG_LAST_LETTER  0xFF
#define LIG_NUM_LETTERS  (LIG_LAST_LETTER - LIG_FIRST_LETTER + 1)
#if LIG_NUM_LETTERS <= 0
	#error
#endif
#define LIG_LET_NUM_GROUPS     8
#define LIG_NUM_BITS_PER_GROUP 2
#define LIG_NUM_BIT_GROUP_MASK 0x3

#define LIG_STATES_SIZE \
	(LIG_NUM_LETTERS * LIG_LET_NUM_GROUPS * LIG_NUM_BITS_PER_GROUP / 8)

typedef unsigned char LIGStatesType[LIG_STATES_SIZE];


/*
 * Sets state for a given letter and group.
 * Returns 0 if letter and group are in the allowed range, -1 otherwise.
 */
int  LIGSetGroupState(LIGStatesType *ioGStates,
                             int           inLetter,
					         int           inGroup,
                             E_LIG_STATE   inGroupState);

/*
 * Returns state for a given letter and group.
 */
E_LIG_STATE LIGGetGroupState(const LIGStatesType *inGStates,
                             int                 inLetter,
					         int                 inGroup);

#endif /* __LISTATE_H */
