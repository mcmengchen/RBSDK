//
//  RBRegisterViewController.m
//  Pudding
//
//  Created by Zhi Kuiyu on 16/1/28.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//

#import "RBRegisterViewController.h"
#import "RBTextFieldView.h"
#import "MitRegex.h"
#import "NSObject+RBFilterNull.h"
#import "RBHtmlViewController.h"
#import "RBLoginConfig.h"
#import "MitLoading.h"
#import "UIView+RBLayoutExtension.h"
#import "UIDevice+RBHardware.h"
#import "RBAuthApi.h"
#import "NSBundle+RBLoginKitBundle.h"
#import "RBLoginKitManager.h"
#import "UIViewController+RBExtension.h"

typedef NS_ENUM(NSUInteger, verifyStep) {
    verifyStepOne,
    verifyStepTwo,
};
@interface RBRegisterViewController ()<UITextFieldDelegate>
{
    dispatch_source_t sendtimer;
}
/** 手机号 */
@property (nonatomic, weak) RBTextFieldView * accoutTxtV;
/** 密码输入框 */
@property (nonatomic, weak) RBTextFieldView *psdTxtV;
/** 验证码输入框 */
@property (nonatomic, weak) RBTextFieldView * verifyCodeTxtV;
/** 协议文本 */
@property (nonatomic, weak) UILabel * agreementLabel;
/** 注册按钮 */
@property (nonatomic, weak) UIButton * registBtn;
/** 倒计时 */
@property (nonatomic, assign) NSInteger countDownTime;
/** 正在等待 */
@property (nonatomic,assign) BOOL isWaiting;
/** 是否注册 */
@property (nonatomic, assign) BOOL isRegist;
/** 富文本 */
@property (nonatomic, strong) NSMutableAttributedString *attributeString;
/** 键盘动画 */
@property (nonatomic, assign) BOOL isKeyboardAnimate;
/** 导航视图 */
@property (nonatomic, weak) UIView * navView;
/** 导航文本 */
@property (nonatomic, weak) UILabel * navLab;
/** 返回按钮 */
@property (nonatomic, weak) UIButton * navBackBtn;

@end

@implementation RBRegisterViewController
#pragma mark ------------------- lifeCycle ------------------------
#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialNav];
    /** 初始化 */
    [self initial];
    
    /** 添加键盘通知 */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self.accoutTxtV becomeFirstRespond];
}
#pragma mark - 状态栏颜色
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

+ (instancetype)show{
    RBRegisterViewController * vc = [[RBRegisterViewController alloc]init];
    [[UIViewController getCurrentVC] presentViewController:vc animated:true completion:nil];
    return vc;
}

#pragma mark - 初始化导航栏
- (void)initialNav{
    self.navView.hidden = false;
    self.navLab.text = @"快速注册";
    self.navBackBtn.hidden = false;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController setNavigationBarHidden:YES animated:false];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}
#pragma mark - 初始化
- (void)initial{
    //设置倒计时时间
    _countDownTime = 60;
    self.view.backgroundColor =[UIColor whiteColor];
    
    //账号文本
    self.accoutTxtV.hidden = NO;
    
    //密码文本
    self.psdTxtV.hidden = NO;
    
    //验证码文本
    self.verifyCodeTxtV.hidden = NO;
    
    //注册按钮
    self.registBtn.hidden = NO;
    
    //协议文本
    self.agreementLabel.hidden = NO;
    
    //设置注册按钮的背景颜色
    self.registBtn.backgroundColor = k_RBLoginKit_Default_UnAbleColor;
    
    //查看手机号是否注册
    [self.accoutTxtV addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    //查看密码
    [self.psdTxtV addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    //查看验证码
    [self.verifyCodeTxtV addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - viewWillAppear
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication]setStatusBarHidden:NO];

}

#pragma mark - viewWillDisAppear
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    [MitLoadingView dismiss];
}
#pragma mark - dealloc
-(void)dealloc{
    [self.accoutTxtV removeObserver:self forKeyPath:@"text"];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
}


