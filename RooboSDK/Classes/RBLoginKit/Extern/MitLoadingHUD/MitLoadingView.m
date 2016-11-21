//
//  MitLoadingView.m
//  渐变层动画
//
//  Created by william on 16/1/5.
//  Copyright © 2016年 Roobo. All rights reserved.
//

#import "MitLoadingView.h"
#import <QuartzCore/QuartzCore.h>
#import "RBLoginConfig.h"
#import "UIView+RBLayoutExtension.h"
#import "NSBundle+MitLoading.h"

@interface MitLoadingView()
@property (nonatomic, weak) UIView * maskView;              /**< 蒙版 */
@property (nonatomic, weak) UIImageView * animateImgV;      /**< 动画视图 */
@property (nonatomic, weak) UIImageView * animateCenterImg; /**< 动画中间视图 */
@property (nonatomic, weak) UILabel * statusLab;            /**< 状态文本 */
@property (nonatomic, assign) MitLoadingType viewType;      /**< 当前界面类型 */
@property (nonatomic, strong) UIImage * img;                /**< 图片 */
@property (nonatomic, strong) NSString * statusTxt;         /**< 状态文本 */
@property (nonatomic, strong) UIColor * txtColor;           /**< 文本颜色 */
@property (nonatomic, weak) UIWindow * mainWindow;          /**< 主要的窗口 */
@property (nonatomic, weak) UIView  * backView;             /**< 背景视图 */
@property (nonatomic, strong) NSTimer *fadeOutTimer;        /**< 消失定时器 */
@property (nonatomic, assign) CGFloat delayTime;            /**< 持续时间 */
@property (nonatomic, assign) CGFloat afterTime;            /**< 延时执行时间 */


@end


@implementation MitLoadingView


#pragma mark ------------------- 单例创建方法 ------------------------
+ (instancetype)sharedView{
    static MitLoadingView * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MitLoadingView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    });
    return instance;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor redColor];
        self.userInteractionEnabled = NO;
    }
    return self;
}


#pragma mark ------------------- 显示状态信息 ------------------------
+ (void)show{
    [MitLoadingView dismiss];
    [self showWithStatus:nil];
}
+ (void)showWithStatus:(NSString *)status{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MitLoadingView dismiss];
        [self showWithStatus:status maskType:MitLoadingViewMaskTypeNone];
    });

}
+ (void)showWithStatus:(NSString *)status delayTime:(CGFloat)delayTime{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MitLoadingView dismiss];
        [[self sharedView]showStatus:status maskType:MitLoadingViewMaskTypeNone type:MitLoadingTypeLoading delayTime:delayTime isVertical:CGAffineTransformIdentity];
    });
}
+ (void)showWithStatus:(NSString *)status maskType:(MitLoadingViewMaskType)maskType{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MitLoadingView dismiss];
        [[self sharedView]showStatus:status maskType:maskType type:MitLoadingTypeLoading delayTime:MAXFLOAT isVertical:CGAffineTransformIdentity];
    });

}
+ (void)showWithStatus:(NSString *)status maskType:(MitLoadingViewMaskType)maskType type:(MitLoadingType)type{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MitLoadingView dismiss];
        [[self sharedView]showStatus:status maskType:maskType type:type delayTime:0 isVertical:CGAffineTransformIdentity];
    });
    
}



#pragma mark ------------------- 显示错误信息 ------------------------
+ (void)showErrorWithStatus:(NSString *)status{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MitLoadingView dismiss];
        [[self sharedView]showStatus:status maskType:0 type:MitLoadingTypeError delayTime:0 isVertical:CGAffineTransformIdentity];
    });
}

+(void)showErrorWithStatus:(NSString *)status transform:(CGAffineTransform)transform{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MitLoadingView dismiss];
        [[self sharedView]showStatus:status maskType:0 type:MitLoadingTypeError delayTime:0 isVertical:transform];
    });
}

+(void)showErrorWithStatus:(NSString *)status maskType:(MitLoadingViewMaskType)maskType{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MitLoadingView dismiss];
        [[self sharedView]showStatus:status maskType:maskType type:MitLoadingTypeError delayTime:0 isVertical:CGAffineTransformIdentity];
    });
}
+(void)showErrorWithStatus:(NSString *)status delayTime:(CGFloat)delayTime{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MitLoadingView dismiss];
        [[self sharedView]showStatus:status maskType:0 type:MitLoadingTypeError delayTime:delayTime isVertical:CGAffineTransformIdentity];
    });
}

