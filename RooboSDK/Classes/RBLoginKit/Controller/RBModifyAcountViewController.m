//
//  PDModifyPhoneNumViewController.m
//  Pudding
//
//  Created by william on 16/2/18.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//

#import "RBModifyAcountViewController.h"
#import "RBTextFieldView.h"
#import "MitRegex.h"
#import "RBLoginConfig.h"
#import "UIView+RBLayoutExtension.h"
#import "MitLoading.h"
#import "UIDevice+RBHardware.h"
#import "RBAuthApi.h"
#import "NSObject+RBFilterNull.h"
#import "NSBundle+RBLoginKitBundle.h"
#import "UIViewController+RBExtension.h"
typedef NS_ENUM(NSUInteger, verifyStep) {
    verifyStepOne,
    verifyStepTwo,
};

@interface RBModifyAcountViewController ()<UITextFieldDelegate>
{
    dispatch_source_t sendtimer;
}
/** 密码输入框 */
@property (nonatomic, weak) RBTextFieldView * psdTxtV;
/** 手机号输入框 */
@property (nonatomic, weak) RBTextFieldView * phoneNumTxtV;
/** 验证码输入框 */
@property (nonatomic, weak) RBTextFieldView * verifyCodeTxtV;
/** 是否正在等待 */
@property (nonatomic, assign) BOOL isWaiting;
/** 验证步骤 */
@property (nonatomic, assign) verifyStep step;
/** 完成按钮 */
@property (nonatomic, weak) UIButton * finishBtn;
/** 是否注册了 */
@property (nonatomic, assign) BOOL isRegist;
/** 键盘动画 */
@property (nonatomic, assign) BOOL isKeyboardAnimate;
/** 导航视图 */
@property (nonatomic, weak) UIView * navView;
/** 导航文本 */
@property (nonatomic, weak) UILabel * navLab;
/** 返回按钮 */
@property (nonatomic, weak) UIButton * navBackBtn;
@end

