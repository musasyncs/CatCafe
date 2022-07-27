//
//  WebsiteController.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/2.
//

import UIKit
import WebKit

class WebsiteController: UIViewController {
    
    var website: String?
    
    private var textField: UITextField!
    private var webView: WKWebView!
    private var activityIndicator: UIActivityIndicatorView!
    
    private lazy var backButton = makeIconButton(imagename: "Icons_24px_Back02",
                                                 imageColor: .ccGrey,
                                                 imageWidth: 24, imageHeight: 24,
                                                 backgroundColor: .clear,
                                                 cornerRadius: 40 / 2)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        webView = WKWebView()
        webView.backgroundColor = .white
        webView.scrollView.bounces = false
        webView.navigationDelegate = self
        view.addSubview(webView)
        webView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                       left: view.leftAnchor,
                       bottom: view.bottomAnchor,
                       right: view.rightAnchor)
        
        let leftBarButton = UIBarButtonItem(
            image: UIImage.asset(.Icons_24px_Back02)?
                .withTintColor(.ccGrey)
                .withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(goBack)
        )
        navigationItem.leftBarButtonItem = leftBarButton
        
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = CGPoint(x: ScreenSize.width * 0.5, y: ScreenSize.height * 0.5)
        view.addSubview(activityIndicator)
        
        start()
    }
    
    func start() {
        self.view.endEditing(true)
        guard let website = website, !website.isEmpty else { return }
        guard let url = URL(string: website) else { return }
        let urlRequest = URLRequest(url: url)
        webView.load(urlRequest)
    }
    
    @objc func goBack() {
        dismiss(animated: true)
    }
    
}

extension WebsiteController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        print("finish to load")
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
    }
}
