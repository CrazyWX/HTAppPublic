//
//  PublicServiceCommonView.swift
//  HTOA
//
//  Created by 王霞 on 2020/6/12.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import YYWebImage
import YYText
import RongIMKit

class PSShowDetailView: UIView {

    let bDetailLabel: UILabel = UILabel().HTSon {
        HTAdapter.configureLabelStyle($0, text: "查看更多", font: UIFont.HTAppRegularFont(with: HTAdapter.adjustFont(16)), textColor: HTTheme.btnColor, aligment: .left)
    }
    let assistanceImageView = UIImageView().HTSon {
        $0.image = UIImage(named: "HTAppPublic.bundle/nextpage")
    }
    let hLine: UIView = UIView().HTSon {
        $0.backgroundColor = HTTheme.lineColor
    }
    
    var buttonList: [UIButton] = []
    var templateButtonList: [HTAppPublicButtonData] = [] {
        didSet {
            buttonList.forEach { item in
                item.removeFromSuperview()
            }
            buttonList.removeAll()
            for (index, data) in templateButtonList.enumerated() {
                let button: UIButton = UIButton().HTSon {
                    $0.titleLabel?.font = UIFont.HTAppRegularFont(with: HTAdapter.adjustFont(16))
                    $0.setTitleColor(HTTheme.btnColor, for: .normal)
                    $0.setTitle(data.showText, for: .normal)
                    $0.tag = index
                }
                button.addTarget(self, action: #selector(clickButtonAction(_:)), for: .touchUpInside)
                buttonList.append(button)
            }
            configButtonList()
        }
    }

    var jumpUrl: String = ""
    var type: PublicServiceModelType = .Unknown
    var moreTitle: String = "查看更多" {
        didSet {
            bDetailLabel.text = moreTitle
            configSubViews()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configSubViews() {
        addSubview(bDetailLabel)
        addSubview(assistanceImageView)
        addSubview(hLine)

        assistanceImageView.snp.makeConstraints { (maker) in
            maker.right.equalToSuperview().offset(HTAdapter.suitW(-17))
            maker.centerY.equalToSuperview()
            maker.size.equalTo(UIImage(named: "HTAppPublic.bundle/nextpage")!.size)
        }
        hLine.snp_makeConstraints { (make) in
            make.left.equalToSuperview().offset(HTAdapter.suitW(6))
            make.right.top.equalToSuperview()
            make.height.equalTo(1.0 / UIScreen.main.scale)
        }
        bDetailLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(hLine).offset(HTAdapter.suitW(11))
            maker.centerY.equalToSuperview()
        }

        let tapGes: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(clickAction))
        addGestureRecognizer(tapGes)
    }
    
    private func configButtonList() {
        subviews.forEach { item in
            item.removeFromSuperview()
        }
        if templateButtonList.count == 1 {
            buttonList.removeAll()
            let data = templateButtonList[0]
            jumpUrl = data.url
            moreTitle = data.showText
            configSubViews()
            return
        }
        let buttonCount = templateButtonList.count
        var allBtnList: [UIButton] = []
        if buttonCount % 2 == 1 { // 最后一行按钮整行显示
            allBtnList = Array(buttonList[0...buttonCount-2])
        } else {
            allBtnList = buttonList
        }
        var offsetY: CGFloat = 0.0
        let offsetX: CGFloat = HTAdapter.suitW(6)
        for (index, item) in allBtnList.enumerated() {
            if index % 2 == 0 {
                addSubview(item)
                item.snp_makeConstraints { (make) in
                    make.left.equalToSuperview().offset(offsetX)
                    make.top.equalToSuperview().offset(offsetY)
                    make.width.equalToSuperview().dividedBy(2)
                    make.height.equalTo(HTAdapter.suitW(44))
                }
                let line: UIView = UIView().HTSon {
                    $0.backgroundColor = HTTheme.lineColor
                }
                addSubview(line)
                line.snp_makeConstraints { (make) in
                    make.left.equalToSuperview().offset(offsetX)
                    make.right.equalToSuperview()
                    make.top.equalToSuperview().offset(offsetY)
                    make.height.equalTo(1.0 / UIScreen.main.scale)
                }
            } else {
                let line: UIView = UIView().HTSon {
                    $0.backgroundColor = HTTheme.lineColor
                }
                addSubview(line)
                line.snp_makeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.top.equalToSuperview().offset(offsetY)
                    make.height.equalTo(HTAdapter.suitW(44))
                    make.width.equalTo(1.0 / UIScreen.main.scale)
                }
                addSubview(item)
                item.snp_makeConstraints { (make) in
                    make.right.equalToSuperview()
                    make.top.equalToSuperview().offset(offsetY)
                    make.width.equalToSuperview().dividedBy(2)
                    make.height.equalTo(HTAdapter.suitW(44))
                }
                offsetY = offsetY + HTAdapter.suitW(44)
            }
        }
        if buttonCount % 2 == 1 {
            if let lastButton = buttonList.last {
                addSubview(lastButton)
                lastButton.snp_makeConstraints { (make) in
                    make.bottom.equalToSuperview()
                    make.left.equalToSuperview().offset(HTAdapter.suitW(6))
                    make.height.equalTo(HTAdapter.suitW(44))
                    make.right.equalToSuperview()
                }
                let line: UIView = UIView().HTSon {
                    $0.backgroundColor = HTTheme.lineColor
                }
                addSubview(line)
                line.snp_makeConstraints { (make) in
                    make.left.equalToSuperview().offset(offsetX)
                    make.right.equalToSuperview()
                    make.bottom.equalTo(lastButton.snp_top)
                    make.height.equalTo(1.0 / UIScreen.main.scale)
                }
            }
        }
    }
    