@implementation RBModifyAcountViewController
+ (instancetype)show{
    RBModifyAcountViewController * vc = [RBModifyAcountViewController new];
    [[UIViewController getCurrentVC] presentViewController:vc animated:true completion:nil];
    return vc;
}
#pragma mark ------------------- lifeCycle ------------------------
#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    /** 初始化导航栏 */
    [self initialNav];
    
    self.view.backgroundColor = [UIColor whiteColor];
    /** 密码文本 */
    self.psdTxtV.hidden = NO;
    /** 手机号文本 */
    self.phoneNumTxtV.hidden = NO;
    /** 验证码文本 */
    self.verifyCodeTxtV.hidden = NO;
    
    /** 完成按钮 */
    self.finishBtn.layer.cornerRadius = self.finishBtn.height*0.5;  
    self.finishBtn.backgroundColor = k_RBLoginKit_Default_UnAbleColor;
    self.finishBtn.userInteractionEnabled = NO;
    
    //监听手机号
    [self.phoneNumTxtV addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    [self.psdTxtV addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    [self.verifyCodeTxtV addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    
    /** 添加键盘通知 */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [self.psdTxtV becomeFirstRespond];
}
#pragma mark - 状态栏颜色
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
#pragma mark - action: 观察者
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if (object == self.phoneNumTxtV) {
        /** 判断账号是否已经注册 */
        if(self.phoneNumTxtV.text.length == 11&&[self.phoneNumTxtV isSelected]){
        }
        if (self.psdTxtV.text.length>0&&self.phoneNumTxtV.text.length>0) {
            self.verifyCodeTxtV.verifyBtn.backgroundColor = k_RBLoginKit_Default_MainColor;
            [self.verifyCodeTxtV.verifyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.verifyCodeTxtV.verifyBtn.layer.borderColor = k_RBLoginKit_Default_MainColor.CGColor;
            self.verifyCodeTxtV.verifyBtn.userInteractionEnabled = YES;
        }else{
            self.verifyCodeTxtV.verifyBtn.backgroundColor = [UIColor clearColor];
            [self.verifyCodeTxtV.verifyBtn setTitleColor:k_RBLoginKit_Default_UnAbleColor forState:UIControlStateNormal];
            self.verifyCodeTxtV.verifyBtn.layer.borderColor = k_RBLoginKit_Default_UnAbleColor.CGColor;
            self.verifyCodeTxtV.verifyBtn.userInteractionEnabled = NO;
        }
        if (self.phoneNumTxtV.text.length >0&&self.psdTxtV.text.length>0&&self.verifyCodeTxtV.text.length>0) {
            self.finishBtn.backgroundColor = k_RBLoginKit_Default_MainColor;
            self.finishBtn.userInteractionEnabled = YES;
        }else{
            self.finishBtn.backgroundColor = k_RBLoginKit_Default_UnAbleColor;
            self.finishBtn.userInteractionEnabled = NO;
        }

    }else if (object == self.psdTxtV){
        if (self.psdTxtV.text.length>0&&self.phoneNumTxtV.text.length>0) {
            self.verifyCodeTxtV.verifyBtn.backgroundColor = k_RBLoginKit_Default_MainColor;
            [self.verifyCodeTxtV.verifyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.verifyCodeTxtV.verifyBtn.layer.borderColor = k_RBLoginKit_Default_MainColor.CGColor;
            self.verifyCodeTxtV.verifyBtn.userInteractionEnabled = YES;
        }else{

            self.verifyCodeTxtV.verifyBtn.backgroundColor = [UIColor clearColor];
            [self.verifyCodeTxtV.verifyBtn setTitleColor:k_RBLoginKit_Default_UnAbleColor forState:UIControlStateNormal];
            self.verifyCodeTxtV.verifyBtn.layer.borderColor = k_RBLoginKit_Default_UnAbleColor.CGColor;
            self.verifyCodeTxtV.verifyBtn.userInteractionEnabled = NO;
        }
        
        if (self.phoneNumTxtV.text.length >0&&self.psdTxtV.text.length>0&&self.verifyCodeTxtV.text.length>0) {
            self.finishBtn.backgroundColor = k_RBLoginKit_Default_MainColor;
            self.finishBtn.userInteractionEnabled = YES;
        }else{
            self.finishBtn.backgroundColor = k_RBLoginKit_Default_UnAbleColor;
            self.finishBtn.userInteractionEnabled = NO;
        }

    }else if (object == self.verifyCodeTxtV){
        if (self.phoneNumTxtV.text.length >0&&self.psdTxtV.text.length>0&&self.verifyCodeTxtV.text.length>0) {
            self.finishBtn.backgroundColor = k_RBLoginKit_Default_MainColor;
            self.finishBtn.userInteractionEnabled = YES;
        }else{
            self.finishBtn.backgroundColor = k_RBLoginKit_Default_UnAbleColor;
            self.finishBtn.userInteractionEnabled = NO;
        }
    }
}

#pragma mark - viewWillDisappear
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    [MitLoadingView dismiss];

}
#pragma mark - dealloc
-(void)dealloc{
    [self.phoneNumTxtV removeObserver:self forKeyPath:@"text"];
    [self.verifyCodeTxtV removeObserver:self forKeyPath:@"text"];
    [self.psdTxtV removeObserver:self forKeyPath:@"text"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - 初始化导航栏
- (void)initialNav{
    if (self.navigationController) {
        self.title = @"修改手机号";
    }else{
        self.navView.hidden = false;
        self.navLab.text = @"修改手机号";
        self.navBackBtn.hidden = false;
    }
    self.navigationController.navigationBar.hidden = true;
    self.automaticallyAdjustsScrollViewInsets = NO;
}
#pragma mark ------------------- Lazy - Load ------------------------
#pragma mark - 创建 -> 密码
static CGFloat kNavHeight = 64;
static CGFloat kEdgePacing = 45;
static CGFloat kHoribleEdgePacing = 30;
static CGFloat kTxtHeight = 45;
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
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:true];
    }else{
        [self dismissViewControllerAnimated:true completion:nil];
    }
}
-(RBTextFieldView *)psdTxtV{
    if (!_psdTxtV) {
        __weak typeof(self) weakself = self;
        RBTextFieldView * vi = [RBTextFieldView RBTextFieldViewWithFrame:CGRectMake(kEdgePacing, kEdgePacing+kNavHeight, self.view.width-2*kEdgePacing, kTxtHeight)  Type:RB_TextTypeNormal OnlyBlock:^(UITextField *txtField) {
            txtField.delegate = weakself;
            txtField.placeholder = @"输入密码";
            txtField.textColor = k_RBLoginKit_Default_TextColor;
            txtField.returnKeyType = UIReturnKeyNext;
            txtField.secureTextEntry = YES;
            txtField.font = [UIFont fontWithName:k_RBLoginKit_DefaultFontName size:k_RBLoginKit_DefaultFontSize - 3];
            [txtField addTarget:weakself action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];

        }];
        vi.selected = NO;
        [self.view addSubview:vi];
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



#pragma mark - 创建 -> 电话
-(RBTextFieldView *)phoneNumTxtV{
    
    if (!_phoneNumTxtV) {
        __weak typeof(self) weakself = self;
        RBTextFieldView * vi =[RBTextFieldView RBTextFieldViewWithFrame:CGRectMake(kEdgePacing, kHoribleEdgePacing+self.psdTxtV.bottom, self.view.width-2*kEdgePacing, kTxtHeight) Type:RB_TextTypeAccount OnlyBlock:^(UITextField *txtField) {
            txtField.delegate = weakself;
            txtField.placeholder =  @"输入手机号";
            txtField.returnKeyType = UIReturnKeyNext;
            txtField.keyboardType = UIKeyboardTypePhonePad;
            txtField.textColor = k_RBLoginKit_Default_TextColor;
            txtField.font = [UIFont fontWithName:k_RBLoginKit_DefaultFontName size:k_RBLoginKit_DefaultFontSize - 3];
        }];
        vi.selected = NO;

        [self.view addSubview:vi];
        _phoneNumTxtV = vi;
    }
    return _phoneNumTxtV;
}



#pragma mark - 创建 -> 验证码
-(RBTextFieldView *)verifyCodeTxtV{
    if (!_verifyCodeTxtV) {
        __weak typeof(self) weakself = self;
        RBTextFieldView * vi =[RBTextFieldView RBTextFieldViewWithFrame:CGRectMake(kEdgePacing, kHoribleEdgePacing+self.phoneNumTxtV.bottom, self.view.width-2*kEdgePacing, kTxtHeight) Type:RB_TextTypeVerifyCode OnlyBlock:^(UITextField *txtField) {
            txtField.delegate = weakself;
            txtField.placeholder =  @"输入验证码";
            txtField.returnKeyType = UIReturnKeyDone;
            txtField.keyboardType = UIKeyboardTypePhonePad;
            txtField.font = [UIFont fontWithName:k_RBLoginKit_DefaultFontName size:k_RBLoginKit_DefaultFontSize - 3];
            txtField.textColor = k_RBLoginKit_Default_TextColor;
        }];
        vi.selected = NO;
        [self.view addSubview:vi];
        vi.callBack = ^(UIButton * btn){
//            NSString *remoteHostName = @"www.roobo.com";
//            Reachability * hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
//            if (![hostReachability isReachable]) {
//                [MitLoadingView showErrorWithStatus:@"请检查网络连接"];
//                return;
//            }
            /** 获取验证码 */
            //1.验证密码和手机号的格式
            if([weakself verifyCodeFormat:verifyStepOne]){
                [weakself checkPhoneIsRegister:weakself.phoneNumTxtV.text];
            }
        };
        _verifyCodeTxtV = vi;
    }
    return _verifyCodeTxtV;
}

#pragma mark - 创建 -> 完成按钮

-(UIButton *)finishBtn{
    if (!_finishBtn) {
        UIButton*btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(self.psdTxtV.left, self.verifyCodeTxtV.bottom+kEdgePacing, self.view.width-2*kEdgePacing, kTxtHeight);
        [btn setTitle:@"完成" forState:UIControlStateNormal];
        btn.layer.cornerRadius = btn.height *0.5;
        btn.layer.masksToBounds = YES;
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(finishAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        _finishBtn = btn;
    }
    return _finishBtn;
}



#pragma mark ------------------- Action ------------------------
#pragma mark - action: 键盘升起
- (void)keyboardWillShow:(NSNotification*)notify{
    CGRect endRect = [[notify.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat y = endRect.origin.y;
    if ([self.phoneNumTxtV isSelected]) {
        if (self.phoneNumTxtV.bottom+ kEdgePacing > y) {
            [UIView animateWithDuration:0.5 animations:^{
                self.view.center = CGPointMake(k_RBLoginKit_ScreenWidth*0.5, k_RBLoginKit_ScreenHeight*0.5 - kEdgePacing);
            }completion:^(BOOL finished) {
                _isKeyboardAnimate = YES;
            }];
        }
    }else if ([self.verifyCodeTxtV isSelected]){
        if (self.verifyCodeTxtV.bottom+ kEdgePacing > y) {
            [UIView animateWithDuration:0.5 animations:^{
                self.view.center = CGPointMake(k_RBLoginKit_ScreenWidth*0.5, k_RBLoginKit_ScreenHeight*0.5 - 2*kEdgePacing);
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
#pragma mark - action: 验证密码，手机号，验证码格式
- (BOOL)verifyCodeFormat:(verifyStep)step{
    __block BOOL result;
    if (step == verifyStepOne) {
        [NSObject mit_makeMitRegexMaker:^(MitRegexMaker *maker) {
            maker.validatePsd(self.psdTxtV.text).validatePhone(self.phoneNumTxtV.text);
        }MitValue:^(MitRegexStateType statusType, NSString *statusStr, BOOL isPassed) {
            if (isPassed) {
//                LogMark(@"通过密码和手机号格式校验，下一步请求验证码");
            }else{
                [MitLoadingView showErrorWithStatus:statusStr];
            }
            result = isPassed;
        }];
    }else{
        [NSObject mit_makeMitRegexMaker:^(MitRegexMaker *maker) {
            maker.validatePsd(self.psdTxtV.text).validatePhone(self.phoneNumTxtV.text).validateCodeNumber(self.verifyCodeTxtV.text);
        }MitValue:^(MitRegexStateType statusType, NSString *statusStr, BOOL isPassed) {
            if (isPassed) {
//                LogMark(@"通过格式校验,下一步发送修改手机的请求");
            }else{
                [MitLoadingView showErrorWithStatus:statusStr];
            }
            result = isPassed;
        }];
    }
    return result;
}




#pragma mark - action: 设置是否可点击
-(void)setIsRegist:(BOOL)isRegist{
    _isRegist = isRegist;
//    if (!isRegist&&self.phoneNumTxtV.text.length == 11) {
//        LogWarm(@"可点");
//        self.verifyCodeTxtV.verifyBtn.backgroundColor = k_RBLoginKit_Default_MainColor;
//        [self.verifyCodeTxtV.verifyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        self.verifyCodeTxtV.verifyBtn.layer.borderColor = k_RBLoginKit_Default_MainColor.CGColor;
//        self.verifyCodeTxtV.verifyBtn.userInteractionEnabled = YES;
//    }else{
//        LogWarm(@"不可点");
//        self.verifyCodeTxtV.verifyBtn.backgroundColor = [UIColor clearColor];
//        [self.verifyCodeTxtV.verifyBtn setTitleColor:k_RBLoginKit_Default_UnAbleColor forState:UIControlStateNormal];
//        self.verifyCodeTxtV.verifyBtn.layer.borderColor = k_RBLoginKit_Default_UnAbleColor.CGColor;
//        self.verifyCodeTxtV.verifyBtn.userInteractionEnabled = NO;
//    }
}


#pragma mark - action: 页面点击，键盘消失
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


#pragma mark - action: 开启倒计时
- (void)startTimeCountdown{
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
                [_verifyCodeTxtV.verifyBtn setTitle:@"重新发送" forState:UIControlStateNormal];
                _verifyCodeTxtV.verifyBtn.enabled = YES;
                _isWaiting = NO;
            });
        }else{
            __block NSString * str = @"";
            dispatch_queue_t queue1 = dispatch_queue_create("1", DISPATCH_QUEUE_CONCURRENT);
            dispatch_async(queue1, ^{
                int seconds = timeout % 60;
                NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
                _verifyCodeTxtV.verifyBtn.enabled = NO;
                str = [NSString stringWithFormat:@"%@s后重新发送",strTime];
            });
            dispatch_barrier_async(queue1, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    //设置界面的按钮显示 根据自己需求设置
                    [_verifyCodeTxtV.verifyBtn setTitle:str forState:UIControlStateNormal];
                    if ([UIDevice isIOS7]) {
                        _verifyCodeTxtV.verifyBtn.titleLabel.text = str;
                        [_verifyCodeTxtV.verifyBtn.titleLabel setAdjustsFontSizeToFitWidth:YES];
                    }
                    _isWaiting = YES;
                });
            });
            timeout--;
        }
    });
    dispatch_resume(sendtimer);
}

#pragma mark - action: 发送网络请求，获取验证码
- (void)sendVerifyRequest{
    if(!_isWaiting){
        [RBAuthApi sendCode:self.phoneNumTxtV.text type:RBSendCodeTypeResetPhone completionBlock:^(BOOL isSend, NSError *error) {
            [MitLoadingView dismiss];
        }];
        //开启倒计时
        [self startTimeCountdown];
        
    }
}
#pragma mark - action: 检查手机号是否已经注册
- (void)checkPhoneIsRegister:(NSString *)phoneText{
    __weak typeof(self) weakself = self;
    [RBAuthApi isRegist:phoneText completionBlock:^(NSNumber *isRegist, NSError *error) {
        __strong typeof(self) strongSelf = weakself;
        if ([isRegist intValue] == 1) {
            //已注册
            [MitLoadingView showErrorWithStatus:@"手机号已注册"];
            strongSelf.isRegist = true;
        } else if([isRegist intValue]==0){
            //未注册
            //发送获取验证码的请求
            strongSelf.isRegist = false;
            [strongSelf sendVerifyRequest];
        } else {
            [MitLoadingView showErrorWithStatus:k_RBLoginKit_Error_Description];
        }
    }];
}



#pragma mark - action: 发送网络请求，修改手机号
- (void)modifyPhoneNumRequest{
    [MitLoadingView showWithStatus:@"正在修改"];
    
    [RBAuthApi updatePhoneNum:self.phoneNumTxtV.text code:self.verifyCodeTxtV.text password:self.psdTxtV.text completionBlock:^(BOOL isSuccess, NSError *error) {
        //修改账号结果回调
        if (self.rb_modifyAccountBack) {
            self.rb_modifyAccountBack(isSuccess,error);
        }
        if (isSuccess) {
            [MitLoadingView showSuceedWithStatus:@"手机号修改成功，请重新登陆" delayTime:3];
        } else {
            [MitLoadingView showErrorWithStatus:k_RBLoginKit_Error_Description];
        }
    }];
}
#pragma mark - action: 完成按钮点击
- (void)finishAction{
    if ([self verifyCodeFormat:verifyStepTwo]) {
        [self modifyPhoneNumRequest];
    }
}



#pragma mark ------------------- UITextFieldDelegate ------------------------
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.superview == self.psdTxtV) {
        [self.phoneNumTxtV becomeFirstRespond];
    }else if (textField.superview == self.phoneNumTxtV){
        [self.verifyCodeTxtV becomeFirstRespond];
    }else{
        [self finishAction];
    }
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([textField.superview isEqual:self.verifyCodeTxtV]) {
        NSString * result = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if([result mStrLength] >4){
            textField.text = [NSString stringWithFormat:@"%@%@",[result substringToIndex:3],[result substringFromIndex:result.length -1]];
            return NO;
        }
    }
    return YES;
}


-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if(textField.superview == self.psdTxtV){
        self.psdTxtV.selected = YES;
    }else if (textField.superview == self.phoneNumTxtV){
        self.phoneNumTxtV.selected = YES;
    }else{
        self.verifyCodeTxtV.selected = YES;
    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField.superview == self.psdTxtV){
        self.psdTxtV.selected = NO;
    }else if (textField.superview == self.phoneNumTxtV){
        self.phoneNumTxtV.selected = NO;
        //验证手机号格式，查看手机号是否已经注册
//        [NSObject mit_makeMitRegexMaker:^(MitRegexMaker *maker) {
//            maker.validatePhone(self.phoneNumTxtV.text);
//        }MitValue:^(MitRegexStateType statusType, NSString *statusStr, BOOL isPassed) {
//            if (isPassed) {
//                [self checkPhoneIsRegister:self.phoneNumTxtV.text];
//            }else{
//                LogMark(@"%@",statusStr);
//            }
//        }];
    }else{
        self.verifyCodeTxtV.selected = NO;
    }
}


@end
