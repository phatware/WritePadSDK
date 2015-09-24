/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                           * */
/* ************************************************************************************* */

/* ************************************************************************************* *
 *
 * Unauthorized distribution of this code is prohibited. For more information
 * refer to the End User Software License Agreement provided with this 
 * software.
 *
 * This source code is distributed and supported by PhatWare Corp.
 * http://www.phatware.com
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
 * 530 Showers Drive Suite 7 #333 Mountain View, CA 94040
 *
 * ************************************************************************************* */

using System;
using Windows.Foundation;
using Windows.UI.Xaml.Media;

namespace WritePad_CSharpSample.SDK
{
    public class PixelAdder
    {
        private const int SEGMENT2 = 2;
        private const int SEGMENT3 = 3;
        private const int SEGMENT4 = 4;

        private const int SEGMENT_DIST_1 = 3;
        private const int SEGMENT_DIST_2 = 6;
        private const int SEGMENT_DIST_3 = 12;

        private static Point _previousLocation;
        /// <summary>
        /// Add a new point to points collection (representing a stroke), keeping the whole stroke antialiased.
        /// </summary>
        /// <param name="x">X point coordinate</param>
        /// <param name="y">Y point coordinate</param>
        /// <param name="isLastPoint">Set to true when adding last point of the stroke</param>
        /// <param name="points">Stroke to which the point is added</param>
        /// <returns></returns>
        public static int AddPixels(double x, double y, bool isLastPoint, ref PointCollection points)
        {
            double    xNew;
            double    yNew;
            double    x1;
            double    y1;
            float    nSeg;
    
            if  ( points.Count == 0 )
            {
                points.Add(new Point(x, y));
                _previousLocation.X = x;
                _previousLocation.Y = y;
                return  1;
            }
    
            var dx = Math.Abs( x - points[points.Count-1].X );
            var dy = Math.Abs( y - points[points.Count-1].Y );
    
            if  ( dx + dy < 2.0f )
                return 0;
    
            if ( dx + dy > 100.0f * SEGMENT_DIST_2 )
                return 0;
    
            if  ( (dx + dy) < SEGMENT_DIST_1 )
            {
                points.Add(new Point(x, y));

                _previousLocation.X = x;
                _previousLocation.Y = y;
                return  1;
            }
    
            if ( (dx + dy) < SEGMENT_DIST_2 )
                nSeg = SEGMENT2;
            else if ( (dx + dy) >= SEGMENT_DIST_3 )
                nSeg = SEGMENT4;
            else
               nSeg = SEGMENT3;
            int     nPoints = 0;
            double EPSILON = 0.0001;
            for (var i = 1; i < nSeg; i++)
            {
                x1 = _previousLocation.X + ((x - _previousLocation.X)*i ) / nSeg;  //the point "to look at"
                y1 = _previousLocation.Y + ((y - _previousLocation.Y)*i ) / nSeg;  //the point "to look at"
       
                xNew = points[points.Count-1].X + (x1 - points[points.Count-1].X) / nSeg;
                yNew = points[points.Count-1].Y + (y1 - points[points.Count-1].Y) / nSeg;

                if ( Math.Abs(xNew - points[points.Count-1].X) > EPSILON || Math.Abs(yNew - points[points.Count-1].Y) > EPSILON )
                {
                    points.Add(new Point(xNew, yNew));
                    nPoints++;
                }
            }
    
            if ( isLastPoint )
            {
                // add last point
                if (Math.Abs(x - points[points.Count - 1].X) > EPSILON || Math.Abs(y - points[points.Count - 1].Y) > EPSILON)
                {
                    points.Add(new Point(x, y));
                    nPoints++;
                }
            }
    
            _previousLocation.X = x;
            _previousLocation.Y = y;
            return nPoints;
        }
    }
}
