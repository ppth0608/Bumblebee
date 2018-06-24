//
//  WebViewController.swift
//  Bumblebee
//
//  Created by Naver on 2018. 6. 23..
//  Copyright © 2018년 benpark. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: ViewController {
    
    struct Constant {
        static let toolBarHeight: CGFloat = UIScreen.main.iPhone10 ? 78 : 60
    }
    
    @IBOutlet fileprivate weak var prevButton: UIButton?
    @IBOutlet fileprivate weak var nextButton: UIButton?
    @IBOutlet fileprivate weak var refreshButton: UIButton?
    @IBOutlet fileprivate weak var closeButton: UIButton?
    @IBOutlet fileprivate weak var toolBarView: UIView?
    @IBOutlet fileprivate weak var toolBarHeight: NSLayoutConstraint!
    
    var webView: WKWebView!
    var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        if let url = url {
            let request = URLRequest(url: url)
            webView?.load(request)
        }
    }
    
    private func setView() {
        toolBarHeight.constant = Constant.toolBarHeight
        
        webView = WKWebView(frame: view.bounds)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.heightAnchor.constraint(equalToConstant: view.bounds.height - Constant.toolBarHeight).isActive = true
    }
    
    @IBAction func prevButtonTapped(_ sender: UIButton) {
        if webView?.canGoBack ?? false {
            webView?.goBack()
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        if webView?.canGoForward ?? false {
            webView?.goForward()
        }
    }
    
    @IBAction func refreshButtonTapped(_ sender: UIButton) {
        if !(webView?.isLoading ?? false) {
            webView?.reload()
        }
    }
    
    @IBAction func cloaseButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateToolBarButtons()
    }
    
    deinit {
        webView?.loadHTMLString("", baseURL: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

fileprivate extension WebViewController {
    
    func updateToolBarButtons() {
        prevButton?.alpha = webView.canGoBack ? 1 : 0.4
        nextButton?.alpha = webView.canGoForward ? 1 : 0.4
        refreshButton?.alpha = !webView.isLoading ? 1 : 0.4
    }
}

extension WebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let _ = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        updateToolBarButtons()
    }
}

extension WebViewController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            let popup = WKWebView(frame: webView.frame, configuration: configuration)
            popup.uiDelegate = self
            view.addSubview(popup)
            if let view = toolBarView {
                view.bringSubview(toFront: view)
            }
            return popup
        }
        return nil
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        webView.removeFromSuperview()
    }
}

