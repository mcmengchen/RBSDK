/* 编码生成声音 */
#ifndef __ENCODE__H
#define __ENCODE__H

#define _USE_MATH_DEFINES
//#include <vector>
#include <cmath>
#include <iostream>
#include "codec.h"
#include "parameter.h"
//#include <string>

using namespace std;

class VoiceEncode : public VoiceCodec {
private:
    float T;
    float *mywin;
    double sigcoeff[8];
    int lastsum;

public:
    virtual void initCfg();

    virtual void resetParam();

    VoiceEncode();

    ~VoiceEncode();

    int paddata(char *id, bool lastfrag);

    int encode(char *str, int stringLen, bool haswindows, char *&pData, long &outLen);

private:

    int num2sig(int num[], float *sig);

    int synSig(int num1, float *sig);

    int threefsig(int, int, int, float *);

};

#endif
