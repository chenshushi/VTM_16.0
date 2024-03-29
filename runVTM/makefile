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
    #  Filename       : makefile.mk
    #  Author         : Liu Chao
    #  Status         : phase 003
    #  Created        : 2021-11-15
    #  Description    : a makefile to control sessions
    #
#-------------------------------------------------------------------------------

#*** PARAMETER *****************************************************************
CSTR_CDC     ?= VTM_Anchor
CSTR_DIR_PRJ ?= ./VTM
CSTR_TAG     ?= Test
CSTR_SESSION := session$(CSTR_TAG)


#*** MAIN BODY *****************************************************************
help:
	@ echo "targets:                                                                                   "
	@ echo "  clean                       clean all generated files under /build/linux                 "
	@ echo "  cleanall                    clean all generated files under /build/linux and all sessions"
	@ echo "  update                      update ${CSTR_CDC}                                           "
	@ echo "  create [CSTR_TAG=String]    create a session named with sessionString                    "
	@ echo "  run    [CSTR_TAG=String]    run session sessionString                                    "
	@ echo "  stop                        stop all ${CSTR_CDC}                                         "
	@ echo "                                                                                           "
	@ echo "parameter:                                                                                 "
	@ echo "  CSTR_TAG could be any string you want, for example: CSTR_TAG=Test                        "

clean:
	cd $(CSTR_DIR_PRJ)    ;\
	make clean

cleanall: clean
	rm -rf session*

update:
	mkdir -p  $(CSTR_DIR_PRJ)/build ;\
	cd        $(CSTR_DIR_PRJ)/build ;\
	cmake ..                           ;\
	make  -j4

create: update
	mkdir -p  ${CSTR_SESSION}
	rm    -rf ${CSTR_SESSION}/*
	mkdir -p  ${CSTR_SESSION}/cfg
	mkdir -p  ${CSTR_SESSION}/script
	cp    ${CSTR_CDC}.sh                          ${CSTR_SESSION}
	cp    $(CSTR_DIR_PRJ)/bin/EncoderAppStatic    ${CSTR_SESSION}/${CSTR_CDC}
	cp -r $(CSTR_DIR_PRJ)/cfg/*                   ${CSTR_SESSION}/cfg
	cp    $(CSTR_DIR_PRJ)/script/*                ${CSTR_SESSION}/script
	cp    ../getBdRate/*                          ${CSTR_SESSION}/script

run: create
	cd ${CSTR_SESSION}    ;\
	chmod +x ./${CSTR_CDC}.sh && ./${CSTR_CDC}.sh

stop:
	- killall -9 ${CSTR_CDC}
