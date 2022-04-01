#!/usr/bin/python3
#-------------------------------------------------------------------------------
    #
    #  The confidential and proprietary information contained in this file may
    #  only be used by a person authorised under and to the extent permitted
    #  by a subsisting licensing agreement from XK Silicon.
    #
    #                   (C) COPYRIGHT 2020 XK Silicon.
    #                       ALL RIGHTS RESERVED
    #
    #  This entire notice must be reproduced on all copies of this file
    #  and copies of this file may only be made by a person if such person is
    #  permitted to do so under the terms of a subsisting license agreement
    #  from XK Silicon.
    #
    #  Revision       : 112933
    #  Release        : XK265
    #
#-------------------------------------------------------------------------------
    #
    #  Filename       : getInfo.py
    #  Author         : Huang Leilei
    #  Status         : phase 003
    #  Created        : 2021-11-04
    #  Description    : get information psnr and bit rate
    #
#-------------------------------------------------------------------------------

#*** IMPORT ********************************************************************
import sys


#*** MAIN **********************************************************************
if __name__ == '__main__':
#--- PARAMTER PREPARATION --------------
    # strings
    CSTR_USAGE = "\n[getBdRate.py] Usage: getInfo.py VVenC.log >> result.log\n"

    # open log
    try:
        fptLog = open(sys.argv[1], "r")
    except:
        assert False, "\n[getInfo.py] CANNOT open the log!" + CSTR_USAGE

    # variables
    #           a, i, p, b
    datPsnrY = [0, 0, 0, 0]
    datPsnrU = [0, 0, 0, 0]
    datPsnrV = [0, 0, 0, 0]
    datBtRt  = [0, 0, 0, 0]
    cnt      = [0, 0, 0, 0]

    # main body
    for strLine in fptLog:
        # split
        strWords = strLine.split()

        # note down type
        if   'bits' in strWords and 'I-SLICE,' in strWords:
            idxTyp = 1
        elif 'bits' in strWords and 'P-SLICE,' in strWords:
            idxTyp = 2
        elif 'bits' in strWords and 'B-SLICE,' in strWords:
            idxTyp = 3

        # note down data
        if 'bits' in strWords:
            datPsnrY[0     ] += float(strWords[15])
            datPsnrU[0     ] += float(strWords[18])
            datPsnrV[0     ] += float(strWords[21])
            datBtRt [0     ] += float(strWords[12])
            cnt     [0     ] += 1
            datPsnrY[idxTyp] += float(strWords[15])
            datPsnrU[idxTyp] += float(strWords[18])
            datPsnrV[idxTyp] += float(strWords[21])
            datBtRt [idxTyp] += float(strWords[12])
            cnt     [idxTyp] += 1

    # print
    for idx in range(0, 4):
        # !!! hack code: add to avoid zero dividing
        if cnt[idx] == 0:
            cnt[idx] = 1
        print("{:<13.2f} \t{:<7.3f} \t{:<7.3f} \t{:<7.3f} \t".
            format(
                datBtRt[idx] * 60 / cnt[idx] / 1000,
                datPsnrY[idx] / cnt[idx],
                datPsnrU[idx] / cnt[idx],
                datPsnrV[idx] / cnt[idx]
            ),
            end=""
        )
