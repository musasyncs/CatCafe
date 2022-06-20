//
//  MainTabController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import UIKit
import FirebaseAuth

class MainTabController: UITabBarController {
        
    var user: User? {
        didSet {
            guard let user = user else {
                return
            }
            configureViewController(withUser: user)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        fetchCurrentUser()
    }
    
    // MARK: - API
    
    func checkIfUserIsLoggedIn() {
        if LocalStorage.shared.hasLogedIn == false {
            DispatchQueue.main.async {
                let controller = LoginController()
                controller.delegate = self
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }
    }
    
    func fetchCurrentUser() {
        guard let currentUid = LocalStorage.shared.getUid() else { return }        
        UserService.fetchUserBy(uid: currentUid, completion: { user in
            self.user = user
            self.navigationItem.title = user.username
        })
    }
    
    // MARK: - Helpers
    
    func configureViewController(withUser user: User) {
        let layout = UICollectionViewFlowLayout()
        let home = templateNavigationController(
            unselectedImage: UIImage(named: "home_unselected")!,
            selectedImage: UIImage(named: "home_selected")!,
            rootViewController: HomeController(collectionViewLayout: layout)
        )
        
        let explore = templateNavigationController(
            unselectedImage: UIImage(named: "search_unselected")!,
            selectedImage: UIImage(named: "search_selected")!,
            rootViewController: ExploreController()
        )
        
        let meet = templateNavigationController(
            unselectedImage: UIImage(named: "speaker_unselected")!,
            selectedImage: UIImage(named: "speaker_selected")!,
            rootViewController: MeetController()
        )
        
        let collection = templateNavigationController(
            unselectedImage: UIImage(named: "bookmark_unselected")!,
            selectedImage: UIImage(named: "bookmark_selected")!,
            rootViewController: CollectionController()
        )
        
        let profileController = ProfileController(user: user)
        let profile = templateNavigationController(
            unselectedImage: UIImage(named: "profile_unselected")!,
            selectedImage: UIImage(named: "profile_selected")!,
            rootViewController: profileController
        )
        
        viewControllers = [home, explore, meet, collection, profile]
        tabBar.tintColor = .black
    }
    
    func templateNavigationController(
        unselectedImage: UIImage,
        selectedImage: UIImage,
        rootViewController: UIViewController
    ) -> UINavigationController {
        
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.image = unselectedImage
        nav.tabBarItem.selectedImage = selectedImage
        nav.navigationBar.tintColor = .black
        return nav
        
    }
}

// MARK: - AuthenticationDelegate

extension MainTabController: AuthenticationDelegate {
    func authenticationDidComplete() {
        fetchCurrentUser()
        self.dismiss(animated: true, completion: nil)
    }
}
