//
//  ZYPlayVideo.h
//  ZYAssist
//
//  Created by Zhi Kuiyu on 15/2/4.
//  Copyright (c) 2015年 Zhi Kuiyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RBPlayVideo : NSObject
/**
 *播放音乐文件
 */
+(BOOL)playMusic:(NSString *)filename;
/**
 *暂停播放
 */
+(void)pauseMusic:(NSString *)filename;
/**
 *停止播放音乐文件
 */
+(void)stopMusic:(NSString *)filename;

+ (NSTimeInterval)musicDruction:(NSString *)filename;

+ (BOOL)playMusicURL:(NSString *)urlStr;

+ (void)playTap:(NSString *)fileName;
@end
