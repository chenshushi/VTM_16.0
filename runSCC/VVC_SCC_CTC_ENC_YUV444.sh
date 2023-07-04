#!/bin/bash
#-------------------------------------------------------------------------------
    #
    #  Revision       : 20.2
    #  Release        : VTM
    #
#-------------------------------------------------------------------------------
    #
    #  Filename       : VTM.sh
    #  Author         : HeChenlong
    #  Status         : phase 000
    #  Reset          : 2022-9-15
    #  Description    : run encoding automatically
    #
#-------------------------------------------------------------------------------

#*** PARAMETER *****************************************************************
# directory or file name
CSTR_CDC="VVC_CTC_ENC"
CSTR_DIR_ORI="/home/share/SCC_CTC/YUV444" 
CSTR_DIR_SRC="/home/share/SCC_CTC/YUV444"                 #REVERT_THIS_ITEM_BEFORE_YOU_COMMIT
CSTR_DIR_DST="dump"                                       #REVERT_THIS_ITEM_BEFORE_YOU_COMMIT
CSTR_LOG_RUN="$CSTR_DIR_DST/runs.log"                     #REVERT_THIS_ITEM_BEFORE_YOU_COMMIT
CSTR_LOG_JOB="$CSTR_DIR_DST/jobs.log"                     #REVERT_THIS_ITEM_BEFORE_YOU_COMMIT
CSTR_LOG_RLT_FFMPEG="$CSTR_DIR_DST/ffmpeg_result.log"     #REVERT_THIS_ITEM_BEFORE_YOU_COMMIT
CSTR_LOG_RLT_PSNR="$CSTR_DIR_DST/vtm_psnr_result.log"     #REVERT_THIS_ITEM_BEFORE_YOU_COMMIT
CSTR_LOG_RLT_SSIM="$CSTR_DIR_DST/vtm_ssim_result.log"     #REVERT_THIS_ITEM_BEFORE_YOU_COMMIT
CSTR_LOG_RLT_BDRT="$CSTR_DIR_DST/bdRate.log"              #REVERT_THIS_ITEM_BEFORE_YOU_COMMIT
CSTR_CFG="randomaccess" 

# sequence
#   name               class  name                   frame  fps   width   height   depth  ai     ra     ld
LIST_SEQ_AVAILABLE=(
                       "F"    "Map"                   600   60    1280    720      8      "M"     "M"    "M"
                       "F"    "Programming"           600   60    1280    720      8      "M"     "M"    "M"
                       "F"    "Robot"                 300   30    1280    720      8      "M"     "M"    "M"
                       "F"    "SlideShow"             500   20    1280    720      8      "M"     "M"    "M"
                       "F"    "WebBrowsing"           300   30    1280    720      8      "M"     "M"    "M"
                       "F"    "RainFruits"            250   50    1920    1080     10     "M"     "M"    "M"
                       "F"    "Kimono"                120   24    1920    1080     10     "M"     "M"    "M"
                       "F"    "Console"               600   60    1920    1080     8      "M"     "M"    "M"
                       "F"    "Desktop"               600   60    1920    1080     8      "M"     "M"    "M"
                       "F"    "FlyingGraphics"        300   60    1920    1080     8      "M"     "M"    "M"
                       "F"    "MissionControl3"       600   60    1920    1080     8      "M"     "M"    "M"
                       "F"    "ArenaOfValor"          300   60    1920    1080     8      "M"     "M"    "M"
                       "F"    "ChineseEditing"        622   60    1920    1080     8      "M"     "M"    "M"
                       "F"    "MissionControl2"       420   60    2560    1440     8      "M"     "M"    "M"
                       "F"    "BasketballScreen"      622   60    2560    1440     8      "M"     "M"    "M"
                       "F"    "GlassHalf"             300   24    3840    2160     10     "M"     "M"    "M"
)
LIST_SEQ_USED=(
                       "F"    "FlyingGraphics"        64   60    1920    1080     8      "M"     "M"    "M"
                       "F"    "Desktop"               64   60    1920    1080     8      "M"     "M"    "M"
                       "F"    "Console"               64   60    1920    1080     8      "M"     "M"    "M"
                       "F"    "ChineseEditing"        64   60    1920    1080     8      "M"     "M"    "M"
                       "F"    "WebBrowsing"           64   30    1280    720      8      "M"     "M"    "M"
                       "F"    "Map"                   64   60    1280    720      8      "M"     "M"    "M"
                       "F"    "Programming"           64   60    1280    720      8      "M"     "M"    "M"
                       "F"    "SlideShow"             64   20    1280    720      8      "M"     "M"    "M"
                       "F"    "ArenaOfValor"          64   60    1920    1080     8      "M"     "M"    "M"
                       "F"    "Robot"                 64   30    1280    720      8      "M"     "M"    "M"
                       "F"    "GlassHalf"             64   24    3840    2160     10     "M"     "M"    "M"
                       "F"    "BasketballScreen"      64   60    2560    1440     8      "M"     "M"    "M"
                       "F"    "MissionControl2"       64   60    2560    1440     8      "M"     "M"    "M"
                       "F"    "MissionControl3"       64   60    1920    1080     8      "M"     "M"    "M"
)

