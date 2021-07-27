//
//  HTPublicServiceView.swift
//  HTOA
//
//  Created by 王霞 on 2020/6/10.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import RongIMKit
import SwiftyJSON
import MessageUI

class PSMessageCell: RCMessageCell {
    override class func size(for model: RCMessageModel!, withCollectionViewWidth collectionViewWidth: CGFloat, referenceExtraHeight extraHeight: CGFloat) -> CGSize {
        let contentModel: PSMessageModel = contentMessageModel(model.content)
        let height = contentModel.modelHeight() + extraHeight
        return CGSize.init(width: collectionViewWidth, height: height)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init!(frame: CGRect) {
        super.init(frame: frame)
        
        setAutoLayout()
    }
    
    override func setDataModel(_ model: RCMessageModel!) {
        super.setDataModel(model)
        configData()
    }
//MARK: - 数据
    // 模板数据
    var messageContentModel: PSMessageModel {
        get {
            return PSMessageCell.contentMessageModel(model.content)
        }
    }
    
    static func contentMessageModel(_ model: RCMessageContent) -> PSMessageModel {
        guard let userInfo = model.senderUserInfo else {
            let object = PSMessageModel(JSON.null)
            if let contentModel: RCTextMessage = model as? RCTextMessage {
                object.title = contentModel.content
            }
            return object
        }
        if userInfo.portraitUri != "" && userInfo.portraitUri != nil {
            let contentTemplate: JSON = JSON.init(parseJSON: model.senderUserInfo.portraitUri)
            return PSMessageModel(contentTemplate)
        }
        let object = PSMessageModel(JSON.null)
        if let contentModel: RCTextMessage = model as? RCTextMessage {
            object.title = contentModel.content
        }
        return object
    }
//MARK: - 视图
    let bkView: UIImageView = UIImageView().HTSon {
        $0.backgroundColor = UIColor.clear
        $0.isUserInteractionEnabled = true
    }

    lazy var titleLabel: TTTAttributedLabel = {
        let label: TTTAttributedLabel = TTTAttributedLabel.init(frame: CGRect.zero)
        label.text = "课后评价提醒"
        label.font = descriptionFont
        label.textColor = HTTheme.aTextColor
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = CGFloat(viewLabelContentWidth())
        label.delegate = self
        label.enabledTextCheckingTypes = NSTextCheckingAllTypes
        label.linkAttributes = [NSAttributedString.Key.foregroundColor: HTTheme.btnColor]
        label.activeLinkAttributes = [NSAttributedString.Key.foregroundColor: HTTheme.btnColor]
        return label
    }()
    lazy var contentLabel: TTTAttributedLabel = {
        let label: TTTAttributedLabel = TTTAttributedLabel.init(frame: CGRect.zero)
        label.text = ""
        label.font = descriptionFont
        label.textColor = HTTheme.bTextColor
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = CGFloat(viewLabelContentWidth())
        label.delegate = self
        label.enabledTextCheckingTypes = NSTextCheckingAllTypes
        label.linkAttributes = [NSAttributedString.Key.foregroundColor: HTTheme.btnColor]
        label.activeLinkAttributes = [NSAttributedString.Key.foregroundColor: HTTheme.btnColor]
        label.isHidden = true
        return label
    }()
    lazy var descriptionLabel: TTTAttributedLabel = {
        let label: TTTAttributedLabel = TTTAttributedLabel.init(frame: CGRect.zero)
        label.text = ""
        label.font = descriptionFont
        label.textColor = HTTheme.aTextColor
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = CGFloat(viewLabelContentWidth())
        label.delegate = self
        label.enabledTextCheckingTypes = NSTextCheckingAllTypes
        label.linkAttributes = [NSAttributedString.Key.foregroundColor: HTTheme.btnColor]
        label.activeLinkAttributes = [NSAttributedString.Key.foregroundColor: HTTheme.btnColor]
        label.isHidden = true
        return label
    }()
    
    let contentLabelView: UIView = UIView().HTSon {
        $0.isHidden = true
    }

    let showDetailView: PSShowDetailView = PSShowDetailView()
    let showTransmitView: PSShowTransmitView = PSShowTransmitView()
    let showQuestionView: PSQuestionView = PSQuestionView().HTSon {
        $0.isHidden = true
    }

    lazy var fromImage: UIImage = {
        let img = UIImage(named: "chat_from_bg_normal")
        let width = img!.size.width / 2.0
        let height = img!.size.height / 2.0 + 10
        let newImage = img!.resizableImage(withCapInsets: UIEdgeInsets.init(top: height, left: width, bottom: img!.size.height - height, right: width), resizingMode: .stretch)
        return newImage
    }()

    lazy var toImage: UIImage = {
        let img = UIImage(named: "chat_to_bg_normal")
        let width = img!.size.width / 2.0
        let height = img!.size.height / 2.0 + 10
        let newImage = img!.resizableImage(withCapInsets: UIEdgeInsets.init(top: height, left: width, bottom: img!.size.height - height, right: width), resizingMode: .stretch)
        return newImage
    }()
    
    private func setAutoLayout() {
        messageContentView.addSubview(bkView)
        bkView.snp_makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        bkView.addSubview(titleLabel)
        titleLabel.snp_makeConstraints { (make) in
            make.top.equalToSuperview().offset(HTAdapter.suitW(10))
            make.left.equalToSuperview().offset(HTAdapter.suitW(17))
            make.right.equalToSuperview().offset(HTAdapter.suitW(-17))
        }
        
        bkView.addSubview(showDetailView)
        showDetailView.snp_makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(HTAdapter.suitW(44))
        }
        bkView.addSubview(showTransmitView)
        showTransmitView.snp_makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(HTAdapter.suitW(44))
        }

