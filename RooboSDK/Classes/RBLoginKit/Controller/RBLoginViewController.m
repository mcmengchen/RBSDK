//
//  RBLoginViewController.m
//  Pods
//
//  Created by william on 16/11/14.
//
//

#import "RBLoginViewController.h"
#import "RBLabButton.h"
#import "RBTextFieldView.h"
#import "RBRightImageBtn.h"
#import "UIView+RBLayoutExtension.h"
#import "RBLoginConfig.h"
#import "MitLoading.h"
#import "MitRegex.h"
#import "RBAuthApi.h"
#import "NSObject+RBFilterNull.h"
#import "RBRegisterViewController.h"
#import "RBForgetPsdViewController.h"
#import "RBLoginKitManager.h"
#import "UIViewController+RBExtension.h"
#import "RBNavigationController.h"
@interface RBLoginViewController ()

/** 账号 */
@property (nonatomic, weak) RBTextFieldView * accoutTxtV;
/** 密码 */
@property (nonatomic, weak) RBTextFieldView * psdTxtV;
/** 登录按钮 */
@property (nonatomic, weak) UIButton *loginBtn;
/** 注册按钮 */
@property (nonatomic, weak) RBRightImageBtn *registBtn;
/** 忘记密码按钮 */
@property (nonatomic, weak) RBLabButton *forgetBtn;
/** 是否注册 */
@property (nonatomic, assign) BOOL isRegist;
/** 键盘是否动画 */
@property (nonatomic, assign) BOOL isKeyboardAnimate;
/** 导航视图 */
@property (nonatomic, weak) UIView * navView;
/** 导航文本 */
@property (nonatomic, weak) UILabel * navLab;

@end

@implementation RBLoginViewController

+ (instancetype)show{
    RBLoginViewController * vc = [[RBLoginViewController alloc]init];
    RBNavigationController * nav = [[RBNavigationController alloc]initWithRootViewController:vc];
    UIViewController * topVc = [UIViewController getCurrentVC];
    [topVc presentViewController:nav animated:true completion:nil];
    return vc;
}

#pragma mark ------------------- life cycle ------------------------
#pragma mark - viewWillAppear
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
    
}
#pragma mark - 状态栏颜色
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [MitLoadingView dismiss];
}



#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    /** 初始化导航 */
    [self initialNav];
    //账号Txt
    self.accoutTxtV.layer.cornerRadius = 5;
    //密码Txt
    self.psdTxtV.layer.cornerRadius = 5;
    //登录按钮
    
    self.loginBtn.backgroundColor = k_RBLoginKit_Default_UnAbleColor;
    //注册按钮
    self.registBtn.backgroundColor  = [UIColor clearColor];
    //忘记密码按钮
    self.forgetBtn.backgroundColor = [UIColor clearColor];
    /** 设置手机号 */
    NSUserDefaults * user =  [NSUserDefaults standardUserDefaults];
    if ([user valueForKey:k_RB_PhoneKey]) {
        [self.accoutTxtV setUpText:[user valueForKey:k_RB_PhoneKey]];
    }
    /** 监听账号 */
    [self.accoutTxtV addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];

    /** 添加键盘通知 */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    //获取上次登录的手机号
    /**
     *  如果有值则是超时退出，如果无值就是点击退出
     *  有值那么密码成为第一响应，无值账号是第一响应。
     */
    NSUserDefaults * users = [NSUserDefaults standardUserDefaults];
    NSString * lastLoginPhone = [users valueForKey:k_RB_PhoneKey];
    if (lastLoginPhone) {
        if (lastLoginPhone.length>0) {
            [self.psdTxtV becomeFirstRespond];
        }else{
            [self.accoutTxtV becomeFirstRespond];
        }
    }else{
        [self.accoutTxtV becomeFirstRespond];
    }
 
}


#pragma mark - action: 观察者方法
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if (object == self.accoutTxtV) {
        if(self.accoutTxtV.text.length == 11&&[self.accoutTxtV isSelected]){
            [self checkPhoneIsRegister:self.accoutTxtV.text];
        }
        //检查登录按钮是否可用
        if (self.accoutTxtV.text.length>0&&self.psdTxtV.text.length>0) {
            self.loginBtn.backgroundColor = k_RBLoginKit_Default_MainColor;
            self.loginBtn.userInteractionEnabled = YES;
        }else{
            self.loginBtn.backgroundColor = k_RBLoginKit_Default_UnAbleColor;
            self.loginBtn.userInteractionEnabled = NO;
        }
    }
    
    
    
}