# encoder
LIST_DAT_Q_P=($(seq 22 5 37))                     #REVERT_THIS_ITEM_BEFORE_YOU_COMMIT
DATA_PRD_INTRA=-2                                 #REVERT_THIS_ITEM_BEFORE_YOU_COMMIT
if [ $1 == "Ai" ] 
then 
    CSTR_CFG="encoder_intra_vtm"
elif [ $1 == "Ldp" ]
then
    CSTR_CFG="encoder_lowdelay_P_vtm"
elif [ $1 == "Ldb" ]
then
    CSTR_CFG="encoder_lowdelay_vtm"
elif [ $1 == "Ra" ]
then 
    CSTR_CFG="encoder_randomaccess_vtm"
else 
    CSTR_CFG="encoder_randomaccess_vtm_gop16"
fi


#*** MAIN BODY *****************************************************************
#--- INIT ------------------------------
# prepare directory
mkdir -p $CSTR_DIR_DST
rm -rf $CSTR_DIR_DST/*
rm -rf $CSTR_LOG_RLT_FFMPEG
rm -rf $CSTR_LOG_RLT_PSNR
printf "%-51s %-51s %-51s %s\n" "average" "I frame" "P frame" "B frame" >> $CSTR_LOG_RLT_PSNR
printf "%-13s \t%-7s \t%-7s \t%-7s \t"    "bitrate(kb/s)" "psnr(Y)"    "psnr(U)"    "psnr(V)"    >> $CSTR_LOG_RLT_PSNR
printf "%-13s \t%-7s \t%-7s \t%-7s \t"    "bitrate(kb/s)" "psnr(Y)"    "psnr(U)"    "psnr(V)"    >> $CSTR_LOG_RLT_PSNR
printf "%-13s \t%-7s \t%-7s \t%-7s \t"    "bitrate(kb/s)" "psnr(Y)"    "psnr(U)"    "psnr(V)"    >> $CSTR_LOG_RLT_PSNR
printf "%-13s \t%-7s \t%-7s \t%-7s\n"     "bitrate(kb/s)" "psnr(Y)"    "psnr(U)"    "psnr(V)"    >> $CSTR_LOG_RLT_PSNR
printf "%-51s %-51s %-51s %s\n" "average" >> $CSTR_LOG_RLT_FFMPEG
printf "%-7s \t%-7s \t%-7s \t%-7s \n"    "psnr(Y)"    "psnr(U)"    "psnr(V)"    "psnr(AVG)"    >> $CSTR_LOG_RLT_FFMPEG

# note down the current time
timeBgnAll=$(date +%s)


#--- LOOP ------------------------------
#--- LOOP SEQUENCE ---
cntSeq=0
numSeq=${#LIST_SEQ_USED[*]}
cntTgtBitSeq=0
while [ $cntSeq -lt $numSeq ]
do
    # extract parameter
    CSTR_CLS=${LIST_SEQ_USED[$cntSeq]};    cntSeq=$((cntSeq + 1))
    CSTR_SEQ=${LIST_SEQ_USED[$cntSeq]};    cntSeq=$((cntSeq + 1))
    NUMB_FRA=${LIST_SEQ_USED[$cntSeq]};    cntSeq=$((cntSeq + 1))
    DATA_FPS=${LIST_SEQ_USED[$cntSeq]};    cntSeq=$((cntSeq + 1))
    SIZE_FRA_X=${LIST_SEQ_USED[$cntSeq]};  cntSeq=$((cntSeq + 1))
    SIZE_FRA_Y=${LIST_SEQ_USED[$cntSeq]};  cntSeq=$((cntSeq + 1))
    DATA_PXL_WD=${LIST_SEQ_USED[$cntSeq]}; cntSeq=$((cntSeq + 1))
    CSTR_AI_EN=${LIST_SEQ_USED[$cntSeq]};  cntSeq=$((cntSeq + 1))
    CSTR_RA_EN=${LIST_SEQ_USED[$cntSeq]};  cntSeq=$((cntSeq + 1))
    CSTR_LD_EN=${LIST_SEQ_USED[$cntSeq]};  cntSeq=$((cntSeq + 1))
    CSTR_FI_EN=${CSTR_RA_EN}

    CSTR_YUV=${CSTR_SEQ}.yuv 
    if [ $1 == "Ai" ] 
    then 
        CSTR_FI_EN=${CSTR_AI_EN}
    elif [ $1 == "Ld" ]
    then
        CSTR_FI_EN=${CSTR_LD_EN}
    elif [ $1 == "Ra" ]
    then 
        CSTR_FI_EN=${CSTR_RA_EN}
    else 
        CSTR_FI_EN=${CSTR_RA_EN}
    fi

    for yuvfile in ${CSTR_DIR_SRC}/${CSTR_SEQ}/*
    do
        CSTR_YUV=$yuvfile
    done

    if [ $1 == "Ra" ]
    then
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
    fi


    # derive parameter
    CSTR_SRC=$CSTR_DIR_SRC/$CSTR_SEQ/$CSTR_SEQ
    CSTR_ORI=$CSTR_DIR_ORI/$CSTR_SEQ/$CSTR_SEQ

    if  [ $CSTR_FI_EN == "M" ] && ( [ $CSTR_CLS == $2 ] || [ $2 == "M" ] ) 
    then
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
        DATA_TAR_BIT_RA=${TAR_BITS_FOR_RA[ $((cntTgtBitSeq + 0))]}
        DATA_TAR_BIT_LDP=${TAR_BITS_FOR_LDP[ $((cntTgtBitSeq + 0))]}
        DATA_TAR_BIT_LDB=${TAR_BITS_FOR_LDB[ $((cntTgtBitSeq + 0))]}; cntTgtBitSeq=$((cntTgtBitSeq + 1))

        if [ $1 == "Ai" ] 
        then 
            echo " target bit for all intra condition is not ready !!!" 
        elif [ $1 == "Ldp" ]
        then
            DATA_TAR_BIT_FINAL=$DATA_TAR_BIT_LDP
        elif [ $1 == "Ldb" ]
        then
            DATA_TAR_BIT_FINAL=$DATA_TAR_BIT_LDB
        elif [ $1 == "Ra" ]
        then 
            DATA_TAR_BIT_FINAL=$DATA_TAR_BIT_RA
        else 
            DATA_TAR_BIT_FINAL=$DATA_TAR_BIT_RA
        fi

        # derive parameter
        CSTR_DIR_SUB=${CSTR_SEQ}_${DATA_Q_P}
        CSTR_DIR_DST_FUL=$CSTR_DIR_DST/$CSTR_DIR_SUB/

        # log
        echo "    qp $DATA_Q_P launched ..."

        # make directory
        mkdir -p $CSTR_DIR_DST_FUL

        if [ -e cfg/per-sequence-non-420/${CSTR_SEQ}_444.cfg ]
        then
            CSTR_SCC_SEQ_CFG=cfg/per-sequence-non-420/${CSTR_SEQ}_444.cfg
        else
            CSTR_SCC_SEQ_CFG=cfg/per-sequence-non-420/${CSTR_SEQ}_444_10bit.cfg
        fi
        # encode (gop, common)
        if [ $1 == "Ra" ]
        then
            ./${CSTR_CDC}                                                                     \
                                                                                              \
                -c                  cfg/${CSTR_CFG}.cfg                                       \
                -c                  cfg/per-class/classSCC.cfg                                \
                -c                  ${CSTR_SCC_SEQ_CFG}                                       \
                                                                                              \
                        --InputFile=${CSTR_YUV}                                               \
                --FramesToBeEncoded=${NUMB_FRA}                                               \
                    --InputBitDepth=${DATA_PXL_WD}                                            \
                 --InternalBitDepth=10                                                        \
                               --QP=${DATA_Q_P}                                               \
                      --IntraPeriod=${DATA_PRD_INTRA}                                         \
                    --BitstreamFile=${CSTR_DIR_DST_FUL}${CSTR_SEQ}_${DATA_Q_P}.bin            \
                        --ReconFile=${CSTR_DIR_DST_FUL}${CSTR_SEQ}_${DATA_Q_P}.yuv            \
            --SEIDecodedPictureHash=1                                                         \
            >& ${CSTR_DIR_DST_FUL}${CSTR_SEQ}_${DATA_Q_P}.log &
        else 
            ./${CSTR_CDC}                                                                     \
                                                                                              \
                -c                  cfg/${CSTR_CFG}.cfg                                       \
                -c                  cfg/per-class/classSCC.cfg                                \
                -c                  ${CSTR_SCC_SEQ_CFG}                                       \
                                                                                              \
                        --InputFile=${CSTR_YUV}                                               \
                        --FrameRate=${DATA_FPS}                                               \
                --FramesToBeEncoded=${NUMB_FRA}                                               \
                    --InputBitDepth=${DATA_PXL_WD}                                            \
                 --InternalBitDepth=10                                                        \
                               --QP=${DATA_Q_P}                                               \
                    --BitstreamFile=${CSTR_DIR_DST_FUL}${CSTR_SEQ}_${DATA_Q_P}.bin            \
                        --ReconFile=${CSTR_DIR_DST_FUL}${CSTR_SEQ}_${DATA_Q_P}.yuv            \
            --SEIDecodedPictureHash=1                                                         \
            >& ${CSTR_DIR_DST_FUL}${CSTR_SEQ}_${DATA_Q_P}.log &
        fi
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
        md5sum ${CSTR_DIR_DST_FUL}${CSTR_SEQ}_${DATA_Q_P}.bin | tee -a $CSTR_LOG_RUN

        # update info (psnr)
        cat ${CSTR_DIR_DST_FUL}${CSTR_SEQ}_${DATA_Q_P}.log    | \
            perl -e 'while (<>) {
                        if (/a\s+([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)/) {
                            printf "%-13.2f \t%-7.3f \t%-7.3f \t%-7.3f \t", $1, $2, $3, $4
                        }
                        if (/i\s+([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)/) {
                            printf "%-13.2f \t%-7.3f \t%-7.3f \t%-7.3f \t", $1, $2, $3, $4
                        }
                        if (/p\s+([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)/) {
                            printf "%-13.2f \t%-7.3f \t%-7.3f \t%-7.3f \t", $1, $2, $3, $4
                        }
                        if (/b\s+([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)/) {
                            printf "%-13.2f \t%-7.3f \t%-7.3f \t%-7.3f \t", $1, $2, $3, $4
                        }
                     }
                    '                 \
        >> $CSTR_LOG_RLT_PSNR
        echo "$CSTR_DIR_SUB" >> $CSTR_LOG_RLT_PSNR

        # update info (ssim)
        cat ${CSTR_DIR_DST_FUL}${CSTR_SEQ}_${DATA_Q_P}.log    | \
            perl -e 'while (<>) {
                        if (/a\s+([\d\.]+)\s+[\d\.]+\s+[\d\.]+\s+[\d\.]+\s+[\d\.]+\s+([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)/) {
                            printf "%-13.2f \t%-7.3f \t%-7.3f \t%-7.3f \t", $1, $2, $3, $4
                        }
                        if (/i\s+([\d\.]+)\s+[\d\.]+\s+[\d\.]+\s+[\d\.]+\s+[\d\.]+\s+([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)/) {
                            printf "%-13.2f \t%-7.3f \t%-7.3f \t%-7.3f \t", $1, $2, $3, $4
                        }
                        if (/p\s+([\d\.]+)\s+[\d\.]+\s+[\d\.]+\s+[\d\.]+\s+[\d\.]+\s+([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)/) {
                            printf "%-13.2f \t%-7.3f \t%-7.3f \t%-7.3f \t", $1, $2, $3, $4
                        }
                        if (/b\s+([\d\.]+)\s+[\d\.]+\s+[\d\.]+\s+[\d\.]+\s+[\d\.]+\s+([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)/) {
                            printf "%-13.2f \t%-7.3f \t%-7.3f \t%-7.3f \t", $1, $2, $3, $4
                        }
                     }
                    '                 \
        >> $CSTR_LOG_RLT_SSIM
        echo "$CSTR_DIR_SUB" >> $CSTR_LOG_RLT_SSIM
        
        # calculate psnr use ffmpeg
        END_FRA=$((NUMB_FRA - 1))

        ffmpeg -s ${SIZE_FRA_X}x${SIZE_FRA_Y} -r ${DATA_FPS} -pix_fmt yuv420p -i ${CSTR_DIR_DST_FUL}${CSTR_SEQ}_${DATA_Q_P}.yuv \
               -s ${SIZE_FRA_X}x${SIZE_FRA_Y} -r ${DATA_FPS} -pix_fmt yuv420p -i ${CSTR_YUV}                                    \
               -filter_complex "[0:v]select=between(n\,0\,${END_FRA})[a];[1:v]select=between(n\,0\,${END_FRA})[b];[a][b]psnr=${CSTR_DIR_DST_FUL}psnr.log" -f null - 2>${CSTR_DIR_DST_FUL}${CSTR_SEQ}_${DATA_Q_P}_ffmpeg.log

        rm ${CSTR_DIR_DST_FUL}${CSTR_SEQ}_${DATA_Q_P}.yuv

        # update info (psnr)
        cat ${CSTR_DIR_DST_FUL}${CSTR_SEQ}_${DATA_Q_P}_ffmpeg.log    | \
            perl -e 'while (<>) {
                        if (/PSNR\s+y:([\d\.]+)\s+u:([\d\.]+)\s+v:([\d\.]+)\s+average:([\d\.]+)/) {
                            printf "%-7.3f \t%-7.3f \t%-7.3f \t%-7.3f \t", $1, $2, $3, $4
                        }
                     }
                    '                 \
        >> $CSTR_LOG_RLT_FFMPEG
        echo "$CSTR_DIR_SUB" >> $CSTR_LOG_RLT_FFMPEG
    done
    # update bd rate
    #./script/getBdRate.py script/anchor.log $CSTR_LOG_RLT_PSNR > $CSTR_LOG_RLT_BDRT
    fi
done
