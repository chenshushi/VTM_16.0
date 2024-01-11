/* The copyright in this software is being made available under the BSD
 * License, included below. This software may be subject to other third party
 * and contributor rights, including patent rights, and no such rights are
 * granted under this license.
 *
 * Copyright (c) 2010-2022, ITU/ISO/IEC
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *  * Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *  * Neither the name of the ITU/ISO/IEC nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

/**
 * \file
 * \brief Implementation of AffineGradientSearch class
 */

// ====================================================================================================================
// Includes
// ====================================================================================================================

#include "AffineGradientSearch.h"
#include <cmath>
//---------------------------
#define Scharr                1
#define sobel_5x5             0
#define Sobel_141             0
//---------------------------
#define Gauss_Pre_Filter      0
//---------------------------
#define Iter                  0
//---------------------------
#define Res_3sigma            0
//---------------------------
#define Aff_Weight            1
#define Aff_Weight_Laplace_sub            0
//---------------------------
//! \ingroup CommonLib
//! \{

// ====================================================================================================================
// Private member functions
// ====================================================================================================================

AffineGradientSearch::AffineGradientSearch()
{
  m_HorizontalSobelFilter = xHorizontalSobelFilter;
  m_VerticalSobelFilter = xVerticalSobelFilter;
  m_EqualCoeffComputer = xEqualCoeffComputer;

#if ENABLE_SIMD_OPT_AFFINE_ME
#ifdef TARGET_SIMD_X86
  initAffineGradientSearchX86();
#endif
#endif
}

void AffineGradientSearch::xHorizontalSobelFilter( Pel *const pPred, const int predStride, int *const pDerivate, const int derivateBufStride, const int width, const int height )
{
  for ( int j = 1; j < height - 1; j++ )
  {
    for ( int k = 1; k < width - 1; k++ )
    {
      int iCenter = j * predStride + k;

      #if Scharr
      pDerivate[j * derivateBufStride + k] =
        ( 3 * (pPred[iCenter + 1 - predStride] - pPred[iCenter - 1 - predStride]) +
         10 * (pPred[iCenter + 1]              - pPred[iCenter - 1])              +
          3 *( pPred[iCenter + 1 + predStride] - pPred[iCenter - 1 + predStride]) )/5;
      
      #elif sobel_5x5
        if ( ((2 < j) || (j  < (height - 2))) && ( (2 < k) || (k < (width -2))) ){
            pDerivate[j * derivateBufStride + k] =
                (( 2 *( pPred[iCenter - 2*predStride - 1 ] - pPred[iCenter - 2*predStride + 1 ]))  +   (1 *( pPred[iCenter - 2*predStride - 2 ] - pPred[iCenter - 2*predStride + 2 ]))
              + ( 8 *( pPred[iCenter - 1*predStride - 1 ] - pPred[iCenter - 1*predStride + 1 ]))  +   (4 *( pPred[iCenter - 1*predStride - 2 ] - pPred[iCenter - 1*predStride + 2 ]))
              + (12 *( pPred[iCenter - 0*predStride - 1 ] - pPred[iCenter - 0*predStride + 1 ]))  +   (6 *( pPred[iCenter - 0*predStride - 2 ] - pPred[iCenter - 0*predStride + 2 ]))
              + ( 8 *( pPred[iCenter + 1*predStride - 1 ] - pPred[iCenter + 1*predStride + 1 ]))  +   (4 *( pPred[iCenter + 1*predStride - 2 ] - pPred[iCenter + 1*predStride + 2 ]))
              + ( 2 *( pPred[iCenter + 2*predStride - 1 ] - pPred[iCenter + 2*predStride + 1 ]))  +   (1 *( pPred[iCenter + 2*predStride - 2 ] - pPred[iCenter + 2*predStride + 2 ]))
                )/6;

        }
        else {
        pDerivate[j * derivateBufStride + k] =
          (pPred[iCenter + 1 - predStride] -
            pPred[iCenter - 1 - predStride] +
            (pPred[iCenter + 1] << 1) -
            (pPred[iCenter - 1] << 1) +
            pPred[iCenter + 1 + predStride] -
            pPred[iCenter - 1 + predStride]);
        }
      #elif  Sobel_141
             pDerivate[j * derivateBufStride + k] =
            (pPred[iCenter + 1 - predStride] -
              pPred[iCenter - 1 - predStride] +
              (pPred[iCenter + 1] *4) -
              (pPred[iCenter - 1] *4) +
              pPred[iCenter + 1 + predStride] -
              pPred[iCenter - 1 + predStride]);
        #else
          pDerivate[j * derivateBufStride + k] =
            (pPred[iCenter + 1 - predStride] -
              pPred[iCenter - 1 - predStride] +
              (pPred[iCenter + 1] << 1) -
              (pPred[iCenter - 1] << 1) +
              pPred[iCenter + 1 + predStride] -
              pPred[iCenter - 1 + predStride]);
        #endif
        

    }

    pDerivate[j * derivateBufStride] = pDerivate[j * derivateBufStride + 1];
    pDerivate[j * derivateBufStride + width - 1] = pDerivate[j * derivateBufStride + width - 2];
  }

  pDerivate[0] = pDerivate[derivateBufStride + 1];
  pDerivate[width - 1] = pDerivate[derivateBufStride + width - 2];
  pDerivate[(height - 1) * derivateBufStride] = pDerivate[(height - 2) * derivateBufStride + 1];
  pDerivate[(height - 1) * derivateBufStride + width - 1] = pDerivate[(height - 2) * derivateBufStride + (width - 2)];

  for ( int j = 1; j < width - 1; j++ )
  {
    pDerivate[j] = pDerivate[derivateBufStride + j];
    pDerivate[(height - 1) * derivateBufStride + j] = pDerivate[(height - 2) * derivateBufStride + j];
  }
}

