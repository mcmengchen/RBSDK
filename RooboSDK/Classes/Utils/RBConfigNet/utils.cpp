//
// Created by 徐江涛 on 15/12/28.
//

#include "Utils.h"
#include <string>
#include <iostream>
#include <fstream>
#include <time.h>
using namespace std;

char*Utils::HexToStr_Upper(char *str, char *hex, int cnt)
{
    char ch, *tstr=str, *thex=hex;
    int tmp_cnt = 0;
    //printf("HexToStr %d\n",cnt);

    while (*thex && (tmp_cnt<cnt))
    {
        if ((ch=*thex++)<='9') *tstr=ch&15;
        else if (ch<='F') *tstr=ch-55;
        else *tstr=ch-87;
        *tstr<<=4;
        if ((ch=*thex++)<='9') *tstr+=ch&15;
        else if (ch<='F') *tstr+=ch-55;
        else *tstr+=ch-87;
        //printf("tstr %d %c\n ",(int)*tstr,*tstr);
        tstr++;
        tmp_cnt++;
    }
    *tstr++=0; *tstr=0; //wchar =0
    return str;
}


char*Utils::HexToStr(char *str, char *hex, int cnt)
{
    char ch, *tstr=str, *thex=hex;
    int tmp_cnt = 0;
    //printf("HexToStr %d\n",cnt);

    while (*thex && (tmp_cnt<cnt))
    {
        if ((ch=*thex++)<='9') *tstr=ch&15;
        else if (ch<='F') *tstr=ch-55;
        else *tstr=ch-87;
        *tstr<<=4;
        if ((ch=*thex++)<='9') *tstr+=ch&15;
        else if (ch<='F') *tstr+=ch-55;
        else *tstr+=ch-87;
        //printf("tstr %d %c\n ",(int)*tstr,*tstr);
        tstr++;
        tmp_cnt++;
    }
    *tstr++=0; *tstr=0; //wchar =0
    return str;
}

//ret is final date
//result_buf is Oct buf
int Utils::translate_hex2unicode(char *ret, char *result_buf,int length)
{
    int index = 0;
    int ret_index = 0;
    char count = 0;

    //printf("translate is start! \n");
    while(index < length)
    {
        if((result_buf[index]>= 'A' && result_buf[index] <= 'F'))
        {
            count = 'F' - result_buf[index] + 1;
            index ++; // increase
            HexToStr(&ret[ret_index], &result_buf[index],count*2);
            ret_index += count*2;
            index += count*4;
        }
        else if(result_buf[index] == '8' || result_buf[index] == '9')
        {
            count = 16 - (result_buf[index] - '0');
            index ++; // increase
            HexToStr(&ret[ret_index], &result_buf[index],count*2);
            ret_index += count*2;
            index += count*4;
        }
        else
        {
            ret[ret_index++] = 0;
            HexToStr(&ret[ret_index], &result_buf[index],1);
            ret_index += 1;
            index += 2;
        }
        //printf("translate_buf ret_index %d index %d \n",ret_index,index);
    }
    return ret_index;
}
#if 0
decodeOct7PureAscii(final String encodeString)
{
	int c, c1, c2, c3;
	String tmp;
	StringBuffer sb = new StringBuffer(150);
	for(int i=0; i<encodeString.length(); i+=7) {
		if (i+7 <= encodeString.length()) {
			tmp = encodeString.substring(i, i+7);
		}
		else {
			continue;
		}
		c = Integer.parseInt(tmp, 8);
		c3 = c % 100;
		c2 = (c / 100) % 100;
		c1 = (c / 10000);
		sb.append(transIntToAscii(c1));
		if (c2 == 0) {
			break;
		}
		sb.append(transIntToAscii(c2));
		if (c3 == 0) {
			break;
		}
		sb.append(transIntToAscii(c3));
	}
	return sb.toString();
}

decodeOct7NotAscii(final String encodeString)
{
	int c = 0;
	int bitCount = 0, cTmp;
	StringBuffer sb = new StringBuffer(150);
	for(int i=0; i<encodeString.length(); i++) {
		c = (c<<3) | transCharToInt(encodeString.charAt(i));
		bitCount += 3;
		if (bitCount >= 4) {
			cTmp = c & getMask(bitCount - 4);
			c = c >> (bitCount - 4);
			sb.append(Integer.toHexString(c).toUpperCase());
			c = cTmp;
			bitCount -= 4;
		}
	}

	return decodeUnicodeUpgrade(sb.toString());
}
#endif
int Utils::getMask(int size)
{
    switch(size) {
        case 1:
            return 1;
        case 2:
            return 3;
        case 3:
            return 7;
        default:
            return 0;
    }
}
int Utils::transCharToInt(char c)
{
    switch(c) {
        case 'F':
            return 15;
        case 'E':
            return 14;
        case 'D':
            return 13;
        case 'C':
            return 12;
        case 'B':
            return 11;
        case 'A':
            return 10;
        case '9':
            return 9;
        case '8':
            return 8;
        case '7':
            return 7;
        case '6':
            return 6;
        case '5':
            return 5;
        case '4':
            return 4;
        case '3':
            return 3;
        case '2':
            return 2;
        case '1':
            return 1;
        case '0':
        default:
            return 0;
    }
}

