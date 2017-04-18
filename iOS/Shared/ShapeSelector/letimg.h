/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    Copyright (c) 2008-2017 PhatWare(r) Corp. All rights reserved.                 * */
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

#ifndef __LETIMG_H
#define __LETIMG_H

#include "recotypes.h"
#include "ligstate.h"

#define LIError		(-1)
#define LINoError	0

#define LItop		0
#define LIbottom	255
#define LIleft		0
#define LIright		255

typedef  struct {
	int top;
	int left;
	int bottom;
	int right;
} LIRectType;

typedef  struct {
	int x;
	int y;
} LIPointType;

typedef  struct {
	int handledb;
} LIDBType;

typedef  struct {
	int handlei;
} LIInfoType;

typedef struct {
	int handlev;
} LIVarType;

typedef struct {
	int handles;
} LIStokeType;

const LIInfoType*  LIGetLetterInfo (const LIDBType *lidb, int letter);
const LIVarType*   LIGetVariantInfo(const LIDBType *lidb, const LIInfoType *letI, int variantIndex);
const LIStokeType* LIGetStrokeInfo (const LIDBType *lidb, const LIVarType  *letV, int strokeIndex);

int LIGetLetNumVar (const LIInfoType  *letI);

int LIGetGroup     (const LIVarType   *letV);
int LIGetNumStrokes(const LIVarType   *letV);

int LIGetNumPoints (const LIStokeType *letS);
int LIGetPointX    (const LIStokeType *letS, int pointIndex);
int LIGetPointY    (const LIStokeType *letS, int pointIndex);

int LIGetVariantBBox    (const LIDBType *lidb, const LIVarType *letV, LIRectType *bbox);
int LIGetVariantBaseLine(const LIDBType *lidb, const LIVarType *letV, LIRectType *baseRect);

//////////////////////////////////////////////////////////////////////////////////////

#define LI_LET_IMG_X				0
#define LI_LET_IMG_X_FROM_RIGHT		0 /* LI_LET_IMG_X */

#ifdef _DEVICE_IPAD_

#define LI_LET_IMG_Y				10 // (g_bIsVGA ? 8 : 4)
#define LI_PAIRED_LET_V_SPACE		10 // (g_bIsVGA ? 10 : 6)
#define LI_LET_IMG_LEFT_OFFSET		30 // (g_bIsVGA ? 40 : 20)
#define LI_LET_SELL_WIDTH			60 // (g_bIsVGA ? 70 : 35)
#define LI_LET_SELL_HEIGHT			60 // (g_bIsVGA ? 70 : 35)
#define LETTER_STRIP_SIZE			66
#define LETTER_NAME_SIZE			22
#define LETTER_PEN_SIZE				3

#else // _DEVICE_IPAD_

#define LETTER_PEN_SIZE				2
#define LI_LET_IMG_Y				6 
#define LI_PAIRED_LET_V_SPACE		6 
#define LI_LET_IMG_LEFT_OFFSET		22 
#define LI_LET_SELL_WIDTH			50 
#define LI_LET_SELL_HEIGHT			50
#define LETTER_STRIP_SIZE			64
#define LETTER_NAME_SIZE			18

#endif // _DEVICE_IPAD_

#define LI_LET_GROUP_H_SPACE		(-2) // (g_bIsVGA ? (-4) : (-2))
#define LI_LET_LINE_V_SPACE			(0)
#define LI_LET_SEL_OVAL_SIZE		10 // (g_bIsVGA ? 18 : 9)
#define LI_LET_CAPT_REPLACE_INDEX_FROM_END	1

//////////////////////////////////////////////////////////////////////////////////////

#define SELECTION_FRAME_PEN_SIZE	1
#define BASELINE_PEN_SIZE			1

#define NUM_OVERLAPED_PTS			2
#define LI_MAX_LET_IMG				16

#define I_WRITE_RG_X				5
#define I_WRITE_RG_Y				0  /* from the controls Y origin */
#define I_WRITE_RG_HEIGHT			19
#define I_WRITE_RB_XSPACE			5
#define I_WRITE_RB_HEIGHT			16
#define I_WRITE_RB_Y				(I_WRITE_RG_Y + I_WRITE_RG_HEIGHT)