#pragma mark - 初始化导航栏
- (void)initialNav{
    self.navView.hidden = false;
    self.navLab.text = @"登录";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController setNavigationBarHidden:YES animated:false];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

#pragma mark - dealloc
-(void)dealloc{
    [self.accoutTxtV removeObserver:self forKeyPath:@"text"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark ------------------- Lazy - Load ------------------------
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

//#pragma mark - 创建 -> 导航返回按钮
//- (UIButton *)navBackBtn{
//    if (!_navBackBtn) {
//        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        btn.frame = CGRectMake(0, 20, 60, 44);
//        [self.navView addSubview:btn];
//        [btn addTarget:self action:@selector(navBackBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//        _navBackBtn = btn;
//    }
//    return _navBackBtn;
//}
//#pragma mark - action: 导航返回按钮点击
//- (void)navBackBtnClick:(UIButton *)btn{
//    if (self.rb_LoginBackBtnClick) {
//        self.rb_LoginBackBtnClick();
//    }
//}



#pragma mark - 创建 -> 账号
static CGFloat kEdgePacing = 45;
static CGFloat kTxtHeight = 45;
static CGFloat kHoribleEdgePacing = 30;
-(RBTextFieldView *)accoutTxtV{
    if (!_accoutTxtV) {
        __weak typeof(self) weakself = self;
        RBTextFieldView *vi = [RBTextFieldView RBTextFieldViewWithFrame:CGRectMake(kEdgePacing, kEdgePacing+k_RBLoginKit_NavHeight, self.view.width-2*kEdgePacing, kTxtHeight) Type:RB_TextTypeAccount OnlyBlock:^(UITextField *txtField) {
            txtField.delegate = weakself;
            txtField.placeholder = @"请输入手机号";
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

#pragma mark - action: 监控密码文本
- (void)textFieldChanged:(UITextField*)textField{
    //空格解决方案s
    NSString *_string = textField.text;
    NSRange _range = [_string rangeOfString:@" "];
    if (_range.location != NSNotFound) {
        //有空格
        [MitLoadingView showErrorWithStatus:@"密码中不能包含空格"];
        textField.text = [NSString stringWithFormat:@"%@",[textField.text substringToIndex:textField.text.length - 1]];
    }
}

#pragma mark - 创建 -> 密码
-(RBTextFieldView *)psdTxtV{
    
    if (!_psdTxtV) {
        __weak typeof(self) weakself = self;
        RBTextFieldView *vi = [RBTextFieldView RBTextFieldViewWithFrame:CGRectMake(kEdgePacing, kHoribleEdgePacing+self.accoutTxtV.bottom, self.view.width-2*kEdgePacing, kTxtHeight) Type:RB_TextTypeSecret OnlyBlock:^(UITextField *txtField) {
            txtField.delegate = weakself;
            txtField.placeholder =  @"请输入6-20位密码";
            txtField.returnKeyType = UIReturnKeyGo;
            txtField.secureTextEntry = YES;
            txtField.autocorrectionType = UITextAutocorrectionTypeNo;
            txtField.textColor = k_RBLoginKit_Default_TextColor;
            txtField.keyboardType = UIKeyboardTypeAlphabet;
            txtField.keyboardAppearance = UIKeyboardAppearanceDefault;
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
#pragma mark - 创建 -> 登录按钮
-(UIButton *)loginBtn{
    if (!_loginBtn) {
        UIButton*btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(self.psdTxtV.left, self.psdTxtV.bottom + 2.5*kEdgePacing, self.view.width-2*kEdgePacing, kTxtHeight);
        [btn setTitle:@"登录" forState:UIControlStateNormal];
        btn.layer.cornerRadius = btn.height*0.5;
        btn.layer.masksToBounds = YES;
        btn.backgroundColor = k_RBLoginKit_Default_MainColor;
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        _loginBtn = btn;
    }
    return _loginBtn;
}

static CGFloat kRegistBtnWidth = 100;
static CGFloat kRegistBtnHeight = 40;
#pragma mark - 创建 -> 注册按钮
-(RBRightImageBtn *)registBtn{
    if (!_registBtn) {
        RBRightImageBtn*btn = [RBRightImageBtn buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(self.psdTxtV.left, self.psdTxtV.bottom+kEdgePacing*0.25, kRegistBtnWidth, kRegistBtnHeight);
        [btn setTitle:@"快速注册" forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor clearColor];
        btn.titleLabel.font = [UIFont systemFontOfSize:k_RBLoginKit_DefaultFontSize - 3];
        btn.titleLabel.textAlignment = NSTextAlignmentLeft;
        [btn setTitleColor:k_RBLoginKit_Default_TextColor forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"icon_skip"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(registAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.isTitleLeft = YES;
        btn.offsetX = 5;
        [self.view addSubview:btn];
        _registBtn = btn;
    }
    return _registBtn;
}

static CGFloat kForgetBtnWidth = 100;
static CGFloat kForgetBtnHeight = 40;
#pragma mark - 创建 -> 忘记密码
-(RBLabButton *)forgetBtn{
    if (!_forgetBtn) {
        RBLabButton * btn = [RBLabButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(self.psdTxtV.right - kForgetBtnWidth, self.psdTxtV.bottom+kEdgePacing*0.25, kForgetBtnWidth, kForgetBtnHeight);
        [btn setTitle:@"忘记密码?" forState:UIControlStateNormal];
        btn.layer.borderColor = [UIColor blackColor].CGColor;
        btn.titleLabel.font = [UIFont systemFontOfSize:k_RBLoginKit_DefaultFontSize - 3];
        btn.titleLabel.textAlignment = NSTextAlignmentRight;
        btn.backgroundColor = [UIColor orangeColor];
        [btn setTitleColor:k_RBLoginKit_Default_TextColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(foegetPsdAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        _forgetBtn = btn;
    }
    return _forgetBtn;
}




#pragma mark ------------------- Action ------------------------
#pragma mark - action: 键盘升起
- (void)keyboardWillShow:(NSNotification*)notify{
    if ([self.psdTxtV isSelected]) {
        CGRect endRect = [[notify.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat y = endRect.origin.y;
        if (self.psdTxtV.bottom+ kEdgePacing > y) {
            
            [UIView animateWithDuration:0.5 animations:^{
                self.view.center = CGPointMake(k_RBLoginKit_ScreenWidth*0.5, k_RBLoginKit_ScreenHeight*0.5 - kEdgePacing);
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
#pragma mark - action: 检查手机号是否注册
- (void)checkPhoneIsRegister:(NSString *)phoneText{
    self.isRegist = NO;
    __weak typeof(self) weakself = self;
    [RBAuthApi isRegist:phoneText completionBlock:^(NSNumber *isRegist, NSError *error) {
        __strong typeof(self) strongSelf = weakself;
        if ([isRegist intValue] == 1) {
            //已注册
            strongSelf.isRegist = YES;
        } else if([isRegist intValue]==0){
            //未注册
            [MitLoadingView showErrorWithStatus:@"手机号未注册"];
            strongSelf.isRegist = NO;
        } else {
            [MitLoadingView showErrorWithStatus:k_RBLoginKit_Error_Description];
        }
        
        
        
    }];
}

#pragma mark - action: 校验登录点击
- (BOOL)judgeLogin{
    __block BOOL result = NO;
    [NSObject mit_makeMitRegexMaker:^(MitRegexMaker *maker) {
        maker.validatePhone(self.accoutTxtV.text).validatePsd(self.psdTxtV.text);
    }MitValue:^(MitRegexStateType statusType, NSString *statusStr, BOOL isPassed) {
        if (isPassed) {
//            NSLog(@"通过格式校验，发送登录网络请求");
        }else{
            [MitLoadingView showErrorWithStatus:statusStr];
        }
        result = isPassed;
    }];
    return result;
}


#pragma mark - action: 登录按钮点击
-(void)loginAction:(UIButton*)btn{
    if ([self judgeLogin]) {
        [self sendLoginRequest];
    }
}
#pragma mark - action: 注册按钮点击
- (void)registAction:(UIButton*)btn{
    RBRegisterViewController * vc = [RBRegisterViewController new];
    if (self.rb_registBack) {
        vc.rb_registBack = self.rb_registBack;
    }
    if (self.navigationController) {
        [self.navigationController pushViewController:vc animated:true];
    }else{
        [self presentViewController:vc animated:true completion:nil];
    }
    
}

#pragma mark - action: 消失
- (void)dismiss{
    [self dismissViewControllerAnimated:false completion:false];
    
}
#pragma mark - action: 忘记密码点击
- (void)foegetPsdAction:(UIButton*)btn{
    RBForgetPsdViewController * vc = [RBForgetPsdViewController new];
    if (self.rb_forgetPsdBack) {
        vc.rb_forgetPsdBack = self.rb_forgetPsdBack;
    }
    if (self.navigationController) {
        [self.navigationController pushViewController:vc animated:true];
    }else{
        [self presentViewController:vc animated:true completion:nil];
    }
}

#pragma mark - action: 发送登录的网络请求
- (void)sendLoginRequest{
    self.view.userInteractionEnabled = NO;
    [MitLoadingView showWithStatus:@"正在登录"];
    [RBAuthApi login:self.accoutTxtV.text passWord:self.psdTxtV.text completionBlock:^(RBUserModel *user, NSError *error) {
        [MitLoadingView dismiss];
        if (user) {
            [self saveLoginPhone];
            [MitLoadingView showSuceedWithStatus:@"登录成功"];
            //登陆成功block 回调
            if (self.rb_loginBack) {
                self.rb_loginBack(user,nil);
            }
            //登录成功代理回调
            if (RB_LoginKit_Manager.delegate&&[RB_LoginKit_Manager.delegate respondsToSelector:@selector(rb_loginResultWithModel:Error:)]) {
                [RB_LoginKit_Manager.delegate performSelector:@selector(rb_loginResultWithModel:Error:) withObject:user withObject:nil];
            }
            //发送登陆成功的通知
            [[NSNotificationCenter defaultCenter]postNotificationName:@"rb_login_push_succeed" object:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:true completion:nil];
            });
        }else{
            [MitLoadingView showErrorWithStatus:k_RBLoginKit_Error_Description];
            //登陆失败block回调
            if (self.rb_loginBack) {
                self.rb_loginBack(nil,error);
            }
            //登录成功代理回调
            if (RB_LoginKit_Manager.delegate&&[RB_LoginKit_Manager.delegate respondsToSelector:@selector(rb_loginResultWithModel:Error:)]) {
                [RB_LoginKit_Manager.delegate performSelector:@selector(rb_loginResultWithModel:Error:) withObject:nil withObject:error];
            }
            self.view.userInteractionEnabled = true;

        }
    }];
    
}

static  NSString * const k_RB_PhoneKey = @"loginPhoneNumber";
#pragma mark - action: 存储登录手机号
- (void)saveLoginPhone{
    NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
    NSString * phone = self.accoutTxtV.text;
    if (phone&&phone.length>0) {
        [user setValue:phone forKey:k_RB_PhoneKey];
        [user synchronize];
    }
}

#pragma mark - action: 取消键盘响应
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


#pragma mark ------------------- UITextFieldDelegate ------------------------
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string mIntLength]>1) {
        return NO;
    }
    
    //密码小于20个
    NSString * result = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([textField.superview isEqual:self.psdTxtV]) {
        //限制中文和 部分emoji
        NSString *regex2 = @"[\u4e00-\u9fa5][^ ]*|[\\ud800\\udc00-\\udbff\\udfff\\ud800-\\udfff][^ ]*";
        NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
        if ([result mIntLength] >20||[identityCardPredicate evaluateWithObject:string]) {
            return NO;
        }
    }
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.superview == self.accoutTxtV) {
        [self.psdTxtV becomeFirstRespond];
    }else if (textField.superview == self.psdTxtV){
        if ([self judgeLogin]) {
            [self sendLoginRequest];
        }
    }
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if(textField.superview == self.accoutTxtV){
        self.accoutTxtV.selected = YES;
    }else{
        self.psdTxtV.selected = YES;
    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField.superview == self.accoutTxtV){
        self.accoutTxtV.selected = NO;
    }else{
        self.psdTxtV.selected = NO;
    }
}


@end
