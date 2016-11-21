//
// Created by 徐江涛 on 15/12/28.
//

#include "codec.h"
#include "parameter.h"
#include <string>
#include <cmath>

VoiceCodec::VoiceCodec() : TWO_FREQ_BASE(657), TWO_FREQ_STEP(300), THREE_FREQ_BASE(707),
                           THREE_FREQ_STEP(200) {
    DEBUG_PRINT(
            "VoiceCodec");
    FREQ_GROUP_NUM = 8;
    NSUBFRAME = 630;
    SUBFRAME_NUM = 5;
    DEBUG_PRINT(
            "VoiceCodec 1");
    head[0] = 12;
    head[1] = 6;
    wi[0] = 3;
    wi[1] = 9;
    wi[2] = 4;
    wi[3] = 8;
    DEBUG_PRINT(
            "VoiceCodec 2");
    fTable = NULL;

    DEBUG_PRINT(
            "VoiceCodec end");
}

void VoiceCodec::initFreqTable() {

    int *ptr;
    ptr = (int *) twofTable;
    int step = 0;
    for (int i = 0; i < 32; i++, ptr++) {
        *ptr = TWO_FREQ_BASE + step;
        step += TWO_FREQ_STEP;
    }

    ptr = (int *) threefTable;
    step = 0;

    for (int j = 0; j < 48; j++, ptr++) {
        *ptr = THREE_FREQ_BASE + step;
        step += THREE_FREQ_STEP;
    }
}


void VoiceCodec::initCfg() {
    // 初始化频率表
    initFreqTable();
    // 打开频率配置
    int basefreq, freqgap;
    basefreq = TWO_FREQ_BASE;
    freqgap = THREE_FREQ_STEP;


    NFRAME = NSUBFRAME * SUBFRAME_NUM;
    fTable = (int **) calloc(FREQ_GROUP_NUM, sizeof(int *));
    for (int i = 0; i < FREQ_GROUP_NUM; i++) {
        fTable[i] = (int *) calloc(FREQ_PER_GROUP, sizeof(int));
    }
    for (int i = 0; i < FREQ_GROUP_NUM; i++) {
        for (int j = 0; j < FREQ_PER_GROUP; j++) {
            fTable[i][j] = basefreq;
            basefreq += freqgap;
            //while (((basefreq>4000) && (basefreq<5000)) || ((basefreq>8000) && (basefreq<9000)))
            //	basefreq += freqgap;
        }
    }
}

VoiceCodec::~VoiceCodec() {
    if (fTable != NULL) {
        for (int j = 0; j < FREQ_GROUP_NUM; j++) {
            free(fTable[j]);
            fTable[j] = NULL;
        }
        free(fTable);
        fTable = NULL;
    }
}