void AffineGradientSearch::xVerticalSobelFilter( Pel *const pPred, const int predStride, int *const pDerivate, const int derivateBufStride, const int width, const int height )
{
  for ( int k = 1; k < width - 1; k++ )
  {
    for ( int j = 1; j < height - 1; j++ )
    {
      int iCenter = j * predStride + k;

      #if Scharr
      pDerivate[j * derivateBufStride + k] =
        (3 * (pPred[iCenter + predStride - 1] - pPred[iCenter - predStride - 1]) +
         10* (pPred[iCenter + predStride]     - pPred[iCenter - predStride]    ) +
         3 * (pPred[iCenter + predStride + 1] - pPred[iCenter - predStride + 1]) )/5;
      #elif sobel_5x5
        if ( ((2 < j) || (j  < (height - 2))) && ( (2 < k) || (k < (width -2))) ){
            pDerivate[j * derivateBufStride + k] =
              (  1 * pPred[iCenter - 2*predStride - 2 ] + 4 * pPred[iCenter - 2*predStride - 1 ] + 6 * pPred[iCenter - 2*predStride + 0 ] + 4 * pPred[iCenter - 2*predStride + 1 ] + 1 * pPred[iCenter - 2*predStride + 2 ]
              +  2 * pPred[iCenter - 1*predStride - 2 ] + 8 * pPred[iCenter - 1*predStride - 1 ] +12 * pPred[iCenter - 1*predStride + 0 ] + 8 * pPred[iCenter - 1*predStride + 1 ] + 2 * pPred[iCenter - 1*predStride + 2 ]
              +  0 * pPred[iCenter - 0*predStride - 2 ] + 0 * pPred[iCenter - 0*predStride - 1 ] + 0 * pPred[iCenter - 0*predStride + 0 ] + 0 * pPred[iCenter - 0*predStride + 1 ] + 0 * pPred[iCenter - 0*predStride + 2 ]
              -  2 * pPred[iCenter + 1*predStride - 2 ] - 8 * pPred[iCenter + 1*predStride - 1 ] -12 * pPred[iCenter + 1*predStride + 0 ] - 8 * pPred[iCenter + 1*predStride + 1 ] - 2 * pPred[iCenter + 1*predStride + 2 ]
              -  1 * pPred[iCenter + 2*predStride - 2 ] - 4 * pPred[iCenter + 2*predStride - 1 ] - 6 * pPred[iCenter + 2*predStride + 0 ] - 4 * pPred[iCenter + 2*predStride + 1 ] - 1 * pPred[iCenter + 2*predStride + 2 ]
                )/6;
          }
          else {
        pDerivate[j * derivateBufStride + k] =
          (pPred[iCenter + predStride - 1] -
            pPred[iCenter - predStride - 1] +
            (pPred[iCenter + predStride] << 1) -
            (pPred[iCenter - predStride] << 1) +
            pPred[iCenter + predStride + 1] -
            pPred[iCenter - predStride + 1]);
          }
        #elif  Sobel_141
          pDerivate[j * derivateBufStride + k] =
            (pPred[iCenter + predStride - 1] -
              pPred[iCenter - predStride - 1] +
              (pPred[iCenter + predStride] *4) -
              (pPred[iCenter - predStride] *4) +
              pPred[iCenter + predStride + 1] -
              pPred[iCenter - predStride + 1]);
        #else
          pDerivate[j * derivateBufStride + k] =
            (pPred[iCenter + predStride - 1] -
              pPred[iCenter - predStride - 1] +
              (pPred[iCenter + predStride] << 1) -
              (pPred[iCenter - predStride] << 1) +
              pPred[iCenter + predStride + 1] -
              pPred[iCenter - predStride + 1]);
        #endif
    }

    pDerivate[k] = pDerivate[derivateBufStride + k];
    pDerivate[(height - 1) * derivateBufStride + k] = pDerivate[(height - 2) * derivateBufStride + k];
  }

  pDerivate[0] = pDerivate[derivateBufStride + 1];
  pDerivate[width - 1] = pDerivate[derivateBufStride + width - 2];
  pDerivate[(height - 1) * derivateBufStride] = pDerivate[(height - 2) * derivateBufStride + 1];
  pDerivate[(height - 1) * derivateBufStride + width - 1] = pDerivate[(height - 2) * derivateBufStride + (width - 2)];

  for ( int j = 1; j < height - 1; j++ )
  {
    pDerivate[j * derivateBufStride] = pDerivate[j * derivateBufStride + 1];
    pDerivate[j * derivateBufStride + width - 1] = pDerivate[j * derivateBufStride + width - 2];
  }
}

