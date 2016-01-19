//
//  VCAppHelp.swift
//  CommunicationDebugger
//
//  Created by alimysoyang on 15/9/16.
//  Copyright © 2015年 alimysoyang. All rights reserved.
//

import UIKit

class VCAppHelp: VCAYHBase
{
    private let helpUrlPath:String = "http://blog.csdn.net/alimyso/article/details/9666865";
    private var webView:UIWebView?;
    private var loadingView:UIActivityIndicatorView?;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initViews();
        self.loadRequest();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initViews()
    {
        self.title = NSLocalizedString("About", comment: "");
        self.webView = UIWebView(frame: CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - 64.0));
        self.webView?.scalesPageToFit = true;
        self.webView?.delegate = self;
        self.view.addSubview(self.webView!);
        
        self.loadingView = UIActivityIndicatorView(frame: CGRectMake(self.webView!.frame.size.width / 2.0 - 30.0, self.webView!.frame.size.height / 2.0 - 30.0, 60.0, 60.0));
        self.loadingView?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray;
        self.view.addSubview(self.loadingView!);
    }
    
    private func loadRequest()
    {
        let url:NSURL = NSURL(string: self.helpUrlPath)!;
        let request:NSURLRequest = NSURLRequest(URL: url);
        self.webView?.loadRequest(request);
    }
}

extension VCAppHelp : UIWebViewDelegate
{
    func webViewDidStartLoad(webView: UIWebView) {
        self.loadingView?.startAnimating();
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.loadingView?.stopAnimating();
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        self.loadingView?.stopAnimating();
        if let err = error
        {
            debugPrint(err.localizedDescription);
            //self.view.alert(err.localizedDescription, alertType: UIView.AlertViewType.kAVTFailed);
        }
    }
}