        bkView.addSubview(descriptionLabel)
        descriptionLabel.snp_makeConstraints { (make) in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp_bottom).offset(HTAdapter.suitW(8))
        }

        bkView.addSubview(contentLabelView)
        contentLabelView.snp_makeConstraints { (make) in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(descriptionLabel.snp_bottom).offset(HTAdapter.suitW(8))
        }
        
        bkView.addSubview(contentLabel)
        contentLabel.snp_makeConstraints { (make) in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(descriptionLabel.snp_bottom).offset(HTAdapter.suitW(8))
        }

        bkView.addSubview(showQuestionView)
        showQuestionView.snp_makeConstraints { (make) in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp_bottom).offset(HTAdapter.suitW(8))
        }
    }
    
}
//MARK: - 点击事件
extension PSMessageCell {
    @objc func clickAction() {
        let urlStr: String = messageContentModel.url
        if let url = URL(string: urlStr) {
            let shared = HTAppPublicServiceCellManager.shared
            if let handle = shared.attributedLabelDidSelectedLink {
                handle(url)
            }
        }
    }
}
//MARK: - 模板
extension PSMessageCell {
    func configOnlyTextCell() {
        titleLabel.font = descriptionFont
        titleLabel.linkAttributes = [NSAttributedString.Key.foregroundColor: HTTheme.btnColor]
        titleLabel.activeLinkAttributes = [NSAttributedString.Key.foregroundColor: HTTheme.btnColor]
        titleLabel.isHidden = false
        descriptionLabel.isHidden = true
        contentLabelView.isHidden = true
        contentLabel.isHidden = true
        showDetailView.isHidden = true
        showTransmitView.isHidden = true
        showQuestionView.isHidden = true
        let title: String = messageContentModel.getHyperLinkTitle()
        let titleWidth = descriptionFont.HTAppSize(of: title, constrainedToHeigh: 1000.0).width + HTAdapter.suitW(40)
        let oneLineHeight = descriptionFont.HTAppSize(of: "title", constrainedToWidth: p_titleContentWidth).height
        let titleHeight: CGFloat = descriptionFont.HTAppSize(of: title, constrainedToWidth: p_titleContentWidth).height
        if oneLineHeight == titleHeight {
            if model.senderUserId == HTAppPublicServiceCommonManager.shared.targetId {
                bkView.snp_remakeConstraints { (make) in
                    make.top.left.bottom.equalToSuperview()
                    make.width.equalTo(titleWidth)
                }
            } else {
                bkView.snp_remakeConstraints { (make) in
                    make.top.right.bottom.equalToSuperview()
                    make.width.equalTo(titleWidth)
                }
            }
        } else {
            bkView.snp_remakeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        bkView.isUserInteractionEnabled = true
        let doubleTapGes: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(doubleTapTextLabelAction(_:)))
        doubleTapGes.numberOfTapsRequired = 2
        doubleTapGes.numberOfTouchesRequired = 1
        bkView.addGestureRecognizer(doubleTapGes)
    }
    @objc private func doubleTapTextLabelAction(_ ges: UITapGestureRecognizer) {
        if let currentVc = HTAPCurrentViewController() {
            let imText = IMTextViewController()
            imText.text = messageContentModel.getHyperLinkTitle()
            currentVc.present(imText, animated: true, completion: nil)
        }
    }
    private func configCommonInfoCell() {
        titleLabel.font = titleFont
        titleLabel.linkAttributes = [NSAttributedString.Key.foregroundColor: HTTheme.aTextColor]
        titleLabel.activeLinkAttributes = [NSAttributedString.Key.foregroundColor: HTTheme.aTextColor]
        bkView.snp_remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        titleLabel.isHidden = false
        descriptionLabel.isHidden = false
        contentLabel.isHidden = true
        contentLabelView.isHidden = messageContentModel.type == .Question
        showDetailView.isHidden = messageContentModel.shouldShowInfoDetail == false
        showTransmitView.isHidden = messageContentModel.type != .VideoMeeting
        showQuestionView.isHidden = messageContentModel.type != .Question
    }
    //MARK: -----------  配置模板各个项展示 ------------
    private func configTemplateCommonInfoCell() {
        titleLabel.font = titleFont
        titleLabel.linkAttributes = [NSAttributedString.Key.foregroundColor: HTTheme.aTextColor]
        titleLabel.activeLinkAttributes = [NSAttributedString.Key.foregroundColor: HTTheme.aTextColor]
        bkView.snp_remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        titleLabel.isHidden = false
        descriptionLabel.isHidden = false
        contentLabel.isHidden = false
        contentLabelView.isHidden = true
        showDetailView.isHidden = messageContentModel.buttonList.count == 0
        showTransmitView.isHidden = true
        showQuestionView.isHidden = true
    }

