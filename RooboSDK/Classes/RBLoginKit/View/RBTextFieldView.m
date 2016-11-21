//
//  RBTextFieldView.m
//  Pudding
//
//  Created by william on 16/1/28.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//

#import "RBTextFieldView.h"
#import "RBTextField.h"
#import "RBPhoneTextField.h"
#import "RBLoginConfig.h"
#import "NSBundle+RBLoginKitBundle.h"
typedef NS_ENUM(NSUInteger, RBTextFieldType) {
    RBTextFieldTypeImg,
    RBTextFieldTypeTxt,
    RBTextFieldTypeMix,
    RBTextFieldTypeNone,
};

@interface RBTextFieldView ()

/** 提示图片视图 */
@property (nonatomic, weak) UIImageView * alertImgV;
/** 提示名称Lab */
@property (nonatomic, weak) UILabel *alertLab;
/** 类型 */
@property (nonatomic, assign) RBTextFieldType txtFieldType;

/** 底部的线 */
@property (nonatomic, weak) UIView * bottomLine;

@end


@implementation RBTextFieldView

+(instancetype)RBTextFieldViewWithFrame:(CGRect)frame Txt:(NSString *)txt PlaceTxt:(NSString *)placeTxt{
    return [[self alloc]initWithFrame:frame Txt:txt PlaceTxt:placeTxt];
}
+(instancetype)RBTextFieldViewWithFrame:(CGRect)frame Img:(UIImage *)img PlaceTxt:(NSString *)placeTxt{
    return [[self alloc]initWithFrame:frame Img:img PlaceTxt:placeTxt];
}
+(instancetype)RBTextFieldViewWithFrame:(CGRect)frame Img:(UIImage *)img ImgBlock:(void (^)(UITextField *))block{
    return [[self alloc]initWithFrame:frame Img:img Block:block];
}

+ (instancetype)RBTextFieldViewWithFrame:(CGRect)frame Type:(RB_TextType)type TxtBlock:(void(^)(UITextField*txtField,UILabel*lab))block{
    return [[self alloc]initWithFrame:frame Type:type TxtBlock:block];
}

+ (instancetype)RBTextFieldViewWithFrame:(CGRect)frame Type:(RB_TextType)type ImgBlock:(void(^)(UITextField * txtField,UIImageView * image))block{
    return [[self alloc]initWithFrame:frame Type:type ImgBlock:block];
   
}

+(instancetype)RBTextFieldViewWithFrame:(CGRect)frame Type:(RB_TextType)type OnlyBlock:(void (^)(UITextField *))block{
    return [[self alloc]initWithFrame:frame Type:type OnlyBlock:block];
}



