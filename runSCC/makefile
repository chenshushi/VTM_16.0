#!/bin/bash
#-------------------------------------------------------------------------------
    #  
    #  Revision       : 17.2
    #  Release        : VTM
    #
#-------------------------------------------------------------------------------
    #
    #  Filename       : makefile.mk
    #  Author         : HeChenlong
    #  Status         : phase 000
    #  Created        : 2022-9-13
    #  Description    : a makefile to control sessions
    #
#-------------------------------------------------------------------------------

#*** PARAMETER *****************************************************************
CSTR_ENC       ?= VVC_CTC_ENC
CSTR_DEC       ?= VVC_CTC_DEC
CSTR_DIR_PRJ   ?= ../runVTM/VTM
CSTR_TAG       ?= Test
CSTR_ENC_SHELL ?= VVC_SCC_CTC_ENC_YUV444
CSTR_DEC_SHELL ?= VVC_SCC_CTC_DEC_YUV444
CSTR_ENC_TYP   ?= Ra
CSTR_ENC_CLS   ?= M
CSTR_SESSION   := session_$(CSTR_ENC_TYP)_$(CSTR_ENC_CLS)_$(CSTR_TAG)


#*** MAIN BODY *****************************************************************
help:
	@ echo "targets:                                                                                   "
	@ echo "  clean                       clean all generated files under /build/linux                 "
	@ echo "  cleanall                    clean all generated files under /build/linux and all sessions"
	@ echo "  update                      update ${CSTR_CDC}                                           "
	@ echo "  create [CSTR_TAG=String]    create a session named with sessionString                    "
	@ echo "  run    [CSTR_TAG=String] [CSTR_ENC_TYP=String] [CSTR_ENC_CLS=String]  run session        "
	@ echo "  stop                        stop all ${CSTR_CDC}                                         "
	@ echo "                                                                                           "
	@ echo "parameter:                                                                                 "
	@ echo "  CSTR_TAG could be any string you want, for example: CSTR_TAG=Test                        "

clean:
	mkdir -p $(CSTR_DIR_PRJ)/build        ;\
	cd $(CSTR_DIR_PRJ)/build              ;\
	make clean

cleanall: clean
	rm -rf session*

update:
	cd $(CSTR_DIR_PRJ)                    ;\
	mkdir build                           ;\
	cd build                              ;\
	cmake .. -DCMAKE_BUILD_TYPE=Release   ;\
	make -j 8

create_enc : update
	mkdir -p  ${CSTR_SESSION}
	rm    -rf ${CSTR_SESSION}/*
	mkdir -p  ${CSTR_SESSION}/cfg
	cp    ${CSTR_ENC_SHELL}.sh                     ${CSTR_SESSION}
	cp    $(CSTR_DIR_PRJ)/bin/EncoderAppStatic     ${CSTR_SESSION}/${CSTR_ENC}
	cp -r $(CSTR_DIR_PRJ)/cfg/*                    ${CSTR_SESSION}/cfg

create_dec : 
	cp    ${CSTR_DEC_SHELL}.sh                     ${CSTR_SESSION}
	cp    $(CSTR_DIR_PRJ)/bin/DecoderAppStatic     ${CSTR_SESSION}/${CSTR_DEC}   

create :
	create_enc
	create_dec

encode : create_enc
	cd ${CSTR_SESSION}	;\
	sh ./${CSTR_ENC_SHELL}.sh ${CSTR_ENC_TYP} ${CSTR_ENC_CLS}

decode : create_dec
	cd ${CSTR_SESSION}	;\
	sh ./${CSTR_DEC_SHELL}.sh ${CSTR_ENC_TYP} ${CSTR_ENC_CLS}

codec  : create
	cd ${CSTR_SESSION}	;\
	sh ./${CSTR_ENC_SHELL}.sh ${CSTR_ENC_TYP} ${CSTR_ENC_CLS} ;\
	sh ./${CSTR_DEC_SHELL}.sh ${CSTR_ENC_TYP} ${CSTR_ENC_CLS}
run : create_enc
	cd ${CSTR_SESSION}	;\
	sh ./${CSTR_ENC_SHELL}.sh ${CSTR_ENC_TYP} ${CSTR_ENC_CLS}
# stop:
# 	- killall -9 ${CSTR_ENC}	;\
# 	- killall -9 ${CSTR_DEC}
stop:
	- killall -9 ${CSTR_ENC}	;\
