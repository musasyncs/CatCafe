//
//  ArrangeMeetController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/21.
//

import UIKit

class ArrangeMeetController: UIViewController {
    
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationButtons()
    }
    
    // MARK: - Helpers
    
    func setupNavigationButtons() {
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "Icons_24px_Back02")?
                .withTintColor(.black)
                .withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(handleCancel)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.right")?
                .withTintColor(.black)
                .withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(handleUpload)
        )
    }
    
    // MARK: - Action
    
    @objc private func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func handleUpload() {
        print("DEBUG: handleUpload")
    }
    
}
