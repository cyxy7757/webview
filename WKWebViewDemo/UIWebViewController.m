//
//  UIWebViewController.m
//  WKWebViewDemo
//
//  Created by wcx on 2018/10/10.
//  Copyright © 2018 wcx. All rights reserved.
//

#import "UIWebViewController.h"
#import "Masonry.h"
#import <JavaScriptCore/JavaScriptCore.h>
@interface UIWebViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) JSContext *jsContext;
@end

@implementation UIWebViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createWebView];
}

- (void)createWebView {
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectZero];
    webView.delegate = self;
    [self.view addSubview:webView];
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
        make.bottom.equalTo(self.toolBar.mas_top);
    }];
    
    
    NSURL *url = [[NSBundle mainBundle]URLForResource:@"index_2" withExtension:@"html"];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
    [webView loadRequest:request];
    self.webView = webView;
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"UIWebView 开始加载");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"UIWebView 结束加载");
    
    self.jsContext = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    //在调用前，设置异常回调
    [self.jsContext setExceptionHandler:^(JSContext *context, JSValue *exception){
        NSLog(@"exception:%@", exception);
    }];
    
    // 设置title
    JSValue *jsValue = [self.jsContext evaluateScript:@"document.title"];
    self.title = jsValue.toString;
    
    // js call oc
    self.jsContext[@"share"] = ^(){
        NSArray *args = [JSContext currentArguments];//获取到share里的所有参数
        //args中的元素是JSValue，需要转成OC的对象
        NSMutableArray *messages = [NSMutableArray array];
        for (JSValue *obj in args) {
            [messages addObject:[obj toObject]];
        }
        NSLog(@"点击分享js传回的参数：\n%@", messages);
    };
    
    
    // js call oc 替换js实现
    self.jsContext[@"addMehtod"] = ^NSInteger(NSInteger a,NSInteger b){
        return  a*b;
    };
    
    // js call oc 异步回调
    self.jsContext[@"asyncShare"] =^(JSValue *shareData){//首先这里要注意，回调的参数不能直接写NSDictionary类型，
        
         JSValue *resultFunction = [shareData valueForProperty:@"result"];
        
        void (^result)(BOOL) = ^(BOOL isSuccess){
            [resultFunction callWithArguments:@[@(isSuccess)]];
        };
        
        //模拟异步回调
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"回调分享成功");
            result(YES);
        });
        
    };
   
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"UIWebView 加载失败");
}
#pragma mark -
- (IBAction)refresh:(UIBarButtonItem *)sender {
    
}

- (IBAction)btnOne:(id)sender {
}

- (IBAction)btnTwo:(id)sender {
}
- (IBAction)btnThree:(id)sender {
}

@end
