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
            self.viewControllers = self.tabs.map({
                $0.setController(user: currentUser)
            })
        }
    }
    
    private let tabs: [Tab] = [.feed, .explore, .meet, .profile]
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = self.tabs.map({ $0.setController(user: nil) })
        selectedIndex = Tab.explore.rawValue
        delegate = self
        
        setTabBarApearance()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refetchCurrentUser),
            name: CCConstant.NotificationName.updateProfile,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if LocalStorage.shared.hasLogedIn {
            fetchCurrentUser()
        }
    }
    
    private func setTabBarApearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        
        // Dark mode aware tab bar
        tabBar.overrideUserInterfaceStyle = .light
        
        // Badge background color
        tabBarAppearance.backgroundColor = .white
        tabBarAppearance.stackedLayoutAppearance.normal.badgeBackgroundColor = .brown
        
        // titleTextAttributes
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = .ccGrey
        
        let attrs = [
            NSAttributedString.Key.foregroundColor: UIColor.ccPrimary,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .medium)
        ]
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = attrs
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = attrs
        
        tabBar.standardAppearance = tabBarAppearance
        tabBar.scrollEdgeAppearance = tabBarAppearance
    }
    
    // MARK: - API
    private func fetchCurrentUser() {
        
        let group = DispatchGroup()
        
        group.enter()
        UserService.shared.fetchCurrentUser { currentUser in
            self.currentUser = currentUser
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.dismiss(animated: true)
            
            // 剛註冊
            if UserService.shared.currentUser?.profileImageUrlString == "" {
                if UserService.shared.currentUser?.username == "" {
                    // Apple sign in
                    let controller = AppleSigninProfileEditController()
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: true)
                } else {
                    // native sign in
                    let controller = SetProfilePictureController()
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: true)
                }
                
            }
        }
        
    }
    
    // MARK: - Action
    @objc func refetchCurrentUser() {
        fetchCurrentUser()
    }
}

// MARK: - AuthenticationDelegate
extension MainTabController: AuthenticationDelegate {
    
    func authenticationDidComplete() {
        fetchCurrentUser()
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
                let loginNav = makeNavigationController(rootViewController: loginVC)
                present(loginNav, animated: true)
                return false
            }
            return true
        }
        return true
    }
    
}

private enum Tab: Int {
    case feed
    case explore
    case meet
    case profile
    
    func setController(user: User?) -> UIViewController {
        var controller: UIViewController
        
        switch self {
        case .feed:
            controller = makeNavigationController(rootViewController: FeedController())
        case .explore:
            controller = makeNavigationController(rootViewController: ExploreController())
        case .meet:
            controller = makeNavigationController(rootViewController: MeetController())
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
    
    private func setTabBarItem() -> UITabBarItem {
        switch self {
        case .feed:
            return setTabBarItem(
                title: nil,
                image: UIImage.asset(.home_unselected)!,
                selectedImage: UIImage.asset(.home_selected)!)
        case .explore:
            return setTabBarItem(
                title: nil,
                image: UIImage.asset(.search_unselected)!,
                selectedImage: UIImage.asset(.search_selected)!)
        case .meet:
            return setTabBarItem(
                title: nil,
                image: UIImage.asset(.speaker_unselected)!
                    .resize(to: .init(width: 25, height: 25)),
                selectedImage: UIImage.asset(.speaker_selected)!
                    .resize(to: .init(width: 25, height: 25))
            )
        case .profile:
            return setTabBarItem(
                title: nil,
                image: UIImage.asset(.profile_unselected)!,
                selectedImage: UIImage.asset(.profile_selected)!)
        }
    }

    private func setTabBarItem(
        title: String?,
        image: UIImage?,
        selectedImage: UIImage?
    ) -> UITabBarItem {
        let image = image?
            .withRenderingMode(.alwaysOriginal)
        let selectedImage = selectedImage?
            .withRenderingMode(.alwaysOriginal)
        return UITabBarItem(title: title, image: image, selectedImage: selectedImage)
    }
}
