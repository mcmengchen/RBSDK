//
//  RBSDKEncrypt.h
//  Pods
//
//  Created by baxiang on 16/11/15.
//
//

#import <Foundation/Foundation.h>

/**
  数据加密
 */
@interface RBSDKEncrypt : NSObject

// 加密方法
+ (NSString*)encrypt:(NSString*)plainText;

// 解密方法
+ (NSString*)decrypt:(NSString*)encryptText;

@end


