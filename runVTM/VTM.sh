#!/bin/bash
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
    #  Filename       : VTM.sh
    #  Author         : Liu Chao
    #  Status         : phase 003
    #  Created        : 2021-11-15
    #  Description    : run encoding automatically
    #
#-------------------------------------------------------------------------------

#*** PARAMETER *****************************************************************
# directory or file name
CSTR_CDC=$1
CSTR_DIR_SRC="/home/share/VVC"    #REVERT_THIS_ITEM_BEFORE_YOU_COMMIT   E:\DOWNLOAD\SEQUENCE\HM
CSTR_DIR_DST="dump"                                       #REVERT_THIS_ITEM_BEFORE_YOU_COMMIT
CSTR_LOG_RUN="$CSTR_DIR_DST/runs.log"                     #REVERT_THIS_ITEM_BEFORE_YOU_COMMIT
CSTR_LOG_JOB="$CSTR_DIR_DST/jobs.log"                     #REVERT_THIS_ITEM_BEFORE_YOU_COMMIT
CSTR_LOG_RLT_PSNR="$CSTR_DIR_DST/result.log"              #REVERT_THIS_ITEM_BEFORE_YOU_COMMIT
CSTR_LOG_RLT_time="$CSTR_DIR_DST/result_time.log"         #REVERT_THIS_ITEM_BEFORE_YOU_COMMIT
CSTR_LOG_RLT_ENCT="$CSTR_DIR_DST/encTime.log"             #REVERT_THIS_ITEM_BEFORE_YOU_COMMIT
CSTR_LOG_RLT_BDRT="$CSTR_DIR_DST/bdRate.log"              #REVERT_THIS_ITEM_BEFORE_YOU_COMMIT

# sequence
#   name               frame fps width height depth
LIST_SEQ_AVAILABLE=(
    # A1
    "FoodMarket4"           501     60      3840    2160    10
    "Tango2"                501     60      3840    2160    10
    "Campfire"              501     30      3840    2160    10
    # A2
    "ParkRunning3"          501     50      3840    2160    10
    "CatRobot"              501     60      3840    2160    10
    "DaylightRoad2"         501     60      3840    2160    10
    # B
    "MarketPlace"           501     60      1920    1080    10
    "BasketballDrive"       501     50      1920    1080    8
    "BQTerrace"             501     60      1920    1080    8
    "Cactus"                501     50      1920    1080    8
    "RitualDance"           501     60      1920    1080    10
    # C
    "BasketballDrill"       501     50      832     480     8
    "BQMall"                501     60      832     480     8
    "PartyScene"            501     50      832     480     8
    "RaceHorsesC"           501     30      832     480     8
    # D
    "BasketballPass"        501     50      416     240     8
    "BlowingBubbles"        501     50      416     240     8
    "BQSquare"              501     60      416     240     8
    "RaceHorses"            501     30      416     240     8
    # E
    "FourPeople"            501     60      1280    720     8
    "Johnny"                501     60      1280    720     8
    "KristenAndSara"        501     60      1280    720     8
    # screen content
    "ArenaOfValor"          501     60      1920    1080    8
    "SlideEditing"          501     30      1280    720     8
    "SlideShow"             501     20      1280    720     8
    "BasketballDrillText"   501     50      832     480     8
)
LIST_SEQ=(
    # D
    "BasketballPass"        65     50      416     240     8
    "BlowingBubbles"        65     50      416     240     8
    "BQSquare"              65     60      416     240     8
    "RaceHorses"            65     30      416     240     8
    # C
    "BasketballDrill"       65      50      832     480     8
    "BQMall"                65      60      832     480     8
    "PartyScene"            65      50      832     480     8
    "RaceHorsesC"           65      30      832     480     8
    # E
    "FourPeople"            65     60      1280    720     8
    "Johnny"                65     60      1280    720     8
    "KristenAndSara"        65     60      1280    720     8
    # screen content
    "ArenaOfValor"          65     60      1920    1080    8
    "SlideEditing"          65     30      1280    720     8
    "SlideShow"             65     20      1280    720     8
    "BasketballDrillText"   65     50      832     480     8
    # B
    "MarketPlace"           65      60      1920    1080    10
    "BasketballDrive"       65      50      1920    1080    8
    "BQTerrace"             65      60      1920    1080    8
    "Cactus"                65      50      1920    1080    8
    "RitualDance"           65      60      1920    1080    10
    # A1
    "FoodMarket4"           65     60      3840    2160    10
    "Tango2"                65     60      3840    2160    10
    "Campfire"              65     30      3840    2160    10
    # A2
    "ParkRunning3"          65     50      3840    2160    10
    "CatRobot"              65     60      3840    2160    10
    "DaylightRoad2"         65     60      3840    2160    10
)