+(void)showErrorWithStatus:(NSString *)status afterTime:(CGFloat)afterTime{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(afterTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MitLoadingView dismiss];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((afterTime+0.1) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self sharedView] showStatus:status maskType:0 type:MitLoadingTypeError delayTime:0 isVertical:CGAffineTransformIdentity];
    });
}
+ (void)showErrorWithStatus:(NSString *)status isVertical:(CGAffineTransform )transfrom{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MitLoadingView dismiss];
        [[self sharedView] showStatus:status maskType:0 type:MitLoadingTypeError delayTime:0 isVertical:transfrom];
    });
}
+(void)showErrorWithStatus:(NSString *)status delayTime:(CGFloat)delayTime afterTime:(CGFloat)afterTime{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(afterTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MitLoadingView dismiss];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((afterTime+0.1) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self sharedView] showStatus:status maskType:0 type:MitLoadingTypeError delayTime:0 isVertical:CGAffineTransformIdentity];
    });
}

+(void)showErrorWithStatus:(NSString *)status delayTime:(CGFloat)delayTime maskType:(MitLoadingViewMaskType)maskType{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MitLoadingView dismiss];
        [[self sharedView]showStatus:status maskType:maskType type:MitLoadingTypeError delayTime:delayTime isVertical:CGAffineTransformIdentity];
    });
}

+(void)showErrorWithStatus:(NSString *)status afterTime:(CGFloat)afterTime isVertical:(CGAffineTransform)isvertical{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MitLoadingView dismiss];
        [[self sharedView]showStatus:status maskType:0 type:MitLoadingTypeError delayTime:0 isVertical:isvertical];
    });

}
+(void)showErrorWithStatus:(NSString *)status delayTime:(CGFloat)delayTime isVertical:(CGAffineTransform)isvertical{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MitLoadingView dismiss];
        [[self sharedView]showStatus:status maskType:0 type:MitLoadingTypeError delayTime:delayTime isVertical:isvertical];
    });

}
+(void)showErrorWithStatus:(NSString *)status delayTime:(CGFloat)delayTime afterTime:(CGFloat)afterTime isVertical:(CGAffineTransform)isvertical{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((afterTime) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MitLoadingView dismiss];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((afterTime+0.1) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self sharedView]showStatus:status maskType:0 type:MitLoadingTypeError delayTime:delayTime isVertical:isvertical];
    });

}
+(void)showErrorWithStatus:(NSString *)status delayTime:(CGFloat)delayTime maskType:(MitLoadingViewMaskType)maskType afterTime:(CGFloat)afterTime isVertical:(CGAffineTransform)isvertical{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((afterTime) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MitLoadingView dismiss];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((afterTime+0.1) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self sharedView]showStatus:status maskType:maskType type:MitLoadingTypeError delayTime:delayTime isVertical:isvertical];
    });
}




#pragma mark ------------------- 显示成功信息 ------------------------
+(void)showSuceedWithStatus:(NSString *)status{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MitLoadingView dismiss];
        [[self sharedView]showStatus:status maskType:0 type:MitLoadingTypeSucceed delayTime:0 isVertical:CGAffineTransformIdentity];
    });
}
+(void)showSuceedWithStatus:(NSString *)status maskType:(MitLoadingViewMaskType)maskType{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MitLoadingView dismiss];
        [[self sharedView]showStatus:status maskType:maskType type:MitLoadingTypeSucceed delayTime:0 isVertical:CGAffineTransformIdentity];
    });
}
+(void)showSuceedWithStatus:(NSString *)status delayTime:(CGFloat)delayTime{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MitLoadingView dismiss];
        [[self sharedView]showStatus:status maskType:MitLoadingViewMaskTypeNone type:MitLoadingTypeSucceed delayTime:delayTime isVertical:CGAffineTransformIdentity];
    });
}
+(void)showSuceedWithStatus:(NSString *)status afterTime:(CGFloat)afterTime{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(afterTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MitLoadingView dismiss];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((afterTime + .1) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self sharedView]showStatus:status maskType:MitLoadingViewMaskTypeNone type:MitLoadingTypeSucceed delayTime:0 isVertical:CGAffineTransformIdentity];
    });
}
+(void)showSuceedWithStatus:(NSString *)status delayTime:(CGFloat)delayTime afterTime:(CGFloat)afterTime{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(afterTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MitLoadingView dismiss];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((afterTime + .1) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self sharedView]showStatus:status maskType:MitLoadingViewMaskTypeNone type:MitLoadingTypeSucceed delayTime:delayTime isVertical:CGAffineTransformIdentity];
    });
}

