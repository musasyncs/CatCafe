//
//  WebsiteController.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/2.
//

import UIKit
import WebKit

class WebsiteController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler, UITextFieldDelegate {
    
    var website: String?
    
    var textField: UITextField!
    var webView: WKWebView!
    var activityIndicator: UIActivityIndicatorView!
    
    lazy var backButton = makeIconButton(imagename: "Icons_24px_Back02",
                                         imageColor: .black,
                                         imageWidth: 24, imageHeight: 24,
                                         backgroundColor: .clear,
                                         cornerRadius: 40 / 2)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        webView = WKWebView()
        webView.scrollView.bounces = false
        webView.navigationDelegate = self
        view.addSubview(webView)
        webView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                       left: view.leftAnchor,
                       bottom: view.bottomAnchor,
                       right: view.rightAnchor)
        
        let leftBarButton = UIBarButtonItem(
            image: UIImage(named: "Icons_24px_Back02")?
                .withTintColor(.black)
                .withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(goBack)
        )
        navigationItem.leftBarButtonItem = leftBarButton
        
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = CGPoint(x: UIScreen.width * 0.5, y: UIScreen.height * 0.5)
        view.addSubview(activityIndicator)
        start()
    }
    
    @objc func goBack() {
        dismiss(animated: true)
    }
    
    @objc func start() {
        self.view.endEditing(true)
        guard let website = website else { return }
        let url = URL(string: website)
        let urlRequest = URLRequest(url: url!)
        webView.load(urlRequest)
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.start()
        return true
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Start loading...
        activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        print("finish to load")
    }
    
    // Callback webView function
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
    }
    
}
