//
//  RBForgetPsdViewController.m
//  Pudding
//
//  Created by william on 16/2/3.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//

#import "RBForgetPsdViewController.h"
#import "RBTextFieldView.h"
#import "MitRegex.h"
#import "NSObject+RBFilterNull.h"
#import "RBHtmlViewController.h"
#import "RBLoginConfig.h"
#import "UIView+RBLayoutExtension.h"
#import "MitLoading.h"
#import "RBAuthApi.h"
#import "UIDevice+RBHardware.h"
#import "NSBundle+RBLoginKitBundle.h"
#import "RBLoginKitManager.h"
#import "UIViewController+RBExtension.h"

typedef NS_ENUM(NSUInteger, RBViewType) {
    RBViewTypeStepOne,
    RBViewTypeStepTwo,
};

@interface RBForgetPsdViewController ()<UITextFieldDelegate>
{
    dispatch_source_t       sendtimer;
}
/** 手机号 */
@property (nonatomic, weak) RBTextFieldView * phoneTxtV;
/** 获取验证码按钮 */
@property (nonatomic, weak) UIButton * getVerifyCodeBtn;
/** 验证码 */
@property (nonatomic, weak) RBTextFieldView * verifyTxtV;
/** 新密码 */
@property (nonatomic, weak) RBTextFieldView * psdTxtV;

/** 重置按钮 */
@property (nonatomic, weak) UIButton * resetBtn;
/** 遇到问题按钮 */
@property (nonatomic, weak) UIButton * problemBtn;
/** 正在等待 */
@property (nonatomic,assign) BOOL isWaiting;
/** 是否注册 */
@property (nonatomic, assign) BOOL isRegist;

/** 键盘动画 */
@property (nonatomic, assign) BOOL isKeyboardAnimate;


/** 第一步背景 */
@property (nonatomic, weak) UIView *stepOneBackView;
/** 第二步背景 */
@property (nonatomic, weak) UIView *stepTwoBackView;


/** 页面步骤 */
@property (nonatomic, assign) RBViewType viewType;
/** 导航视图 */
@property (nonatomic, weak) UIView * navView;
/** 导航文本 */
@property (nonatomic, weak) UILabel * navLab;
/** 返回按钮 */
@property (nonatomic, weak) UIButton * navBackBtn;
@end

@implementation RBForgetPsdViewController


+ (instancetype)show{
    RBForgetPsdViewController * vc = [[RBForgetPsdViewController alloc]init];
    [[UIViewController getCurrentVC] presentViewController:vc animated:true completion:nil];
    return vc;
}

#pragma mark ------------------- lifeCycle ------------------------
#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];

    self.viewType = RBViewTypeStepOne;
    //初始化导航栏
    [self initialNav];

    //手机号
    self.phoneTxtV.hidden = NO;
    
    //获取验证码
    self.getVerifyCodeBtn.hidden = NO;
    self.getVerifyCodeBtn.backgroundColor = k_RBLoginKit_Default_UnAbleColor;
    self.getVerifyCodeBtn.userInteractionEnabled = NO;
    
    //密码
    self.psdTxtV.hidden = NO;
    //验证码
    self.verifyTxtV.hidden = NO;
    
    //重置按钮
    self.resetBtn.layer.cornerRadius = self.resetBtn.height*0.5;
    self.resetBtn.backgroundColor = k_RBLoginKit_Default_UnAbleColor;
    self.view.backgroundColor = k_RBLoginKit_Default_BackColor;
    //遇到问题按钮
