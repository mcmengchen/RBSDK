//
//  RBPlayVideo.m
//  ZYAssist
//
//  Created by Zhi Kuiyu on 15/2/4.
//  Copyright (c) 2015年 Zhi Kuiyu. All rights reserved.
//

#import "RBPlayVideo.h"
#import <AVFoundation/AVFoundation.h>
@implementation RBPlayVideo


/**
 *存放所有的音乐播放器
 */
static NSMutableDictionary *_musices;
static AVAudioPlayer       *_singlePlayer;
+(NSMutableDictionary *)musices
{
    if (_musices==nil) {
        _musices=[NSMutableDictionary dictionary];
    }
    return _musices;
}

+ (void)playTap:(NSString *)fileName{
    
    if (!fileName) return ;//如果没有传入文件名，那么直接返回

    if(_singlePlayer){
        [_singlePlayer stop];
        _singlePlayer = nil;
    }
    NSURL *url=[[NSBundle mainBundle]URLForResource:fileName withExtension:nil];
    if (!url) return ;//如果url为空，那么直接返回
    _singlePlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
    if (![_singlePlayer prepareToPlay]) return ;//如果缓冲失败，那么就直接返回
    [_singlePlayer play];

    
}


+ (BOOL)playMusicURL:(NSString *)urlStr{
    
    if (!urlStr) return NO;//如果没有传入文件名，那么直接返回
    [RBPlayVideo stopAllMusic];

    //1.取出对应的播放器
    AVAudioPlayer *player=[self musices][urlStr];
    
    //2.如果播放器没有创建，那么就进行初始化
    if (!player) {
        //2.1音频文件的URL
        NSURL *url = [NSURL URLWithString:urlStr]  ;
        if (!url) return NO;//如果url为空，那么直接返回
        
//        //2.2创建播放器
//        player = [[AVPlayer alloc] initWithURL:url];
//        //2.3缓冲
//        if (![player prepareToPlay]) return NO;//如果缓冲失败，那么就直接返回

        
        NSData *mydata=[[NSData alloc]initWithContentsOfURL:url];
        
        player=[[AVAudioPlayer alloc]initWithData:mydata error:nil];
        
        if (![player prepareToPlay]) return NO;//如果缓冲失败，那么就直接返回
        
        //2.4存入字典
        [self musices][urlStr]=player;
    }
    
    //3.播放
    if (![player isPlaying]) {
        //如果当前没处于播放状态，那么就播放
        return [player play];
    }
    
    return YES;//正在播放，那么就返回YES


}

+ (void)stopAllMusic{
    for(NSString * filename in [[self musices] allKeys]){
        //1.取出对应的播放器
        AVAudioPlayer *player=[self musices][filename];
        
        //2.停止
        [player stop];
    }
    
    //3.将播放器从字典中移除
    [[self musices] removeAllObjects];
}
/**
 *播放音乐
 */
+(BOOL)playMusic:(NSString *)filename
{
    if (!filename) return NO;//如果没有传入文件名，那么直接返回
    //1.取出对应的播放器
    [RBPlayVideo stopAllMusic];
    
    AVAudioPlayer *player=[self musices][filename];
    
    //2.如果播放器没有创建，那么就进行初始化
    if (!player) {
        //2.1音频文件的URL
        NSURL *url=[[NSBundle mainBundle]URLForResource:filename withExtension:nil];
        if (!url) {
            url = [NSURL fileURLWithPath:filename];
            if(!url)
                return NO;
        }
        //2.2创建播放器
        player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
        
        //2.3缓冲
        if (![player prepareToPlay]) return NO;//如果缓冲失败，那么就直接返回
        //2.4存入字典
        [self musices][filename]=player;
    }
    
    //3.播放
    if (![player isPlaying]) {
        //如果当前没处于播放状态，那么就播放
        return [player play];
    }
    
    return YES;//正在播放，那么就返回YES
}


+ (NSTimeInterval)musicDruction:(NSString *)filename{

    if (!filename) return 0;//如果没有传入文件名，那么就直接返回
    
    //1.取出对应的播放器
    AVAudioPlayer *player=[self musices][filename];
    
    return [player duration];

}

+(void)pauseMusic:(NSString *)filename
{
    if (!filename) return;//如果没有传入文件名，那么就直接返回
    
    //1.取出对应的播放器
    AVAudioPlayer *player=[self musices][filename];
    
    //2.暂停
    [player pause];//如果palyer为空，那相当于[nil pause]，因此这里可以不用做处理
    
}

+(void)stopMusic:(NSString *)filename
{
    if (!filename) return;//如果没有传入文件名，那么就直接返回
    
    //1.取出对应的播放器
    AVAudioPlayer *player=[self musices][filename];
    
    //2.停止
    [player stop];

    //3.将播放器从字典中移除
    [[self musices] removeObjectForKey:filename];
    [_singlePlayer stop];

}

@end
