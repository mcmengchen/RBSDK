//
//  NSBundle+MitLoading.h
//  RBLoadingViewHUD
//
//  Created by william on 16/11/7.
//  Copyright © 2016年 Roobo. All rights reserved.
//

#import <Foundation/Foundation.h>
#define MitLoading_Localized(key) [NSBundle mit_localizedStringForKey:(key)]
@interface NSBundle (MitLoading)
+ (NSArray  *)mit_animateImages;
+ (UIImage  *)mit_getImgWithName:(NSString *)imgName;
+ (UIImage  *)mit_getImgWithName:(NSString *)imgName SinglePixel:(BOOL)isPixel;
+ (NSString *)mit_localizedStringForKey:(NSString *)key;
+ (NSString *)mit_localizedStringForKey:(NSString *)key value:(NSString *)value;
@end