+ (void)showSuceedWithStatus:(NSString *)status isVertical:(CGAffineTransform )transfrom{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MitLoadingView dismiss];
        [[self sharedView] showStatus:status maskType:0 type:MitLoadingTypeSucceed delayTime:0 isVertical:transfrom];
    });
}


#pragma mark ------------------- 提示信息 ------------------------
+(void)showNoticeWithStatus:(NSString *)status{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MitLoadingView dismiss];
        [[self sharedView]showStatus:status maskType:0 type:MitLoadingTypeNotice delayTime:0 isVertical:CGAffineTransformIdentity];
    });
}
+ (void)showNoticeWithStatus:(NSString *)status mskType:(MitLoadingViewMaskType)maskType{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MitLoadingView dismiss];
        [[self sharedView]showStatus:status maskType:maskType type:MitLoadingTypeNotice delayTime:0 isVertical:CGAffineTransformIdentity];
    });
}


static const CGFloat kFadeTimeDuration = 1.8;
#pragma mark ------------------- 通用创建方法 ------------------------
- (void)showStatus:(NSString*)status maskType:(MitLoadingViewMaskType)maskType type:(MitLoadingType)type delayTime:(CGFloat)delayTime isVertical:(CGAffineTransform )transfrom{
//    NSLog(@"MitLoadingView 状态文本 == %@",status);
    if([status length] == 0)
        return;
    
    if (self.fadeOutTimer) {
        [[MitLoadingView sharedView] dismiss];
        [UIView animateWithDuration:0.1 animations:^{
            self.maskView.frame = CGRectMake(self.bounds.size.width*0.5, self.bounds.size.height*0.5, 5, 5);
        }completion:^(BOOL finished) {
            [[MitLoadingView sharedView] dismiss];
        }];
    }
    
    /** 1.添加到当前窗口上 */
    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows){
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible = !window.hidden && window.alpha > 0;
        BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;
        
        if (windowOnMainScreen && windowIsVisible && windowLevelNormal) {
            [window addSubview:self.maskView];
            self.mainWindow =window;
            break;
        }
    }
    
    
    /** 2.设置界面的类型 */
    self.viewType = type;
    
    /** 3.设置当前文本 */
    self.statusTxt = status;
    
    /** 4.设置蒙版的类型 */
    switch (maskType) {
        case MitLoadingViewMaskTypeNone:
//            self.maskView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.1];
            self.maskView.backgroundColor = [UIColor clearColor];
            self.txtColor = [UIColor grayColor];
            break;
        case MitLoadingViewMaskTypeBlack:
//            self.maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.9];
            self.maskView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.1];
            self.maskView.userInteractionEnabled = NO;
            self.txtColor = [UIColor grayColor];
            self.userInteractionEnabled = NO;
            break;
        case MitLoadingViewMaskTypeClear:
            self.maskView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.1];
            self.txtColor = [UIColor blackColor];
            break;
    }

    /** 5.设置视图的类型 */
    switch (type) {
        case MitLoadingTypeLoading:
        {
            self.animateImgV.center = CGPointMake(self.center.x-50, self.center.y);
//            self.backView.backgroundColor = [UIColor clearColor];
            [self.animateImgV startAnimating];
        }
            break;
        case MitLoadingTypeError:
        {
            self.animateImgV.center = CGPointMake(self.center.x, self.center.y-50);
            self.statusLab.center = CGPointMake(self.center.x, self.center.y);
        }
            break;
        case MitLoadingTypeSucceed:
        {
            self.animateImgV.center = CGPointMake(self.center.x, self.center.y-50);
            self.statusLab.center = CGPointMake(self.center.x, self.center.y);
        }
            break;
        case MitLoadingTypeNotice:
        {
//            NSLog(@"MitLoadingTypeNotice 不创建动画图片");
        }
            break;
    }

    
    //布局
    [self layoutSubviews];
    self.backView.transform = transfrom;

