//
//  MainTabController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import UIKit

class MainTabController: UITabBarController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureViewController()
    }
    
    // MARK: - Helpers
    
    func configureViewController() {
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
        
        let profile = templateNavigationController(
            unselectedImage: UIImage(named: "profile_unselected")!,
            selectedImage: UIImage(named: "profile_selected")!,
            rootViewController: ProfileController()
        )
        
        viewControllers = [home, explore, meet, collection, profile]
        tabBar.tintColor = .black
    }
    
    func templateNavigationController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.image = unselectedImage
        nav.tabBarItem.selectedImage = selectedImage
        nav.navigationBar.tintColor = .black
        return nav
    }
}
