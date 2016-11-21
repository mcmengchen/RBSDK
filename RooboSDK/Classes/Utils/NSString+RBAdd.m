//
//  NSString+RBAdd.m
//  Pods
//
//  Created by baxiang on 16/11/13.
//
//

#import "NSString+RBAdd.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
@implementation NSString (RBAdd)

- (NSString *)md5HexDigest
{
    NSString * input = [NSString stringWithFormat:@"geG^_s[3Kl%@",self];
    const char *cStr = [input UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end
