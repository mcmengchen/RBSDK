//
// Created by 徐江涛 on 15/12/28.
//

#ifndef PUDDING_CONFIG_H
#define PUDDING_CONFIG_H

#include "parameter.h"
#include <cmath>
#include <iostream>
class VoiceCodec {
protected:
    const int TWO_FREQ_BASE;
    const int TWO_FREQ_STEP;
    const int THREE_FREQ_BASE;
    const int THREE_FREQ_STEP;
protected:
    void initFreqTable();

    virtual void initCfg();

    virtual void resetParam() = 0;

    VoiceCodec();

    ~VoiceCodec();

protected:

    int head[2];
    int wi[4];
    int twofTable[2][16];
    int threefTable[3][16];
    int buffer1[MAX_ARRAY_NUM];
    int buffer2[MAX_ARRAY_NUM];
public:
    int NFRAME;                  //每个音长度。默认为4200
protected:
    int FREQ_GROUP_NUM;              // 默认8组
    int NSUBFRAME;                     // 子帧长度
    int SUBFRAME_NUM;                  // 子帧数量
    int **fTable;                // 频率表

};


#endif //PUDDING_CONFIG_H
