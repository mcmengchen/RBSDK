
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#ifndef __PARAMETER_H
#define __PATAMETER_H
#pragma clang diagnostic pop

#define PLAY_FS 44100         // 播放采样率
#define BLOCK_COUNT 8
//#define RECORD_FS 44100                // 录音采样率
#define RECORD_FS 48000                // 录音采样率

#define nframe1    512

#define FRAGMENNT_SIZE nframe1//3072              // 录音缓冲区大小
//#define DECODE_LENGTH   3500 //490
#define FRAGMENNT_NUM 8                  // 缓冲区个数
#define FREQ_PER_GROUP 8
#define CODECVRSION 1
#define LEN_BIT 5              // 5位表示数据长度，其中三位数据长度，一位版本号，一位校验

#define MAX_OCT_NUM		360//595		// 最大有效八进制数
#define MAX_ARRAY_NUM	640//1048		// 最大数组
#define MAX_FRAG_NUM	80//131			// 最大数据段数
//static char _HEADER[] = {
//        0x2e,0x72, 0x6f, 0x6f
//};

#define M_PI_2X    M_PI * 2


#if ANDROID_DEBUG
#include <android/log.h>
#define DEBUG_PRINT(format,args...) __android_log_print(ANDROID_LOG_DEBUG,"VocieCodec", format,##args)
#define pint(_x)  __android_log_print(ANDROID_LOG_DEBUG,"VocieCodec","[%20s( %04d )]  %-30s = %d (0x%08x)\n",__FUNCTION__,__LINE__, #_x, (int)(_x), (int)(_x))
#define puint(_x) __android_log_print(ANDROID_LOG_DEBUG,"VocieCodec","[%20s( %04d )]  %-30s = %u (0x%08x)\n",__FUNCTION__,__LINE__, #_x, (unsigned int)(_x), (unsigned int)(_x))
#define pstr(_x) __android_log_print(ANDROID_LOG_DEBUG,"VocieCodec","[%20s( %04d )]  %-30s = %s \n",__FUNCTION__,__LINE__, #_x, (char*)(_x))
#define ERR_PRINT(format,args...) __android_log_print(ANDROID_LOG_ERROR,"VocieCodec", format,##args)
#else
#define DEBUG_PRINT(format, args...)
#define pint(_x)
#define puint(_x)
#define pstr(_x)
#define ERR_PRINT(format, args...)
#endif

#ifndef __ERRINC_H__
#define __ERRINC_H__
//自定义错误码
#define OK     0
#define NO_ERR OK

#define ERR_OVERLENGTH	1	//生成音频时输入字符串太长
#define ERR_DECODE		2	//接收端解码失败
#define ERR_DECODE_LEN	3	//接收端解码长度时失败
#define ERR_LOW_VERSION	4	//接收端版本太低

#define ERR_NOT_ENOUGH_MEMORY  11
#define ERR_CREAT_THREAD       12
#define ERR_MAX  13//fix me !
#endif

#endif