    @objc func clickButtonAction(_ sender: UIButton) {
        let tag = sender.tag
        let data = templateButtonList[tag]
        let shared = HTAppPublicServiceCellManager.shared
        if data.hrefType == 3 { // 电话
            var number:String = data.showText
            number = "telprompt:" + number
            let url:URL = URL.init(string: number)!
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:]) { (openSuccuss) in
                    if openSuccuss == true {
                    }
                }
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            if let handle = shared.hrefContentClickActionBlock {
                handle(data.hrefType, data.url, data.showText, data.secret)
            }
        }
    }

    @objc func clickAction() {
        let shared = HTAppPublicServiceCellManager.shared
        if templateButtonList.count == 1 {
            let data = templateButtonList[0]
            if let handle = shared.hrefContentClickActionBlock {
                handle(data.hrefType, data.url, data.showText, data.secret)
            }
            return
        }
        if let handle = shared.showMoreActionBlock {
            handle(type, jumpUrl)
        }
    }
}

class PSQuestionView: UIView {

    var dataSource: [PSInfoObject] = [] {
        didSet {
            configSubViews()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        configSubViews()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configSubViews() {
        subviews.forEach { (sView) in
            sView.removeFromSuperview()
        }
        var topView: UIView? = nil
        var index: Int = 1
        dataSource.forEach { (object) in
            var questionContent: String  = "\(index)." + object.title
            var phoneRange: NSRange = NSRange(location: 0, length: 0)
            if index == dataSource.count && questionContent.contains("{") && questionContent.contains("}") {
                let leftRange: NSRange = (questionContent as NSString).range(of: "{")
                let rightRange: NSRange = (questionContent as NSString).range(of: "}")
                let location: Int = leftRange.location + 1
                let length: Int = rightRange.location - leftRange.location - 1
                phoneRange = NSRange(location: location, length: length)
                questionContent = (questionContent as NSString).replacingOccurrences(of: "{", with: " ")
                questionContent = (questionContent as NSString).replacingOccurrences(of: "}", with: " ")
            }
            let detailLabel = YYLabel().HTSon {
                $0.font = descriptionFont
                $0.textColor = HTTheme.btnColor
                $0.numberOfLines = 0
                $0.isUserInteractionEnabled = true
                $0.preferredMaxLayoutWidth = CGFloat(p_titleContentWidth)
            }
            detailLabel.text = questionContent
            let text = NSMutableAttributedString(string: questionContent)
            text.yy_font = descriptionFont
            text.yy_color = index == dataSource.count ? HTTheme.aTextColor : HTTheme.btnColor
            text.yy_alignment = .left
            if index == dataSource.count { // 最后一个
                text.yy_setColor(HTTheme.btnColor, range: phoneRange)
                let hi = YYTextHighlight()
                hi.tapAction = { containerView, text, range, rect in
                    var number:String = (questionContent as NSString).substring(with: phoneRange)
                    number = "telprompt:" + number
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
                text.yy_setTextHighlight(hi, range: phoneRange)
            } else {
                let image: UIImage = UIImage(named: "HTAppPublic.bundle/appservice_icon_finger") ?? UIImage()
                let attachText: NSMutableAttributedString = NSMutableAttributedString.yy_attachmentString(withEmojiImage: image, fontSize: descriptionFont.pointSize) ?? NSMutableAttributedString(string: "")
                text.append(attachText)
                let hi = YYTextHighlight()
                let textRange:NSRange = NSRange(location: 0, length: text.length)
                hi.tapAction = { [weak self](containerView, text, range, rect) in
                    if let weakSelf = self {
                        weakSelf.resendQuestion(object)
                    }
                }
                text.yy_setTextHighlight(hi, range: textRange)
            }
            detailLabel.attributedText = text
            addSubview(detailLabel)
            let titleHeight = descriptionFont.HTAppSize(of: questionContent + "12345", constrainedToWidth: p_titleContentWidth).height
            if topView == nil {
                detailLabel.snp_makeConstraints { (make) in
                    make.left.right.equalToSuperview()
                    make.top.equalToSuperview()
                    make.height.equalTo(titleHeight + HTAdapter.suitW(8))
                }
            } else {
                detailLabel.snp_makeConstraints { (make) in
                    make.left.right.equalToSuperview()
                    make.top.equalTo(topView!.snp_bottom)
                    make.height.equalTo(titleHeight + HTAdapter.suitW(8))
                }
            }
            topView = detailLabel
            index = index + 1
        }
    }

    @objc func resendQuestion(_ info: PSInfoObject) {
        if info.value != "" && info.value.contains("http") {
//                MobClick.event(MobClickEvent.appservice_info_question)
            if let url = URL(string: info.value) {
                let shared = HTAppPublicServiceCellManager.shared
                if let handle = shared.attributedLabelDidSelectedLink {
                    handle(url)
                }
            }
            return
        }
//            MobClick.event(MobClickEvent.appservice_info_question, attributes: ["value":info.title])
        let content = RCTextMessage()
        content.content = info.title
        RCIM.shared()?.sendMessage(.ConversationType_APPSERVICE, targetId: HTAppPublicServiceCommonManager.shared.targetId, content: content, pushContent: nil, pushData: nil, success: { (code) in
        }, error: { (code, messageID) in
        })
    }

}

class PSShowTransmitView: UIView {

    let joinButton = UIButton().HTSon {
        $0.setTitle("参加", for: .normal)
        $0.setTitleColor(HTTheme.btnColor, for: .normal)
        $0.tag = 0
        $0.titleLabel?.font = UIFont.HTAppRegularFont(with: HTAdapter.adjustFont(16))
    }
    let transmitButton = UIButton().HTSon {
        $0.setTitle("转发", for: .normal)
        $0.setTitleColor(HTTheme.btnColor, for: .normal)
        $0.tag = 1
        $0.titleLabel?.font = UIFont.HTAppRegularFont(with: HTAdapter.adjustFont(16))
    }
    let vLine: UIView = UIView().HTSon {
        $0.backgroundColor = HTTheme.lineColor
    }

    let hLine: UIView = UIView().HTSon {
        $0.backgroundColor = HTTheme.lineColor
    }

    var meetingId: Int = 0
    var jumpUrl: String = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        configSubViews()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configSubViews() {
        addSubview(joinButton)
        addSubview(transmitButton)
        addSubview(vLine)
        addSubview(hLine)

        vLine.snp_makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview().offset(HTAdapter.suitW(6))
            make.width.equalTo(1.0 / UIScreen.main.scale)
        }
        hLine.snp_makeConstraints { (make) in
            make.left.equalToSuperview().offset(HTAdapter.suitW(6))
            make.right.top.equalToSuperview()
            make.height.equalTo(1.0 / UIScreen.main.scale)
        }
        transmitButton.snp.makeConstraints { (maker) in
            maker.left.equalTo(hLine)
            maker.top.bottom.equalToSuperview()
            maker.right.equalTo(vLine.snp_left)
        }
        joinButton.snp.makeConstraints { (maker) in
            maker.top.bottom.right.equalToSuperview()
            maker.left.equalTo(vLine.snp_right)
        }

        joinButton.addTarget(self, action: #selector(clickBtnAction(_:)), for: .touchUpInside)
        transmitButton.addTarget(self, action: #selector(clickBtnAction(_:)), for: .touchUpInside)
    }

    @objc func clickBtnAction(_ sender: UIButton) {
        let tag: Int = sender.tag
        let shared = HTAppPublicServiceCellManager.shared
        if let handle = shared.infoMessageButtonClickAction {
            handle(tag, meetingId)
        }
    }
}