//    self.problemBtn.backgroundColor = self.view.backgroundColor;
    
    //是否注册
    self.isRegist = NO;
    
    //观察手机号
    [self.phoneTxtV addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    //观察是否注册属性
    [self addObserver:self forKeyPath:@"isRegist" options:NSKeyValueObservingOptionNew context:nil];
    //观察验证码
    [self.psdTxtV addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    
    /** 添加键盘通知 */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [self.phoneTxtV becomeFirstRespond];
    
}


#pragma mark - 状态栏颜色
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


#pragma mark - action: 观察者模式
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if (object == self.phoneTxtV) {
        if(self.phoneTxtV.text.length == 11&&[self.phoneTxtV isSelected]){
        }
        if (self.phoneTxtV.text.length>0) {
            self.getVerifyCodeBtn.backgroundColor = k_RBLoginKit_Default_MainColor;
            self.getVerifyCodeBtn.userInteractionEnabled = YES;
        }else{
            self.getVerifyCodeBtn.backgroundColor = k_RBLoginKit_Default_UnAbleColor;
            self.getVerifyCodeBtn.userInteractionEnabled = NO;
        }

    }else if (object == self){
        if (self.isRegist == YES) {
            self.getVerifyCodeBtn.backgroundColor = k_RBLoginKit_Default_MainColor;
            self.getVerifyCodeBtn.userInteractionEnabled = YES;
        }else{
            self.getVerifyCodeBtn.backgroundColor = k_RBLoginKit_Default_UnAbleColor;
            self.getVerifyCodeBtn.userInteractionEnabled = NO;
        }

    }else if (object == self.psdTxtV){
        if (self.psdTxtV.text.length>0&&self.verifyTxtV.text.length>0) {
            self.resetBtn.backgroundColor = k_RBLoginKit_Default_MainColor;
            self.resetBtn.userInteractionEnabled = YES;
        }else{
            self.resetBtn.backgroundColor = k_RBLoginKit_Default_UnAbleColor;
            self.resetBtn.userInteractionEnabled = NO;
        }
    }
}


#pragma mark - 初始化导航栏
-(void)initialNav{
    /** 设置导航标题 */
    self.navView.hidden = false;
    self.navLab.text = @"找回密码";
    self.navBackBtn.hidden = false;
    self.view.backgroundColor = k_RBLoginKit_Default_BackColor;
}

#pragma mark - viewWillDisappear
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    [MitLoadingView dismiss];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = true;
    self.navigationController.navigationBarHidden = true;
    
}

#pragma mark - dealloc
-(void)dealloc{
    [self.phoneTxtV removeObserver:self forKeyPath:@"text"];
    [self removeObserver:self forKeyPath:@"isRegist"];
    [self.psdTxtV removeObserver:self forKeyPath:@"text"];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}


#pragma mark ------------------- LazyLoad ------------------------
#pragma mark - 创建 -> 导航视图
-(UIView *)navView{
    if (!_navView) {
        UIView * vi  =[[UIView alloc]initWithFrame:CGRectMake(0, 0, k_RBLoginKit_ScreenWidth, k_RBLoginKit_NavHeight)];
        vi.backgroundColor = k_RBLoginKit_Default_MainColor;
        [self.view addSubview:vi];
        _navView = vi;
    }
    return _navView;
}
#pragma mark - 创建 -> 导航文本
-(UILabel *)navLab{
    if (!_navLab) {
        UILabel * lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.textColor = [UIColor whiteColor];
        lab.center = CGPointMake(self.navView.width*0.5, 20+lab.height*0.5);
        [self.navView addSubview:lab];
        _navLab = lab;
    }
    return _navLab;
}

#pragma mark - 创建 -> 导航返回按钮
- (UIButton *)navBackBtn{
    if (!_navBackBtn) {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 20, 60, 44);
        [btn setImage:[NSBundle rb_LoginKit_ImgWithImgName:@"icon_white_back"] forState:UIControlStateNormal];
        [self.navView addSubview:btn];
        [btn addTarget:self action:@selector(navBackBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _navBackBtn = btn;
    }
    return _navBackBtn;
}

#pragma mark - action: 导航返回按钮点击
- (void)navBackBtnClick:(UIButton *)btn{
    
    
    if (self.viewType == RBViewTypeStepOne) {
        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:true];
        } else {
            [self dismissViewControllerAnimated:true completion:nil];
        }
    }else{
        self.stepOneBackView.hidden = NO;
        [UIView animateWithDuration:0.5 animations:^{
            self.stepOneBackView.center = CGPointMake(self.view.width*0.5, self.stepOneBackView.center.y);
            self.stepTwoBackView.center = CGPointMake(self.view.width*1.5, self.stepTwoBackView.center.y);
        }completion:^(BOOL finished) {
            self.viewType = RBViewTypeStepOne;
        }];
        if(sendtimer){
            dispatch_source_cancel(sendtimer);
            sendtimer = nil;
        }
        [self.verifyTxtV.verifyBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        self.verifyTxtV.verifyBtn.enabled = YES;
        if (_isWaiting) {
            _isWaiting = NO;
        }
        [self.phoneTxtV becomeFirstRespond];
    }
    
    
}



