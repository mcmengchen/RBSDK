//
//  PDHtmlViewController.m
//  Pudding
//
//  Created by william on 16/2/25.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//

#import "RBHtmlViewController.h"
#import <WebKit/WebKit.h>
#import "UIDevice+RBHardware.h"
#import "MitLoading.h"
#import "RBLoginConfig.h"
#import "UIView+RBLayoutExtension.h"
#import "NSBundle+RBLoginKitBundle.h"

@interface RBHtmlViewController ()<WKNavigationDelegate,UIWebViewDelegate,WKUIDelegate>
/** wkWebView网页 */
@property (nonatomic, strong) WKWebView *wkWebView;
/** uiwebView网页 */
@property (nonatomic, strong) UIWebView *webView;
/** 导航视图 */
@property (nonatomic, weak) UIView * navView;
/** 导航文本 */
@property (nonatomic, weak) UILabel * navLab;
/** 返回按钮 */
@property (nonatomic, weak) UIButton * navBackBtn;
@end

@implementation RBHtmlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialNav];
    dispatch_async(dispatch_get_main_queue(), ^{
        [MitLoadingView showWithStatus:@"正在加载"];
    });
    
    /** 创建 webView */
    if (IS_IOS8_OR_LATER) {
//        NSLog(@"wkwebView");
        if (self.urlString.length>0) {
            [self.wkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];

        }else{

            [self.wkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.roobo.com"]]];

        }
    }else{
//        NSLog(@"UIWebView");
        if (self.urlString.length>0) {
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];
        }else{

            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.roobo.com"]]];

        }
    }

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [self.navigationController setNavigationBarHidden:YES animated:false];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MitLoadingView dismiss];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

}

#pragma mark - 初始化导航栏
- (void)initialNav{

    self.navView.hidden = false;
    self.navLab.text = self.navTitle;
    self.navBackBtn.hidden = false;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = k_RBLoginKit_BackColor;
    self.navigationController.navigationBar.hidden = true;
    __weak typeof(self) weakself = self;
//    [self.navView setLeftCallBack:^(BOOL flag){
//        __strong typeof(self) strongSelf = weakself;
//        if(strongSelf.wkWebView && [strongSelf.wkWebView canGoBack]){
//            [strongSelf.wkWebView goBack];
//            return ;
//        }
//        if(strongSelf.webView && [strongSelf.webView canGoBack]){
//            [self.webView goBack];
//            return ;
//        }
//        if (strongSelf.navigationController) {
//           [strongSelf.navigationController popViewControllerAnimated:YES];
//        }else{
//            [strongSelf dismissViewControllerAnimated:YES completion:nil];
//        }
//    }];

}
//#pragma mark - url
//- (NSURL*)url{
//    NSString * urlStr = @"http://www.baidu.com";
//    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSURL*url = [NSURL URLWithString:urlStr];
//    return url;
//}
#pragma mark - 创建 -> wkWebView
-(WKWebView *)wkWebView{
    if (!_wkWebView) {
        WKWebView *vi= [[WKWebView alloc]initWithFrame:CGRectMake(0, k_RBLoginKit_NavHeight, self.view.width, self.view.height - k_RBLoginKit_NavHeight)];
        vi.allowsBackForwardNavigationGestures = YES;
        vi.navigationDelegate = self;
        vi.UIDelegate = self;
        UIView * backVi = nil;
        for (id v in [vi.scrollView.subviews firstObject].subviews) {
            backVi = v;
            //            backVi.backgroundColor = [UIColor grayColor];
        }
        
        [self.view addSubview:vi];
        _wkWebView = vi;
        if (self.showJSTitle) {
            [vi addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
        }
        
        
    }
    return _wkWebView;
}


#pragma mark - 状态栏颜色
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"title"])
    {
        if (object == self.wkWebView) {
            self.title = self.wkWebView.title;
        }
        else
        {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
}



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
#pragma mark - 创建 -> webView
-(UIWebView *)webView{
    if (!_webView) {
        UIWebView *vi = [[UIWebView alloc]initWithFrame:CGRectMake(0, k_RBLoginKit_NavHeight, self.view.width, self.view.height - k_RBLoginKit_NavHeight)];
        vi.delegate = self;
        [self.view addSubview:vi];
        _webView = vi;
        UILabel*lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 40)];
        lab.center = CGPointMake(self.view.width/2.0, lab.height/2.0);
        lab.font = [UIFont systemFontOfSize:12];
        lab.text = @"网页由 roobo.bo 提供";
        lab.textColor = [UIColor whiteColor];
        lab.textAlignment = NSTextAlignmentCenter;
        [_webView insertSubview:lab atIndex:0];
        
    }
    return _webView;
    
}

- (void)showErrorTip:(NSError *)error{
    if(error.code == -1009){
        [MitLoadingView showErrorWithStatus:@"请检测网络连接"];
        __weak typeof(self) weakself = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakself;
            if (strongSelf.navigationController) {
                [strongSelf.navigationController popViewControllerAnimated:YES];
            }else{
                [strongSelf dismissViewControllerAnimated:true completion:false];
            }
        });
    }else{
        [MitLoadingView showErrorWithStatus:[NSString stringWithFormat:@"error code %ld",(long)error.code]];
    }
}

#pragma mark ------------------- WKNavigationDelegate ------------------------
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
//    NSLog(@"didStartProvisionalNavigation");
}
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
//    NSLog(@"didCommitNavigation");
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
//    NSLog(@"didFinishNavigation");
    [MitLoadingView dismiss];
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
//    NSLog(@"didFailProvisionalNavigation");
    [self showErrorTip:error];
    
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if(webView != self.wkWebView) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    
    NSURL *url = navigationAction.request.URL;
    if ([url.scheme isEqualToString:@"tel"])
    {
        if ([[UIApplication sharedApplication] canOpenURL:url])
        {
            NSString * telStr=[[NSString alloc] initWithFormat:@"telprompt://%@",url.resourceSpecifier];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telStr]];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

//-(void)callPhoneAlterHanle


#pragma mark ------------------- webViewDelegate ------------------------
- (void)webViewDidStartLoad:(UIWebView *)webView{
//    NSLog(@"StartLoad");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
//    NSLog(@"FinishLoad");
    [MitLoadingView dismiss];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self showErrorTip:error];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (self.showJSTitle) {
        NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        self.title = theTitle;
        return YES;
    }
    
    return NO;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    if (self.showJSTitle) {
        [self.wkWebView removeObserver:self forKeyPath:@"title"];
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
