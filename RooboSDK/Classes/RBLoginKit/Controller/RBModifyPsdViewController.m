//
//  RBModifyPsdViewController.m
//  Pudding
//
//  Created by william on 16/2/18.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//

#import "RBModifyPsdViewController.h"
#import "RBTextFieldView.h"
#import "MitRegex.h"
#import "RBLoginConfig.h"
#import "UIView+RBLayoutExtension.h"
#import "MitLoading.h"
#import "RBAuthApi.h"
#import "NSObject+RBFilterNull.h"
#import "NSBundle+RBLoginKitBundle.h"
#import "UIViewController+RBExtension.h"
@interface RBModifyPsdViewController ()<UITextFieldDelegate>
/** 旧的密码 */
@property (nonatomic, weak) RBTextFieldView * oldPsdTxtV;
/** 新的密码 */
@property (nonatomic, weak) RBTextFieldView * psdTxtV;
/** 完成按钮 */
@property (nonatomic, weak) UIButton * finishBtn;


/** 键盘是否动画 */
@property (nonatomic, assign) BOOL isKeyboardAnimate;

/** 可用的颜色 */
@property (nonatomic, strong) UIColor *abledColor;
/** 不可用的颜色 */
@property (nonatomic, strong) UIColor *disabledColor;
/** 导航视图 */
@property (nonatomic, weak) UIView * navView;
/** 导航文本 */
@property (nonatomic, weak) UILabel * navLab;
/** 返回按钮 */
@property (nonatomic, weak) UIButton * navBackBtn;

@end

@implementation RBModifyPsdViewController

+ (instancetype)show{
    RBModifyPsdViewController * vc = [RBModifyPsdViewController new];
    [[UIViewController getCurrentVC] presentViewController:vc animated:true completion:nil];
    return vc;
}

#pragma mark ------------------- lifeCycle ------------------------
#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    /** 初始化导航栏 */
    [self initialNav];
    self.view.backgroundColor = [UIColor whiteColor];//k_RBLoginKit_BackColor
    /** 旧密码 */
    self.oldPsdTxtV.hidden = NO;
    /** 新密吗 */
    self.psdTxtV.hidden = NO;
    
    /** 完成按钮 */
    
    self.finishBtn.layer.cornerRadius = self.finishBtn.height*0.5;
    self.finishBtn.backgroundColor = k_RBLoginKit_Default_UnAbleColor;
    self.finishBtn.userInteractionEnabled = NO;
    
    /** 监听旧密码 */
    [self.oldPsdTxtV addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    /** 监听密码 */
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
    
    [self.oldPsdTxtV becomeFirstRespond];

}

