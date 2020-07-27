//
//  WKWebViewViewController.swift
//  Swift-JavaScriptCore
//
//  Created by summerxx on 2020/7/27.
//  Copyright © 2020 summerxx. All rights reserved.
//

import UIKit
import WebKit

class WKWebViewViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {

    private var webView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configWkWebView()
        
        self.webView.configuration.userContentController.add(self, name: "showMessage")
    }
    
    func configWkWebView() -> Void {
        let config = WKWebViewConfiguration.init()
        let preferences = WKPreferences.init()
        preferences.minimumFontSize = 40.0;
        preferences.javaScriptEnabled = true;
        preferences.javaScriptCanOpenWindowsAutomatically = true;
        config.preferences = preferences;
        
        self.webView = WKWebView.init(frame: self.view.bounds, configuration: config)
        
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        self.webView.allowsBackForwardNavigationGestures = true
        self.view.addSubview(self.webView)
        
        guard let bundlePath = Bundle.main.path(forResource: "summerxx-test", ofType: "html") else { return  }
        self.webView.load(NSURLRequest.init(url: NSURL.fileURL(withPath: bundlePath)) as URLRequest)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "showMessage" {
            let alert = UIAlertController.init(title: "信息", message: "点击了获取位置", preferredStyle: UIAlertController.Style.alert)
            
            let okAction = UIAlertAction.init(title: "同意", style: UIAlertAction.Style.default) { (_: UIAlertAction) in
                print("didSelect 同意")
                
                self.callBackJs()
            }
            
            let cancelAction = UIAlertAction.init(title: "取消", style: UIAlertAction.Style.default) { (_: UIAlertAction) in
                print("didSelect 取消")
            }
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true) {
                print("do nothing")
            }
        }
    }
    
    ///Mark 点击同意给JS回传信息
    ///回传信息为 "虽然我同意了你, 但是答应我别骄傲." 根据实际需要和合作的同学约定传递的数据
    func callBackJs() -> Void {
        let jsNews = NSString.localizedStringWithFormat("setLocation('%@')","虽然我同意了你, 但是答应我别骄傲.") as String
        
        self.webView.evaluateJavaScript(jsNews) { (_ obj: Any?, _ error: Error?) in
            print("success")
        }
    }
    
    deinit {
        self.webView.configuration.userContentController.removeAllUserScripts()
    }

}
