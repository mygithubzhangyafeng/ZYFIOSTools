//
//  ZYFWKWebViewController.swift
//  ZYFIOSTools
//
//  Created by 张亚峰 on 2022/4/20.
//

import UIKit
import WebKit

class ZYFWKWebViewController: UIViewController {

    override func viewDidLoad() {
        var url = ""
        var fixTitle:String?
        override func viewDidLoad() {
            super.viewDidLoad()
            self.navigationController?.navigationBar.isHidden = false
            self.view.addSubview(wkWebView)
            self.view.addSubview(progressView)
            wkWebView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            if !FSDataCheck.isEmpty(fixTitle){
                self.title = fixTitle
            }
            
            //添加监测网页加载进度的观察者
            wkWebView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
            //添加监测网页标题title的观察者
            wkWebView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        }
        
        deinit{
            wkWebView.removeObserver(self, forKeyPath: "estimatedProgress")
            wkWebView.removeObserver(self, forKeyPath: "title")
        }
        
        lazy var wkWebView: WKWebView = {
            let config = WKWebViewConfiguration()
            let preference = WKPreferences()
            // 允许不经过用户交互由js自动打开窗口
            preference.javaScriptCanOpenWindowsAutomatically = true
            config.preferences = preference
            // 是使用h5的视频播放器在线播放, 还是使用原生播放器全屏播放
            config.allowsInlineMediaPlayback = true;
            
            
            let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight), configuration: config)
            //导航代理
            webView.navigationDelegate = self
    //        webView.uiDelegate = self
            
            //是否允许手势左滑返回上一级, 类似导航控制的左滑返回
            webView.allowsBackForwardNavigationGestures = true
            //可返回的页面列表, 存储已打开过的网页
            //        webView.backForwardList
            
            var urlStr = urlPercentEncoding(url: self.url)
            var nsurl = NSURL(string: urlStr) ?? nil
      
            if nsurl != nil {
                let url = nsurl! as URL
                
                let request = URLRequest(url: url)
                webView.load(request)
            }else{
                
            }
            
            return webView
        }()
        
        lazy var progressView: UIProgressView = {
            let isTranslucent = self.navigationController?.navigationBar.isTranslucent
            var y:CGFloat = kNavStatusHeight
            if isTranslucent == false {
                y = 0
            }
            
            let progressView = UIProgressView(frame: CGRect(x: 0, y:y , width: kScreenWidth, height: 2))
            progressView.tintColor = kColor_MainGold;
            progressView.trackTintColor = UIColor.clear
            return progressView
        }()
        
        func loadLocalFile(name:String, type:String){
            let docPath = Bundle.main.path(forResource: name, ofType: type) ?? ""
            let docURL = URL.init(fileURLWithPath: docPath)
            wkWebView.loadFileURL(docURL, allowingReadAccessTo: docURL)
        }
        
        func reloadUrl(srcUrl:String){
            if FSDataCheck.isEmpty(srcUrl) {
                return
            }
            
            let urlStr = urlPercentEncoding(url: srcUrl)
            var nsurl = NSURL(string: urlStr) ?? nil
            if nsurl != nil {
                let url = nsurl! as URL
                print("weburl地址：\(url.absoluteString)")
                let request = URLRequest(url: url)
                wkWebView.load(request)
            }
        }
        
        func urlPercentEncoding(url:String) -> String {
            var urlStr = url
            if self.includeChinese(str: url) {
                let charSet = CharacterSet.urlQueryAllowed as NSCharacterSet
                let mutSet = charSet.mutableCopy() as! NSMutableCharacterSet
                mutSet.addCharacters(in: "#")
                urlStr = urlStr.addingPercentEncoding(withAllowedCharacters:mutSet as CharacterSet)! //对汉字进行转码
            }
            return urlStr
        }
        
        func includeChinese(str:String) -> Bool {
            for (_, value) in str.enumerated() {
                
                if ("\u{4E00}" <= value  && value <= "\u{9FA5}") {
                    return true
                }
            }
            return false
        }
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            print("\(Float(wkWebView.estimatedProgress))")
            if keyPath == "estimatedProgress" && object as? WKWebView == wkWebView{
                
                progressView.progress = Float(wkWebView.estimatedProgress)
                if Float(wkWebView.estimatedProgress) >= 1.0 {
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                        self.progressView.progress = 0;
                    }
                    
                }
            }else if keyPath == "title" && object as? WKWebView == wkWebView {
                if FSDataCheck.isEmpty(self.fixTitle){
                    self.title = wkWebView.title
                }
                
                
            }else{
                
            }
        }
    }

    extension BGBaseWebController: WKNavigationDelegate {
        func webView( _ webView: WKWebView,didReceive challenge: URLAuthenticationChallenge,
            completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
        ) {
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust{
                let testcard = URLCredential(trust: challenge.protectionSpace.serverTrust!)
                completionHandler(URLSession.AuthChallengeDisposition.useCredential,testcard)
            }
        }
        
        //页面开始加载时调用
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("webViewDidStartLoad")
        }
        
        // 页面加载失败时调用
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            self.progressView.setProgress(0, animated: false)
            
        }
        
        // 当内容开始返回时调用
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            
        }
        
        //页面加载完成之后调用
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("webViewDidFinishLoad")
        }
        
        //提交发生错误时调用
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("webViewDidFailLoad")
            self.progressView.setProgress(0, animated: false)
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            print("开始请求url")
            let url = navigationAction.request.url?.absoluteString ?? ""
            self.url = url
            print(url)
            
            decisionHandler(.allow)

        }
        
        // show js alert
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
              let alert = UIAlertController.init(title: message, message: nil, preferredStyle: .alert)
              let action = UIAlertAction.init(title: "确定", style: .default) { (action) in
                  completionHandler()
              }
              alert.addAction(action)
              
              
              
              self.present(alert, animated: true, completion: nil)
        }
        // show js commfirm
        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
            let alert = UIAlertController.init(title: message, message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction.init(title: "取消", style: .cancel) { (action) in
                completionHandler(false)
            }
            alert.addAction(cancelAction)
            
            let sureAction = UIAlertAction.init(title: "确定", style: .default) { (action) in
                completionHandler(true)
            }
            alert.addAction(sureAction)
            
            self.present(alert, animated: true, completion: nil)
        }

        // show js Prompt
        func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
            let alert = UIAlertController.init(title: "提示", message: prompt, preferredStyle: .alert)
            
            alert.addTextField { (texfiled) in
                texfiled.placeholder = defaultText
            }
            
            let sureAction = UIAlertAction.init(title: "确定", style: .default) { (action) in
                completionHandler(alert.textFields?.last?.text ?? "")
            }
            alert.addAction(sureAction)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            print("decidePolicyFor navigationResponse")
            decisionHandler(.allow)
            
        }
    }