    private func configQuestionInfoCell() {
        titleLabel.font = descriptionFont
        titleLabel.linkAttributes = [NSAttributedString.Key.foregroundColor: HTTheme.btnColor]
        titleLabel.activeLinkAttributes = [NSAttributedString.Key.foregroundColor: HTTheme.btnColor]
        descriptionLabel.isHidden = true
        if messageContentModel.head == "" {
            titleLabel.isHidden = true
            showQuestionView.snp_remakeConstraints { (make) in
                make.left.right.equalTo(titleLabel)
                make.top.equalTo(titleLabel)
                make.bottom.equalToSuperview()
            }
        } else {
            titleLabel.isHidden = false
            showQuestionView.snp_remakeConstraints { (make) in
                make.left.right.equalTo(titleLabel)
                make.top.equalTo(titleLabel.snp_bottom).offset(HTAdapter.suitW(8))
                make.bottom.equalToSuperview()
            }
        }
    }
    //MARK: -----------  配置模板表项内容 ------------
    private func configTemplateContentCell() {
        let titleContent: String = messageContentModel.firstHead
        let firstHeaderWidth = titleFont.HTAppSize(of: titleContent, constrainedToHeigh: 1000.0).width + HTAdapter.suitW(40)

        var templateContent: String = messageContentModel.secondHead?.content ?? ""
        if templateContent.count < messageContentModel.form?.content.count ?? 0 {
            templateContent = messageContentModel.form?.content ?? ""
        }
        let title: String = messageContentModel.getHyperLinkTemplateContent(templateContent)
        var titleWidth = descriptionFont.HTAppSize(of: title, constrainedToHeigh: 1000.0).width + HTAdapter.suitW(40)
        titleWidth = max(firstHeaderWidth, titleWidth)
        let oneLineHeight = descriptionFont.HTAppSize(of: "title", constrainedToWidth: p_titleContentWidth).height
        let titleHeight: CGFloat = descriptionFont.HTAppSize(of: title, constrainedToWidth: p_titleContentWidth).height
        if oneLineHeight == titleHeight, messageContentModel.buttonList.count == 0 {
            if model.senderUserId == HTAppPublicServiceCommonManager.shared.targetId {
                bkView.snp_remakeConstraints { (make) in
                    make.top.left.bottom.equalToSuperview()
                    make.width.equalTo(titleWidth)
                }
            } else {
                bkView.snp_remakeConstraints { (make) in
                    make.top.right.bottom.equalToSuperview()
                    make.width.equalTo(titleWidth)
                }
            }
        } else {
            bkView.snp_remakeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
}
//MARK: - 模板数据
extension PSMessageCell {
    func configData() {
        if messageContentModel.version == "" {
            configOldMessage()
        } else {
            configTemplateMessage()
        }
    }
    //MARK: -----------  老的模板接口对接 ------------
    private func configOldMessage() {
        showDetailView.jumpUrl = messageContentModel.url
        showDetailView.type = messageContentModel.type
        showDetailView.moreTitle = messageContentModel.endTitle
        showTransmitView.jumpUrl = messageContentModel.url
        showTransmitView.meetingId = messageContentModel.id
        showQuestionView.dataSource = messageContentModel.template
        if model.senderUserId == HTAppPublicServiceCommonManager.shared.targetId {
            bkView.image = fromImage
        } else {
            bkView.image = toImage
        }
        if messageContentModel.type == .Unknown || messageContentModel.type == .Normal {
            configOnlyTextCell()
            var linkURL: [String] = []
            var linkRange: [NSRange] = []
            let content: String = messageContentModel.getHyperLinkTitle(titleLabel, { (url, range) in
                linkURL = url
                linkRange = range
            })
            titleLabel.text = content
            
            if linkURL.count > 0 && linkRange.count > 0 {
                for (index, url) in linkURL.enumerated() {
                    let linkRange: NSRange = linkRange[index]
                    if linkRange.location + linkRange.length <= content.count {
                        let linkAction: TTTAttributedLabelLink = titleLabel.addLink(to: URL.init(string: url.HTurlEncoded()), with: linkRange)
                        linkAction.linkTapBlock = TTTAttributedLabelLinkBlock?.init({ [weak self](label, link) in
                            if let weakSelf = self {
                                if let url: URL = link?.result.url {
                                    weakSelf.doOnlyTextHyperLinkAction(url)
                                }
                            }
                        })
                    }
                }
            }
        } else {
            configCommonInfoCell()
            titleLabel.text = messageContentModel.head
            descriptionLabel.text = messageContentModel.title
            if messageContentModel.title == "" {
                descriptionLabel.isHidden = true
                contentLabelView.snp_remakeConstraints { (make) in
                    make.left.right.equalTo(titleLabel)
                    make.top.equalTo(titleLabel.snp_bottom).offset(HTAdapter.suitW(8))
                }
            }else {
                descriptionLabel.isHidden = false
                contentLabelView.snp_remakeConstraints { (make) in
                    make.left.right.equalTo(titleLabel)
                    make.top.equalTo(descriptionLabel.snp_bottom).offset(HTAdapter.suitW(8))
                }
            }
            if messageContentModel.type == .Question {
                configQuestionInfoCell()
            } else {
                configInfoDetailCellModel()
            }
        }

    }
    //MARK: -----------  通用模板接口对接 ------------
    private func configTemplateMessage() {
        configTemplateCommonInfoCell()

        titleLabel.text = messageContentModel.firstHead
        descriptionLabel.text = messageContentModel.secondHead?.content
        
        showDetailView.templateButtonList = messageContentModel.buttonList
        
        if model.senderUserId == HTAppPublicServiceCommonManager.shared.targetId {
            bkView.image = fromImage
        } else {
            bkView.image = toImage
        }
        
        if messageContentModel.firstHead == "" && messageContentModel.secondHead?.content == "" { // 主标题、副标题都为空
            titleLabel.isHidden = true
            descriptionLabel.isHidden = true
            contentLabel.snp_remakeConstraints { (make) in
                make.left.right.equalTo(titleLabel)
                make.top.equalToSuperview().offset(HTAdapter.suitW(10))
            }
        } else if messageContentModel.firstHead == "" && messageContentModel.secondHead?.content != "" {
            titleLabel.isHidden = true
            descriptionLabel.isHidden = false
            descriptionLabel.snp_remakeConstraints { (make) in
                make.left.right.equalTo(titleLabel)
                make.top.equalToSuperview().offset(HTAdapter.suitW(10))
            }
        } else {
            descriptionLabel.snp_remakeConstraints { (make) in
                make.left.right.equalTo(titleLabel)
                make.top.equalTo(titleLabel.snp_bottom).offset(HTAdapter.suitW(8))
            }
        }
        var btnCount: Int = messageContentModel.buttonList.count
        btnCount = (btnCount % 2 == 1) ? (1 + btnCount / 2) : btnCount / 2
        showDetailView.snp_remakeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(HTAdapter.suitW(44) * CGFloat(btnCount))
        }
        configTemplateContentCell()
        var linkURL: [String] = []
        var linkRange: [NSRange] = []
        
        let secondHead: String = messageContentModel.getHyperLinkTemplateContent(messageContentModel.secondHead?.content,descriptionLabel, { (url, range) in
            linkURL = url
            linkRange = range
        })
        descriptionLabel.text = secondHead
        if linkURL.count > 0 && linkRange.count > 0 {
            for (index, url) in linkURL.enumerated() {
                let linkRange: NSRange = linkRange[index]
                if linkRange.location + linkRange.length <= secondHead.count {
                    let linkAction: TTTAttributedLabelLink = descriptionLabel.addLink(to: URL.init(string: url.HTurlEncoded()), with: linkRange)
                    linkAction.linkTapBlock = TTTAttributedLabelLinkBlock?.init({ [weak self](label, link) in
                        if let weakSelf = self {
                            if let url: URL = link?.result.url {
                                var urlComponents: [String: AnyObject]?
                                if #available(iOS 10.2, *) {
                                    urlComponents = url.absoluteString.HTurlParameters
                                } else {
                                    // Fallback on earlier versions
                                }
                                if let urlParam = urlComponents {
                                    let type: Int = (urlParam["hrefType"] as? String ?? "0").HTtoInt() ?? 0
                                    let hyperLink: String = urlParam["url"] as? String ?? ""
                                    let hyperName: String = urlParam["showText"] as? String ?? ""
                                    let secret: String = urlParam["secret"] as? String ?? ""

                                    let shared: HTAppPublicServiceCellManager = HTAppPublicServiceCellManager.shared
                                    if let handle = shared.hrefContentClickActionBlock {
                                        handle(type, hyperLink, hyperName, secret)
                                    }
                                } else {
                                    weakSelf.doOnlyTextHyperLinkAction(url)
                                }
                            }
                        }
                    })
                }
            }
        }
        linkURL.removeAll()
        linkRange.removeAll()

        let content: String = messageContentModel.getHyperLinkTemplateContent(messageContentModel.form?.content,contentLabel, { (url, range) in
            linkURL = url
            linkRange = range
        })
        contentLabel.text = content
        
        if linkURL.count > 0 && linkRange.count > 0 {
            for (index, url) in linkURL.enumerated() {
                let linkRange: NSRange = linkRange[index]
                if linkRange.location + linkRange.length <= content.count {
                    let linkAction: TTTAttributedLabelLink = contentLabel.addLink(to: URL.init(string: url.HTurlEncoded()), with: linkRange)
                    linkAction.linkTapBlock = TTTAttributedLabelLinkBlock?.init({ [weak self](label, link) in
                        if let weakSelf = self {
                            if let url: URL = link?.result.url {
                                weakSelf.doOnlyTextHyperLinkAction(url)
                            }
                        }
                    })
                }
            }
        }

    }
    func configInfoDetailCellModel() {
        configSubDetailInfoArray(messageContentModel.template)
    }
    func configSubDetailInfoArray(_ dataList: [PSInfoObject]) {
        contentLabelView.subviews.forEach { (sView) in
            sView.removeFromSuperview()
        }
        var topView: UIView? = nil
        dataList.forEach { (object) in
            let tLabel: UILabel = UILabel().HTSon {
                HTAdapter.configureLabelStyle($0, text: "", font: descriptionFont, textColor: HTTheme.bTextColor, aligment: .left)
                $0.numberOfLines = 0
            }
            contentLabelView.addSubview(tLabel)
            tLabel.text = object.title + " : " + object.value
            if topView == nil {
                tLabel.snp_makeConstraints { (make) in
                    make.left.top.right.equalToSuperview()
                }
            } else {
                tLabel.snp_makeConstraints { (make) in
                    make.left.right.equalToSuperview()
                    make.top.equalTo(topView!.snp_bottom)
                }
            }
            topView = tLabel
        }
    }
}