int Utils::transInt2Hex(int a)
{
    switch(a) {
        case 15:
            return 'F';
        case 14:
            return 'E';
        case 13:
            return 'D';
        case 12:
            return 'C';
        case 11:
            return 'B';
        case 10:
            return 'A';
        case 9:
            return '9';
        case 8:
            return '8';
        case 7:
            return '7';
        case 6:
            return '6';
        case 5:
            return '5';
        case 4:
            return '4';
        case 3:
            return '3';
        case 2:
            return '2';
        case 1:
            return '1';
        case 0:
            return '0';
        default:
            cout<<"transInt2Hex is err ! "<<a<<endl;
            return 0;
    }
}

char Utils::transIntToAscii(int intValue)
{
    if (intValue == 1) {
        return '\t';
    }
    else {
        return (char) (intValue + 0x1E);
    }
}

int Utils::transOctStr2Int(char * octStr,int num)
{
    int a = 0;
    if(NULL == octStr)
    {
        cout<<"string is NULL"<<endl;
        return 0;
    }
    for(int i=0; i<num; i++)
        a = a*8 + transCharToInt(octStr[i]);

    return a;
}

int Utils::translate_oct2hex(char *hex_buf, char *oct_buf,int length)
{
    int hex_len = 0;
    char fist_letter = oct_buf[0];
    //printf("fist_letter is %c  length is %d \n", fist_letter, length);
    if(fist_letter == '1')
    {
        int c = 0;
        int bitCount = 0, cTmp;
        //char * sb = calloc(150, 1);
        for(int i=1; i< length ; i++) {
            c = (c<<3) | transCharToInt(oct_buf[i]);
            bitCount += 3;
            if (bitCount >= 4) {
                cTmp = c & getMask(bitCount - 4);
                c = c >> (bitCount - 4);
                //sb.append(Integer.toHexString(c).toUpperCase());
                hex_buf[hex_len++] = transInt2Hex(c);
                c = cTmp;
                bitCount -= 4;
            }
        }
        //free(sb);
        return hex_len;
    }
    else
    {
        int c, c1, c2, c3;
        char * tmp;
        //StringBuffer sb = new StringBuffer(150);
        for(int i=1; i<(length - 1); i+=7) {
            if (i+7 <= length) {
                tmp = &oct_buf[i];//encodeString.substring(i, i+7);
            }
            else {
                continue;
            }
            //c = Integer.parseInt(tmp, 8);
            c = transOctStr2Int(tmp,7);
            c3 = c % 100;
            c2 = (c / 100) % 100;
            c1 = (c / 10000);
            //printf("%d %d %d i %d\n", c1, c2, c3 ,i);
            //sb.append(transIntToAscii(c1));
            hex_buf[hex_len++] = transInt2Hex((transIntToAscii(c1)>>4)&0xF);
            hex_buf[hex_len++] = transInt2Hex(transIntToAscii(c1)&0xF);
            if (c2 == 0) {
                break;
            }
            //sb.append(transIntToAscii(c2));
            hex_buf[hex_len++] = transInt2Hex((transIntToAscii(c2)>>4)&0xF);
            hex_buf[hex_len++] = transInt2Hex(transIntToAscii(c2)&0xF);
            if (c3 == 0) {
                break;
            }
            //sb.append(transIntToAscii(c3));
            hex_buf[hex_len++] = transInt2Hex((transIntToAscii(c3)>>4)&0xF);
            hex_buf[hex_len++] = transInt2Hex(transIntToAscii(c3)&0xF);
        }
        //return sb.toString();

    }
    return hex_len;
}

bool Utils::findOrder(int before, int after, long src[], int dst[])
{
    if (after<=before){
        return false;
    }else{
        if (src[before]>src[before+1]){
            dst[0] = before;
            dst[1] = before+1;
        }else{
            dst[0] = before+1;
            dst[1] = before;
        }

        for (int i=before+2; i<=after; i++){
            dst[i-before] = i;

            for (int m=0; m<i-before; m++){
                if (src[i]>src[dst[m]]){
                    for (int n=i-before; n>m; n--){
                        dst[n] = dst[n-1];
                    }
                    dst[m] = i;
                    break;
                }
            }
        }
        return true;
    }
}

// 查找数组最大值
int Utils::findMax(int before, int after, long array[])
{
    if(before > after)
    {
        return -1;
    }
    else
    {
        while (before < after)
        {
            if(array[before] < array[after])
                ++before;
            else
                --after;
        }
        return after;
    }
}

void Utils::findMaxSecond(int before, int after, long array[], int &iMax, int &iSecond)
{
    if (array[before]>array[before+1]){
        iMax = before;
        iSecond = before+1;
    }else{
        iMax = before+1;
        iSecond = before;
    }
    for (int i=before+2; i<=after; i++){
        if (array[i]>array[iMax]){
            iSecond = iMax;
            iMax = i;
        }else if (array[i]>array[iSecond]){
            iSecond = i;
        }
    }
    return;
}


// 将输入字符创转换为数组
int Utils::string2array(char *id, int *array) {
    int len = (int)strlen(id);
    int d = 0;
    for (int i = 0; i < len; i++) {
        char ch = id[i];
        switch (ch) {
            case '0':
                d = 0;
                break;
            case '1':
                d = 1;
                break;
            case '2':
                d = 2;
                break;
            case '3':
                d = 3;
                break;
            case '4':
                d = 4;
                break;
            case '5':
                d = 5;
                break;
            case '6':
                d = 6;
                break;
            case '7':
                d = 7;
                break;
            default:
                d = -1;
                break;
        }
        array[i] = d;
    }
    return 0;
}