void AffineGradientSearch::xEqualCoeffComputer( Pel *pResidue, int residueStride, int **ppDerivate, int derivateBufStride, int64_t( *pEqualCoeff )[7], int width, int height, bool b6Param )
{
  int affineParamNum = b6Param ? 6 : 4;
  int mean = 0;
  int Variance = 0;
  for (int j = 0; j != height; j++){
    for( int k = 0; k != width; k++ ){
      int idx = j * derivateBufStride + k;
      mean += pResidue[idx];
    }
  }
  mean = mean/(height*width);

  for (int j = 0; j != height; j++){
    for( int k = 0; k != width; k++ ){
      int idx = j * derivateBufStride + k;
      Variance += (pResidue[idx] - mean) * (pResidue[idx] - mean);
    }
  }
  Variance = sqrt(Variance/(height*width));

  for ( int j = 0; j != height; j++ )
  {
    int cy = ((j >> 2) << 2) + 2;
    for ( int k = 0; k != width; k++ )
    {
      int iC[6];

      int idx = j * derivateBufStride + k;
      #if Res_3sigma 
      if (pResidue[idx] > (mean + 3*Variance) || pResidue[idx] < (mean - 3*Variance)  ) {
        break;
      }
      #endif
      int cx = ((k >> 2) << 2) + 2;
      if ( !b6Param )
      {
        iC[0] = ppDerivate[0][idx];
        iC[1] = cx * ppDerivate[0][idx] + cy * ppDerivate[1][idx];
        iC[2] = ppDerivate[1][idx];
        iC[3] = cy * ppDerivate[0][idx] - cx * ppDerivate[1][idx];
      }
      else
      {
        iC[0] = ppDerivate[0][idx];
        iC[1] = cx * ppDerivate[0][idx];
        iC[2] = ppDerivate[1][idx];
        iC[3] = cx * ppDerivate[1][idx];
        iC[4] = cy * ppDerivate[0][idx];
        iC[5] = cy * ppDerivate[1][idx];
      }
      #if Aff_Weight
      // double laplace_numerator    = sqrt((j - height / 2) * (j - height / 2) + (k - width / 2) * (k - width / 2));
      // double laplace_denominator  = sqrt(height * width);
      // double laplace_weight       = exp(-laplace_numerator / laplace_denominator);
      //-------------------------------Scharr_weight1-----------------------------
            // double laplace_numerator ;
      // if (!b6Param) {
      //   laplace_numerator    = sqrt(j*j + k*k)
      //                        + sqrt(j*j + (k - width) * (k - width ));
      // }
      // else {
      //   laplace_numerator    = sqrt(j*j + k*k)
      //                        + sqrt(j*j + (k - width) * (k - width ))
      //                        + sqrt((j - height ) * (j - height) +  k*k);
      // }
      // double laplace_denominator  = sqrt(height * width);
      // double laplace_weight       = exp(-laplace_numerator / laplace_denominator);
      //----------------------------Scharr_weight2-------------------------------------
      // double laplace_numerator ;
      // if (!b6Param) {
      //   laplace_numerator    = sqrt(j*j + k*k)
      //                        + sqrt(j*j + (k - width) * (k - width ));
      // }
      // else {
      //   laplace_numerator    = sqrt(j*j + k*k)
      //                        + sqrt(j*j + (k - width) * (k - width ))
      //                        + sqrt((j - height ) * (j - height) +  k*k);
      // }
      // double laplace_denominator  = 2 * sqrt(height * width);
      // double laplace_weight       = exp(-laplace_numerator / laplace_denominator);
      //----------------------------Scharr_weight3-------------------------------------
      // double laplace_weight       = 1 / laplace_numerator;
      //---------------------Test_Scahrr_Weight_blk_laplace--------------------------------------------
      double Weight_base = 1/(height*width)*(4*4);
      double laplace_numerator    = sqrt((j -cy) * (j - cy) + (k - cx) * (k - cx));
      double laplace_denominator  = sqrt(4 * 4);
      double laplace_weight       = Weight_base * exp(-laplace_numerator / laplace_denominator);
      //-----------------------------------------------------------------
      if (cy == j && cx == k) {
        laplace_weight = 1.0;
      }
      for ( int col = 0; col < affineParamNum; col++ )
      {
        for ( int row = 0; row < affineParamNum; row++ )
        {
          pEqualCoeff[col + 1][row] += (int64_t)iC[col] * iC[row]* int(laplace_weight * 100);
        }
        pEqualCoeff[col + 1][affineParamNum] += ((int64_t)iC[col] * pResidue[idx]* int(laplace_weight * 100)) << 3;
      }
      #elif Aff_Weight_Laplace_sub
        double laplace_numerator    = sqrt((cy - height / 2) * (cy - height / 2) + (cx - width / 2) * (cx - width / 2));
        double laplace_denominator  = sqrt(height * width);
        double laplace_weight       = exp(-laplace_numerator / laplace_denominator);
        for ( int col = 0; col < affineParamNum; col++ )
        {
          for ( int row = 0; row < affineParamNum; row++ )
          {
            pEqualCoeff[col + 1][row] += (int64_t)iC[col] * iC[row]* int(laplace_weight * 100);
          }
          pEqualCoeff[col + 1][affineParamNum] += ((int64_t)iC[col] * pResidue[idx]* int(laplace_weight * 100)) << 3;
        }
      #else
      for ( int col = 0; col < affineParamNum; col++ )
      {
        for ( int row = 0; row < affineParamNum; row++ )
        {
          pEqualCoeff[col + 1][row] += (int64_t)iC[col] * iC[row];
        }
        pEqualCoeff[col + 1][affineParamNum] += ((int64_t)iC[col] * pResidue[idx]) << 3;
      }
      #endif
    }
  }
}


//! \}