extension PSMessageCell: TTTAttributedLabelDelegate {
    override func becomeFirstResponder() -> Bool {
        return true
    }
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        let urlStr = url.absoluteString
        if urlStr.contains("mailto:") { //发送邮件
            let toEmail: String = (urlStr as NSString).substring(from: "mailto:".count)
            doEmailAction(toEmail)
            return
        }
        let shared = HTAppPublicServiceCellManager.shared
        if let handle = shared.attributedLabelDidSelectedLink {
            handle(url)
        }
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithPhoneNumber phoneNumber: String!) {
        let number:String = "telprompt:" + phoneNumber
        let url:URL = URL.init(string: number)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:]) { (openSuccuss) in
                if openSuccuss == true {
                }
            }
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    private func doOnlyTextHyperLinkAction(_ url: URL) {
        let shared: HTAppPublicServiceCellManager = HTAppPublicServiceCellManager.shared
        if let handle = shared.doOnlyTextHyperLinkActionBlock {
            handle(url)
        }
    }
}
//MARK: - 邮件发送
extension PSMessageCell: MFMailComposeViewControllerDelegate {
    func doEmailAction(_ toEmail: String) {
        if let currentVc = HTAPCurrentViewController() {
            //首先要判断设备具不具备发送邮件功能
            if MFMailComposeViewController.canSendMail() {
                let controller = MFMailComposeViewController()
                //设置代理
                controller.mailComposeDelegate = self
                //设置主题
                controller.setSubject("问题")
                //设置收件人
                controller.setToRecipients([toEmail])
                              
                //设置邮件正文内容（支持html）
                controller.setMessageBody("", isHTML: false)
                 
                //打开界面
                currentVc.present(controller, animated: true, completion: nil)
            }else{
                HTAPShowTip(tips: "本设备不能发送邮件", viewController: currentVc)
            }
        }
    }
    //发送邮件代理方法
    private func mailComposeController(controller: MFMailComposeViewController!,
        didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismiss(animated: true, completion: nil)
             
        if let currentVc = HTAPCurrentViewController() {
            var tips: String = ""
            switch result{
            case .sent:
                tips = "邮件已发送"
            case .cancelled:
                tips = "邮件已取消"
            case .saved:
                tips = "邮件已保存"
            case .failed:
                tips = "邮件发送失败"
            default:
                tips = "邮件未发送"
            }
            HTAPShowTip(tips: tips, viewController: currentVc)
        }
    }
}
