//
//  WebView.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/12.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    var webView = WKWebView()
    let reportButton = UIButton()
    var url = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.load(URLRequest(url: URL(string: url)!))
        webView.allowsBackForwardNavigationGestures = true
        view.addSubview(webView)
        webView.fillSuperView()
        
        addDragFloatBtn()
    }
}

extension WebViewController {
    private func addDragFloatBtn() {
        reportButton.frame = CGRect(x: UIScreen.width - 70, y: 70, width: 60, height: 60)

        reportButton.layer.cornerRadius = 60 / 2
        view.addSubview(reportButton)
        reportButton.setImage(
            UIImage.asset(.Icons_24px_Close)?
                .withTintColor(.white),
            for: .normal
        )
        reportButton.backgroundColor = .black.withAlphaComponent(0.4)
        reportButton.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        reportButton.addTarget(self, action: #selector(floatButtonAction(sender:)), for: .touchUpInside)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(dragAction(gesture:)))
        reportButton.addGestureRecognizer(panGesture)
    }

    @objc private func dragAction(gesture: UIPanGestureRecognizer) {
        let moveState = gesture.state
        switch moveState {
        case .changed:
            let point = gesture.translation(in: view)
            reportButton.center = CGPoint(x: reportButton.center.x + point.x, y: reportButton.center.y + point.y)
        case .ended:
            let point = gesture.translation(in: view)
            var newPoint = CGPoint(x: reportButton.center.x + point.x, y: reportButton.center.y + point.y)
            if newPoint.x < view.bounds.width / 2.0 {
                newPoint.x = 40.0
            } else {
                newPoint.x = view.bounds.width - 40.0
            }
            if newPoint.y <= 40.0 {
                newPoint.y = 40.0
            } else if newPoint.y >= view.bounds.height - 40.0 {
                newPoint.y = view.bounds.height - 40.0
            }
            UIView.animate(withDuration: 0.5) {
                self.reportButton.center = newPoint
            }
        default:
            break
        }
        gesture.setTranslation(.zero, in: view)
    }

    @objc private func floatButtonAction(sender _: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
