//
//  MitLoadingConfig.h
//  RBLoadingViewHUD
//
//  Created by william on 16/11/4.
//  Copyright © 2016年 Roobo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define MitLoadingConfigManager [MitLoadingConfig sharedManager]
@interface MitLoadingConfig : NSObject
/** 动画视图 （过度动画默认使用动画视图第一帧图片）*/
@property (nonatomic, strong) NSArray * mit_animateImages;
/** 失败 */
@property (nonatomic, strong) UIImage * mit_successImg;
/** 成功 */
@property (nonatomic, strong) UIImage * mit_errorImg;
/** 提醒视图（提醒默认没有视图） */
@property (nonatomic, strong) UIImage * mit_noticeImg;
/** 动画持续时间 */
@property (nonatomic, assign) NSInteger mit_animteDuration;
/**  Default蒙版类型的背景颜色 */
@property (nonatomic, strong) UIColor * mit_maskNoneTypeColor;
/**  Clear 蒙版类型的背景颜色 */
@property (nonatomic, strong) UIColor * mit_maskClearTypeColor;
/**  Black 蒙版类型的背景颜色 */
@property (nonatomic, strong) UIColor * mit_maskBlackTypeColor;
/**  Default 蒙版文本颜色 */
@property (nonatomic, strong) UIColor * mit_maskNoneTxtColor;
/**  Clear 蒙版文本颜色 */
@property (nonatomic, strong) UIColor * mit_maskClearTxtColor;
/**  Black 蒙版文本颜色 */
@property (nonatomic, strong) UIColor * mit_maskBlackTxtColor;

/**
 *  初始化
 *
 */
+ (instancetype)sharedManager;
@end
