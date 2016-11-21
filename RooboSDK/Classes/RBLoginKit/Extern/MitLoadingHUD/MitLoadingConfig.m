//
//  MitLoadingConfig.m
//  RBLoadingViewHUD
//
//  Created by william on 16/11/4.
//  Copyright © 2016年 Roobo. All rights reserved.
//

#import "MitLoadingConfig.h"
#import "NSBundle+MitLoading.h"
@implementation MitLoadingConfig
+(instancetype)sharedManager{
    return [[self alloc]init];
}

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static MitLoadingConfig * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [super allocWithZone:zone];
    });
    return manager;
}

#pragma mark - action: 重写动画视图数组方法，如果没有设置动画视图数组，返回默认
-(NSArray *)mit_animateImages{
    if (!_mit_animateImages) {
        _mit_animateImages = [NSBundle mit_animateImages];
    }
    return _mit_animateImages;
}

@end
