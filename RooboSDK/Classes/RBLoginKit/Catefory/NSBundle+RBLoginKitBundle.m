//
//  NSBundle+RBLoginKitBundle.m
//  Pods
//
//  Created by william on 16/11/15.
//
//

#import "NSBundle+RBLoginKitBundle.h"
#import <UIKit/UIKit.h>
#import "RBLoginConfig.h"
@implementation NSBundle (RBLoginKitBundle)
+ (instancetype)rb_LoginKit_loadingBundle
{
    static NSBundle * loadingBundle = nil;
    if (loadingBundle == nil) {
        loadingBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[RBLoginConfig class]] pathForResource:@"RBLoginKit" ofType:@"bundle"]];
    }
    return loadingBundle;
}


+(UIImage *)rb_LoginKit_ImgWithImgName:(NSString *)imgName{
    CGFloat scale = [UIScreen mainScreen].scale;
    int num = 0;
    if (scale <2.0  ) {
        num = 2;
    }else{
        num = (int)scale;
    }
    UIImage * img = [UIImage imageWithContentsOfFile:[[NSBundle rb_LoginKit_loadingBundle] pathForResource:[NSString stringWithFormat:@"%@@%dx",imgName,num] ofType:@"png"]];
    return img;
}
@end
