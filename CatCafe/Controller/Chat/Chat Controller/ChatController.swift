//
//  ChatController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/26.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Gallery

class ChatController: MessagesViewController {
    private var chatId = ""
    private var recipientId = ""
    private var recipientName = ""
    var displayingMessagesCount = 0
    var maxMessageNumber = 0
    var minMessageNumber = 0
    var typingCounter = 0
    
    var mkMessages = [MKMessage]()
    let currentUser = MKSender(
        senderId: LocalStorage.shared.getUid()!,
        displayName: UserService.shared.currentUser!.username
    )
    var allLocalMessages = [LocalMessage]()
    var gallery: GalleryController!
    
    // MARK: - UI
    let leftBarButtonView: UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    }()
    
    let titleLabel: UILabel = {
        let title = UILabel(frame: CGRect(x: 5, y: 0, width: 180, height: 25))
        title.textAlignment = .left
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        title.adjustsFontSizeToFitWidth = true
        return title
    }()
    
    let subTitleLabel: UILabel = {
        let subTitle = UILabel(frame: CGRect(x: 5, y: 22, width: 180, height: 20))
        subTitle.textAlignment = .left
        subTitle.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        subTitle.adjustsFontSizeToFitWidth = true
        return subTitle
    }()
    
    let refreshController = UIRefreshControl()
    let micButton = InputBarButtonItem()
    
    // MARK: - Inits
    init(chatId: String, recipientId: String, recipientName: String) {
        super.init(nibName: nil, bundle: nil)
        self.chatId = chatId
        self.recipientId = recipientId
        self.recipientName = recipientName
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureLeftBarButton()
        configureCustomTitle()
        configureMessageCollectionView()
        configureMessageInputBar()
        
        createTypingObserver()
        
        loadChats()
        listenForNewChats()
        listenForReadStatusChange()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        RecentChatService.shared.resetRecentCounter(chatRoomId: chatId)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        RecentChatService.shared.resetRecentCounter(chatRoomId: chatId)
    }

    // MARK: - Load Chats
    func loadChats() {
        MessageService.shared.checkForOldChats(LocalStorage.shared.getUid()!, collectionId: chatId) { localMessages in
            self.allLocalMessages = localMessages
            
            self.insertMessages()
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem(animated: true)
        }
    }

    func listenForNewChats() {
        MessageService.shared.listenForNewChats(
            LocalStorage.shared.getUid()!,
            collectionId: chatId,
            lastMessageDate: lastMessageDate()
        ) { newMessage in
            self.insertMessage(newMessage)
        }
    }
    
    // MARK: - Helper
    private func lastMessageDate() -> Date {
        let lastMessageDate = allLocalMessages.last?.date ?? Date()
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate
    }
    
    private func removeListeners() {
        TypingService.shared.removeTypingListener()
        MessageService.shared.removeListeners()
    }
    
    // MARK: - Action
    @objc func backButtonPressed() {
        removeListeners()
        navigationController?.popViewController(animated: true)
    }
    
    func messageSend(text: String?, photo: UIImage?, video: Video?) {
        MessageSender.send(
            chatId: chatId,
            text: text,
            photo: photo,
            video: video,
            memberIds: [LocalStorage.shared.getUid()!, recipientId]
        ) { newMessage in
            self.insertMessage(newMessage)
        }
    }
    
    private func actionAttachMessage() {
        messageInputBar.inputTextView.resignFirstResponder()
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoOrVideo = UIAlertAction(title: "相機", style: .default) { _ in
            self.showImageGallery(camera: true)
        }
        let shareMedia = UIAlertAction(title: "相簿", style: .default) { _ in
            self.showImageGallery(camera: false)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        takePhotoOrVideo.setValue(UIImage(systemName: "camera"), forKey: "image")
        shareMedia.setValue(UIImage(systemName: "photo.fill"), forKey: "image")
        
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(shareMedia)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true)
    }
    
    // MARK: - Action
    private func showImageGallery(camera: Bool) {
        gallery = GalleryController()
        gallery.delegate = self
        
        Config.tabsToShow = camera ? [.cameraTab] : [.imageTab, .videoTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        Config.VideoEditor.maximumDuration = 30
        
        self.present(gallery, animated: true)
    }

}

// MARK: - Update Typing indicator
extension ChatController {
    
    func createTypingObserver() {
        TypingService.shared.createTypingObserver(chatRoomId: chatId) { (isTyping) in
            DispatchQueue.main.async {
                self.updateTypingIndicator(isTyping)
            }
        }
    }
    
