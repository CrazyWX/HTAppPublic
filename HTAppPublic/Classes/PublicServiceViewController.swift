//
//  PublicServiceViewController.swift
//  HTOA
//
//  Created by 王霞 on 2020/6/8.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import RongIMKit
import SwiftyJSON
import Photos
import Alamofire
import CryptoSwift

public class PublicServiceViewController: RCPublicServiceChatViewController {

    private let navi = HTNaviBarView().HTSon {
        $0.configureLeftButton(image: UIImage(named: "HTAppPublic.bundle/Rectangle"))
    }
    public weak var delegate: HTAppPublicServiceDelegate? = nil
    weak var userInfoDataSource: HTAPServiceDataSource? = nil {
        didSet {
            HTAPIMUserManager.shared.userInfoDataSource = userInfoDataSource
        }
    }
    public var chatTitle:String? = "" {
        didSet {
            navi.configureCenterTitle(title: chatTitle ?? "")
        }
    }
    //MARK: - 水印
    // 是否显示水印
    public var showWaterMaskView: Bool = true {
        didSet {
            backView.isHidden = showWaterMaskView == false
        }
    }
    // 水印上面的图片
    public var waterMaskImage: UIImage? {
        didSet {
            if let image = waterMaskImage {
                backView.backgroundColor = UIColor(patternImage: image)
            }
        }
    }
    // 聊天人登录信息
    let chatUserName: String = HTAppPublicServiceCommonManager.shared.userName
    
    private lazy var backView: UIView = {
        let waterMaskView = UIView()
        return waterMaskView
    }()
    //MARK: -
    private var callBackMsgModel:RCMessageModel?
            
    private var shareModel: RCMessageModel?
    
    private var _longGestureIndexPath: IndexPath?
               
    public var headerView: UIView = UIView().HTSon {
        // 头部额外增加的view
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        register(PSMessageCell.self, forMessageClass: RCTextMessage.classForCoder())
        configureSubviews()
        configureChatSetting()
        getWelcomMessage()
    }
    
