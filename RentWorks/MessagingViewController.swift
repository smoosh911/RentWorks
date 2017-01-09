//
//  MessagingViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 1/7/17.
//  Copyright © 2017 Michael Perry. All rights reserved.
//

import Foundation

class MessagingViewController: UIViewController, NotificationControllerDelegate {
    
    // MARK: outlets
    
    @IBOutlet weak var clcvwMessages: UICollectionView!
    @IBOutlet weak var txtfldMessage: UITextField!
    
    @IBOutlet weak var cnstrntSendMessageTextViewSpaceToBottom: NSLayoutConstraint!
    
    // MARK: variables
    
    var messages: [Message] = []
    var lastCollectionViewItemIndexPath: IndexPath?
    
    var shouldScrollToBottomOfCollectionView = true
    
    // MARK: life cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.notificationDelegate = self
        
        hideKeyboardWhenViewIsTapped(viewToDismissWhenTapped: clcvwMessages)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if shouldScrollToBottomOfCollectionView {
            resetCollectionView(viewJustLoaded: true)
            shouldScrollToBottomOfCollectionView = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.notificationDelegate = nil
    }
    
    // MARK: actions
    
    @IBAction func backNavigationButtonTapped(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSend_TouchedUpInside(_ sender: UIButton) {
        guard let messageText = txtfldMessage.text else {
            return
        }
        sendMessage(messageText: messageText) { success in
            if success {
                self.txtfldMessage.text = ""
                self.resetCollectionView(viewJustLoaded: false)
            } else {
                AlertManager.alert(withTitle: "Failed to send", withMessage: "Looks like that last message didn't take off, try again!", dismissTitle: "Ok", inViewController: self)
            }
        }
    }
    
    // MARK: notficationcontroller delegate
    
    func recievedNotification(message: String, toUser: String, fromUser: String, fromUserName: String, forProperty: String) {
        Message(message: message, toUserID: toUser, fromUserID: fromUser, fromUserName: fromUserName, forPropertyID: forProperty)
        
        do {
            try CoreDataStack.messagingContext.save()
        } catch let e {
            log(e)
        }
        
        resetCollectionView(viewJustLoaded: false)
    }
    
    // MARK: helper functions
    
    internal func sendMessage(messageText: String, completion: @escaping (_ success: Bool) -> Void) {
        
    }
    
    private func resetCollectionView(viewJustLoaded: Bool = false) {
        clcvwMessages.reloadData()
        let lastItem = collectionView(clcvwMessages, numberOfItemsInSection: 0) - 1
        let lastItemIndex = NSIndexPath.init(item: lastItem, section: 0) as IndexPath
        let moreThanZeroMessages = lastItemIndex[1] != -1 // must check if there are more than zero messages before scrolling collection view or else app will crash
        if moreThanZeroMessages {
            if viewJustLoaded {
                clcvwMessages.scrollToItem(at: lastItemIndex, at: UICollectionViewScrollPosition.bottom, animated: false)
            } else {
                clcvwMessages.scrollToItem(at: lastItemIndex, at: UICollectionViewScrollPosition.bottom, animated: true)
            }
        }
    }
    
    // MARK: keyboard
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if cnstrntSendMessageTextViewSpaceToBottom.constant == 0 {
                UIView.animate(withDuration: 0.3, animations: { 
                    self.cnstrntSendMessageTextViewSpaceToBottom.constant += keyboardSize.height
                    self.view.layoutIfNeeded()
                }, completion: { success in
                    self.resetCollectionView()
                })
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if cnstrntSendMessageTextViewSpaceToBottom.constant != 0 {
                UIView.animate(withDuration: 0.3, animations: {
                    self.cnstrntSendMessageTextViewSpaceToBottom.constant -= keyboardSize.height
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
}

extension MessagingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.CollectionViewCells.MessageCell.rawValue, for: indexPath) as! MessageCollectionViewCell
        
        let message = messages[indexPath.row]
        
        cell.txtvwMessage.text = message.message
        cell.txtvwMessage.layer.cornerRadius = 15
        if let messageText = message.message {
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedSize = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
            
            let viewOrigin = cell.vwMessage.frame.origin
            
            let offsetX = view.frame.width - estimatedSize.width - viewOrigin.x - 16 - 8
            
            if let currentUserID = UserController.currentUserID {
                if message.fromUserID == currentUserID {
                    cell.imgSender.isHidden = true
                    cell.txtvwMessage.backgroundColor = AppearanceController.vengaYellowColor
                    let textRect = CGRect(x: offsetX, y: 0, width: estimatedSize.width + 16, height: estimatedSize.height + 20)
                    cell.txtvwMessage.frame = textRect
                } else {
                    cell.imgSender.isHidden = false
                    cell.txtvwMessage.textAlignment = .left
                    cell.txtvwMessage.backgroundColor = UIColor(white: 0.95, alpha: 1)
                    cell.txtvwMessage.frame = CGRect(x: 0, y: 0, width: estimatedSize.width + 16, height: estimatedSize.height + 20)
                }
            }
            cell.txtvwMessage.bounds.origin.x = -4
            cell.vwMessage.frame = CGRect(x: viewOrigin.x, y: viewOrigin.y, width: view.frame.width, height: estimatedSize.height + 20)
        }
        
        if indexPath.row == (messages.count - 1) {
            lastCollectionViewItemIndexPath = indexPath
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let message = messages[indexPath.row]
        if let messageText = message.message {
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedSize = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
            
            return CGSize(width: view.frame.width, height: estimatedSize.height + 20)
        }
        return CGSize(width: view.frame.width, height: 100)
    }
    
    // MARK: collectionview helper functions
    
    internal func getAllMessages() -> [Message] {
        do {
            guard let allMessages = try CoreDataStack.context.fetch(Message.fetchRequest()) as? [Message] else {
                return []
            }
            return allMessages
        } catch let e {
            log(e)
        }
        return []
    }
}