//    if (transfrom) {
//        UIDevice *device = [UIDevice currentDevice];
//        switch (device.orientation) {
//            case UIDeviceOrientationUnknown:
//                LogWarm(@"Unknown");
//                break;
//                
//            case UIDeviceOrientationFaceUp:
//                LogWarm(@"Device oriented flat, face up");
//                break;
//                
//            case UIDeviceOrientationFaceDown:
//                LogWarm(@"Device oriented flat, face down");
//                break;
//                
//            case UIDeviceOrientationLandscapeLeft:
//                LogWarm(@"Device oriented horizontally, home button on the right");
//                self.backView.transform  = CGAffineTransformRotate(self.backView.transform, M_PI*0.5);
//                
//                break;
//                
//            case UIDeviceOrientationLandscapeRight:
//                LogWarm(@"Device oriented horizontally, home button on the left");
//                self.backView.transform  = CGAffineTransformRotate(self.backView.transform, -M_PI*0.5);
//                
//                break;
//                
//            case UIDeviceOrientationPortrait:
//                LogWarm(@"Device oriented vertically, home button on the bottom");
//                break;
//                
//            case UIDeviceOrientationPortraitUpsideDown:
//                LogWarm(@"Device oriented vertically, home button on the top");
//                break;
//                
//            default:
//                LogWarm(@"cannot distinguish");
//                break;
//        }
//    }
    //设置延时时间
    if (delayTime == 0) {
        self.delayTime = kFadeTimeDuration;
    }else{
        self.delayTime = delayTime;
    }
    
    //开启定时器
    self.fadeOutTimer = [NSTimer timerWithTimeInterval:self.delayTime target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.fadeOutTimer forMode:NSRunLoopCommonModes];
}


#pragma mark ------------------- 添加动画 ------------------------
#pragma mark - loading 动画
- (void)addAnimate{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.fromValue = 0;
    animation.toValue = [NSNumber numberWithFloat:M_PI*2];
    animation.duration = 1;
    animation.removedOnCompletion = NO;
    animation.repeatCount = INFINITY;
    animation.fillMode = kCAFillModeForwards;
    animation.autoreverses = NO;
    [self.animateImgV.layer addAnimation:animation forKey:@"key"];
}
#pragma mark ------------------- 设置界面的类型 ------------------------
-(void)setViewType:(MitLoadingType)viewType{
    _viewType = viewType;
    switch (viewType) {
        case MitLoadingTypeSucceed:
        {
            self.img = [NSBundle mit_getImgWithName:@"icon_tips_success"];
        }
            break;
        case MitLoadingTypeError:
        {
            self.img = [NSBundle mit_getImgWithName:@"icon_tips_fail"];
        }
            break;
        case MitLoadingTypeLoading:
        {
            self.img = [NSBundle mit_getImgWithName:@"loading_1" SinglePixel:false];
        }
            break;
        case MitLoadingTypeNotice:
        {
//            NSLog(@"没有图片");
        }
            break;
    }
}




#pragma mark ------------------- lazy Load ------------------------
#pragma mark - 蒙版视图
- (UIView *)maskView{
    if (!_maskView) {
        UIView*vi = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        vi.alpha = 0.5;
        vi.userInteractionEnabled = YES;
        [self addSubview:vi];
        //        UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click)];
        //        tap.numberOfTapsRequired = 1;
        //        [vi addGestureRecognizer:tap];
        _maskView = vi;
    }
    return _maskView;
}

#pragma mark - 创建 -> 背景视图
-(UIView *)backView{
    if (!_backView) {
        UIView *vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 40)];
        vi.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.8];
        vi.layer.cornerRadius = 5;
        vi.layer.masksToBounds = true;
        [self.mainWindow addSubview:vi];
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
//        tap.numberOfTapsRequired = 1;
//        tap.numberOfTouchesRequired = 1;
//        [tap addTarget:self action:@selector(tapClick)];
//        [vi addGestureRecognizer:tap];
        _backView = vi;
    }
    return _backView;
}
#pragma mark - action: 点击
- (void)tapClick{
    [MitLoadingView dismiss];
}