#pragma mark - 创建 -> 第一步骤背景图
-(UIView *)stepOneBackView{
    if (!_stepOneBackView) {
        
        UIView *vi = [[UIView alloc]initWithFrame:CGRectMake(0, k_RBLoginKit_NavHeight, self.view.width, k_RBLoginKit_ScreenHeight - k_RBLoginKit_NavHeight)];
        vi.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:vi];
        _stepOneBackView = vi;
    }
    return _stepOneBackView;
}
#pragma mark - 创建 -> 第二步骤背景图
-(UIView *)stepTwoBackView{
    if (!_stepTwoBackView) {
        UIView *vi = [[UIView alloc]initWithFrame:CGRectMake(self.view.width, k_RBLoginKit_NavHeight, self.view.width, k_RBLoginKit_ScreenHeight - k_RBLoginKit_NavHeight)];
        vi.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:vi];
        _stepTwoBackView = vi;
    }
    return _stepTwoBackView;
}


#pragma mark - 创建 -> 账号
static CGFloat kEdgePacing = 45;
static CGFloat kTxtHeight = 45;
-(RBTextFieldView *)phoneTxtV{
    if (!_phoneTxtV) {
        __weak typeof(self) weakself = self;
        RBTextFieldView * vi = [RBTextFieldView RBTextFieldViewWithFrame:CGRectMake(kEdgePacing, kEdgePacing, self.view.width-2*kEdgePacing, kTxtHeight) Type:RB_TextTypeAccount OnlyBlock:^(UITextField *txtField) {
            txtField.delegate = weakself;
            txtField.placeholder = @"请输入手机号";
            txtField.returnKeyType = UIReturnKeyNext;
            txtField.textColor = k_RBLoginKit_Default_TextColor;
            txtField.backgroundColor = [UIColor clearColor];
            txtField.keyboardType = UIKeyboardTypePhonePad;
            txtField.font = [UIFont fontWithName:k_RBLoginKit_DefaultFontName size:k_RBLoginKit_DefaultFontSize - 1];
        }];
        vi.selected = NO;
        [self.stepOneBackView addSubview:vi];
        _phoneTxtV = vi;
    }
    return _phoneTxtV;
}

#pragma mark - 创建 -> 获取验证码按钮
-(UIButton *)getVerifyCodeBtn{
    if (!_getVerifyCodeBtn) {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(kEdgePacing, self.phoneTxtV.bottom+kEdgePacing, k_RBLoginKit_ScreenWidth - 2*kEdgePacing, kTxtHeight);
        btn.backgroundColor = k_RBLoginKit_Default_MainColor;
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitle:@"获取验证码" forState:UIControlStateNormal];
        btn.layer.cornerRadius = btn.height *0.5;
        btn.layer.masksToBounds = true;
        [btn addTarget:self action:@selector(getVerifyCodeBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.stepOneBackView addSubview:btn];
        _getVerifyCodeBtn = btn;
    }
    return _getVerifyCodeBtn;
    
    
    
    
}


