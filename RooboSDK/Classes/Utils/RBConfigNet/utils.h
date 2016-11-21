//
// Created by 徐江涛 on 15/12/28.
//

#ifndef PUDDING_UTILS_H
#define PUDDING_UTILS_H


class Utils {
public:
    static char* HexToStr_Upper(char *str, char *hex, int cnt);

    static bool findOrder(int before, int after, long src[], int dst[]);

    static int findMax(int before, int after, long array[]);

    static void findMaxSecond(int before, int after, long array[], int &iMax, int &iSecond);

    static int translate_hex2unicode(char *ret, char *result_buf,int length);

    static int translate_oct2hex(char *hex_buf, char *oct_buf,int length);

    static int transOctStr2Int(char * octStr,int num);

    static char transIntToAscii(int intValue);

    static int transInt2Hex(int a);

    static int transCharToInt(char c);

    static int getMask(int size);

    static char *HexToStr(char *str, char *hex, int cnt);

    static int string2array(char *id, int *array);
//hejq

};


#endif //PUDDING_UTILS_H
