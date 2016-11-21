#include "encode.h"
#include "rscodec.h"
#include "utils.h"

VoiceEncode::VoiceEncode() {
    DEBUG_PRINT(
            "VoiceEncode");
    lastsum = 0;
    T = 1.0 / PLAY_FS;
    mywin = NULL;
    sigcoeff[0] = 0.2;
    sigcoeff[1] = 0.05;
    sigcoeff[2] = 0.1;
    sigcoeff[3] = 0.05;
    sigcoeff[4] = 0.05;
    sigcoeff[5] = 0.2;
    sigcoeff[6] = 0.3;
    sigcoeff[7] = 0.05;

    DEBUG_PRINT(
            "VoiceEncode SUBFRAME_NUM=%d, NSUBFRAME=%d FREQ_GROUP_NUM=%d FREQ_PER_GROUP=%d",
            SUBFRAME_NUM, NSUBFRAME, FREQ_GROUP_NUM, FREQ_PER_GROUP);
}

VoiceEncode::~VoiceEncode() {
    if (mywin != NULL) {
        free(mywin);
        mywin = NULL;
    }
}


void VoiceEncode::initCfg() {
    DEBUG_PRINT("VoiceEncode::initCfg");
    VoiceCodec::initCfg();

// 汉明窗
    mywin = (float *) calloc(NFRAME, sizeof(float));
    for (int i = 0; i < (NFRAME + 1) / 2; ++i) {
        mywin[i] = 1.0 * float(0.54 - 0.46 * cos(2.0 * M_PI * i / (NFRAME - 1)));
        mywin[NFRAME - 1 - i] = mywin[i];
    }
}

void VoiceEncode::resetParam() {

}

// 单频数据头信号
int VoiceEncode::synSig(int num1, float *sig) {
    for (int i = 0; i < NFRAME; i++) {
        sig[i] = sin(2.0 * M_PI * twofTable[0][num1] * i * T);
    }
    return 0;
}

// 三频数据长度信号
int VoiceEncode::threefsig(int num1, int num2, int num3, float *sig) {
    double max_value = 0.0;
    for (int i = 0; i < NFRAME; i++) {
        sig[i] = (0.3 * sin(2.0 * M_PI * threefTable[0][num1] * i * T) +
                  0.3 * sin(2.0 * M_PI * threefTable[1][num2] * i * T) +
                  0.4 * sin(2.0 * M_PI * threefTable[2][num3] * i * T));   // 换成cos？
        if (abs(sig[i]) > max_value) {
            max_value = abs(sig[i]);
        }
    }
    double amp = 1.0 / max_value;
    for (int j = 0; j < NFRAME; j++) {
        sig[j] = sig[j] * amp;
    }
    return 0;
}

// 根据数字产生相应频率的信号
int VoiceEncode::num2sig(int num[], float *sig) {
    double max_value = 0.0;
    double M_PI_2X_T = M_PI_2X * T;
    double *sig1 = (double *) calloc(NFRAME, sizeof(double));
    for (int k = 0; k < FREQ_GROUP_NUM; k++) {
        for (int i = 0; i < NFRAME; i++) {
            sig1[i] += sigcoeff[k] * sin(M_PI_2X_T * fTable[k][num[k]] * i);
            if (abs(sig1[i]) > max_value) {
                max_value = abs(sig1[i]);
            }
        }

    }
    double amp = 1.0 / max_value;
    for (int j = 0; j < NFRAME; j++) {
        sig[j] = sig1[j] * amp;
    }
    free(sig1);
    sig1 = NULL;

    return 0;
}

// 汉明窗
//int myhamming(int N, float amp, float *win) {
//    for (int i = 0; i < (N + 1) / 2; ++i) {
//        win[i] = amp * float(0.54 - 0.46 * cos(2.0 * M_PI * i / (N - 1)));
//        win[N - 1 - i] = win[i];
//    }
//    return 0;
//}

// 填充数据并进行rs编码
int VoiceEncode::paddata(char *id, bool lastfrag) {
    int len = (int)strlen(id);
    int *idArray = (int *) calloc(len, sizeof(int));
    Utils::string2array(id, idArray);

    int fragsum = 0;
    for (int i = 0; i < len; i++) {
        data[i] = idArray[i];
        fragsum += wi[i] * idArray[i];
        lastsum += idArray[i];
    }
    if (lastfrag) {
        data[len] = lastsum % 8;
        fragsum += wi[len] * data[len];
        data[len + 1] = (fragsum % 8 + fragsum / 8) % 8;
        if ((len + 2) != kk) {
            for (int i = len + 2; i < kk; i++) {
                data[i] = 0;
            }
        }
    }
    else {
        data[len] = (fragsum % 8 + fragsum / 8) % 8;
        if ((len + 1) != kk) {
            for (int i = len + 1; i < kk; i++) {
                data[i] = 0;
            }
        }
    }

    free(idArray);
    idArray = NULL;
    return 0;
}