#pragma mark - 创建 -> 密码
-(RBTextFieldView *)psdTxtV{
    if (!_psdTxtV) {
        __weak typeof(self) weakself = self;
        RBTextFieldView *vi =[RBTextFieldView RBTextFieldViewWithFrame:CGRectMake(kEdgePacing, kEdgePacing+self.verifyTxtV.bottom, self.view.width-2*kEdgePacing, kTxtHeight) Type:RB_TextTypeSecret OnlyBlock:^(UITextField *txtField) {
            txtField.delegate = weakself;
            txtField.placeholder =  @"请输入6-20位密码";
            txtField.returnKeyType = UIReturnKeyNext;
            txtField.secureTextEntry = YES;
            txtField.textColor = k_RBLoginKit_Default_TextColor;
            txtField.font = [UIFont fontWithName:k_RBLoginKit_DefaultFontName size:k_RBLoginKit_DefaultFontSize - 3];
            [txtField addTarget:weakself action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        }];
        vi.selected = NO;
        [self.stepTwoBackView addSubview:vi];
        _psdTxtV = vi;
    }
    return _psdTxtV;
}
#pragma mark - action: 监控密码文本
- (void)textFieldChanged:(UITextField*)textField{
    //空格解决方案
    NSString *_string = textField.text;
    NSRange _range = [_string rangeOfString:@" "];
    if (_range.location != NSNotFound) {
        //有空格
        [MitLoadingView showErrorWithStatus:@"密码中不能包含空格"];
        textField.text = [NSString stringWithFormat:@"%@",[textField.text substringToIndex:textField.text.length - 1]];
    }
}



#pragma mark - 创建 -> 验证码
-(RBTextFieldView *)verifyTxtV{
    if (!_verifyTxtV) {
        __weak typeof(self) weakself = self;
        RBTextFieldView * vi = [RBTextFieldView RBTextFieldViewWithFrame:CGRectMake(kEdgePacing, kEdgePacing, self.view.width-2*kEdgePacing, kTxtHeight) Type:RB_TextTypeVerifyCode OnlyBlock:^(UITextField *txtField) {
            txtField.delegate = weakself;
            txtField.placeholder =  @"4位短信验证码";
            txtField.keyboardType = UIKeyboardTypePhonePad;
            txtField.secureTextEntry = NO;
            txtField.textColor = k_RBLoginKit_Default_TextColor;
            txtField.font = [UIFont fontWithName:k_RBLoginKit_DefaultFontName size:k_RBLoginKit_DefaultFontSize - 3];
        }];
        vi.selected = NO;
        [self.stepTwoBackView addSubview:vi];
        /** 验证码按钮点击回调 */
        vi.callBack = ^(UIButton *btn){
            [NSObject mit_makeMitRegexMaker:^(MitRegexMaker *maker) {
                maker.validatePhone(weakself.phoneTxtV.text);
            }MitValue:^(MitRegexStateType statusType, NSString *statusStr, BOOL isPassed) {
                if (isPassed&&weakself.isRegist) {
                    [weakself getVerifyCodeAction];
                }else{
//                    NSLog(@"手机格式不对,%@",statusStr);
                }
            }];
        };
        _verifyTxtV = vi;
    }
    return _verifyTxtV;
}





#pragma mark - 创建 -> 重置按钮
-(UIButton *)resetBtn{
    if (!_resetBtn) {
        UIButton*btn =[UIButton buttonWithType: UIButtonTypeCustom];
        btn.frame = CGRectMake(self.phoneTxtV.left, self.psdTxtV.bottom+kEdgePacing, self.phoneTxtV.width, kTxtHeight);
        [btn setTitle:@"重置密码" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.backgroundColor = k_RBLoginKit_Default_MainColor;
        [btn addTarget:self action:@selector(resetClick) forControlEvents:UIControlEventTouchUpInside];
        [self.stepTwoBackView addSubview:btn];
        _resetBtn = btn ;
        
    }
    return _resetBtn;
    
}

static const CGFloat kProblemBtnWidth = 80;
#pragma mark - 创建 -> 问题按钮
-(UIButton *)problemBtn{
    if (!_problemBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(self.resetBtn.right - kProblemBtnWidth, self.resetBtn.bottom+kEdgePacing*0.5, kProblemBtnWidth, kTxtHeight);
        btn.titleLabel.textAlignment = NSTextAlignmentRight;
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitle:@"遇到问题？" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:k_RBLoginKit_DefaultFontSize - 3];
        [btn addTarget:self action:@selector(problemBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        _problemBtn = btn;
        
    }
    return _problemBtn;
}



#pragma mark ------------------- Action ------------------------
#pragma mark - action: 设置是否可点击
-(void)setIsRegist:(BOOL)isRegist{
    _isRegist = isRegist;
    if (isRegist&&self.phoneTxtV.text.length == 11) {
        self.verifyTxtV.verifyBtn.backgroundColor = k_RBLoginKit_Default_MainColor;
        [self.verifyTxtV.verifyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.verifyTxtV.verifyBtn.layer.borderColor = k_RBLoginKit_Default_MainColor.CGColor;
        self.verifyTxtV.verifyBtn.userInteractionEnabled = YES;
    }else{
        self.verifyTxtV.verifyBtn.backgroundColor = [UIColor clearColor];
        [self.verifyTxtV.verifyBtn setTitleColor:k_RBLoginKit_Default_UnAbleColor forState:UIControlStateNormal];
        self.verifyTxtV.verifyBtn.layer.borderColor = k_RBLoginKit_Default_UnAbleColor.CGColor;
        self.verifyTxtV.verifyBtn.userInteractionEnabled = NO;
    }
}
#pragma mark - action: 重写返回
-(void)back{
    if (self.viewType == RBViewTypeStepOne) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        self.stepOneBackView.hidden = NO;
        [UIView animateWithDuration:0.5 animations:^{
            self.stepOneBackView.center = CGPointMake(self.view.width*0.5, self.stepOneBackView.center.y);
            self.stepTwoBackView.center = CGPointMake(self.view.width*1.5, self.stepTwoBackView.center.y);
        }completion:^(BOOL finished) {
            self.viewType = RBViewTypeStepOne;
        }];
        if(sendtimer){
            dispatch_source_cancel(sendtimer);
            sendtimer = nil;
        }
        [self.verifyTxtV.verifyBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        self.verifyTxtV.verifyBtn.enabled = YES;
        if (_isWaiting) {
            _isWaiting = NO;
        }
        [self.phoneTxtV becomeFirstRespond];
    }
    
}
#pragma mark - action: 获取验证码点击
- (void)getVerifyCodeBtnClick{
    [NSObject mit_makeMitRegexMaker:^(MitRegexMaker *maker) {
        maker.validatePhone(self.phoneTxtV.text);
    }MitValue:^(MitRegexStateType statusType, NSString *statusStr, BOOL isPassed) {
        if (isPassed) {
            //发送网络请求查看手机号是否注册
            [self checkPhoneIsRegister:self.phoneTxtV.text];
        }else{
            [MitLoadingView showErrorWithStatus:statusStr];
        }
    }];

}

#pragma mark - action: 开启移动动画
- (void)startMoveAnimate{
    self.viewType = RBViewTypeStepTwo;
    [UIView animateWithDuration:0.5 animations:^{
        self.stepOneBackView.center = CGPointMake(-self.view.width*0.5, self.stepOneBackView.center.y);
        self.stepTwoBackView.center = CGPointMake(self.view.width*0.5, self.stepTwoBackView.center.y);
    }completion:^(BOOL finished) {
        self.stepOneBackView.hidden = YES;
    }];
}

#pragma mark - action: 键盘升起
- (void)keyboardWillShow:(NSNotification*)notify{
    CGRect endRect = [[notify.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat y = endRect.origin.y;
    if ([self.psdTxtV isSelected]) {
        if (self.psdTxtV.bottom+ kEdgePacing > y) {
            [UIView animateWithDuration:0.5 animations:^{
                self.view.center = CGPointMake(k_RBLoginKit_ScreenWidth*0.5, k_RBLoginKit_ScreenHeight*0.5 - kEdgePacing);
            }completion:^(BOOL finished) {
                _isKeyboardAnimate = YES;
            }];
        }
    }else if ([self.verifyTxtV isSelected]){
        if (self.verifyTxtV.bottom+ kEdgePacing > y) {
            [UIView animateWithDuration:0.5 animations:^{
                self.view.center = CGPointMake(k_RBLoginKit_ScreenWidth*0.5, k_RBLoginKit_ScreenHeight*0.5 - 2 * kEdgePacing);
            }completion:^(BOOL finished) {
                _isKeyboardAnimate = YES;
            }];
        }
        
    }else{
        self.view.center = CGPointMake(k_RBLoginKit_ScreenWidth*0.5, k_RBLoginKit_ScreenHeight*0.5);
    }
}
#pragma mark - action: 键盘收起
- (void)keyboardWillHide:(NSNotification *)notify{
    if (_isKeyboardAnimate) {
        [UIView animateWithDuration:0.5 animations:^{
            self.view.center = CGPointMake(k_RBLoginKit_ScreenWidth*0.5, k_RBLoginKit_ScreenHeight*0.5);
        }completion:^(BOOL finished) {
            _isKeyboardAnimate = NO;
        }];
    }
}


#pragma mark - action: 键盘消失
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
#pragma mark - action: 检查手机号是否已经注册
- (void)checkPhoneIsRegister:(NSString *)phoneText{
    [RBAuthApi isRegist:phoneText completionBlock:^(NSNumber *isRegist, NSError *error) {
        if (isRegist) {
            self.verifyTxtV.verifyBtn.enabled = YES;
            self.isRegist = YES;
            //注册了那么去第二步骤
            [self.verifyTxtV becomeFirstRespond];
            [self sendVerifyRequest];
            [self startMoveAnimate];
        }else{
            [MitLoadingView showErrorWithStatus:k_RBLoginKit_Error_Description];
            self.verifyTxtV.verifyBtn.enabled = NO;
            self.isRegist = NO;
        }
    }];
}
#pragma mark - action: 获取验证码
- (void)getVerifyCodeAction{
    if (!_isWaiting) {
        /** 获取验证码网络请求 */
        [self sendVerifyRequest];
    }else{
//        NSLog(@"已经发送了，请等待");
    }
}

#pragma mark - action: 重置按钮点击
- (void)resetClick{
    __weak typeof(self) weakself = self;
    [NSObject mit_makeMitRegexMaker:^(MitRegexMaker *maker) {
        maker.validateCodeNumber(self.verifyTxtV.text).validatePsd(self.psdTxtV.text);
    }MitValue:^(MitRegexStateType statusType, NSString *statusStr, BOOL isPassed) {
        if (isPassed) {
            [weakself sendResetRequest];
        }else{
            if (self.verifyTxtV.text.length ==0) {
                [MitLoadingView showNoticeWithStatus:@"请输入验证码"];
            }else{
                [MitLoadingView showErrorWithStatus:statusStr];
            }
        }
    }];
}

 #pragma mark - action: 发送重置的请求
- (void)sendResetRequest{
    self.view.userInteractionEnabled = NO;
    [MitLoadingView showWithStatus:@"正在发送"];
    [RBAuthApi resetPassword:self.psdTxtV.text phoneNum:self.phoneTxtV.text code:self.verifyTxtV.text completionBlock:^(BOOL isSuccess, NSError *error) {
        self.view.userInteractionEnabled = YES;
        if (isSuccess) {
            //修改密码结果回调
            if (RB_LoginKit_Manager.delegate && [RB_LoginKit_Manager.delegate respondsToSelector:@selector(rb_resetPsdResult:)]) {
                [RB_LoginKit_Manager.delegate performSelector:@selector(rb_resetPsdResult:) withObject:[NSNumber numberWithBool:isSuccess]];
            }
            //修改密码block回调

            if (self.rb_forgetPsdBack) {
                self.rb_forgetPsdBack(isSuccess,nil);
            }
            
            
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.navigationController) {
                    [self.navigationController popViewControllerAnimated:true];
                }else{
                    [self dismissViewControllerAnimated:true completion:nil];
                }
            });
        }else{

            //修改密码结果回调
            if (RB_LoginKit_Manager.delegate && [RB_LoginKit_Manager.delegate respondsToSelector:@selector(rb_resetPsdResult:)]) {
                [RB_LoginKit_Manager.delegate performSelector:@selector(rb_resetPsdResult:) withObject:[NSNumber numberWithBool:isSuccess]];
            }
            //修改密码block回调
            if (self.rb_forgetPsdBack) {
                self.rb_forgetPsdBack(isSuccess,error);
            }
            [MitLoadingView showErrorWithStatus:k_RBLoginKit_Error_Description];
        }
    }];
}

#pragma mark - action: 问题按钮点击
- (void)problemBtnClick{
    RBHtmlViewController*vc = [[RBHtmlViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - action: 开启倒计时
- (void)startTiemCountdown{
    __block int timeout = 60; //倒计时时间
    if(sendtimer){
        dispatch_source_cancel(sendtimer);
        sendtimer = nil;
    }
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    sendtimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(sendtimer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(sendtimer, ^{
        if(timeout<=1){ //倒计时结束，关闭
            dispatch_source_cancel(sendtimer);
            sendtimer = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [self.verifyTxtV.verifyBtn setTitle:@"重新发送" forState:UIControlStateNormal];
                self.verifyTxtV.verifyBtn.enabled = YES;
                _isWaiting = NO;
            });
        }else{
            __block NSString * str = @"";
            dispatch_queue_t queue1 = dispatch_queue_create("1", DISPATCH_QUEUE_CONCURRENT);
            dispatch_async(queue1, ^{
                int seconds = timeout % 60;
                NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
                _verifyTxtV.verifyBtn.enabled = NO;
                str = [NSString stringWithFormat:@"%@s后重新发送",strTime];
            });
            dispatch_barrier_async(queue1, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    //设置界面的按钮显示 根据自己需求设置
                    [_verifyTxtV.verifyBtn setTitle:str forState:UIControlStateNormal];
                    if ([UIDevice isIOS7]) {
                        _verifyTxtV.verifyBtn.titleLabel.text = str;
                        [_verifyTxtV.verifyBtn.titleLabel setAdjustsFontSizeToFitWidth:YES];
                    }
                    _isWaiting = YES;
                });
            });
            timeout--;
        }
    });
    dispatch_resume(sendtimer);
}
#pragma mark - action: 发送网络请求获取验证码
- (void)sendVerifyRequest{
    if(!_isWaiting){
        [RBAuthApi sendCode:self.phoneTxtV.text type:RBSendCodeTypeResetPsd completionBlock:^(BOOL isSend, NSError *error) {
            [MitLoadingView dismiss];
        }];
        /** 开启倒计时 */
        [self startTiemCountdown];
    }
}

#pragma mark ------------------- textFieldDelegate ------------------------
#pragma mark - Go
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.superview == self.psdTxtV){
        [self.verifyTxtV becomeFirstRespond];
    }
    return YES;
}
#pragma mark - 截取输入
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString * result = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if([result mStrLength] >4 && [textField.superview isEqual:self.verifyTxtV]){
        textField.text = [NSString stringWithFormat:@"%@%@",[result substringToIndex:3],[result substringFromIndex:result.length -1]];
        return NO;
    }
    //限制密码输入
    if ([string mIntLength]>1) {
        return NO;
    }
    if ([textField.superview isEqual:self.psdTxtV]) {
        //限制中文和 部分emoji
        NSString *regex2 = @"[\u4e00-\u9fa5][^ ]*|[\\ud800\\udc00-\\udbff\\udfff\\ud800-\\udfff][^ ]*";
        NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
        if ([result mIntLength] >20||[identityCardPredicate evaluateWithObject:string]) {
            return NO;
        }
    }
    return YES;
    
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if(textField.superview == self.phoneTxtV){
        self.phoneTxtV.selected = YES;
    }else if (textField.superview == self.psdTxtV){
        self.psdTxtV.selected = YES;
    }else{
        self.verifyTxtV.selected = YES;
    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField.superview == self.phoneTxtV){
        self.phoneTxtV.selected = NO;
    }else if (textField.superview == self.psdTxtV){
        self.psdTxtV.selected = NO;
    }else{
        self.verifyTxtV.selected = NO;
    }
}





@end