#pragma mark - action: 观察者
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if (object == self.oldPsdTxtV) {
        //检查登录按钮是否可用
        if (self.oldPsdTxtV.text.length>0&&self.psdTxtV.text.length>0) {
            self.finishBtn.backgroundColor = k_RBLoginKit_Default_MainColor;
            self.finishBtn.userInteractionEnabled = YES;
        }else{
            self.finishBtn.backgroundColor = k_RBLoginKit_Default_UnAbleColor;
            self.finishBtn.userInteractionEnabled = NO;
        }
    }else if (object == self.psdTxtV){
        //检查登录按钮是否可用
        if (self.oldPsdTxtV.text.length>0&&self.psdTxtV.text.length>0) {
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
    [self.oldPsdTxtV removeObserver:self forKeyPath:@"text"];
    [self.psdTxtV removeObserver:self forKeyPath:@"text"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}
#pragma mark - 初始化导航栏
- (void)initialNav{
    if (self.navigationController) {
        self.title = @"修改密码";
    }else{
        self.navView.hidden = false;
        self.navLab.text = @"修改密码";
        self.navBackBtn.hidden = false;
    }
    self.navigationController.navigationBar.hidden = true;
    self.automaticallyAdjustsScrollViewInsets = NO;

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

#pragma mark - 创建 -> 旧密码
static CGFloat kNavHeight = 64;
static CGFloat kEdgePacing = 45;
static CGFloat kTxtHeight = 45;
static CGFloat kHoribleEdgePacing = 30;
-(RBTextFieldView *)oldPsdTxtV{
    if (!_oldPsdTxtV) {
        __weak typeof(self) weakself = self;
        RBTextFieldView * vi = [RBTextFieldView RBTextFieldViewWithFrame:CGRectMake(kEdgePacing, kEdgePacing+kNavHeight, self.view.width-2*kEdgePacing, kTxtHeight) Type:RB_TextTypeNormal OnlyBlock:^(UITextField *txtField) {
            txtField.delegate = weakself;
            txtField.placeholder = @"输入旧密码";
            txtField.textColor = k_RBLoginKit_Default_TextColor;
            txtField.returnKeyType = UIReturnKeyNext;
            txtField.secureTextEntry = YES;
            txtField.font = [UIFont fontWithName:k_RBLoginKit_DefaultFontName size:k_RBLoginKit_DefaultFontSize - 3];
            
        }];
        vi.selected = NO;
        [self.view addSubview:vi];
        _oldPsdTxtV = vi;
    }
    return _oldPsdTxtV;
}

#pragma mark - 创建 -> 新密码
-(RBTextFieldView *)psdTxtV{
    if (!_psdTxtV) {
        __weak typeof(self) weakself = self;
        RBTextFieldView * vi = [RBTextFieldView RBTextFieldViewWithFrame:CGRectMake(kEdgePacing,self.oldPsdTxtV.bottom + kHoribleEdgePacing, self.view.width-2*kEdgePacing, kTxtHeight) Type:RB_TextTypeSecret OnlyBlock:^(UITextField *txtField) {
            txtField.delegate = weakself;
            txtField.placeholder = @"输入新密码";
            txtField.textColor = k_RBLoginKit_Default_TextColor;
            txtField.returnKeyType = UIReturnKeyGo;
            txtField.secureTextEntry = YES;
            txtField.font = [UIFont fontWithName:k_RBLoginKit_DefaultFontName size:k_RBLoginKit_DefaultFontSize - 1];
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


#pragma mark - 创建 -> 完成按钮
-(UIButton *)finishBtn{
    if (!_finishBtn) {
        UIButton*btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(self.psdTxtV.left, self.psdTxtV.bottom+kEdgePacing, self.view.width-2*kEdgePacing, kTxtHeight);
        [btn setTitle:@"完成" forState:UIControlStateNormal];
        btn.layer.borderColor = [UIColor blackColor].CGColor;
        btn.layer.masksToBounds = YES;
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(finishAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        _finishBtn = btn;
    }
    return _finishBtn;
}


#pragma mark - 状态栏颜色
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
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


#pragma mark - action: 完成按钮
- (void)finishAction{
    if ([self verifyPsdFormat]) {
        [self sendModifyPsdRequest];
    }
    
}
#pragma mark - action: 验证密码格式
- (BOOL)verifyPsdFormat{
    __block BOOL result;
    [NSObject mit_makeMitRegexMaker:^(MitRegexMaker *maker) {
        maker.validatePsd(self.oldPsdTxtV.text).validatePsd(self.psdTxtV.text);
    }MitValue:^(MitRegexStateType statusType, NSString *statusStr, BOOL isPassed) {
        if (isPassed) {
        }else{
            [MitLoadingView showErrorWithStatus:statusStr];
        }
        result = isPassed;
    }];
    return result;
}
#pragma mark - action: 发送网络请求修改密码
- (void)sendModifyPsdRequest{
    [MitLoadingView showWithStatus:@"正在发送"];
    
    [RBAuthApi updatePassword:self.oldPsdTxtV.text newPsd:self.psdTxtV.text completionBlock:^(BOOL isSuccess, NSError *error) {
        //发送修改成功的回调
        if (self.rb_modifyResultBack) {
            self.rb_modifyResultBack(isSuccess,error);
        }
        if (isSuccess) {
            [MitLoadingView showSuceedWithStatus:@"修改成功" delayTime:1.2];

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.navigationController) {
                    [self.navigationController popViewControllerAnimated:true];
                }else{
                    [self dismissViewControllerAnimated:true completion:nil];
                }
            });
        }else{
            [MitLoadingView showErrorWithStatus:k_RBLoginKit_Error_Description];
        }
        
    }];
}
#pragma mark - action: 点击页面，键盘消失
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark ------------------- UITextFieldDelegate ------------------------

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.superview == self.oldPsdTxtV) {
        [self.psdTxtV becomeFirstRespond];
    }else{
        [self finishAction];
    }
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField.superview == self.oldPsdTxtV) {
        self.oldPsdTxtV.selected = YES;
    }else{
        self.psdTxtV.selected = YES;
    }
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.superview == self.oldPsdTxtV) {
        self.oldPsdTxtV.selected = NO;
    }else{
        self.psdTxtV.selected = NO;
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    //密码小于20个
    NSString * result = [textField.text stringByReplacingCharactersInRange:range withString:string];
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