    private func getWelcomMessage() {
        let appId: String = "10001004"
        //时间戳
        let timestamp: Int = Int(Date().timeIntervalSince1970 * 1000)
        //8位随机数
        let noStr: Int = Int(arc4random_uniform(89999999) + 10000000)
        let secret: String = "asdfasdfasd"
        let sign: String = "appId=\(appId)&noStr=\(noStr)&secret=\(secret)&timestamp=\(timestamp)"
        let plainData = sign.data(using: String.Encoding.utf8)
        let base64String: String = plainData?.base64EncodedString().uppercased() ?? ""
        let headers: HTTPHeaders = [
            "appId": appId,
            "noStr": "\(noStr)",
            "timestamp":"\(timestamp)",
            "sign":base64String,
            "Content-Type":"application/json"
        ]
        let officialAccountId: String = targetId
        let userId: String = HTAppPublicServiceCommonManager.shared.currentUserInfo?.userId ?? ""
        let param: Parameters = ["officialAccountCode":officialAccountId,"interval":2,"userId":userId,"pushFlag":true]
        var hyperLink: String = ""
        if HTAppPublicServiceCommonManager.shared.testService == true {
            hyperLink = "http://172.30.10.108:8082/ronghub/officialAccount/pushWelcomeMsg.json"
        } else {
            hyperLink = "https://esb.huatu.com/ronghub/officialAccount/pushWelcomeMsg.json"
        }
        HTAppPublicNetwork.apiRequest(hyperLink, parameters: param, headers: headers, timeOutHandle: nil, notConnectInternet: nil) { json, error in
            //
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshUserInfoOrGroupInfo()
        configNotice()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.scrollToBottom(animated: true)
    }
            
    private func configureSubviews() {
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = HTTheme.backgroundColor
        if let del = delegate {
            if let rightBarItemTitle = del.naviBarRightButtonTitle?(targetId) {
                navi.configureRightButton(text: rightBarItemTitle)
            }
            if let image = del.naviBarRightButtonImage?(targetId) {
                navi.configureRightButton(image: image)
            }
        }
        navi.addLeftButtonTarget(target: self, action: #selector(backAction), forControlEvents: .touchUpInside)
        navi.addRightButtonTarget(target: self, action: #selector(clickRightBtn), forControlEvents: .touchUpInside)
        view.addSubview(navi)
        conversationMessageCollectionView.backgroundView = backView
        let barHeight: CGFloat = CGFloat(UIDevice().HTisIphoneX() ? 84 : 64)
        navi.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalTo(view)
            make.height.equalTo(barHeight)
        }
        if let del = delegate {
            if let bottomView = del.appPublicServiceBottomView?(targetId) {
                view.addSubview(bottomView)
                bottomView.snp.makeConstraints { (make) in
                    make.bottom.equalTo(chatSessionInputBarControl.snp_top)
                    make.left.right.equalToSuperview()
                    make.height.equalTo(bottomView.frame.size.height)
                }
                conversationMessageCollectionView.snp_remakeConstraints { (make) in
                    make.bottom.equalTo(bottomView.snp_top)
                    make.top.equalTo(navi.snp_bottom)
                    make.left.right.equalToSuperview()
                }
            }
            if let headerView = del.appPublicServiceHeaderView?() {
                view.addSubview(headerView)
            }
        }
        
        if let profile: RCPublicServiceProfile = RCIMClient.shared()?.getPublicServiceProfile(.APP_PUBLIC_SERVICE, publicServiceId: self.targetId) {
            var menuList: [RCPublicServiceMenuItem] = []
            if let del = delegate {
                menuList = del.publicServiceMenuList?() ?? []
            }
            if menuList.count > 0 {
                chatSessionInputBarControl.setInputBarType(.pubType, style: .CHAT_INPUT_BAR_STYLE_SWITCH_CONTAINER_EXTENTION)
                let menu: RCPublicServiceMenu = RCPublicServiceMenu.init()
                menu.menuItems = menuList
                chatSessionInputBarControl.publicServiceMenu = menu
                profile.menu = menu
            }
        }
    }
    
    @objc func backAction() {
        navigationController?.popViewController(animated: true)
    }
    
    private func configureChatSetting() {
        enableSaveNewPhotoToLocalSystem = true
        defaultInputType = RCChatSessionInputBarInputType.extention
        enableContinuousReadUnreadVoice = true
    }
    
    func configNotice() {
        if let del = delegate {
            del.appPublicServiceRefreshNoticeHeader?(targetId, navi)
        }
    }

    func refreshUserInfoOrGroupInfo() {
        guard let user = RCIM.shared()?.currentUserInfo else {
            return
        }
        HTAPIMUserManager.shared.getUserInfo(withUserId: user.userId) { (userInfo) in
            RCIM.shared()?.refreshUserInfoCache(userInfo, withUserId: userInfo?.userId)
        }
    }
    
    public override func willSendMessage(_ messageContent: RCMessageContent!) -> RCMessageContent! {
        //可以在这里修改将要发送的消息
        return messageContent
    }
}
//MARK: - 点击事件
extension PublicServiceViewController {
    @objc func shareHandle() {
        if let model = shareModel {
            var title: String = ""
            if let del = delegate, let delTitle = del.appPublicServiceShareTitle?() {
                title = delTitle
            }
            if model.content.isMember(of: RCFileMessage.classForCoder()) {
                let file = model.content as! RCFileMessage
                if file.fileUrl != nil {
                    let fileUrl = URL(string: file.fileUrl)
                    if let handle = HTAppPublicServiceCellManager.shared.shareToWechatBlock {
                        handle(title, file.name, nil, fileUrl)
                    }
                }else {
                    HTAPShowTip(tips: "文件源获取失败", viewController: self)
                }
            }else if model.content.isMember(of: RCImageMessage.classForCoder()){
                let image = model.content as! RCImageMessage
                if image.imageUrl != nil {
                    let imageUrl = URL(string: image.imageUrl)
                    let thumbImage = image.thumbnailImage
                    if let handle = HTAppPublicServiceCellManager.shared.shareToWechatBlock {
                        handle(title, "", thumbImage, imageUrl)
                    }
                }else {
                    HTAPShowTip(tips: "图片获取失败", viewController: self)
                }
            }
        }
    }
        
    public override func onPublicServiceMenuItemSelected(_ selectedMenuItem: RCPublicServiceMenuItem!) {
        if let del = delegate, let menuId = selectedMenuItem.id.HTtoInt() {
            del.appPublicServiceMenuDidSeleted?(menuId)
        }
    }
    /// 跳转到h5界面
    func goToWebView(_ url: String) {
        if let del = delegate {
            del.appPublicServiceTapUrl?(url)
            return
        }
    }
}
//MARK: - 融云接口实现
extension PublicServiceViewController {
    
    public override func saveNewPhotoToLocalSystem(afterSendingSuccess newImage: UIImage!) {
        DispatchQueue.global().async {
            PHPhotoLibrary.shared().performChanges({
                if newImage != nil {
                   PHAssetChangeRequest.creationRequestForAsset(from: newImage)
                }
            }, completionHandler: { (success, error) in

            })
        }
    }

    public override func presentImagePreviewController(_ model: RCMessageModel!) {
        if let del = delegate {
            if let function = del.presentImagePreviewController {
                function(model)
                return
            }
        }
        super.presentImagePreviewController(model)
    }
    
    public override func willDisplayMessageCell(_ cell: RCMessageBaseCell!, at indexPath: IndexPath!) {
        super.willDisplayMessageCell(cell, at: indexPath)
        if cell.model.content.isKind(of: RCRecallNotificationMessage.classForCoder()) {
            if cell.isKind(of: RCTipMessageCell.classForCoder()) {
                let tipLabel = (cell as! RCTipMessageCell).tipMessageLabel
                var labelRect: CGRect = tipLabel?.frame ?? CGRect.zero
                let titleContent: String = (chatTitle ?? "") + " 撤回了一条消息"
                let titleWidth = (tipLabel?.font.HTAppSize(of: titleContent, constrainedToHeigh: 1000.0).width ?? 0.0) + 20
                labelRect.size.width = titleWidth
                labelRect.origin.x = (kHTScreenWidth - titleWidth) / 2.0
                (cell as! RCTipMessageCell).tipMessageLabel.frame = labelRect
                (cell as! RCTipMessageCell).tipMessageLabel.text = titleContent
            }
        }

        /*if cell.isKind(of: RCTextMessageCell.classForCoder()) {
            (cell as! RCTextMessageCell).delegate = self
        }*/
        if cell.isKind(of: PSMessageCell.self) {
            let pCell: PSMessageCell = (cell as! PSMessageCell)
            pCell.nicknameLabel.isHidden = true
            let rect = pCell.messageContentView.frame
            if pCell.nicknameLabel.text == chatUserName {
                let oriX: CGFloat = rect.origin.x + rect.size.width - messageContentWidth
                pCell.messageContentView.frame = CGRect.init(x: oriX, y: 0, width: messageContentWidth, height: rect.height)
            } else {
                pCell.messageContentView.frame = CGRect.init(x: rect.origin.x, y: 0, width: messageContentWidth, height: rect.height)
            }
            let longGes: UILongPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(addLongGestureAction(_:)))
            longGes.minimumPressDuration = 0.5
            longGes.allowableMovement = 100.0
            pCell.addGestureRecognizer(longGes)

        }
    }
    
    public override func didTapCellPortrait(_ userId: String!) {
        super.didTapCellPortrait(userId)
    }
        
    public override func getLongTouchMessageCellMenuList(_ model: RCMessageModel!) -> [UIMenuItem]! {
        if var menuList = super.getLongTouchMessageCellMenuList(model) {
            guard menuList.count > 0 else {return menuList}
            callBackMsgModel = model
            for (index, each) in menuList.enumerated() {
                if each.title == "更多..." {
                    menuList.remove(at: index)
                }
            }
            if model.content.isMember(of: RCFileMessage.classForCoder()) || model.content.isMember(of: RCImageMessage.classForCoder()) {
                let share = UIMenuItem(title: "分享微信", action: #selector(shareHandle))
                self.shareModel = model
                menuList.append(share)
            }
            return menuList
        }else {
            return super.getLongTouchMessageCellMenuList(model)
        }
    }
    
    public override func didTapMessageCell(_ model: RCMessageModel!) {
        super.didTapMessageCell(model)
    }
    
    public override func didTapUrl(inPublicServiceMessageCell url: String!, model: RCMessageModel!) {
        goToWebView(url)
    }
    
    public override func didLongPressCellPortrait(_ userId: String!) {
        super.didLongPressCellPortrait(userId)
    }
            
    public override func pluginBoardView(_ pluginBoardView: RCPluginBoardView!, clickedItemWithTag tag: Int) {
        if let del = delegate {
            let result: ObjCBool = del.pluginBoardView?(tag) ?? false
            if result.boolValue == true {
                return
            }
        }
        super.pluginBoardView(pluginBoardView, clickedItemWithTag: tag)

    }
    
    @objc func addLongGestureAction(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            let location: CGPoint = recognizer.location(in: conversationMessageCollectionView)
            _longGestureIndexPath = conversationMessageCollectionView.indexPathForItem(at: location)
            if let touchView = recognizer.view {
                if touchView.isKind(of: PSMessageCell.classForCoder()) {
                    let pCell = recognizer.view as! PSMessageCell
                    _ = pCell.becomeFirstResponder()
                    let delItem: UIMenuItem = UIMenuItem.init(title: "删除", action: #selector(delAction))
                    UIMenuController.shared.menuItems = [delItem]
                    var rect = pCell.bkView.convert(pCell.bkView.frame, to: conversationMessageCollectionView)
                    if pCell.nicknameLabel.text == chatUserName {
                        rect.origin.x = pCell.messageContentView.frame.origin.x + pCell.bkView.frame.origin.x
                    }
                    UIMenuController.shared.setTargetRect(rect, in: conversationMessageCollectionView)
                    UIMenuController.shared.setMenuVisible(true, animated: true)
                }
            }
        }
    }
    @objc func delAction() {
        guard let delIndexPath = _longGestureIndexPath else {
            return
        }
        
        if let pCell = conversationMessageCollectionView.cellForItem(at: delIndexPath) {
            if pCell.isKind(of: PSMessageCell.classForCoder()) {
                deleteMessage((pCell as! PSMessageCell).model)
            }
        }
    }
    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(delAction) {
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    public override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let del = delegate {
            del.scrollViewWillBeginDragging?()
        }
        super.scrollViewWillBeginDragging(scrollView)
    }
}
/*
extension PublicServiceViewController: DoubleTapDelegate {
    
    func doubleTapTextMessage(_ model: RCMessageModel!) {
        chatSessionInputBarControl.resetToDefaultStatus()
        chatSessionInputBarControl.resignFirstResponder()
        if model.content.isMember(of: RCTextMessage.classForCoder()) {
            let msg = model.content as! RCTextMessage
            if let del = delegate {
                if del.doubleTapTextMessage?(msg.content) != nil {
                    del.doubleTapTextMessage?(msg.content)
                } else {
                    let imText = IMTextViewController()
                    imText.text = msg.content
                    present(viewController: imText)
                }
            }
        }
    }
}*/
//MARK: - 文档查看
extension PublicServiceViewController {
    @objc func clickRightBtn() {
        if let del = delegate {
            del.naviBarRightButtonAction?()
        }
    }
}
