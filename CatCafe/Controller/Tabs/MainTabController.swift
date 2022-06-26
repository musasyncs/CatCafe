//
//  MainTabController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import UIKit
import FirebaseAuth

class MainTabController: UITabBarController {
    
    var currentUser: User? {
        didSet {
            guard let currentUser = currentUser else { return }
            self.viewControllers = self.tabs.map({ $0.setController(user: currentUser) })
        }
    }
    
    private let tabs: [Tab] = [.home, .explore, .meet, .collection, .profile]
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup
        viewControllers = self.tabs.map({ $0.setController(user: nil) })
        selectedIndex = Tab.explore.rawValue
        delegate = self
        
        // style
        setTabBarApearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if LocalStorage.shared.hasLogedIn {
            fetchCurrentUser()
        }
    }
    
    // MARK: - Helpers
    
    private func setTabBarApearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        
        // Dark mode aware tab bar
        tabBar.overrideUserInterfaceStyle = .light
        
        // Badge background color
        tabBarAppearance.backgroundColor = .white
        tabBarAppearance.stackedLayoutAppearance.normal.badgeBackgroundColor = .brown
        
        // titleTextAttributes
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = .black
        
        let attrs = [
            NSAttributedString.Key.foregroundColor: UIColor.systemBrown,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .medium)
        ]
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = attrs
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = attrs
        
        tabBar.standardAppearance = tabBarAppearance
        tabBar.scrollEdgeAppearance = tabBarAppearance
    }
    
    private func fetchCurrentUser() {
        guard let currentUid = LocalStorage.shared.getUid() else { return }
        UserService.fetchUserBy(uid: currentUid, completion: { currentUser in
            self.currentUser = currentUser
        })
    }
}

// MARK: - AuthenticationDelegate

extension MainTabController: AuthenticationDelegate {
    
    func authenticationDidComplete() {
        fetchCurrentUser()
        self.dismiss(animated: true)
    }
}

// MARK: - UITabBarControllerDelegate

extension MainTabController: UITabBarControllerDelegate {
    
    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {
        guard let navVC = viewController as? UINavigationController,
              navVC.viewControllers.first is ExploreController else {
            
            // 不是 explore page 需登入
            guard LocalStorage.shared.hasLogedIn else {
                let loginVC = LoginController()
                loginVC.delegate = self
                let loginNav = UINavigationController(rootViewController: loginVC)
                present(loginNav, animated: true)
                return false
            }
            return true
        }
        return true
    }
    
}

private enum Tab: Int {
    case home
    case explore
    case meet
    case collection
    case profile
    
    func setController(user: User?) -> UIViewController {
        var controller: UIViewController
        let layout = UICollectionViewFlowLayout()
        
        switch self {
        case .home:
            controller = makeNavigationController(rootViewController: FeedController(collectionViewLayout: layout))
        case .explore:
            controller = makeNavigationController(rootViewController: ExploreController())
        case .meet:
            controller = makeNavigationController(rootViewController: MeetController())
        case .collection:
            controller = makeNavigationController(rootViewController: ReelsController())
        case .profile:
            if let user = user {
                controller = makeNavigationController(rootViewController: ProfileController(user: user))
            } else {
                controller = makeNavigationController(rootViewController: UIViewController())
            }
        }
        controller.tabBarItem = setTabBarItem()
        controller.tabBarItem.imageInsets = UIEdgeInsets(top: 6.0, left: 0.0, bottom: -6.0, right: 0.0)
        return controller
    }
    
    func setTabBarItem() -> UITabBarItem {
        switch self {
        case .home:
            return setTabBarItem(
                title: nil,
                image: UIImage(named: "home_unselected")!,
                selectedImage: UIImage(named: "home_selected")!)
        case .explore:
            return setTabBarItem(
                title: nil,
                image: UIImage(named: "search_unselected")!,
                selectedImage: UIImage(named: "search_selected")!)
        case .meet:
            return setTabBarItem(
                title: nil,
                image: UIImage(named: "speaker_unselected")!,
                selectedImage: UIImage(named: "speaker_selected")!)
        case .collection:
            return setTabBarItem(
                title: nil,
                image: UIImage(named: "bookmark_unselected")!,
                selectedImage: UIImage(named: "bookmark_selected")!)
        case .profile:
            return setTabBarItem(
                title: nil,
                image: UIImage(named: "profile_unselected")!,
                selectedImage: UIImage(named: "profile_selected")!)
        }
    }
    
    // nav bar appearance
    private func makeNavigationController(rootViewController: UIViewController) -> UINavigationController {
        let navC = UINavigationController(rootViewController: rootViewController)
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithDefaultBackground()
        navBarAppearance.backgroundColor = .white
        
        // navbar 標題顏色跟字型
        let attrs = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .medium)
        ]
        navBarAppearance.titleTextAttributes = attrs
        
        // navbar 返回按鈕自訂圖片("arrow.backward")
        let backIndicatorImage = UIImage(named: "Icons_24px_Back02")?.withRenderingMode(.alwaysOriginal)
        navBarAppearance.setBackIndicatorImage(backIndicatorImage, transitionMaskImage: backIndicatorImage)
        
        // 返回按鈕 字型樣式(clear color)
        let backButtonAppearance = UIBarButtonItemAppearance()
        backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        navBarAppearance.backButtonAppearance = backButtonAppearance
        
        // Hide navigation bar underline
        let controllerName = String(describing: type(of: rootViewController.self))
        [
            String(describing: FeedController.self),
            String(describing: ExploreController.self),
            String(describing: MeetController.self),
            String(describing: ReelsController.self),
            String(describing: ProfileController.self)
            
        ].forEach { name in
            if name == controllerName {
                navBarAppearance.shadowColor = .clear
            }
        }
        
        // Status bar style
        navC.navigationBar.overrideUserInterfaceStyle = .light
        
        navC.navigationBar.standardAppearance = navBarAppearance
        navC.navigationBar.compactAppearance = navBarAppearance
        navC.navigationBar.scrollEdgeAppearance = navBarAppearance
        return navC
    }
    
    // tab bar item style
    private func setTabBarItem(
        title: String?,
        image: UIImage?,
        selectedImage: UIImage?
    ) -> UITabBarItem {
        let image = image?.withRenderingMode(.alwaysOriginal)
        let selectedImage = selectedImage?.withRenderingMode(.alwaysOriginal)
        return UITabBarItem(title: title, image: image, selectedImage: selectedImage)
    }
}
