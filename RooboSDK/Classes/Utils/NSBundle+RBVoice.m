//
//  NSBundle+RBVoice.m
//  Pods
//
//  Created by william on 16/11/17.
//
//

#import "NSBundle+RBVoice.h"
#import "RBPlayVideo.h"

@implementation NSBundle (RBVoice)

+ (instancetype)rb_RBVoiceBundle
{
    static NSBundle * loadingBundle = nil;
    if (loadingBundle == nil) {
        loadingBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[RBPlayVideo class]] pathForResource:@"RBVoice" ofType:@"bundle"]];
    }
    return loadingBundle;
}
+(NSString *)openVoiceConfigSourcePath{
    NSString * urlStr = [[NSBundle rb_RBVoiceBundle]pathForResource:@"opensoudwave" ofType:@"mp3"];
    return urlStr;
}
@end
