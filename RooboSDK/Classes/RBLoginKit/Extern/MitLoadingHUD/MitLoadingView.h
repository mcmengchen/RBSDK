//
//  MitLoadingView.h
//  渐变层动画
//
//  Created by william on 16/1/5.
//  Copyright © 2016年 Roobo. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  蒙版类型
 */
typedef NS_ENUM(NSUInteger, MitLoadingViewMaskType) {
    MitLoadingViewMaskTypeNone,
    MitLoadingViewMaskTypeClear,
    MitLoadingViewMaskTypeBlack,
};
/**
 *  当前视图类型
 */
typedef NS_ENUM(NSUInteger, MitLoadingType) {
    MitLoadingTypeLoading,
    MitLoadingTypeError,
    MitLoadingTypeSucceed,
    MitLoadingTypeNotice,
};






@interface MitLoadingView : UIView

+ (instancetype)sharedView;
+ (void)show;
+ (void)showWithStatus:(NSString *)status;
+ (void)showWithStatus:(NSString *)status delayTime:(CGFloat)delayTime;
+ (void)showWithStatus:(NSString *)status maskType:(MitLoadingViewMaskType)maskType;
+ (void)showWithStatus:(NSString *)status maskType:(MitLoadingViewMaskType)maskType type:(MitLoadingType)type;

/** 显示错误 */
#pragma mark 显示错误
/**
 *  显示错误最简单的创建方法
 *
 *  @param status 状态文字
 */
+ (void)showErrorWithStatus:(NSString *)status;



/**
 *  显示错误
 *
 *  @param status    状态文字
 *  @param transform  transform
 */
+ (void)showErrorWithStatus:(NSString *)status transform:(CGAffineTransform)transform;

/**
 *  显示错误 + 蒙版状态
 *
 *  @param status   状态文字
 *  @param maskType 蒙版状态
 */
+ (void)showErrorWithStatus:(NSString *)status
                   maskType:(MitLoadingViewMaskType)maskType;

/**
 *  显示错误 + 延迟消失时间
 *
 *  @param status    状态文字
 *  @param delayTime 延迟时间
 */
+ (void)showErrorWithStatus:(NSString *)status
                  delayTime:(CGFloat)delayTime;

/**
 *  显示错误 + 是否是竖屏
 *
 *  @param status     状态文字
 *  @param isvertical 是否是竖屏
 */
+ (void)showErrorWithStatus:(NSString *)status
                  isVertical:(CGAffineTransform)isvertical;

/**
 *  显示错误 + 延迟消失时间 + 是否是竖屏
 *
 *  @param status     状态文字
 *  @param delayTime  延迟时间
 *  @param isvertical 是否是竖屏
 *  @discussion isvertical：yes 为竖屏
 */
+ (void)showErrorWithStatus:(NSString *)status
                  delayTime:(CGFloat)delayTime
                 isVertical:(CGAffineTransform)isvertical;

/**
 *  显示错误 + 延迟创建时间
 *
 *  @param status    状态文字
 *  @param afterTime 延迟创建时间
 */
+ (void)showErrorWithStatus:(NSString *)status
                  afterTime:(CGFloat)afterTime;

/**
 *  显示错误 + 延迟创建时间 + 是否是竖屏
 *
 *  @param status     状态文字
 *  @param afterTime  延迟创建时间
 *  @param isvertical 是否是竖屏
 */
+ (void)showErrorWithStatus:(NSString *)status
                  afterTime:(CGFloat)afterTime
                 isVertical:(CGAffineTransform)isvertical;

/**
 *  显示错误 + 延迟消失时间 + 延迟创建时间
 *
 *  @param status    状态文字
 *  @param delayTime 延迟消失时间
 *  @param afterTime 延迟创建时间
 */
+ (void)showErrorWithStatus:(NSString *)status
                  delayTime:(CGFloat)delayTime
                  afterTime:(CGFloat)afterTime;

/**
 *  显示错误 + 延迟消失时间 + 延迟创建时间 + 是否是横竖屏
 *
 *  @param status     状态文字
 *  @param delayTime  延迟消失时间
 *  @param afterTime  延迟创建时间
 *  @param isvertical 是否是竖屏
 */
+ (void)showErrorWithStatus:(NSString *)status
                  delayTime:(CGFloat)delayTime
                  afterTime:(CGFloat)afterTime
                 isVertical:(CGAffineTransform)isvertical;

/**
 *  显示错误 + 延迟消失时间 + 蒙版类型
 *
 *  @param status    状态文字
 *  @param delayTime 延迟消失时间
 *  @param maskType  蒙版类型
 */
+ (void)showErrorWithStatus:(NSString *)status
                  delayTime:(CGFloat)delayTime
                   maskType:(MitLoadingViewMaskType)maskType;

/**
 *  显示错误 + 延迟消失时间 + 蒙版类型 + 延迟创建时间 + 是否是竖屏
 *
 *  @param status     状态文字
 *  @param delayTime  延迟消失时间
 *  @param maskType   蒙版类型
 *  @param afterTime  延迟创建时间
 *  @param isvertical 是否是竖屏
 */
+ (void)showErrorWithStatus:(NSString *)status
                  delayTime:(CGFloat)delayTime
                   maskType:(MitLoadingViewMaskType)maskType
                  afterTime:(CGFloat)afterTime
                 isVertical:(CGAffineTransform)isvertical;

//显示成功
#pragma mark - 显示成功
+ (void)showSuceedWithStatus:(NSString *)status;
+ (void)showSuceedWithStatus:(NSString *)status afterTime:(CGFloat)afterTime;
+ (void)showSuceedWithStatus:(NSString *)status delayTime:(CGFloat)delayTime;
+ (void)showSuceedWithStatus:(NSString *)status delayTime:(CGFloat)delayTime afterTime:(CGFloat)afterTime;
+ (void)showSuceedWithStatus:(NSString *)status maskType:(MitLoadingViewMaskType)maskType;
+ (void)showSuceedWithStatus:(NSString *)status isVertical:(CGAffineTransform )transfrom;
//显示提醒
#pragma mark - 显示提醒
+ (void)showNoticeWithStatus:(NSString *)status;
+ (void)showNoticeWithStatus:(NSString *)status mskType:(MitLoadingViewMaskType)maskType;


+ (void)dismiss;
+ (void)dismissDelay:(CGFloat)delayTime;
@end
