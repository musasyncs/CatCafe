//
//  ChatController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/26.
//

import UIKit
import MessageKit
import Gallery

class ChatController: MessagesViewController {
    
    private var chatId = ""
    private var recipientId = ""
    private var recipientName = ""
    
    var displayingMessagesCount = 0
    private var maxMessageNumber = 0
    private var minMessageNumber = 0
    private var typingCounter = 0
    
    var allLocalMessages = [LocalMessage]()
    var mkMessages = [MKMessage]()
    
    let currentUser = MKSender(
        senderId: LocalStorage.shared.getUid()!,
        displayName: UserService.shared.currentUser!.username
    )
    private var gallery: GalleryController!
    private let refreshController = UIRefreshControl()
    
    // MARK: - View
    private let leftBarButtonView: UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    }()
    
    private let titleLabel: UILabel = {
        let title = UILabel(frame: CGRect(x: 5, y: 0, width: 180, height: 25))
        title.textAlignment = .left
        title.textColor = .ccGrey
        title.font = .systemFont(ofSize: 14, weight: .medium)
        title.adjustsFontSizeToFitWidth = true
        return title
    }()
    
    private let subTitleLabel: UILabel = {
        let subTitle = UILabel(frame: CGRect(x: 5, y: 22, width: 180, height: 20))
        subTitle.textAlignment = .left
        subTitle.textColor = .ccGreyVariant
        subTitle.font = .systemFont(ofSize: 12, weight: .medium)
        subTitle.adjustsFontSizeToFitWidth = true
        return subTitle
    }()

    private lazy var chatInputView: ChatInputAccessoryView = {
        let inputView = ChatInputAccessoryView()
        inputView.delegate = self
        return inputView
    }()
    override var inputAccessoryView: UIView? { return chatInputView }
    override var canBecomeFirstResponder: Bool { return true }
    
    // MARK: - Initializer
    init(chatId: String, recipientId: String, recipientName: String) {
        super.init(nibName: nil, bundle: nil)
        self.chatId = chatId
        self.recipientId = recipientId
        self.recipientName = recipientName
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLeftBarButton()
        setupCustomTitle()
        setupMessageCollectionView()
        setupTypingObserver()
        
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createGradientBackground()
    }
        
    // MARK: - Helper
    func messageSend(text: String?, photo: UIImage?, video: Video?) {
        MessageSender.send(
            chatId: chatId,
            text: text,
            photo: photo,
            video: video,
            memberIds: [LocalStorage.shared.getUid()!, recipientId]
        ) { [weak self] newMessage in
            guard let self = self else { return }
            self.insertMessage(newMessage)
        }
    }
    
    // MARK: - Action
    @objc func backButtonPressed() {
        TypingService.shared.removeTypingListener()
        MessageService.shared.removeListeners()
        navigationController?.popViewController(animated: true)
    }

}

extension ChatController {
    
    private func setupLeftBarButton() {
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(
                image: UIImage.asset(.Icons_24px_Back02)?
                    .withTintColor(.ccGrey)
                    .withRenderingMode(.alwaysOriginal),
                style: .plain,
                target: self,
                action: #selector(backButtonPressed)
            )
        ]
    }
    
    private func setupCustomTitle() {
        leftBarButtonView.addSubviews(titleLabel, subTitleLabel)
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)
        navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
        
        titleLabel.text = recipientName
    }
    
    private func setupMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        
        messagesCollectionView.backgroundColor = .clear
        messagesCollectionView.showsVerticalScrollIndicator = false
        messagesCollectionView.refreshControl = refreshController
    }
    
    private func setupTypingObserver() {
        TypingService.shared.createTypingObserver(chatRoomId: chatId) { [weak self] isTyping in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.subTitleLabel.text = isTyping ? "正在輸入..." : ""
            }
        }
    }
    
}

extension ChatController {

