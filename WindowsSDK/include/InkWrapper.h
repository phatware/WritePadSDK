/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    Copyright (c) 2008-2014 PhatWare(r) Corp. All rights reserved.                 * */
/* ************************************************************************************* */

/* ************************************************************************************* *
 *
 * File: InkWrapper.h
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


#ifndef __ink_wrapper_h__
#define __ink_wrapper_h__

#include <stdio.h>
#include "RecognizerApi.h"

#define LF_FONT_BOLD		0x00000001
#define LF_FONT_ITALIC		0x00000002
#define LF_FONT_UNDERSCORE	0x00000004
#define LF_FONT_STRIKE		0x00000008

#define OBJECTFLAG_POSITIONLOCKED   0x00010000
#define OBJECTFLAG_SIZELOCKED       0x00020000
#define OBJECTFLAG_CONTENTLOCKED    0x00040000
#define OBJECTFLAG_LOCKED           0x00070000
#define OBJECTFLAG_GROUPED          0x00100000

#if defined(__cplusplus)
extern "C"
{
#endif
	
	typedef void * INK_DATA_PTR;
		
	typedef struct __ImageAttributes
	{
		CGRect		imagerect;
		int			iZOrder;
		int			nIndex;
		void *		pData;
		UInt32		nDataSize;
		void *		userData;
		UInt32		flags;
	} ImageAttributes;

	typedef struct __TextAttributes
	{
		CGRect		textrect;
		int			iZOrder;
		int			nIndex;
		LPCUSTR		pUnicodeText;
		UInt32		nTextLength;
		LPUSTR		pFontName;
		int 		fontSize;
		UInt32		fontAttributes;
		UInt32		alignment;
		COLORREF	fontColor;
		COLORREF	backColor;
		void *		userData;
        UInt32      flags;
	} TextAttributes;
    
	// Ink data API
	INK_DATA_PTR	INK_InitData();
	void			INK_FreeData( INK_DATA_PTR pData );
	void			INK_Erase( INK_DATA_PTR pData );
	int 			INK_StrokeCount( INK_DATA_PTR pData, BOOL selectedOnly );
	BOOL			INK_DeleteStroke( INK_DATA_PTR pData, int nStroke );
	SHAPETYPE		INK_RecognizeShape( CGStroke pStroke, int nStrokeCnt, SHAPETYPE inType );
	int 			INK_AddStroke( INK_DATA_PTR pData, CGStroke pStroke, int nStrokeCnt, float fWidth, COLORREF color );
	int				INK_GetStroke( INK_DATA_PTR pData, int nStroke, CGPoint ** ppoints, float * pfWidth, COLORREF * color );
    int             INK_GetStrokeP( INK_DATA_PTR pData, int nStroke, CGStroke * ppoints, float * pfWidth, COLORREF * pColor );
	BOOL			INK_GetStrokeRect( INK_DATA_PTR pData, int nStroke, CGRect * rect, BOOL bAddWidth );
	BOOL			INK_GetDataRect( INK_DATA_PTR pData, CGRect * rect, BOOL selectedOnly );
	int 			INK_AddEmptyStroke( INK_DATA_PTR pData, float fWidth, COLORREF color );
	int 			INK_AddPixelToStroke( INK_DATA_PTR pData, int nStroke, float x, float y, int p );
    BOOL            INK_GetStrokePointP( INK_DATA_PTR pData, int nStroke, int nPoint, float * pX, float * pY, int *pP );
    BOOL            INK_GetStrokePoint( INK_DATA_PTR pData, int nStroke, int nPoint, float * pX, float * pY );
	INK_DATA_PTR	INK_CreateCopy( INK_DATA_PTR pData );
	void			INK_SortInk( INK_DATA_PTR pData );
	void			INK_Undo( INK_DATA_PTR pData );
	void			INK_Redo( INK_DATA_PTR pData );
	BOOL			INK_CanRedo( INK_DATA_PTR pData );
	BOOL			INK_CanUndo( INK_DATA_PTR pData );
	BOOL			INK_SelectAllStrokes( INK_DATA_PTR pData, BOOL bSelect );
	BOOL			INK_DeleteSelectedStrokes( INK_DATA_PTR pData, BOOL bAll );
	void			INK_SetStrokesRecognizable( INK_DATA_PTR pData, BOOL bSet, BOOL bSelectedOnly );
	void			INK_SetStrokeRecognizable( INK_DATA_PTR pData, int nStroke, BOOL bSet );
	void			INK_SelectStroke( INK_DATA_PTR pData, int nStroke, BOOL bSelect );
	BOOL			INK_IsStrokeRecognizable( INK_DATA_PTR pData, int nStroke );
	BOOL			INK_IsStrokeSelected( INK_DATA_PTR pData, int nStroke );
	void			INK_SetUndoLevels( INK_DATA_PTR pData, int levels );
	int				INK_Serialize( INK_DATA_PTR pData, BOOL bWrite, FILE * pFile, void ** ppData, long * pcbSize, BOOL skipImages, BOOL savePressure );
	BOOL			INK_Paste( INK_DATA_PTR pData, const void * pRawData, long cbSize, CGPoint atPosition );
	BOOL			INK_Copy( INK_DATA_PTR pData, void ** ppRawData, long * pcbSize );
	BOOL			INK_MoveStroke( INK_DATA_PTR pData, int nStroke, float xOffset, float yOffset, CGRect * pRect, BOOL recordUndo );
	void			INK_ChangeSelZOrder( INK_DATA_PTR pData, int iDepth, BOOL bFwd );
	BOOL			INK_IsShapeRecognitionEnabled( INK_DATA_PTR pData );
	void			INK_EnableShapeRecognition( INK_DATA_PTR pData, BOOL bEnable );
	int				INK_FindStrokeByPoint( INK_DATA_PTR pData, CGPoint thePoint, float proximity );
	int				INK_SelectStrokesInRect( INK_DATA_PTR pData, CGRect selRect );
	void			INK_EmptyUndoBuffer( INK_DATA_PTR pData );
    BOOL             INK_CurveIntersectsStroke( INK_DATA_PTR pData, int nStroke, const CGStroke points, int nPointCount );
	BOOL			INK_SetStrokeWidthAndColor( INK_DATA_PTR pData, int nStroke, COLORREF color, float fWidth );
    int             INK_DeleteIntersectedStrokes( INK_DATA_PTR pData, const CGStroke points, int nPointCount );
	BOOL			INK_ResizeStroke( INK_DATA_PTR pData, int nStroke, float x0, float y0, float scalex, float scaley, BOOL bReset, CGRect * pRect, BOOL recordUndo );
    
    int             INK_GetStrokeZOrder( INK_DATA_PTR pData, int nStroke );
    BOOL            INK_SetStrokeZOrder( INK_DATA_PTR pData, int nStroke, int iZOrder );
	
	// image support
	int				INK_AddImage( INK_DATA_PTR pData, const ImageAttributes * pImage ); 
	int				INK_SetImage( INK_DATA_PTR pData, int nImageIndex, const ImageAttributes * pImage ); 
	BOOL			INK_SetImageUserData( INK_DATA_PTR pData, int nImageIndex, void * userData ); 
	BOOL			INK_DeleteImage( INK_DATA_PTR pData, int nImageIndex );
	BOOL			INK_GetImage( INK_DATA_PTR pData, int nImageIndex, ImageAttributes * pAttrib );
	int				INK_GetImageFromPoint( INK_DATA_PTR pData, CGPoint point, ImageAttributes * pAttrib );
	BOOL			INK_DeleteAllImages( INK_DATA_PTR pData );
	int				INK_CountImages( INK_DATA_PTR pData );
	BOOL			INK_SetImageFrame( INK_DATA_PTR pData, int nImageIndex, CGRect frame );

	// text support
	BOOL			INK_AddText( INK_DATA_PTR pData, const TextAttributes * pText ); 
	BOOL			INK_SetText( INK_DATA_PTR pData, int nTextIndex, const TextAttributes * pText ); 
	BOOL			INK_SetTextUserData( INK_DATA_PTR pData, int nTextIndex, void * userData ); 
	BOOL			INK_DeleteText( INK_DATA_PTR pData, int nTextIndex );
	BOOL			INK_GetText( INK_DATA_PTR pData, int nTextIndex, TextAttributes * pText );
	int				INK_GetTextFromPoint( INK_DATA_PTR pData, CGPoint point, TextAttributes * pText );
	BOOL			INK_DeleteAllTexts( INK_DATA_PTR pData, BOOL bRecordUndo );
	int				INK_CountTexts( INK_DATA_PTR pData );
	BOOL			INK_SetTextFrame( INK_DATA_PTR pData, int nTextIndex, CGRect frame );
	
#if defined(__cplusplus)
}
#endif

#endif
