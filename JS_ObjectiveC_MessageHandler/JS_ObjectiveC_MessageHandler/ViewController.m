//
//  ViewController.m
//  JS_ObjectiveC_MessageHandler
//
//  Created by 景天 on 2019/4/30.
//  Copyright © 2019年 summerxx. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController ()
<
WKUIDelegate,
WKNavigationDelegate,
WKScriptMessageHandler
>

@property (nonatomic, strong) WKWebView *wkwebView;
@property (nonatomic, strong) UIProgressView *progressView;
@end

@implementation ViewController

- (UIProgressView *)progressView
{
    if (!_progressView){
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 1, self.view.frame.size.width, 2)];
        _progressView.tintColor = [UIColor blueColor];
        _progressView.trackTintColor = [UIColor clearColor];
    }
    return _progressView;
}

- (void)createWkWebView {
    /// 创建网页配置对象
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    /// 创建设置对象
    WKPreferences *preference = [[WKPreferences alloc]init];
    /// 最小字体大小 当将javaScriptEnabled属性设置为NO时，可以看到明显的效果
    preference.minimumFontSize = 40.0;
    /// 设置是否支持javaScript 默认是支持的
    preference.javaScriptEnabled = YES;
    /// 在iOS上默认为NO，表示是否允许不经过用户交互由javaScript自动打开窗口
    preference.javaScriptCanOpenWindowsAutomatically = YES;
    config.preferences = preference;
    /// 这个类主要用来做native与JavaScript的交互管理
    
    _wkwebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) configuration:config];
    [self.view addSubview:_wkwebView];
    /// Load WebView
#if 0
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://m.benlai.com/huanan/zt/1231cherry"]];
    [self.wkwebView loadRequest:request];
#endif
    
#if 1
    NSString *bundleStr = [[NSBundle mainBundle] pathForResource:@"summerxx-test" ofType:@"html"];
    [self.wkwebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:bundleStr]]];
#endif
    
    // UI代理
    _wkwebView.UIDelegate = self;
    // 导航代理
    _wkwebView.navigationDelegate = self;
    // 是否允许手势左滑返回上一级, 类似导航控制的左滑返回
    _wkwebView.allowsBackForwardNavigationGestures = YES;
    
    // 添加监测网页加载进度的观察者
    [self.wkwebView addObserver:self
                     forKeyPath:@"estimatedProgress"
                        options:0
                        context:nil];
    // 添加监测网页标题title的观察者
    [self.wkwebView addObserver:self
                     forKeyPath:@"title"
                        options:NSKeyValueObservingOptionNew
                        context:nil];
}


/**
 observeValueForKeyPath: 监听进度
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))]
        && object == _wkwebView) {
        NSLog(@"网页加载进度 = %f",_wkwebView.estimatedProgress);
        self.progressView.progress = _wkwebView.estimatedProgress;
        if (_wkwebView.estimatedProgress >= 1.0f) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressView.progress = 0;
            });
        }
    }else if([keyPath isEqualToString:@"title"]
             && object == _wkwebView){
        self.navigationItem.title = _wkwebView.title;
    }else{
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}


#pragma mark - WKScriptMessageHandler
/// 通过接收JS传出消息的name进行捕捉的回调方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([message.name isEqualToString:@"showMessage"]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"title" message:@"messgae" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"同意" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NSString *jsStr = [NSString stringWithFormat:@"setLocation('%@')",@"虽然我同意了你, 但是答应我别骄傲."];
            [self.wkwebView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                NSLog(@"%@----%@",result, error);
            }];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"cancel");
        }];
        UIAlertAction *errorAction = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSString *jsStr = [NSString stringWithFormat:@"setLocation('%@')",@"虽然我拒绝了你, 但是继续爱我好吗"];
            [self.wkwebView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                NSLog(@"%@----%@",result, error);
            }];
            
        }];
        // cancel类自动变成最后一个，警告类推荐放上面
        [alertController addAction:errorAction];
        [alertController addAction:okAction];
        [alertController addAction:cancelAction];
        
        // 出现
        [self presentViewController:alertController animated:YES completion:^{
            
        }];
        
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.progressView];
    [self createWkWebView];
    
    [self.wkwebView.configuration.userContentController addScriptMessageHandler:self name:@"showMessage"];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void)dealloc {
    /// Remove removeObserver
    [_wkwebView removeObserver:self
                    forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    [_wkwebView removeObserver:self
                    forKeyPath:NSStringFromSelector(@selector(title))];
    
    
    WKUserContentController *userCC = self.wkwebView.configuration.userContentController;
    [userCC removeScriptMessageHandlerForName:@"showMessage"];
}
@end
