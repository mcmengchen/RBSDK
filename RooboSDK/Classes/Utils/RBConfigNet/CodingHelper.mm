//
//  CodingHelper.c
//  TEst
//
//  Created by Zhi Kuiyu on 15/12/15.
//  Copyright © 2015年 Zhi Kuiyu. All rights reserved.
//

#import "CodingHelper.h"

static const NSString * TYPE_OCT7_PURE_ASCII = @"0";
static const NSString * TYPE_OCT7_NOT_ASCII = @"1";
static bool sDisorderResult = false;





bool containsNotAscii(NSString * content){
    if (content == NULL || content.length<=0) {
        return false;
    }
    char * charsContent = (char *)[content UTF8String];
    for(int i=0; i<content.length; i++) {
        if ((charsContent[i]>>8) != 0) {
            return true;
        }
        if (charsContent[i] < 0x20 && charsContent[i] != '\t') {
            return true;
        }
    }
    return false;
}


SInt8* getBypes(NSString * str){
    NSData * data = [str dataUsingEncoding:NSUnicodeStringEncoding];
    SInt8 *unicodeBaytes = (SInt8 *)[data bytes];
    return unicodeBaytes;
}

NSInteger getByteLength(NSString * str){
    NSData * data = [str dataUsingEncoding:NSUnicodeStringEncoding];
    return data.length;
}

bool isMisorderSystem() {
    if (sDisorderResult == false) {
        SInt8 * unicodeBytes;
        unicodeBytes = getBypes(@"123");
        sDisorderResult = (unicodeBytes[0] != -2);
    }
    return sDisorderResult;
    
}

void swap(SInt8 * data,NSInteger length) {
    SInt8 tmpByte;
    
    for(int i=0; i<length; i+=2) {
        if (i+1 >=length) {
            break;
        }
        tmpByte = data[i];
        data[i] = data[i+1];
        data[i+1] = tmpByte;
    }
}

NSString * byte2HexString(SInt8 b) {
    int tmpInt = 0xff & b;
    NSMutableString * s = [NSMutableString new];
    if (tmpInt < 16) {
        [s appendString:@"0"];
    }
    else {
        [s appendString:@""];
    }
    [s appendFormat:@"%X",tmpInt];
    return s;
}



NSString * encodeUnicodeUpgrade(NSString * content){
    if (content == NULL || content.length<=0) {
        return NULL;
    }

    SInt8 *unicodeBytes = getBypes(content) ;
    NSInteger byteLength = getByteLength(content);
    

    if (isMisorderSystem()) {
        swap(unicodeBytes,byteLength);
    }
 
    NSMutableString * sb = [NSMutableString new];
    NSMutableString * cachedNotAsciiSb = NULL;
    
    int cachedNotAsciiLen = 0;
    int tmpIntHigh, tmpIntLow;
    
    
    
    
    
    for(int i=2; i< byteLength; i+=2) {
        if (i+1 >= byteLength) {
            break;
        
        }
        
        tmpIntHigh = 0xff & unicodeBytes[i];
        tmpIntLow = 0xff & unicodeBytes[i+1];
        if (tmpIntHigh == 0 && (tmpIntLow&0x80)==0) {
            //0 ~ 127, ASCII
            if (cachedNotAsciiSb != NULL) {
                [sb appendFormat:@"%X",16-cachedNotAsciiLen];
                [sb appendString:cachedNotAsciiSb];
                cachedNotAsciiSb = NULL;
                cachedNotAsciiLen = 0;
            }
            [sb appendString:byte2HexString((SInt8)tmpIntLow)];
            continue;
        }
        
        if (cachedNotAsciiSb == NULL) {
            cachedNotAsciiSb = [NSMutableString new];
            cachedNotAsciiLen = 0;
        }
        
        [cachedNotAsciiSb appendString:byte2HexString((SInt8)tmpIntHigh)] ;
        [cachedNotAsciiSb appendString:byte2HexString((SInt8)tmpIntLow)] ;
        
 
        cachedNotAsciiLen++;
        
        if (cachedNotAsciiLen == 8) {
            [sb appendFormat:@"%X",16 - cachedNotAsciiLen];
            [sb appendFormat:@"%@",cachedNotAsciiSb];
            
            cachedNotAsciiSb = NULL;
            cachedNotAsciiLen = 0;
        }
    }
    if (cachedNotAsciiSb != NULL) {
        [sb appendFormat:@"%X",16-cachedNotAsciiLen];
        [sb appendFormat:@"%@",cachedNotAsciiSb];

    }
    return sb;
}

int getMask(int size) {
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

int transCharToInt(char c) {
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


NSString * encodeOct7NotAscii(NSString * content){
    NSString *unicodeUpgrade = [encodeUnicodeUpgrade(content) uppercaseString];
    int c = 0;
    int bitCount = 0, cTmp;
    NSMutableString * sb = [[NSMutableString alloc] initWithCapacity:200];
    for(int i=0; i<unicodeUpgrade.length ; i++) {
        
        c = (c << 4) | transCharToInt([unicodeUpgrade characterAtIndex:i]);
        bitCount += 4;
        while(bitCount >= 3) {
            cTmp = c & getMask(bitCount-3);
            c = c >> (bitCount-3);
            [sb appendFormat:@"%O",c];
            c = cTmp;
            bitCount -= 3;
        }
    }
    if (bitCount > 0) {
        c = c << (3 - bitCount);
        [sb appendFormat:@"%O",c];

    }
    return sb;
}

int transAsciiToInt(char ascii) {
    if (ascii == '\t') {
        return 1;
    }
    else {
        return ascii - 0x1E;
    }
}

NSString* encodeOct7PureAscii(NSString* content) {
    char *charsContent = (char *)[content UTF8String];
    int c, c1, c2, c3;
    NSMutableString * result = [[NSMutableString alloc] initWithCapacity:200];
    NSMutableString * tmp = [[NSMutableString alloc] init];

    for(int i = 0; i<content.length; i+=3) {
        c1 = transAsciiToInt(charsContent[i]);
        if (i+1 < content.length) {
            c2 = transAsciiToInt(charsContent[i+1]);
        }
        else {
            c2 = 0;
        }
        if (i+2 < content.length) {
            c3 = transAsciiToInt(charsContent[i+2]);
        }
        else {
            c3 = 0;
        }
        c = c1 * 100 * 100 + c2 * 100 + c3;
        tmp = [[NSMutableString alloc] initWithFormat:@"%O",c];
        while (tmp.length < 7) {
            NSString * t = [tmp copy];
            tmp = [[NSMutableString alloc] initWithFormat:@"0%@",t];
        }
        [result appendString:tmp];
    }
    return result;
}

NSString* encodeOct7(NSString* content){

    if (containsNotAscii(content)) {
        return [NSString stringWithFormat:@"%@%@",TYPE_OCT7_NOT_ASCII , encodeOct7NotAscii(content)];
    }
    else {
        return [NSString stringWithFormat:@"%@%@",TYPE_OCT7_PURE_ASCII , encodeOct7PureAscii(content)];
    }
}

NSString* encode(NSString * content){
    return encodeOct7(content);
    
}