# encoder
LIST_DAT_Q_P=($(seq 22 5 37))                      #REVERT_THIS_ITEM_BEFORE_YOU_COMMIT
DATA_PRD_INTRA=-1                               #REVERT_THIS_ITEM_BEFORE_YOU_COMMIT


#*** MAIN BODY *****************************************************************
#--- INIT ------------------------------
# prepare directory
mkdir -p $CSTR_DIR_DST
rm -rf $CSTR_DIR_DST/*
rm -rf $CSTR_LOG_RLT_PSNR
rm -rf $CSTR_LOG_RLT_time
printf "%-15s %-13s\n" "encTime" "test_Sequence" >> $CSTR_LOG_RLT_time
printf "%-51s %-51s %-51s %s\n" "average" "I frame" "P frame" "B frame" >> $CSTR_LOG_RLT_PSNR
printf "%-13s \t%-7s \t%-7s \t%-7s \t"    "bitrate(kb/s)" "psnr(Y)"    "psnr(U)"    "psnr(V)"    >> $CSTR_LOG_RLT_PSNR
printf "%-13s \t%-7s \t%-7s \t%-7s \t"    "bitrate(kb/s)" "psnr(Y)"    "psnr(U)"    "psnr(V)"    >> $CSTR_LOG_RLT_PSNR
printf "%-13s \t%-7s \t%-7s \t%-7s \t"    "bitrate(kb/s)" "psnr(Y)"    "psnr(U)"    "psnr(V)"    >> $CSTR_LOG_RLT_PSNR
printf "%-13s \t%-7s \t%-7s \t%-7s\n"     "bitrate(kb/s)" "psnr(Y)"    "psnr(U)"    "psnr(V)"    >> $CSTR_LOG_RLT_PSNR
# note down the current time
timeBgnAll=$(date +%s)


#--- LOOP ------------------------------
#--- LOOP SEQUENCE ---
cntSeq=0
numSeq=${#LIST_SEQ[*]}
while [ $cntSeq -lt $numSeq ]
do
    # extract parameter
    CSTR_SEQ=${LIST_SEQ[$cntSeq]}; cntSeq=$((cntSeq + 1))
    NUMB_FRA=${LIST_SEQ[$cntSeq]}; cntSeq=$((cntSeq + 1))
    DATA_FPS=${LIST_SEQ[$cntSeq]}; cntSeq=$((cntSeq + 1))
    SIZE_FRA_X=${LIST_SEQ[$cntSeq]}; cntSeq=$((cntSeq + 1))
    SIZE_FRA_Y=${LIST_SEQ[$cntSeq]}; cntSeq=$((cntSeq + 1))
    DATA_PXL_WD=${LIST_SEQ[$cntSeq]}; cntSeq=$((cntSeq + 1))

    # derive parameter
    CSTR_SRC=$CSTR_DIR_SRC/$CSTR_SEQ/
    CSTR_SRC_YUV=$(ls $CSTR_DIR_SRC/$CSTR_SEQ)
    # set DATA_PRD_INTRA as CTC
    if [ ${DATA_FPS} == 20 ]
    then
        DATA_PRD_INTRA=32
    elif [ ${DATA_FPS} == 24 ]
    then
        DATA_PRD_INTRA=32
    elif [ ${DATA_FPS} == 30 ]
    then
        DATA_PRD_INTRA=32
    elif [ ${DATA_FPS} == 50 ]
    then
        DATA_PRD_INTRA=64
    elif [ ${DATA_FPS} == 60 ]
    then
        DATA_PRD_INTRA=64
    elif [ ${DATA_FPS} == 100 ]
    then
        DATA_PRD_INTRA=96
    else
        DATA_PRD_INTRA=32
    fi
    # log
    echo ""
    echo "encoding $CSTR_SRC ..."

    # note down the current time
    timeBgnCur=$(date +%s)

    #--- LOOP QP (ENCODE) ---
    cntQp=0
    numQp=${#LIST_DAT_Q_P[*]}
    while [ $cntQp -lt $numQp ]
    do
        # extract parameter
        DATA_Q_P=${LIST_DAT_Q_P[ $((cntQp + 0)) ]}; cntQp=$((cntQp + 1))

        # derive parameter
        CSTR_DIR_SUB=${CSTR_SEQ}_${DATA_Q_P}
        CSTR_DIR_DST_FUL=$CSTR_DIR_DST/$CSTR_DIR_SUB/

        # log
        echo "    qp $DATA_Q_P launched ..."

        # make directory
        mkdir -p $CSTR_DIR_DST_FUL

        # encode (gop, common)
        ./${CSTR_CDC}                                                 \
                                                                      \
            -c                  cfg/encoder_randomaccess_vtm.cfg      \
                    --InputFile=${CSTR_SRC}/${CSTR_SRC_YUV}           \
            --FramesToBeEncoded=${NUMB_FRA}                           \
                  --SourceWidth=${SIZE_FRA_X}                         \
                 --SourceHeight=${SIZE_FRA_Y}                         \
            --InputChromaFormat=420                                   \
                --InputBitDepth=${DATA_PXL_WD}                        \
                    --FrameRate=${DATA_FPS}                           \
                           --QP=${DATA_Q_P}                           \
                  --IntraPeriod=$((DATA_PRD_INTRA    ))               \
                --BitstreamFile=${CSTR_DIR_DST_FUL}${CSTR_CDC}.bin    \
                                                                      \
        >& ${CSTR_DIR_DST_FUL}${CSTR_CDC}.log &
    done

    # wait
    numJob=1
    while [ $numJob -ne 0 ]
    do
        sleep 1
        timeEnd=$(date +%s)
        printf "    delta time: %d min %d s; run time: %d min %d s (jobs: %d)        \r"    \
            $(((timeEnd-timeBgnCur) / 60                        ))                          \
            $(((timeEnd-timeBgnCur) - (timeEnd-timeBgnCur)/60*60))                          \
            $(((timeEnd-timeBgnAll) / 60                        ))                          \
            $(((timeEnd-timeBgnAll) - (timeEnd-timeBgnAll)/60*60))                          \
            $(jobs | wc -l)
        jobs > $CSTR_LOG_JOB
        numJob=$(cat $CSTR_LOG_JOB | wc -l)
    done
    rm $CSTR_LOG_JOB
    timeEnd=$(date +%s)
    printf "    delta time: %d min %d s; run time: %d min %d s                   \n"    \
        $(((timeEnd-timeBgnCur) / 60                        ))                          \
        $(((timeEnd-timeBgnCur) - (timeEnd-timeBgnCur)/60*60))                          \
        $(((timeEnd-timeBgnAll) / 60                        ))                          \
        $(((timeEnd-timeBgnAll) - (timeEnd-timeBgnAll)/60*60))

    #--- LOOP QP (CHECK) ---
    cntQp=0
    numQp=${#LIST_DAT_Q_P[*]}
    while [ $cntQp -lt $numQp ]
    do
        # extract parameter
        DATA_Q_P=${LIST_DAT_Q_P[ $((cntQp + 0)) ]}; cntQp=$((cntQp + 1))
        CSTR_DIR_SUB=${CSTR_SEQ}_${DATA_Q_P}
        CSTR_DIR_DST_FUL=$CSTR_DIR_DST/$CSTR_DIR_SUB/

        # calculate md5
        md5sum ${CSTR_DIR_DST_FUL}${CSTR_CDC}.bin | tee -a $CSTR_LOG_RUN

        # update info (psnr)
        chmod +x ./script/getInfo.py && ./script/getInfo.py ${CSTR_DIR_DST_FUL}${CSTR_CDC}.log >> $CSTR_LOG_RLT_PSNR
        echo "$CSTR_DIR_SUB" >> $CSTR_LOG_RLT_PSNR

        # process time
        # ./script/getTime.py ${CSTR_DIR_DST_FUL}${CSTR_CDC}.log >> $CSTR_LOG_RLT_time
        echo "$CSTR_DIR_SUB" >> $CSTR_LOG_RLT_time
    done

    # update bd rate
    # chmod +x ./script/getBdRate.py  && ./script/getBdRate.py script/anchor.log $CSTR_LOG_RLT_PSNR > $CSTR_LOG_RLT_BDRT
    # uodate enc time
    # chmod +x ./script/getEncTime.py && ./script/getEncTime.py script/anchor_time.log  $CSTR_LOG_RLT_time > $CSTR_LOG_RLT_ENCT
done
