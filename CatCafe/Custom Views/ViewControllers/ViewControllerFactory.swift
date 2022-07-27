//
//  ViewControllerFactory.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/20.
//

import UIKit

func makeNavigationController(rootViewController: UIViewController) -> UINavigationController {
    let navController = UINavigationController(rootViewController: rootViewController)
    
    let navBarAppearance = UINavigationBarAppearance()
    navBarAppearance.configureWithDefaultBackground()
    navBarAppearance.backgroundColor = .white
    
    // navbar 標題顏色跟字型
    let attrs = [
        NSAttributedString.Key.foregroundColor: UIColor.ccGrey,
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .medium)
    ]
    navBarAppearance.titleTextAttributes = attrs
    
    // navbar 返回按鈕自訂圖片("arrow.backward")
    let backIndicatorImage = UIImage.asset(.Icons_24px_Back02)?
        .withRenderingMode(.alwaysOriginal)
        .withTintColor(.ccGrey)
    navBarAppearance.setBackIndicatorImage(backIndicatorImage, transitionMaskImage: backIndicatorImage)
    
    // 返回按鈕 字型樣式(clear color)
    let backButtonAppearance = UIBarButtonItemAppearance()
    backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
    navBarAppearance.backButtonAppearance = backButtonAppearance
    
    let controllerName = String(describing: type(of: rootViewController.self))
    
    // Hide navigation bar underline
    [
        String(describing: FeedController.self),
        String(describing: ExploreController.self),
        String(describing: MeetController.self),
        String(describing: ProfileController.self)
        
    ].forEach { name in
        if name == controllerName {
            navBarAppearance.shadowColor = .clear
        }
    }
    
    // Status bar style
    [ String(describing: ProfileController.self)].forEach { name in
        if name == controllerName {
            navController.navigationBar.overrideUserInterfaceStyle = .dark
        } else {
            navController.navigationBar.overrideUserInterfaceStyle = .light
        }
    }
    
    navController.navigationBar.standardAppearance = navBarAppearance
    navController.navigationBar.compactAppearance = navBarAppearance
    navController.navigationBar.scrollEdgeAppearance = navBarAppearance
    return navController
}