#pragma mark - 动画视图
-(UIImageView *)animateImgV{
    if (!_animateImgV) {
        UIImageView*img = [[UIImageView alloc]initWithImage:self.img];
        img.center = self.center;
        img.animationImages = [NSBundle mit_animateImages];
        img.animationRepeatCount = MAXFLOAT;
        img.animationDuration = 1.5;
//        [self.mainWindow addSubview:img];
        [self.backView addSubview:img];
        _animateImgV = img;
    }
    return _animateImgV;
}
#pragma mark - 内容文本
- (UILabel *)statusLab{
    if (!_statusLab) {
        UILabel*lab = [[UILabel alloc]init];
        lab.font = [UIFont systemFontOfSize:15];
        lab.textColor = self.txtColor;
        lab.text = self.statusTxt;
        lab.textColor = [UIColor whiteColor];
//        [lab sizeToFit];
        lab.textAlignment = NSTextAlignmentLeft;
//        [self.mainWindow addSubview:lab];
        [self.backView addSubview:lab];
        _statusLab = lab;
    }
    return _statusLab;
}
#pragma mark - 动画中心的购物车
-(UIImageView *)animateCenterImg{
    if (!_animateCenterImg) {
        UIImageView*vi = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_loading_cart"]];
        [self.mainWindow addSubview:vi];
        _animateCenterImg = vi;
    }
    return _animateCenterImg;
}




static const CGFloat kEdgeWidth = 18;
static const CGFloat kLittleEdge = 4;
static const CGFloat kBackViewHeight = 40;
#pragma mark - action: layoutSubviews
-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGSize size = [self sizeWithFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(k_RBLoginKit_ScreenWidth, kBackViewHeight)];
    if (self.viewType == MitLoadingTypeError||self.viewType == MitLoadingTypeSucceed) {
        self.backView.frame = CGRectMake(0, 0, size.width + 2*kEdgeWidth+kLittleEdge + self.animateImgV.width, kBackViewHeight);
        self.backView.center = CGPointMake(self.mainWindow.center.x, self.mainWindow.center.y );
        self.animateImgV.center = CGPointMake(kEdgeWidth+self.animateImgV.width*0.5, self.backView.height*0.5);
        self.statusLab.frame = CGRectMake(kEdgeWidth+self.animateImgV.width+kLittleEdge, (kBackViewHeight -size.height)*0.5, size.width, size.height);
    }else if(self.viewType == MitLoadingTypeNotice){
        self.backView.frame = CGRectMake(0, 0, size.width + 2*kEdgeWidth, kBackViewHeight);
        self.backView.center = CGPointMake(self.mainWindow.center.x, self.mainWindow.center.y );
        self.statusLab.frame = CGRectMake(kEdgeWidth, (kBackViewHeight -size.height)*0.5, size.width, size.height);
    }else{
        self.backView.frame = CGRectMake(0, 0, self.animateImgV.width+2*kEdgeWidth, self.animateImgV.height+kEdgeWidth);
        self.backView.center = CGPointMake(self.mainWindow.center.x, self.mainWindow.center.y );
        self.animateImgV.center = CGPointMake(self.backView.width*0.5, self.backView.height*0.5);
    }
    
    
}

#pragma mark - action: 计算返回的尺寸
-(CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [self.statusTxt boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}


#pragma mark ------------------- 蒙版点击方法 ------------------------
//- (void)click{
//    [self dismiss];
//}


#pragma mark ------------------- 消失的方法 ------------------------
+ (void)dismiss{
    [[self sharedView] dismiss];
    
}
+ (void)dismissDelay:(CGFloat)delayTime{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MitLoadingView dismiss];
    });
}
- (void)dismiss{
    if ([_animateImgV isAnimating]) {
        [_animateImgV stopAnimating];
    }
    [self.fadeOutTimer invalidate];
    self.fadeOutTimer = nil;
    [_animateImgV.layer removeAllAnimations];
    [_maskView removeFromSuperview];
    [_animateImgV removeFromSuperview];
    [_statusLab removeFromSuperview];
    [_animateCenterImg removeFromSuperview];
    [self.backView removeFromSuperview];

    _backView = nil;
    _animateCenterImg = nil;
    _maskView = nil;
    _animateImgV = nil;
    _statusLab = nil;
    self.img = nil;
    [self removeFromSuperview];
}

@end
