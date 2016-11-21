#include "encode.h"
#include <string.h>
#include <time.h>
#include <stdio.h>
#include <assert.h>
#import "soundtrans.h"
#import "CodingHelper.h"

#ifdef __cplusplus
extern "C" {
#endif
    
    typedef void *HANDLE;
    
    char *wavFilePath = NULL;
    /* *******************************************************
     * 音频操作函数定义
     *********************************************************/
    typedef struct TagWaveHead {
        unsigned int rId;
        unsigned int rLen;
        unsigned int wId;
        unsigned int fId;
        unsigned int fLen;
        unsigned short wFormatTag;
        unsigned short nChannels;
        unsigned int nSamplesPerSec;
        unsigned int nAvgBytesPerSec;
        unsigned short nBlockAlign;
        unsigned short wBitsPerSample;
    } TWavHeader, *PWavHeader;
    
    typedef struct TagWaveFile {
        FILE *fHandle;
        unsigned short nBlockAlign;
        unsigned int DataLeng;
    } TWaveFile, *PWaveFile;
    
    /* ******************************************************
     * HANDLE CreateWavFile(char *fn, WORD channels, WORD resolution, DWORD rate, WORD WavFMt)
     * 功能  创建wav文件，并进行文件头的相关处理
     * 参数  fn          wav文件保存路径
     *       channels    音频流数据通道数，1表示单通道，2表示双通道（立体声）
     *       resolution  音频流数据的采样位数(对于DAR恒为16位)
     *       rate        音频流的采样率
     *       WavFMt      音频流数据压缩格式（无压缩 WavFMT=1）
     ********************************************************/
    HANDLE creatf(char *fn, unsigned int channels, unsigned int resolution, unsigned int rate,
                  unsigned int WavFMt) {
        TWavHeader wh;
        FILE *tmpf;
        PWaveFile tmpWavHan;
        unsigned short Hda1;
        unsigned int Hda2;
        
        wh.rId = 0x46464952;  //'RIFF'
        wh.rLen = 0x0;
        wh.wId = 0x45564157;  // 'WAVE'
        wh.fId = 0x20746d66; //'fmt '
        wh.fLen = 18;
        wh.wFormatTag = WavFMt;
        wh.nChannels = channels;
        wh.nSamplesPerSec = rate;
        wh.nAvgBytesPerSec = channels * rate * (resolution / 8);
        wh.nBlockAlign = channels * (resolution / 8);
        wh.wBitsPerSample = resolution;
        if ((tmpf = fopen(fn, "wb")) == NULL)///wb 只写打开或新建一个二进制文件；只允许写数据，返回指向该文本的流文件
        {
            return NULL;
        }
        
        fwrite(&wh, 1, sizeof(TWavHeader), tmpf);
        Hda1 = 0x0000;
        fwrite(&Hda1, 1, 2, tmpf);
        
        Hda2 = 0x74636166; //'fact'
        fwrite(&Hda2, 1, 4, tmpf);
        Hda2 = 0x00000004;
        fwrite(&Hda2, 1, 4, tmpf);
        Hda2 = 0x00000000;
        fwrite(&Hda2, 1, 4, tmpf);
        
        Hda2 = 0x61746164; //'data'
        fwrite(&Hda2, 1, 4, tmpf);
        Hda2 = 0x00000000;
        fwrite(&Hda2, 1, 4, tmpf);
        fclose(tmpf);
        
        tmpWavHan = (PWaveFile) malloc(sizeof(TWaveFile));
        if (tmpWavHan == NULL)
            return 0;
        if ((tmpWavHan->fHandle = fopen(fn, "rb+")) == NULL)//rb+ 读写打开一个二进制文件，只允许读写数据
            return NULL;
        tmpWavHan->DataLeng = 50;
        tmpWavHan->nBlockAlign = wh.nBlockAlign;
        fseek(tmpWavHan->fHandle, 58, SEEK_SET);//SEEK_SET： 文件开头
        return (HANDLE) tmpWavHan;
    }
    
    /* *****************************************************
     * BOOL WriteWavData(HANDLE wfHand, char *WavData, DWORD DataLen)
     * 功能 向wav文件中写数据
     * 参数 wfHand     CreateWavFile后取得的句柄
     *      WavData    音频流数据buffer指针
     *      DataLen    音频流数据写入量
     *******************************************************/
    int writef(HANDLE wfHand, char *WavData, unsigned long DataLen) {
        unsigned long Wsize;
        PWaveFile tmpWavHan = (PWaveFile) wfHand;
        if (wfHand == NULL) {
            return 0;
        }
        Wsize = fwrite(WavData, 1, DataLen, tmpWavHan->fHandle);
        if (Wsize == 0) {
            return 0;
        }
        tmpWavHan->DataLeng += Wsize;
        return 1;
    }
    
    /* ****************************************************
     * void CloseWavFile(HANDLE *wfHand)
     * 功能   关闭音频流数据文件
     * 参数 wfHand  CreateWavFile后取得的操作句柄
     ******************************************************/
    void closef(HANDLE *wfHand) {
        PWaveFile tmpWavHan = (PWaveFile) *wfHand;
        if (*wfHand == NULL) {
            return;
        }
        *wfHand = NULL;
        
        fseek(tmpWavHan->fHandle, 4, SEEK_SET);
        fwrite(&tmpWavHan->DataLeng, 4, 1, tmpWavHan->fHandle);
        
        tmpWavHan->DataLeng -= 50;
        fseek(tmpWavHan->fHandle, 54, SEEK_SET);
        fwrite(&tmpWavHan->DataLeng, 4, 1, tmpWavHan->fHandle);
        
        tmpWavHan->DataLeng /= tmpWavHan->nBlockAlign;
        fseek(tmpWavHan->fHandle, 46, SEEK_SET);
        fwrite(&tmpWavHan->DataLeng, 4, 1, tmpWavHan->fHandle);
        
        fclose(tmpWavHan->fHandle);
        free(tmpWavHan);
    }
    
    int playstr(char *loadstr) {
        
        VoiceEncode *voiceEncode = new VoiceEncode();
        voiceEncode->initCfg();
        HANDLE wfHand = NULL;
        
        int inputlen = (int)strlen(loadstr);
        long outLen = 0;
        char *mpData = NULL;
        
        int encodeResult = voiceEncode->encode(loadstr, inputlen, true, mpData, outLen);
        if (!encodeResult) {
            printf("\n\n");
            
            bool createWavOk = false;
            wfHand = creatf(wavFilePath, 1, 16, 44100, 1);
            if (wfHand) {
                createWavOk = true;
                writef(wfHand, mpData, outLen);
                closef(&wfHand);
            }
            
            free(mpData);
            mpData = NULL;
            return createWavOk ? 0 : 101;
        }
        
        delete voiceEncode;
        return encodeResult;
        return 0;
    }
    
    
    char* getBypes(NSString * str){
        NSData * data = [str dataUsingEncoding:NSUnicodeStringEncoding];
        char *unicodeBaytes = (char *)[data bytes];
        return unicodeBaytes;
    }
    
    
    int32_t voicebarcode_Sender_createWavRaw(NSString * loadstring ,NSString * filePath){
        loadstring = encode(loadstring);
        
        char* pStr = NULL;
        if([loadstring length] > 0 ){
            pStr = (char*)malloc([loadstring length] + 1);
            if (!pStr)
            {
                return NULL;
            }
            memcpy(pStr, [filePath UTF8String], [loadstring length]);
            pStr[[loadstring length]] = '\0';
            
        }
        char * a = (char *)[loadstring UTF8String];
        
        wavFilePath = (char *) [filePath UTF8String];
        int32_t result = playstr(a);
        wavFilePath = NULL;
        
        return result;
        
    }

    NSString* stringAddEncode(NSString* str) {
        NSMutableString * builder = [NSMutableString new];
        for (int i = 0; i < str.length; ++i) {
            NSString *temp = nil;
            temp = [str substringWithRange:NSMakeRange(i, 1)];
            if ([temp isEqualToString: @"#"]) {
                [builder appendString:@"\\"];
            } else if ([temp isEqualToString: @"\\"]) {
                [builder appendString:@"\\"];
            }
            [builder appendFormat:@"%@",temp];
            
//            unichar ch = [str characterAtIndex:i];
//            if (ch == '#') {
//                [builder appendString:@"\\"];
//            } else if (ch == '\\') {
//                [builder appendString:@"\\"];
//            }
//            [builder appendFormat:@"%c",ch];
        }
        return builder;
    }

    int createWifiWarFile(NSString * wifiName ,NSString * wifiPsd,NSString * settingID,NSString * path){
        NSMutableString * builder = [NSMutableString new];
        [builder appendString:@"v1#"];
        if (wifiName != NULL) {
            [builder appendString:stringAddEncode(wifiName)];
//            [builder appendString:wifiName];
        }
        [builder appendString:@"#"];
        
        if (wifiPsd != NULL) {
            [builder appendString:stringAddEncode(wifiPsd)];
        }
        [builder appendString:@"#"];
        
        if (settingID != NULL) {
            [builder appendString:stringAddEncode(settingID)];
        }
        [builder appendString:@"##"];
        
        return voicebarcode_Sender_createWavRaw(builder, path);
        
//        char *loadstr = (char *)[@"v1#a##adcdefghi\\#jklmn##" UTF8String];
//        wavFilePath =  (char *)[@"/Users/zky/Desktop/test.wav" UTF8String] ;
//        int result = playstr(loadstr);
//        wavFilePath = NULL;
//        return result;

//        loadstring = encode(loadstring);
//        
//        char* pStr = NULL;
//        if([loadstring length] > 0 ){
//            pStr = (char*)malloc([loadstring length] + 1);
//            if (!pStr)
//            {
//                return NULL;
//            }
//            memcpy(pStr, [filePath UTF8String], [loadstring length]);
//            pStr[[loadstring length]] = '\0';
//            
//        }
//        char * a = (char *)[loadstring UTF8String];
//        
//        wavFilePath = (char *) [filePath UTF8String];
//        int32_t result = wavaudioplay(a);
//        wavFilePath = NULL;
//        
//        return result;
    
    }

#ifdef __cplusplus
}
#endif
