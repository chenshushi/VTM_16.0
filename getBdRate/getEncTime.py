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
    #  Filename       : getEncTime.py
    #  Author         : ChenSS
    #  Status         : phase 003
    #  Reset          : 2022-4-29
    #  Description    : calculate EncTime
    #
#-------------------------------------------------------------------------------

#*** IMPORT ********************************************************************
import sys
import re
import numpy as np
from getBdRateCore import getBdRateCore


#*** FUNCTION ******************************************************************
# getDat
def getDat(fpt):
    # main body
    datFul = {}
    idx_line = 0
    for strLineCur in fpt:
        # cal idx_line
        idx_line = idx_line + 1
        if idx_line == 1:
            continue
        # get info
        [strDat, strSeq] = strLineCur.split()
        [strSeq, strQp] = strSeq.split(sep = "_")
        datQp = int(strQp)
        # print(strDat,strSeq,strQp)
        # create seq key
        if not strSeq in datFul:
            datFul[strSeq] = {}
        # create qp key
        if not datQp in datFul[strSeq]:
            datFul[strSeq][datQp] = {}
        # set data
        datFul[strSeq][datQp] = float(strDat) # round((float (datFul[strSeq]) + float(strDat)),2)
    # print(datFul)

    # close
    fpt.close()

    # return
    return datFul


#*** MAIN **********************************************************************
if __name__ == '__main__':
#--- PARAMTER PREPARATION --------------
    # strings
    CSTR_TYPE     = ("anchor(s)", "testor(s)", "timeSave(%)", "sequence")
    # CSTR_INFO_BFR = ("bitrate(kb/s)", "psnr(Y)", "psnr(U)", "psnr(V)")
    # CSTR_INFO_AFT = ("bdrate(Y)", "bdrate(U)", "bdrate(V)", "bdrate(average)")
    CSTR_USAGE    = "\n[getEncTime.py] Usage: getEncTime.py anchor_time.log testor_time.log [YUV420|YUV444] > bdRate.log\n"

    # open anchor
    try:
        fptAnchor = open(sys.argv[1], "r")
    except:
        assert False, "\n[getEncTime.py] CANNOT open the anchor!" + CSTR_USAGE

    # open testor
    try:
        fptTestor = open(sys.argv[2], "r")
    except:
        assert False, "\n[getEncTime.py] CANNOT open the testor!" + CSTR_USAGE

    # check redundant parameter
    if len(sys.argv) > 3:
        assert False, "\n[getEncTime.py] unknown parameter \"{:s}\"\n".format(sys.argv[4]) + CSTR_USAGE


#--- DATA PREPARATION ------------------
    # get anchor data
    datAnchor = getDat(fptAnchor)

    # get testor data
    datTestor = getDat(fptTestor)


#--- DATA PROCESS ----------------------
    # head
    print("{:<13s} {:<13s} {:<13s} {:s}".format(*CSTR_TYPE))
    # body
    timeSaveArray = []
    # for sequence
    for strSeq in datAnchor:
        timeSave = 0
        for strQp in datAnchor[strSeq]:
            timeSave = timeSave + round(-100 * (datAnchor[strSeq][strQp] - datTestor[strSeq][strQp]) / datAnchor[strSeq][strQp], 3 )
        timeSave = round(timeSave/4,3)
        timeSaveArray.append(timeSave)
        print("{:<13s} {:<13s} {:<13s} {:s}".format(str(datAnchor[strSeq][strQp]),str(datTestor[strSeq][strQp]),str(timeSave),strSeq))
    timeSaveArray = np.array(timeSaveArray)
    # get MAX MIN and AVERAGE result
    print("\n                TIME SAVE (%)")
    print("  \"-\" means decrease and \"+\" means increase")
    print("===============================================")
    print("{:<19s} {:<19s} {:s}".format("    MAX","MIN","AVE"))
    print("-----------------------------------------------")
    print("{:<15s} {:<21s} {:s}".format("  "+ str(np.min(timeSaveArray)),"  " + str(np.max(timeSaveArray)),str(np.mean(timeSaveArray))))
    print("===============================================")
