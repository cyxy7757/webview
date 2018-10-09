//
//  ViewController.m
//  WKWebViewDemo
//
//  Created by wcx on 2018/10/8.
//  Copyright © 2018 wcx. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import <WebKit/WebKit.h>
#import "NSString+urlEncode.h"
#define KScreenWidth [UIScreen mainScreen].bounds.size.width
@interface ViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) CALayer *progressLayer;
@end

@implementation ViewController
- (void)dealloc{
    [self removeAllScriptMsgHandle];
}
-(void)removeAllScriptMsgHandle{
    WKUserContentController *controller = self.webView.configuration.userContentController;
    [controller removeScriptMessageHandlerForName:@"showMobile"];
    [controller removeScriptMessageHandlerForName:@"showName"];
    [controller removeScriptMessageHandlerForName:@"showSendMsg"];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setUpWebView];
    
    [self setupProgress];
    [self addKVOObserve];
    
}
/**
- (void)setUpWebView {
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];

    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    [self.view addSubview:webView];
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    NSString *urlString = @"https://www.baidu.com";

    NSURLRequest *request = [NSURLRequest requestWithURL:[urlString encodeUrl]];
    [webView loadRequest:request];
    self.webView = webView;
}
 **/
- (void)setUpWebView{
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    // js call window.webkit.messageHandlers.Hello.postMessage(); to call oc method
    configuration.userContentController = [[WKUserContentController alloc]init];
    [configuration.userContentController addScriptMessageHandler:self name:@"showMobile"];
    [configuration.userContentController addScriptMessageHandler:self name:@"showName"];
    [configuration.userContentController addScriptMessageHandler:self name:@"showSendMsg"];
    
    // 注入js
    NSString *js = @"function ocCallJs(){alert('执行注入js')}ocCallJs()";
    WKUserScript *script = [[WKUserScript alloc]initWithSource:js injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    [configuration.userContentController addUserScript:script];
    
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    [self.view addSubview:webView];
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
        make.bottom.equalTo(self.toolBar.mas_top);
    }];
    
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    
    
    NSURL *url = [[NSBundle mainBundle]URLForResource:@"index_1" withExtension:@"html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    self.webView = webView;
}
-(void)setupProgress{
   
    UIView *progress = [[UIView alloc]init];
    progress.backgroundColor = [UIColor  clearColor];
    [self.view addSubview:progress];
    [progress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
        make.height.mas_equalTo(3);
    }];
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0, 0, 3);
    layer.backgroundColor = [UIColor greenColor].CGColor;
    [progress.layer addSublayer:layer];
    self.progressLayer = layer;
   
}

- (void)addKVOObserve{
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
}

- (IBAction)refreshWeb:(UIBarButtonItem *)sender {
    [self.webView reload];
}
- (IBAction)undo:(UIBarButtonItem *)sender {
    [self.webView goBack];
}
- (IBAction)redo:(id)sender {
    [self.webView goForward];
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressLayer.opacity = 1;
        if ([change[@"new"] floatValue] <[change[@"old"] floatValue]) {
            return;
        }
        self.progressLayer.frame = CGRectMake(0, 0, KScreenWidth*[change[@"new"] floatValue], 3);
        if ([change[@"new"]floatValue] == 1.0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressLayer.opacity = 0;
                self.progressLayer.frame = CGRectMake(0, 0, 0, 3);
            });
        }
    }else if ([keyPath isEqualToString:@"title"]){
        self.title = change[@"new"];
    }
}

- (void)msgAlert:(NSString *)message completionHandler:(void (^)(void))completionHandler{
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"alert" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (completionHandler) {
             completionHandler();
        }
    }];
    [vc addAction:action];
    [self presentViewController:vc animated:YES completion:nil];
}
#pragma mark - WKUIDelegate


- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    
    [self msgAlert:message completionHandler:^{
        completionHandler();
    }];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"confirm" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }];
    UIAlertAction *no = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }];
    [vc addAction:yes];
    [vc addAction:no];
    [self presentViewController:vc animated:YES completion:nil];
    
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler{
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"prompt" message:@"prompt 弹窗" preferredStyle:UIAlertControllerStyleAlert];
    [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.backgroundColor = [UIColor redColor];
    }];
    [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler([vc.textFields.lastObject text]);
    }]];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - WKNavigationDelegate
/* 页面开始加载 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"<<<<页面开始加载");
}
/* 开始返回内容 */
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
     NSLog(@"<<<<开始返回内容");
}
/* 页面加载完成 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
     NSLog(@"<<<<页面加载完成");
}
/* 页面加载失败 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
     NSLog(@"<<<<页面加载失败");
}
/* 在发送请求之前，决定是否跳转 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    //允许跳转
    NSLog(@"<<<<加载url:%@",navigationAction.request.URL.absoluteString);
    decisionHandler(WKNavigationActionPolicyAllow);
   
}
/* 在收到响应后，决定是否跳转 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSLog(@"<<<<在收到响应后，决定是否跳转");
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationResponsePolicyCancel);
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    NSLog(@"<<<<重定向了");
}

#pragma mark - WKScriptMessageHandler
/*!
 js call oc
 */
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    NSString *name = message.name;
   
    if ([name isEqualToString:@"showMobile"]) {
        [self msgAlert:@"showMobile" completionHandler:nil];
    }
    
    if ([name isEqualToString:@"showName"]) {
        NSString *parameter = message.body;
        parameter = [NSString stringWithFormat:@"showName:%@",parameter];
        [self msgAlert:parameter completionHandler:nil];
    }
    
    if ([name isEqualToString:@"showSendMsg"]) {
        NSArray *info = message.body;
        NSString *parameter = [NSString stringWithFormat:@"showSendMsg:%@,%@",info.firstObject,info.lastObject];
        [self msgAlert:parameter completionHandler:nil];
    }
}

#pragma mark - oc call js

- (IBAction)ocCallJSOne:(id)sender {
    [self.webView evaluateJavaScript:@"alertMobile()" completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        NSLog(@"response:%@, error:%@",response,error);
    }];
}

- (IBAction)ocCallJSTwo:(id)sender {
    [self.webView evaluateJavaScript:@"alertName('给你一个参数')" completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        NSLog(@"response:%@, error:%@",response,error);
    }];
}
- (IBAction)ocCallJSThree:(id)sender {
    [self.webView evaluateJavaScript:@"alertSendMsg('first msg','second msg')" completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        NSLog(@"response:%@, error:%@",response,error);
    }];
}

@end