    // 載入歷史訊息
    private func loadChats() {
        MessageService.shared.checkForOldChats(LocalStorage.shared.getUid()!,
                                               collectionId: chatId
        ) { [weak self] localMessages in
            guard let self = self else { return }
            self.allLocalMessages = localMessages
            self.insertOldMessages()
            
            DispatchQueue.main.async {
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }
    
    private func insertOldMessages() {
        maxMessageNumber = allLocalMessages.count - displayingMessagesCount
        minMessageNumber = maxMessageNumber - CCConstant.NUMBEROFMESSAGES
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        for number in minMessageNumber ..< maxMessageNumber {
            insertMessage(allLocalMessages[number])
        }
    }

    // 監聽新訊息
    private func listenForNewChats() {
        MessageService.shared.listenForNewChats(
            LocalStorage.shared.getUid()!,
            collectionId: chatId,
            lastMessageDate: lastMessageDate()
        ) { [weak self] newMessage in
            guard let self = self else { return }
            self.insertMessage(newMessage)
        }
    }
    private func lastMessageDate() -> Date {
        let lastMessageDate = allLocalMessages.last?.date ?? Date()
        return Calendar.current.date(
            byAdding: .second,
            value: 1,
            to: lastMessageDate
        ) ?? lastMessageDate
    }
    
    // 插入訊息
    private func insertMessage(_ localMessage: LocalMessage) {
        if localMessage.senderId != LocalStorage.shared.getUid()! {
            markMessageAsRead(localMessage)
        }
        mkMessages.append(
            MessageCreator(_collectionView: self).createMessage(localMessage: localMessage)!
        )
        displayingMessagesCount += 1
        
        DispatchQueue.main.async {
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem(animated: false)
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
    
    // 送出的訊息判斷是否被讀
    private func listenForReadStatusChange() {
        MessageService.shared.listenForReadStatusChange(
            LocalStorage.shared.getUid()!,
            collectionId: chatId
        ) { [weak self] updatedMessage in
            guard let self = self else { return }
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
                    DispatchQueue.main.async {
                        self.messagesCollectionView.reloadData()
                    }
                }
            }
        }
    }
}

// MARK: - CommentInputAccessoryViewDelegate
extension ChatController: ChatInputAccessoryViewDelegate {
    
    func chatInputView(_ inputView: ChatInputAccessoryView, textDidChangeTo text: String) {
        if !text.isEmpty {
            typingIndicatorUpdate()
        }
    }
    private func typingIndicatorUpdate() {
        typingCounter += 1
        TypingService.saveTypingCounter(typing: true, chatRoomId: chatId)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.typingCounterStop()
        }
    }
    private func typingCounterStop() {
        typingCounter -= 1
        if typingCounter == 0 {
            TypingService.saveTypingCounter(typing: false, chatRoomId: chatId)
        }
    }
    
    func chatInputView(_ inputView: ChatInputAccessoryView, wantsToUploadText text: String) {
        messageSend(text: text, photo: nil, video: nil)
        inputView.clearChatTextView()
    }
    
    func openCamera(_ inputView: ChatInputAccessoryView) {
        self.showImageGallery(camera: true)
    }
    
    func openGallery(_ inputView: ChatInputAccessoryView) {
        self.showImageGallery(camera: false)
    }
    
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
    private func loadMoreMessages(maxNumber: Int, minNumber: Int) {
        maxMessageNumber = minNumber - 1
        minMessageNumber = maxMessageNumber - CCConstant.NUMBEROFMESSAGES
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        for number in (minMessageNumber ... maxMessageNumber).reversed() {
            self.mkMessages.insert(
                MessageCreator(_collectionView: self)
                    .createMessage(localMessage: allLocalMessages[number])!, at: 0
            )
            displayingMessagesCount += 1
        }
    }

}

// MARK: - GalleryControllerDelegate
extension ChatController: GalleryControllerDelegate {
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        if images.count > 0 {
            images.first!.resolve { [weak self] image in
                guard let self = self else { return }
                self.messageSend(text: nil, photo: image, video: nil)
            }
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
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