// 编码
int VoiceEncode::encode(char *str, int stringLen, bool haswindows, char *&pData, long &outLen) {
    int inputcodeindex = -1;
    if (stringLen <= MAX_OCT_NUM)           // 最大MAX_OCT_NUM
    {
#ifdef _DEBUG_PRINTF
        printf("发送ing...\n");
#endif
        // 加入数据头
        inputcodeindex++;
        buffer1[inputcodeindex] = head[0];

        // rs编码数据长度并填充数据长度
        init_rs(4);             // 初始化rs编码
        // 加入版本号
        data[0] = CODECVRSION;
        // 加入数据长度
        data[1] = stringLen >> 8;
        data[2] = (stringLen & 255) >> 4;
        data[3] = stringLen & 15;
        if (data[1] != 0 && data[2] != 0 && data[3] != 0) {
            data[4] = (data[1] * data[2] * data[3] + data[0]) % 16;
        }
        else {
            data[4] = (data[1] + data[2] + data[3] + data[0]) % 16;
        }
        // 补0
        if (LEN_BIT != kk) {
            for (int i = LEN_BIT; i < kk; i++) {
                data[i] = 0;
            }
        }
        // 对版本号和数据长度进行rs编码
        encode_rs();

        // 将版本号及数据长度及它们的校验码加入待发送队列
        // 添加两位校验码
        for (int i = 0; i < nn - kk; i++) {
            inputcodeindex++;
            buffer1[inputcodeindex] = bb[i];
        }
        // 添加版本号和长度
        for (int j = 0; j < LEN_BIT; j++) {
            inputcodeindex++;
            buffer1[inputcodeindex] = data[j];
        }

        // 计算段数
        init_rs(3);               // 重新初始化rs编码器
        int strFragNum = 0;
        int firstStrLen = (stringLen + 1) % (kk - 1);    // 每段包含的有效数字由5变为4（kk -> kk-1）
        if (firstStrLen == 0) {
            strFragNum = (stringLen + 1) / (kk - 1);     // 每段包含的有效数字由5变为4（kk -> kk-1）
            firstStrLen = kk - 1;                      // 每段包含的有效数字由5变为4（kk -> kk-1）
        }
        else {
            strFragNum = (stringLen + 1) / (kk - 1) + 1; // 每段包含的有效数字由5变为4（kk -> kk-1）
        }

        // 添加数据
        for (int i = 0; i < strFragNum; i++) {
            int currentStrLen = 0;
            if (i == 0) {
                currentStrLen = firstStrLen;
            }
            else {
                currentStrLen = kk - 1;                        // 每段包含的有效数字由5变为4（kk -> kk-1）
            }
            //第一段
            char *curStr = (char *) calloc(currentStrLen + 1, sizeof(char));
            if (i == 0) {
                strncpy(curStr, str, currentStrLen);
            }
            else {
                strncpy(curStr, str + firstStrLen + (i - 1) * currentStrLen, currentStrLen);
            }
            if (i == strFragNum - 1) {
                paddata(curStr, true);
            }
            else {
                paddata(curStr, false);
            }

            encode_rs();
            for (int i = 0; i < nn - kk; i++) {
                inputcodeindex++;
                buffer1[inputcodeindex] = bb[i];
            }
            for (int i = 0; i < currentStrLen + 1; i++) {
                inputcodeindex++;
                buffer1[inputcodeindex] = data[i];
            }
            free(curStr);
            curStr = NULL;
        }

        // 填补空缺
        int gap = FREQ_GROUP_NUM - (inputcodeindex - 10 + 1) % FREQ_GROUP_NUM;
        if (gap != FREQ_GROUP_NUM) {
            for (int i = 0; i < gap; i++) {
                inputcodeindex++;
                buffer1[inputcodeindex] = 0;
            }
        }

        int codeLen = inputcodeindex + 1;

        // 交插
        for (int i = 0; i < 10; i++) {
            buffer2[i] = buffer1[i];
        }
        int numfrag = (codeLen - 10) / FREQ_GROUP_NUM;   // 数据段数
        int **inputcodematrix;
        inputcodematrix = (int **) calloc(numfrag, sizeof(int *));
        for (int i = 0; i < numfrag; i++) {
            inputcodematrix[i] = (int *) calloc(FREQ_GROUP_NUM, sizeof(int));
        }

#ifdef _DEBUG_PRINTF
        printf("交插前数据:\n");
#endif
        int idx = 10;
        for (int i = 0; i < numfrag; i++) {
            for (int j = 0; j < FREQ_GROUP_NUM; j++) {
                inputcodematrix[i][j] = buffer1[idx];
                idx++;
#ifdef _DEBUG_PRINTF
                printf("%d ", inputcodematrix[i][j]);
#endif
                //cout << inputcodematrix[i][j] << " ";
            }
#ifdef _DEBUG_PRINTF
            printf("\n");
#endif
        }
#ifdef _DEBUG_PRINTF
        printf("\n");
#endif
        idx = 10;
        for (int i = 0; i < FREQ_GROUP_NUM; i++) {
            for (int j = 0; j < numfrag; j++) {
                buffer2[idx] = inputcodematrix[j][i];
                idx++;
            }
        }

        for (int i = 0; i < numfrag; i++) {
            free(inputcodematrix[i]);
            inputcodematrix[i] = NULL;
        }
        free(inputcodematrix);
        inputcodematrix = NULL;
        long outlen = NFRAME * ((codeLen - 10) / FREQ_GROUP_NUM + 9 / 3 + 1);  // 加上一帧数据头同步帧
        float *out = (float *) calloc(outlen, sizeof(float));
        float *ydata = (float *) calloc(NFRAME, sizeof(float));

        // 产生同步数据头信号
        synSig(buffer2[0], ydata);
#ifdef _DEBUG_PRINTF
        printf("数据头: %d\n", sendcode[0]);
#endif
        for (int i = 0; i < NFRAME; i++) {
            if (haswindows) {
                out[i] = ydata[i] * mywin[i];
            }
            else {
                out[i] = ydata[i];
            }

        }

        // 产生代表版本号和数据长度的3频信号
#ifdef _DEBUG_PRINTF
        printf("版本号及数据长度:");
#endif
        for (int i = 1; i < 10; i += 3) {
            threefsig(buffer2[i], buffer2[i + 1], buffer2[i + 2], ydata);
#ifdef _DEBUG_PRINTF
            printf("%d %d %d ", buffer2[i], buffer2[i+1], buffer2[i+2]);
#endif
            idx = NFRAME + (i - 1) / 3 * NFRAME;
            for (int j = 0; j < NFRAME; j++) {
                if (haswindows) {
                    out[j + idx] = ydata[j] * mywin[j];
                }
                else {
                    out[j + idx] = ydata[j];
                }
            }
        }
#ifdef _DEBUG_PRINTF
        printf("\n交插后数据:\n");
#endif
        // 产生数据信号
        int *code = (int *) calloc(FREQ_GROUP_NUM, sizeof(int));
        //cout << "codeLen: " << codeLen << endl;
        for (int i = 10; i < codeLen; i += FREQ_GROUP_NUM) {
            for (int j = 0; j < FREQ_GROUP_NUM; j++) {
                code[j] = buffer2[i + j];
#ifdef _DEBUG_PRINTF
                printf("%d ", code[j]);
#endif
            }
#ifdef _DEBUG_PRINTF
            printf("\n");
#endif
            num2sig(code, ydata);
            idx = 4 * NFRAME + (i - 10) / FREQ_GROUP_NUM * NFRAME;
            for (int j = 0; j < NFRAME; j++) {
                if (haswindows) {
                    out[j + idx] = ydata[j] * mywin[j];
                }
                else {
                    out[j + idx] = ydata[j];
                }
            }
        }
        free(ydata);
        ydata = NULL;
        free(code);
        code = NULL;
        lastsum = 0;

        outLen = 2 * (outlen);
        pData = (char *) calloc(outLen, sizeof(char));
        for (int i = 0; i < outlen; i++) {
            idx = (short) (out[i] * 32768);
            pData[i << 1] = (char) (idx);
            pData[(i << 1) + 1] = (char) (idx >> 8);
        }
        free(out);
        out = NULL;
        inputcodeindex = -1;
        return OK;
    }
    else {
#ifdef _DEBUG_PRINTF
        printf("字符串太长了吧！\n");
#endif
        return ERR_OVERLENGTH;
    }
}