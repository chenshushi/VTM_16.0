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
    #  Filename       : getTime.py
    #  Author         : ChenSS
    #  Created        : 2022-04-29
    #  Description    : get enc time
    #
#-------------------------------------------------------------------------------

#*** IMPORT ********************************************************************
import sys

#*** MAIN **********************************************************************
if __name__ == '__main__':
    #--- PARAMTER PREPARATION --------------
    # strings
    CSTR_USAGE = "\n[getTime.py] Usage: getTime.py VTM.log >> time.log\n"

    # open log
    try:
        fptLog = open(sys.argv[1], "r")
    except:
        assert False, "\n[getTime.py] CANNOT open the log!" + CSTR_USAGE

    # variables
    #          sec
    encTime  = 0

    # main body
    for strLine in fptLog:
        # split
        strWords = strLine.split()
        #get encTime
        if 'Time:' in strWords:
            encTime = float(strWords[2])
    # print
    print("{:<13.2f} \t".
        format(
            encTime
        ),
        end=""
    )
