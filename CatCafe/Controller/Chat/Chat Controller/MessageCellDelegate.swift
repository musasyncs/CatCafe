//
//  MessageCellDelegate.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/29.
//

import MessageKit
import AVFoundation
import AVKit
import SKPhotoBrowser

extension ChatController: MessageCellDelegate {
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let mkMessage = mkMessages[indexPath.section]
            
            // photo item
            if mkMessage.photoItem != nil && mkMessage.photoItem!.image != nil {
                var images = [SKPhoto]()
                let photo = SKPhoto.photoWithImage(mkMessage.photoItem!.image!)
                images.append(photo)
                
                let browser = SKPhotoBrowser(photos: images)
                browser.initializePageIndex(0)
                
                present(browser, animated: true, completion: nil)
            }
            
            // video item
            if mkMessage.videoItem != nil && mkMessage.videoItem!.url != nil {
                let player = AVPlayer(url: mkMessage.videoItem!.url!)
                let moviePlayer = AVPlayerViewController()
                
                let session = AVAudioSession.sharedInstance()
                // swiftlint:disable force_try
                try! session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
                // swiftlint:enable force_try
                moviePlayer.player = player
                
                navigationController?.pushViewController(moviePlayer, animated: true)
            }

        }
    }
}