#pragma mark - action: 观察者
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if(object == self.accoutTxtV){
        if(self.accoutTxtV.text.length == 11&&[self.accoutTxtV isSelected]){
        }
        if (self.accoutTxtV.text.length>0&&self.psdTxtV.text.length>0) {
            self.verifyCodeTxtV.verifyBtn.backgroundColor = k_RBLoginKit_Default_MainColor;
            [self.verifyCodeTxtV.verifyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.verifyCodeTxtV.verifyBtn.layer.borderColor = k_RBLoginKit_Default_MainColor.CGColor;
            self.verifyCodeTxtV.verifyBtn.userInteractionEnabled = true;
        }else{
            self.verifyCodeTxtV.verifyBtn.backgroundColor = [UIColor clearColor];
            [self.verifyCodeTxtV.verifyBtn setTitleColor:k_RBLoginKit_Default_UnAbleColor forState:UIControlStateNormal];
            self.verifyCodeTxtV.verifyBtn.layer.borderColor = k_RBLoginKit_Default_UnAbleColor.CGColor;
            self.verifyCodeTxtV.verifyBtn.userInteractionEnabled = NO;
            
        }
        if (self.accoutTxtV.text.length >0&&self.psdTxtV.text.length>0&&self.verifyCodeTxtV.text.length>0) {
            self.registBtn.backgroundColor = k_RBLoginKit_Default_MainColor;
            self.registBtn.userInteractionEnabled = true;
        }else{
            self.registBtn.backgroundColor = k_RBLoginKit_Default_UnAbleColor;
            self.registBtn.userInteractionEnabled = NO;
        }
    }else if (object == self.psdTxtV){
        if (self.accoutTxtV.text.length>0&&self.psdTxtV.text.length>0) {
            self.verifyCodeTxtV.verifyBtn.backgroundColor = k_RBLoginKit_Default_MainColor;
            [self.verifyCodeTxtV.verifyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.verifyCodeTxtV.verifyBtn.layer.borderColor = k_RBLoginKit_Default_MainColor.CGColor;
            self.verifyCodeTxtV.verifyBtn.userInteractionEnabled = true;
        }else{
            self.verifyCodeTxtV.verifyBtn.backgroundColor = [UIColor clearColor];
            [self.verifyCodeTxtV.verifyBtn setTitleColor:k_RBLoginKit_Default_UnAbleColor forState:UIControlStateNormal];
            self.verifyCodeTxtV.verifyBtn.layer.borderColor = k_RBLoginKit_Default_UnAbleColor.CGColor;
            self.verifyCodeTxtV.verifyBtn.userInteractionEnabled = NO;
            
        }
        if (self.accoutTxtV.text.length >0&&self.psdTxtV.text.length>0&&self.verifyCodeTxtV.text.length>0) {
            self.registBtn.backgroundColor = k_RBLoginKit_Default_MainColor;
            self.registBtn.userInteractionEnabled = true;
        }else{
            self.registBtn.backgroundColor = k_RBLoginKit_Default_UnAbleColor;
            self.registBtn.userInteractionEnabled = NO;
        }
    }else if (object == self.verifyCodeTxtV){
        if (self.accoutTxtV.text.length >0&&self.psdTxtV.text.length>0&&self.verifyCodeTxtV.text.length>0) {
            self.registBtn.backgroundColor = k_RBLoginKit_Default_MainColor;
            self.registBtn.userInteractionEnabled = true;
        }else{
            self.registBtn.backgroundColor = k_RBLoginKit_Default_UnAbleColor;
            self.registBtn.userInteractionEnabled = NO;
        }
    }
}



#pragma mark ------------------- LazyLoad ------------------------
#pragma mark - 创建 -> 账号
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

#pragma mark - 创建 -> 账号文本
-(RBTextFieldView *)accoutTxtV{
    if (!_accoutTxtV) {
        __weak typeof(self) weakself = self;
        RBTextFieldView *vi = [RBTextFieldView RBTextFieldViewWithFrame:CGRectMake(kEdgePacing, kEdgePacing+k_RBLoginKit_NavHeight, self.view.width-2*kEdgePacing, kTxtHeight) Type:RB_TextTypeAccount OnlyBlock:^(UITextField *txtField) {
            txtField.delegate = weakself;
            txtField.placeholder = @"请输入您的手机号";
            txtField.returnKeyType = UIReturnKeyNext;
            txtField.textColor = k_RBLoginKit_Default_TextColor;
            txtField.backgroundColor = [UIColor clearColor];
            txtField.keyboardType = UIKeyboardTypePhonePad;
            txtField.font = [UIFont fontWithName:k_RBLoginKit_DefaultFontName size:k_RBLoginKit_DefaultFontSize - 3];
        }];
        vi.selected = NO;
        [self.view addSubview:vi];
        _accoutTxtV = vi;
    }
    return _accoutTxtV;
}

#pragma mark - 创建 -> 密码
-(RBTextFieldView *)psdTxtV{
    if (!_psdTxtV) {
        __weak typeof(self) weakself = self;
        RBTextFieldView * vi =[RBTextFieldView RBTextFieldViewWithFrame:CGRectMake(kEdgePacing, kHoribleEdgePacing+self.accoutTxtV.bottom, self.view.width-2*kEdgePacing, kTxtHeight) Type:RB_TextTypeSecret OnlyBlock:^(UITextField *txtField) {
            txtField.delegate = weakself;
            txtField.placeholder =  @"请输入6-20位密码";
            txtField.returnKeyType = UIReturnKeyNext;
            txtField.secureTextEntry = true;
            txtField.textColor = k_RBLoginKit_Default_TextColor;
            txtField.font = [UIFont fontWithName:k_RBLoginKit_DefaultFontName size:k_RBLoginKit_DefaultFontSize - 3];
            [txtField addTarget:weakself action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        }];
        vi.hidePsdBtn.backgroundColor = [UIColor clearColor];
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

#pragma mark - 创建 -> 验证码
-(RBTextFieldView *)verifyCodeTxtV{
    if (!_verifyCodeTxtV) {
        __weak typeof(self) weakself = self;
        RBTextFieldView * vi = [RBTextFieldView RBTextFieldViewWithFrame:CGRectMake(kEdgePacing, kHoribleEdgePacing+self.psdTxtV.bottom, self.view.width-2*kEdgePacing, kTxtHeight) Type:RB_TextTypeVerifyCode OnlyBlock:^(UITextField *txtField) {
            txtField.delegate = weakself;
            txtField.placeholder =  @"4位短信验证码";
            txtField.textColor = k_RBLoginKit_Default_TextColor;
            txtField.returnKeyType = UIReturnKeyDone;
            txtField.keyboardType = UIKeyboardTypePhonePad;
            txtField.font = [UIFont fontWithName:k_RBLoginKit_DefaultFontName size:k_RBLoginKit_DefaultFontSize - 3];
        }];
        [self.view addSubview:vi];
        vi.selected = NO;
        vi.callBack = ^(UIButton * btn){
            /** 获取验证码 */
            //1.验证密码和手机号的格式
            if([weakself verifyCodeFormat:verifyStepOne]){
                //通过格式校验，查看是否注册，如果未注册则进行下一步
                [self checkPhoneIsRegister:self.accoutTxtV.text];
                //发送获取验证码的请求
//                [weakself sendVerifyRequest];
            }
        };
        _verifyCodeTxtV = vi;
    }
    return _verifyCodeTxtV;
}



static const CGFloat kLeftEdge = 90;
#pragma mark - 创建 -> 协议文本
-(UILabel *)agreementLabel{
    if (!_agreementLabel) {
        UILabel*lab = [[UILabel alloc]initWithFrame:CGRectMake(self.accoutTxtV.left , self.registBtn.bottom+kEdgePacing, self.accoutTxtV.width , self.accoutTxtV.height)];
        lab.font = [UIFont systemFontOfSize:k_RBLoginKit_DefaultFontSize - 3];
        lab.textAlignment = NSTextAlignmentLeft;
        lab.attributedText = self.attributeString;
        lab.userInteractionEnabled = true;
        lab.textColor = k_RBLoginKit_Default_UnAbleColor;
        CGSize maximumLabelSize = CGSizeMake(self.accoutTxtV.width - kLeftEdge, self.accoutTxtV.height);
        CGSize expectSize = [lab sizeThatFits:maximumLabelSize];
        lab.bounds = CGRectMake(0, 0, expectSize.width, expectSize.height);
        lab.center = CGPointMake(self.view.width *0.5, self.registBtn.bottom+kHoribleEdgePacing*0.5+lab.height*0.5);
        [self.view addSubview:lab];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(agreeLabTapClick:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired  = 1;
        [lab addGestureRecognizer:tap];
        _agreementLabel = lab;
    }
    return _agreementLabel;
}
#pragma mark - 创建 -> 富文本
-(NSMutableAttributedString *)attributeString{
    if (!_attributeString) {
        NSMutableAttributedString *content = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"点击注册,即代表您同意 用户协议"]];
        NSRange contentRange = NSMakeRange(12, 4);
        [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
        [content addAttribute:NSForegroundColorAttributeName value:k_RBLoginKit_Default_UnAbleColor range:contentRange];
        _attributeString = content;
    }
    return _attributeString;
}



#pragma mark - 创建 -> 注册按钮
-(UIButton *)registBtn{
    if (!_registBtn) {
        UIButton*btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(kEdgePacing, self.verifyCodeTxtV.bottom+kEdgePacing, self.view.width - 2*kEdgePacing, kTxtHeight);
        [self.view addSubview:btn];
        [btn setTitle:@"快速注册" forState:UIControlStateNormal];
        btn.backgroundColor  = k_RBLoginKit_Default_MainColor;
        btn.layer.cornerRadius = btn.height*0.5;
        btn.layer.masksToBounds = true;
        [btn addTarget:self action:@selector(registAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        _registBtn = btn;
    }
    return _registBtn;
}




#pragma mark ------------------- Action ------------------------
#pragma mark - action: 键盘升起
- (void)keyboardWillShow:(NSNotification*)notify{
    CGRect endRect = [[notify.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat y = endRect.origin.y;
    if ([self.psdTxtV isSelected]) {
        if (self.psdTxtV.bottom+ kEdgePacing > y) {
            [UIView animateWithDuration:0.5 animations:^{
                self.view.center = CGPointMake(k_RBLoginKit_ScreenWidth*0.5, k_RBLoginKit_ScreenHeight*0.5 - kEdgePacing);
            }completion:^(BOOL finished) {
                _isKeyboardAnimate = true;
            }];
        }
    }else if ([self.verifyCodeTxtV isSelected]){
        if (self.verifyCodeTxtV.bottom+ kEdgePacing > y) {
            [UIView animateWithDuration:0.5 animations:^{
                self.view.center = CGPointMake(k_RBLoginKit_ScreenWidth*0.5, k_RBLoginKit_ScreenHeight*0.5 - 2 * kEdgePacing);
            }completion:^(BOOL finished) {
                _isKeyboardAnimate = true;
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
#pragma mark - action: 检查手机号是否注册
- (void)checkPhoneIsRegister:(NSString *)phoneText{
    [MitLoadingView showWithStatus:@"正在加载"];
    [NSObject mit_makeMitRegexMaker:^(MitRegexMaker *maker) {
        maker.validatePhone(phoneText);
    }MitValue:^(MitRegexStateType statusType, NSString *statusStr, BOOL isPassed) {
        if (isPassed) {
            __weak typeof(self) weakself = self;
            [RBAuthApi isRegist:phoneText completionBlock:^(NSNumber *isRegist, NSError *error) {
                __strong typeof(self) strongSelf = weakself;
                if ([isRegist intValue] == 1) {
                    //已注册
                    [MitLoadingView showErrorWithStatus:@"手机号已注册"];
                    self.isRegist = true;
                } else if([isRegist intValue]==0){
                    //未注册
                    //发送获取验证码的请求
                    weakself.isRegist = false;
                    weakself.verifyCodeTxtV.verifyBtn.enabled = true;
                    [weakself sendVerifyRequest];
                } else {
                    [MitLoadingView showErrorWithStatus:k_RBLoginKit_Error_Description];
                }
            }];
        }else{
            [MitLoadingView showErrorWithStatus:statusStr];

        }
    }];
}





#pragma mark - action: 设置是否可点击
-(void)setIsRegist:(BOOL)isRegist{
    _isRegist = isRegist;
//    if (!isRegist&&self.accoutTxtV.text.length == 11) {
//        NSLog(@"可点");
//        self.verifyCodeTxtV.verifyBtn.backgroundColor = PDMainColor;
//        [self.verifyCodeTxtV.verifyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        self.verifyCodeTxtV.verifyBtn.layer.borderColor = PDMainColor.CGColor;
//        self.verifyCodeTxtV.verifyBtn.userInteractionEnabled = true;
//    }else{
//        NSLog(@"不可点");
//        self.verifyCodeTxtV.verifyBtn.backgroundColor = [UIColor clearColor];
//        [self.verifyCodeTxtV.verifyBtn setTitleColor:k_RBLoginKit_Default_UnAbleColor forState:UIControlStateNormal];
//        self.verifyCodeTxtV.verifyBtn.layer.borderColor = k_RBLoginKit_Default_UnAbleColor.CGColor;
//        self.verifyCodeTxtV.verifyBtn.userInteractionEnabled = NO;
//    }
}


#pragma mark - action: 验证密码，手机号，验证码格式
- (BOOL)verifyCodeFormat:(verifyStep)step{
    __block BOOL result;
    if (step == verifyStepOne) {
        [NSObject mit_makeMitRegexMaker:^(MitRegexMaker *maker) {
            maker.validatePhone(self.accoutTxtV.text);
        }MitValue:^(MitRegexStateType statusType, NSString *statusStr, BOOL isPassed) {
            if (isPassed) {

                
            }else{
                if (self.accoutTxtV.text.length==0) {
                    [MitLoadingView showNoticeWithStatus:@"请输入手机号"];
                }else{
                    [MitLoadingView showErrorWithStatus:statusStr];
                }
            }
            result = isPassed;
        }];
    }else{
        [NSObject mit_makeMitRegexMaker:^(MitRegexMaker *maker) {
            maker.validatePhone(self.accoutTxtV.text).validatePsd(self.psdTxtV.text).validateCodeNumber(self.verifyCodeTxtV.text);
        }MitValue:^(MitRegexStateType statusType, NSString *statusStr, BOOL isPassed) {
            if (isPassed) {

            }else{
                if (self.accoutTxtV.text.length == 0) {
                    [MitLoadingView showNoticeWithStatus:@"请输入11位手机号"];
                }else{
                    [MitLoadingView showErrorWithStatus:statusStr];

                }
                
            }
            result = isPassed;
        }];
    }
    return result;
}

#pragma mark - action: 页面点击，收起键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
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
                [self.verifyCodeTxtV.verifyBtn setTitle:@"重新发送" forState:UIControlStateNormal];
                self.verifyCodeTxtV.verifyBtn.enabled = true;
                _isWaiting = NO;
            });
        }else{
            __block NSString * str = @"";
            __block int seconds = 0;
            __block NSString * strTime = @"";
            dispatch_queue_t queue1 = dispatch_queue_create("1", DISPATCH_QUEUE_CONCURRENT);
            dispatch_async(queue1, ^{
                seconds = timeout % 60;
                strTime = [NSString stringWithFormat:@"%.2d", seconds];
            });
            dispatch_barrier_async(queue1, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    _verifyCodeTxtV.verifyBtn.enabled = NO;
                    str = [NSString stringWithFormat:@"%@s后重新发送",strTime];
                    //设置界面的按钮显示 根据自己需求设置
                    [_verifyCodeTxtV.verifyBtn setTitle:str forState:UIControlStateNormal];
                    if ([UIDevice isIOS7]) {
                        _verifyCodeTxtV.verifyBtn.titleLabel.text = str;
                        [_verifyCodeTxtV.verifyBtn.titleLabel setAdjustsFontSizeToFitWidth:YES];
                    }
                    _isWaiting = true;
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
        [RBAuthApi sendCode:self.accoutTxtV.text type:RBSendCodeTypeRegister completionBlock:^(BOOL isSend, NSError *error) {
            [MitLoadingView dismiss];
            [self startTiemCountdown];
        }];
    }
}
#pragma mark - action: 服务条款点击
- (void)agreeLabTapClick:(UITapGestureRecognizer*)tap{
    CGPoint  point = [tap locationInView:self.agreementLabel];
    if (point.x>100&&point.x<self.agreementLabel.width) {
        RBHtmlViewController*vc = [[RBHtmlViewController alloc]init];
        vc.urlString = @"http://m.pudding.roobo.com/lisences.htm";
        vc.navTitle = @"用户协议";
        if (self.navigationController) {
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            [self presentViewController:vc animated:true completion:nil];
        }
    }
}
#pragma mark - action: 注册按钮点击
- (void)registAction:(UIButton*)btn{
    /** 判断注册 */
    if ([self verifyCodeFormat:verifyStepTwo]) {
        [self sendRegistRequest];
    }
}


#pragma mark - action: 发送注册请求
- (void)sendRegistRequest{
    self.view.userInteractionEnabled = false;
    [MitLoadingView showWithStatus:@"注册中..."];
    [RBAuthApi regist:self.accoutTxtV.text password:self.psdTxtV.text code:self.verifyCodeTxtV.text nickName:self.accoutTxtV.text completionBlock:^(RBUserModel *user, NSError *error) {
        if (user) {
            [MitLoadingView showSuceedWithStatus:@"注册成功"];
            //注册成功block回调
            if (self.rb_registBack) {
                self.rb_registBack(user,nil);
            }
            //注册成功代理回调
            if (RB_LoginKit_Manager.delegate && [RB_LoginKit_Manager.delegate respondsToSelector:@selector(rb_registResultWithModel:error:)]) {
                [RB_LoginKit_Manager.delegate performSelector:@selector(rb_registResultWithModel:error:) withObject:user withObject:nil];
            }
            //注册成功界面消失
            [self dismissViewControllerAnimated:true completion:nil];
        }else{
            [MitLoadingView showErrorWithStatus:k_RBLoginKit_Error_Description];
            //注册失败block回调
            if (self.rb_registBack) {
                self.rb_registBack(nil,error);
            }
            //注册成功代理回调
            if (RB_LoginKit_Manager.delegate && [RB_LoginKit_Manager.delegate respondsToSelector:@selector(rb_registResultWithModel:error:)]) {
                [RB_LoginKit_Manager.delegate performSelector:@selector(rb_registResultWithModel:error:) withObject:nil withObject:error];
            }
        }
        self.view.userInteractionEnabled = true;
    }];
}

#pragma mark ------------------- textfiledDelegate ------------------------
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString * result = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if([result mStrLength] >4 && [textField.superview isEqual:self.verifyCodeTxtV]){
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
    return true;
    
    
    
    return true;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if(textField.superview == self.accoutTxtV){
        self.accoutTxtV.selected = true;

    }else if (textField.superview == self.verifyCodeTxtV){
        self.verifyCodeTxtV.selected = true;
    }else{
        self.psdTxtV.selected = true;
    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField.superview == self.accoutTxtV){
        self.accoutTxtV.selected = NO;
        
    }else if (textField.superview == self.verifyCodeTxtV){
        self.verifyCodeTxtV.selected = NO;
    }else{
        self.psdTxtV.selected = NO;
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.superview == self.psdTxtV) {
        [self.verifyCodeTxtV becomeFirstRespond];
    }
    return true;
}


@end