#pragma mark ------------------- 初始化方式 ------------------------
-(instancetype)initWithFrame:(CGRect)frame Img:(UIImage *)image PlaceTxt:(NSString*)placeTxt{
    if (self = [super initWithFrame:frame]) {
        self.alertImgV.image = image;
        self.txtFieldType = RBTextFieldTypeImg;
        self.txtField.placeholder = placeTxt;
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame Txt:(NSString *)txt PlaceTxt:(NSString*)placeTxt{
    if (self = [super initWithFrame:frame]) {
        self.alertLab.text = txt;
        self.txtFieldType = RBTextFieldTypeTxt;
        self.txtField.placeholder = placeTxt;


    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame Txt:(NSString *)txt Img:(UIImage *)image PlaceTxt:(NSString*)placeTxt{
    if (self = [super initWithFrame:frame]) {
        self.alertImgV.image= image;
        self.alertLab.text = txt;
        self.txtFieldType = RBTextFieldTypeMix;
        self.txtField.placeholder = placeTxt;
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame Type:(RB_TextType)type TxtBlock:(void(^)(UITextField*txtField,UILabel*label))block{
    if (self = [super initWithFrame:frame]) {
        self.type = type;
        self.txtFieldType = RBTextFieldTypeTxt;
        block(self.txtField,self.alertLab);
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame Type:(RB_TextType)type ImgBlock:(void(^)(UITextField*txtField,UIImageView*imageV))block{
    if (self = [super initWithFrame:frame]) {
        self.type = type;
        self.txtFieldType = RBTextFieldTypeImg;
        block(self.txtField,self.alertImgV);
        /** 添加通知 */
//        if (self.type == RB_TextTypeAccount) {
//            NSLog(@"%lu",self.type);
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shouldChangeCharactersInRange:) name:UITextFieldTextDidChangeNotification object:nil];
//        }

    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame Type:(RB_TextType)type OnlyBlock:(void(^)(UITextField*txtField))block{
    if (self = [super initWithFrame:frame]) {
        self.type = type;
        self.txtFieldType = RBTextFieldTypeNone;
        block(self.txtField);
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shouldChangeCharactersInRange:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}



- (instancetype)initWithFrame:(CGRect)frame Img:(UIImage *)image Block:(void(^)(UITextField*txtField))block{
    if (self = [super initWithFrame:frame]) {
        self.alertImgV.image= image;
        self.txtFieldType = RBTextFieldTypeImg;
        block(self.txtField);
    }
    return self;
}



//四周的边距
static CGFloat kEdgePacing = 5;
static CGFloat kAlertLabWidth = 45;
#pragma mark ------------------- LazyLoad 方法 ------------------------
#pragma mark - 创建 -> 创建 alertImgV
-(UIImageView *)alertImgV{
    if (!_alertImgV) {
        UIImageView*imgV = [[UIImageView alloc]initWithFrame:CGRectMake(kEdgePacing, kEdgePacing, self.frame.size.height-kEdgePacing*2, self.frame.size.height-2*kEdgePacing)];
        [self addSubview:imgV];
        _alertImgV = imgV;
    }
    return _alertImgV;
}


#pragma mark - 创建 -> 创建 alertLab
-(UILabel *)alertLab{
    if (!_alertLab) {
        UILabel*lab = [[UILabel alloc]initWithFrame:CGRectMake(kEdgePacing, kEdgePacing, kAlertLabWidth, self.frame.size.height-2*kEdgePacing)];
        lab.textColor = [UIColor blackColor];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = [UIFont systemFontOfSize:15];
        [self addSubview:lab];
        _alertLab = lab;
    }
    return _alertLab;
}

static const CGFloat kVerifyWidth = 100;
#pragma mark - 创建 -> 验证码按钮
-(UIButton *)verifyBtn{
    if (!_verifyBtn) {
        UIButton*btn =[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(self.frame.size.width - kEdgePacing - kVerifyWidth, kEdgePacing, kVerifyWidth, self.frame.size.height - 2*kEdgePacing);
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = btn.frame.size.height *0.5;
        btn.layer.borderColor = k_RBLoginKit_Default_UnAbleColor.CGColor;
        btn.layer.borderWidth = 1;
        btn.backgroundColor = [UIColor clearColor];
        [btn setTitle:@"发送验证码" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:k_RBLoginKit_DefaultFontSize - 4];
        [btn setTitleColor:k_RBLoginKit_Default_UnAbleColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(verifyBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        _verifyBtn = btn;
    }
    return _verifyBtn;
}

static const CGFloat kPsdBtnWidth = 30;
#pragma mark - 创建 -> 隐藏密码按钮
- (UIButton *)hidePsdBtn{
    if (!_hidePsdBtn) {
        UIButton*btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(self.frame.size.width - kPsdBtnWidth - 2*kEdgePacing, kEdgePacing, kPsdBtnWidth, self.frame.size.height - 2*kEdgePacing);
        [btn setImage:[NSBundle rb_LoginKit_ImgWithImgName:@"icon_eye_on"] forState:UIControlStateNormal];
        [btn setImage:[NSBundle rb_LoginKit_ImgWithImgName:@"icon_eye_off"] forState:UIControlStateSelected];
        btn.layer.cornerRadius = btn.frame.size.height*0.5;
        btn.layer.masksToBounds = YES;
        [btn addTarget:self action:@selector(hidePsdClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        _hidePsdBtn = btn;
    }
    return _hidePsdBtn;
}

#pragma mark - 创建 -> textField
-(RBTextField *)txtField{
    if (!_txtField) {
        RBTextField*txtF;
        if (self.type==RB_TextTypeAccount) {
            txtF =(RBTextField *)[[RBPhoneTextField alloc]initWithFrame:CGRectZero];
        }else{
            txtF = [[RBTextField alloc]initWithFrame:CGRectZero];
        }
        switch (self.txtFieldType) {
            case RBTextFieldTypeTxt:
            {
                if (self.type ==RB_TextTypeVerifyCode) {
                    txtF.frame =CGRectMake(self.alertLab.frame.origin.x+self.alertLab.frame.size.width+kEdgePacing, kEdgePacing, self.frame.size.width-2*kEdgePacing-self.alertLab.frame.size.width - self.verifyBtn.frame.size.width - kEdgePacing, self.frame.size.height-2*kEdgePacing);
                }else if (self.type == RB_TextTypeSecret){
                    txtF.frame =CGRectMake(self.alertLab.frame.origin.x+self.alertLab.frame.size.width+kEdgePacing, kEdgePacing, self.frame.size.width-2*kEdgePacing-self.alertLab.frame.size.width - self.hidePsdBtn.frame.size.width - 2*kEdgePacing, self.frame.size.height-2*kEdgePacing);
                }else{
                    txtF.frame =CGRectMake(self.alertLab.frame.origin.x+self.alertLab.frame.size.width+kEdgePacing, kEdgePacing, self.frame.size.width-2*kEdgePacing-self.alertLab.frame.size.width, self.frame.size.height-2*kEdgePacing);
                }
            }
                break;
            case RBTextFieldTypeImg:
            {
                if (self.type ==RB_TextTypeVerifyCode) {
                    txtF.frame =CGRectMake(self.alertImgV.frame.origin.x+self.alertImgV.frame.size.width+2*kEdgePacing, kEdgePacing, self.frame.size.width-4*kEdgePacing-self.alertImgV.frame.size.width - self.verifyBtn.frame.size.width - kEdgePacing, self.frame.size.height-2*kEdgePacing);
                }else if (self.type == RB_TextTypeSecret){
                    txtF.frame =CGRectMake(self.alertImgV.frame.origin.x+self.alertImgV.frame.size.width+ 2*kEdgePacing, kEdgePacing, self.frame.size.width-4*kEdgePacing-self.alertImgV.frame.size.width - self.hidePsdBtn.frame.size.width - 2*kEdgePacing, self.frame.size.height-2*kEdgePacing);
                    
                }else{
                    txtF.frame =CGRectMake(self.alertImgV.frame.origin.x+self.alertImgV.frame.size.width+2*kEdgePacing, kEdgePacing, self.frame.size.width-4*kEdgePacing-self.alertImgV.frame.size.width, self.frame.size.height-2*kEdgePacing);
                }
            }
                break;
            case RBTextFieldTypeNone:
            {
                if (self.type ==RB_TextTypeVerifyCode) {
                    txtF.frame =CGRectMake(kEdgePacing, kEdgePacing, self.frame.size.width-4*kEdgePacing - self.verifyBtn.frame.size.width , self.frame.size.height-2*kEdgePacing);
                }else if (self.type == RB_TextTypeSecret){
                    txtF.frame =CGRectMake( kEdgePacing, kEdgePacing, self.frame.size.width-4*kEdgePacing - self.hidePsdBtn.frame.size.width, self.frame.size.height-2*kEdgePacing);
                }else{
                    txtF.frame =CGRectMake(kEdgePacing, kEdgePacing, self.frame.size.width-kEdgePacing, self.frame.size.height-2*kEdgePacing);
                }
            }
            case RBTextFieldTypeMix:
                break;
        }
        txtF.tintColor = k_RBLoginKit_Default_UnAbleColor;
        txtF.font = [UIFont systemFontOfSize:15];
        txtF.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self addSubview:txtF];
        _txtField = txtF;
    }
    return _txtField;
}


#pragma mark - 创建 -> 底部的线
-(UIView *)bottomLine{
    if (!_bottomLine) {
        UIView *vi = [[UIView alloc]initWithFrame:CGRectZero];
        if (self.type == RB_TextTypeVerifyCode) {
            vi.frame = CGRectMake(0, self.frame.size.height - 1, self.txtField.frame.size.width, 1);
        }else{
            vi.frame = CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1);
        }
        vi.backgroundColor = k_RBLoginKit_Default_UnAbleColor;
        [self addSubview:vi];
        _bottomLine  = vi;
    }
    return _bottomLine;
    
    
}


#pragma mark ------------------- Action ------------------------
#pragma mark - action: 观察者方法，设置 text 的改变
- (void)shouldChangeCharactersInRange:(NSNotification *)sender{
    UITextField * textField = sender.object;
    self.text =[textField.attributedText.string stringByReplacingOccurrencesOfString:@" " withString:@""];
}
#pragma mark - action: 设置选中状态
-(void)setSelected:(BOOL)selected{
    _selected = selected;
    if (selected) {
        self.bottomLine.backgroundColor = k_RBLoginKit_Default_MainColor;
    }else{
        self.bottomLine.backgroundColor = k_RBLoginKit_Default_UnAbleColor;
    }
}
#pragma mark - action: 验证码按钮点击
- (void)verifyBtnClick{
    if (self.callBack) {
        self.callBack(_verifyBtn);
    }
}
#pragma mark - action: 隐藏密码按钮点击
- (void)hidePsdClick{
    self.hidePsdBtn.selected = !self.hidePsdBtn.selected;
    self.txtField.secureTextEntry = !self.hidePsdBtn.selected;
    self.txtField.font = [UIFont fontWithName:k_RBLoginKit_DefaultFontName size:k_RBLoginKit_DefaultFontSize - 2];
    if (!self.txtField.isSecureTextEntry) {
        NSLog(@"切换了");
        self.txtField.keyboardType = UIKeyboardTypeAlphabet;
        
    }
}




#pragma mark - action: 隐藏密码按钮点击，是否能够看密码
-(void)clickHidePsdBtn:(BOOL)canSee{
    self.hidePsdBtn.selected = canSee;
    self.txtField.secureTextEntry = !canSee;
    
}


#pragma mark - action: 成为第一响应者
- (void)becomeFirstRespond{
    [self.txtField becomeFirstResponder];
}
#pragma mark - action: 取消第一响应者
- (void)resignFirstRespond{
    [self.txtField resignFirstResponder];

}

#pragma mark - action: 设置当前页面类型
-(void)setType:(RB_TextType)type{
    _type = type;
}

#pragma mark - action: 获取输入框文本
-(NSString *)text{
    if (!self.isContainSpace) {
        NSString * str = [_txtField.attributedText.string stringByReplacingOccurrencesOfString:@" " withString:@""];
        return str;
    }else{
        return _txtField.attributedText.string;
    }
}
-(void)setIsContainSpace:(BOOL)isContainSpace{
    NSLog(@"isContainSpace = %d",isContainSpace);
    _isContainSpace = isContainSpace;
}

#pragma mark - action: 设置当前输入框文本
- (void)setUpText:(NSString *)text{
    self.txtField.text = text;
}

#pragma mark - action: 验证码按钮恢复原样
-(void)verifyBecomeOriginal{
    [self.verifyBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
}


#pragma mark - action: 显示警告文本
-(void)showWarmText:(NSString *)text{
    NSLog(@"%s",__func__);
}


#pragma mark - dealloc
- (void)dealloc{
//    if (self.type == RB_TextTypeAccount) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
//    }
}
@end
