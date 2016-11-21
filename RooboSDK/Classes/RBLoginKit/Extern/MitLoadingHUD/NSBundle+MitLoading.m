//
//  NSBundle+MitLoading.m
//  RBLoadingViewHUD
//
//  Created by william on 16/11/7.
//  Copyright © 2016年 Roobo. All rights reserved.
//

#import "NSBundle+MitLoading.h"
#import "MitLoadingView.h"
@implementation NSBundle (MitLoading)


+ (instancetype)mit_loadingBundle
{
    static NSBundle * loadingBundle = nil;
    if (loadingBundle == nil) {
        loadingBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[MitLoadingView class]] pathForResource:@"MitLoading" ofType:@"bundle"]];
    }
    return loadingBundle;
}



#pragma mark - action: 获取动画图片
+(NSArray *)mit_animateImages{
    NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
    for (int i = 1; i<27; i++) {
        UIImage * img = [UIImage imageWithContentsOfFile:[[NSBundle mit_loadingBundle] pathForResource:[NSString stringWithFormat:@"loading_%d@2x",i] ofType:@"png"]];
        [arr addObject:img];
    }
    return [arr copy];
}

+(UIImage *)mit_getImgWithName:(NSString *)imgName{
    CGFloat scale = [UIScreen mainScreen].scale;
    int num = 0;
    if (scale <2.0  ) {
        num = 2;
    }else{
        num = (int)scale;
    }
    UIImage * img = [UIImage imageWithContentsOfFile:[[NSBundle mit_loadingBundle] pathForResource:[NSString stringWithFormat:@"%@@%dx",imgName,num] ofType:@"png"]];
    return  img;
}

+(UIImage *)mit_getImgWithName:(NSString *)imgName SinglePixel:(BOOL)isPixel{
    if (isPixel) {
        UIImage * img = [UIImage imageWithContentsOfFile:[[NSBundle mit_loadingBundle] pathForResource:[NSString stringWithFormat:@"%@",imgName] ofType:@"png"]];
        return  img;
    }else{
        CGFloat scale = [UIScreen mainScreen].scale;
        int num = 0;
        if (scale <2.0  ) {
            num = 2;
        }else{
            num = (int)scale;
        }
        UIImage * img = [UIImage imageWithContentsOfFile:[[NSBundle mit_loadingBundle] pathForResource:[NSString stringWithFormat:@"%@@%dx",imgName,num] ofType:@"png"]];
        return  img;
        
    }

}



+(NSString *)mit_localizedStringForKey:(NSString *)key{
    return [self mit_localizedStringForKey:key value:nil];
}
+ (NSString *)mit_localizedStringForKey:(NSString *)key value:(NSString *)value
{
    static NSBundle *bundle = nil;
    if (bundle == nil) {
        //目前只处理中文，英文，俄文
        NSString *language = [NSLocale preferredLanguages].firstObject;
        if ([language hasPrefix:@"en"]) {
            language = @"en";  //英文
        } else if ([language hasPrefix:@"zh"]) {
            language = @"zh-Hans"; // 简体中文
            
        }else {
            language = @"en";
        }
        // 从RBError.bundle中查找资源
        bundle = [NSBundle bundleWithPath:[[NSBundle mit_loadingBundle] pathForResource:language ofType:@"lproj"]];
    }
    value = [bundle localizedStringForKey:key value:value table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
}


@end