    func typingIndicatorUpdate() {
        typingCounter += 1
        TypingService.saveTypingCounter(typing: true, chatRoomId: chatId)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.typingCounterStop()
        }
    }
    
    func typingCounterStop() {
        typingCounter -= 1
        if typingCounter == 0 {
            TypingService.saveTypingCounter(typing: false, chatRoomId: chatId)
        }
    }
    
    func updateTypingIndicator(_ show: Bool) {
        subTitleLabel.text = show ? "正在輸入..." : ""
    }
}

// UpdateReadMessagesStatus
extension ChatController {
    
    func listenForReadStatusChange() {
        MessageService.shared.listenForReadStatusChange(
            LocalStorage.shared.getUid()!,
            collectionId: chatId
        ) { (updatedMessage) in
            if updatedMessage.status != CCConstant.SENT {
                self.updateMessage(updatedMessage)
            }
        }
    }
    
    private func updateMessage(_ localMessage: LocalMessage) {
        for index in 0 ..< mkMessages.count {
            let tempMessage = mkMessages[index]

            if localMessage.id == tempMessage.messageId {
                mkMessages[index].status = localMessage.status
                mkMessages[index].readDate = localMessage.readDate
                                
                if mkMessages[index].status == CCConstant.READ {
                    self.messagesCollectionView.reloadData()
                }
            }
        }
    }
}

// MARK: - Insert Messages
extension ChatController {
    
    private func insertMessages() {
        maxMessageNumber = allLocalMessages.count - displayingMessagesCount
        minMessageNumber = maxMessageNumber - CCConstant.NUMBEROFMESSAGES
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        for number in minMessageNumber ..< maxMessageNumber {
            insertMessage(allLocalMessages[number])
        }
    }

    private func insertMessage(_ localMessage: LocalMessage) {
        if localMessage.senderId != LocalStorage.shared.getUid()! {
            markMessageAsRead(localMessage)
        }
        let messageReceiver = MessageReceiver(_collectionView: self)
        self.mkMessages.append(messageReceiver.createMessage(localMessage: localMessage)!)
        displayingMessagesCount += 1
        
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.scrollToLastItem(animated: false)
    }
    
    private func loadMoreMessages(maxNumber: Int, minNumber: Int) {
        maxMessageNumber = minNumber - 1
        minMessageNumber = maxMessageNumber - CCConstant.NUMBEROFMESSAGES
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        for number in (minMessageNumber ... maxMessageNumber).reversed() {
            insertOlderMessage(allLocalMessages[number])
        }
    }
    
    private func markMessageAsRead(_ localMessage: LocalMessage) {
        if localMessage.senderId != LocalStorage.shared.getUid()!
            && localMessage.status != CCConstant.READ {
            
            MessageService.shared.updateMessageInFireStore(
                localMessage,
                memberIds: [LocalStorage.shared.getUid()!, recipientId]
            )
        }
    }
    
    private func insertOlderMessage(_ localMessage: LocalMessage) {
        let messageReceiver = MessageReceiver(_collectionView: self)
        self.mkMessages.insert(messageReceiver.createMessage(localMessage: localMessage)!, at: 0)
        displayingMessagesCount += 1
    }
    
}

// MARK: - Configurations
extension ChatController {
    
    private func configureLeftBarButton() {
        self.navigationItem.leftBarButtonItems = [
            UIBarButtonItem(
                image: UIImage(named: "Icons_24px_Back02")?
                    .withTintColor(.black)
                    .withRenderingMode(.alwaysOriginal),
                style: .plain,
                target: self,
                action: #selector(backButtonPressed)
            )
        ]
    }
    
    private func configureCustomTitle() {
        leftBarButtonView.addSubview(titleLabel)
        leftBarButtonView.addSubview(subTitleLabel)
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)
        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
        
        titleLabel.text = recipientName
    }
    
    private func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        
        messagesCollectionView.refreshControl = refreshController
    }
    
    private func configureMessageInputBar() {
        messageInputBar.delegate = self
        
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(
            systemName: "plus",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)
        )
        attachButton.setSize(CGSize(width: 30, height: 30), animated: false)
        attachButton.onTouchUpInside { _ in
            self.actionAttachMessage()
        }
                
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
    }
    
}

// MARK: - UIScrollViewDelegate
extension ChatController {
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshController.isRefreshing {
            if displayingMessagesCount < allLocalMessages.count {
                self.loadMoreMessages(maxNumber: maxMessageNumber, minNumber: minMessageNumber)
                messagesCollectionView.reloadDataAndKeepOffset()
            }
            refreshController.endRefreshing()
        }
    }
}

// MARK: - GalleryControllerDelegate
extension ChatController: GalleryControllerDelegate {
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        if images.count > 0 {
            images.first!.resolve { (image) in
                self.messageSend(text: nil, photo: image, video: nil)
            }
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        print("selected video")
        self.messageSend(text: nil, photo: nil, video: video)
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