#define I_WR_OFTEN_WIDTH			80
#define I_WR_SOMETIMES_WIDTH		80
#define I_WR_RARE_WIDTH				80

#define LANGUAGE_Y					10
#define LANGUAGE_W					80

#define ORIGIN_LEFT(r)		((r).left + (((r).right - (r).left) <= 250 ? 5 : 20))

#define LI_ARRAY_LENGTH(a)	(sizeof(a)/sizeof((a)[0]))

enum E_LET_GROUPMODE {
	LI_SET_GROUP_STATE,
	LI_GET_GROUP_STATE,
	LI_GET_DTEGROUP
};

typedef struct {
	int group;
	int index;
} LIVarSortType;

enum E_LI_LETSTATE {
	LI_OFTEN,
	LI_SOMETIMES,
	LI_RARE
};

typedef struct {
	LIRectType    groupRect[LI_MAX_LET_IMG];
	LIRectType    letterRect[LI_MAX_LET_IMG];
	int           letterVar[LI_MAX_LET_IMG];
	enum E_LI_LETSTATE letState[LI_MAX_LET_IMG];
	int           numVar;
	int           numGroup;
	int           letter;
	int           selOvalSize;
	int           selectedGroupIndex;
} LILayoutType;

#define NUM_PAIRED_CHARS	2

typedef struct {
	char         letter[NUM_PAIRED_CHARS];
	LIRectType   framerect;
	struct { int x; int y; }  sepline[2];
	LILayoutType letimg[NUM_PAIRED_CHARS];
} LILetImgDrawType;

int		LIGetLetNumOfGroup( const LILayoutType *inLayout);
int		LISelelectGroup( LILayoutType  *ioLayout, int inGroupIndex);
int		LIGetSelectedGroup( const LILayoutType  *inLayout);
int		LIIntersectRect( const LIRectType *inSrc1, const LIRectType *inSrc2 );

int		LIGetDTELetGroup(
						 const LIDBType     *inLidb,
						 const LILayoutType *inLayout,
						 int                inGroupIndex );
int		LIGetLetGroupState(
						   const LIDBType     *inLidb,
						   const LILayoutType *inLayout,
						   int                inGroupIndex);
int		LISetLetGroupState(
						   const LIDBType *inLidb,
						   LILayoutType   *ioLayout,
						   int            inGroupIndex,
						   enum E_LI_LETSTATE  inLetState);
int		GetSetLetGroupParms(
							const LIDBType  *inLidb,
							LILayoutType    *ioLayout,
							int             inGroupIndex,
							enum E_LI_LETSTATE   inLetState,
							enum E_LET_GROUPMODE inMode);
int		LIHitTestLetterLayout(
						  const LILayoutType *inLayout,
						  int                inX,
						  int                inY,
						  int                inIsTestGroup);
int		LIGetLetGroupRect(
						  const LILayoutType *inLayout,
						  int                inGroupIndex,
						  LIRectType         *outRect);
int		LICalcLetterLayout(const LIDBType *inLidb,
						   int            inLetter,
						   LILayoutType   *outLayout,
						   LIRectType     *ioDestRect,
						   int            inLetHSize,
						   int            inLetVSize,
						   int            inLineHeight,
						   int            inGroupHSpace,
						   int            inPenSize );

// calculates layout for all letters...
void	CalcLetterLayout(
						 LIRectType          *ioDestRect,
						 char                inLetter,
						 LILetImgDrawType    *outLayout,
						 const LIDBType      *inLidb,
						 const LIGStatesType *inGStates );

int		CalculateScreenRect(
						const LIRectType *inBBox,
						const LIRectType *inDestRect,
						LIRectType       *outScreenRect );

int		ConvertToScreenCoord(
						 LIPointType      *ioPt,
						 const LIRectType *inSrcRect,
						 const LIRectType *inDestRect );

enum E_LI_LETSTATE SelectNextGroupDtate( const LIDBType *lidb, LILetImgDrawType *ioLIdraw, LIGStatesType  *ioGStates );

#endif /* __LETIMG_H */

