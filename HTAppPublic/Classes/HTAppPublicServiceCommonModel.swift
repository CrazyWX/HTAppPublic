//
//  HTAppPublicServiceCommonModel.swift
//  HTOA
//
//  Created by 王霞 on 2021/4/26.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import SwiftyJSON

public enum PublicServiceModelType: Int {
    case Unknown = 0 // 未知
    case Normal = 1 // 普通文本
    case VideoMeeting = 2 // 视频会议
    case Question = 4 // 问答
    case InfoDetailToOriginal = 5 // 考勤异常
    case InfoDetailToH5 = 6 // 查看详情，进入h5
    case InfoDetailToUser = 7 // 查看详情，进入个人信息
    case InfoDetailToAgent = 8 //审批代理
    case InfoDetailToAttendanceReport = 9 //考勤月报表
    case SupervisorService = 10//督学服务
    case PersonalHomePage = 11//进入个人主页
    case BUSetting = 12//BU设置
    case InfoDetailNoMore = 13
}

//MARK: - 信息卡片模型
public class PSInfoObject: NSObject {
    public var title: String = ""
    public var value: String = ""
    
    init(_ json: JSON) {
        title = json["templateKey"].stringValue
        value = json["templateValue"].stringValue
    }
    public override init() {
    }
}

public struct HTAppPublicCommonData {
    public var content: String = ""
    //是否包含外链接需要处理。如果为true，需要移动端处理<esbhref>{此处为外链信息JSON串}</esbhref>
    public var includeHref: Bool = false
    init(_ json: JSON) {
        if json["formContent"] != JSON.null {
            content = json["formContent"].stringValue
        } else if json["secondHeadContent"] != JSON.null {
            content = json["secondHeadContent"].stringValue
        }
        includeHref = json["includeHref"].boolValue
    }
}
public struct HTAppPublicButtonData {
    var hrefType: Int = 0 //链接类型 1：H5 2：原生 3: 电话 4: 接口 5: 文件
    var url: String = ""//链接地址，包含参数。H5及原生都使用此种方式传参
    var showText: String = "" //展示的按钮名字
    var secret: String = "" //密钥
    var fileType: String = "" //文件
    
    init(_ json: JSON) {
        hrefType = json["hrefType"].intValue
        url = json["url"].stringValue
        showText = json["showText"].stringValue
        secret = json["secret"].stringValue
        fileType = json["fileType"].stringValue
    }
}

public class PSMessageModel: NSObject {
    public var template: [PSInfoObject] = []
    public var type: PublicServiceModelType = .Unknown
    public var head: String = ""
    public var title: String = ""
    public var url: String = ""
    public var id: Int = 0
    public var endTitle: String = ""
    
    public var version: String = ""
    public var firstHead: String = ""
    public var secondHead: HTAppPublicCommonData? = nil
    public var form: HTAppPublicCommonData? = nil
    public var buttonList: [HTAppPublicButtonData] = []
    
    public var hyperLinkContent: String {
        get {
            return getHyperLinkTitle()
        }
    }

    public override init() {
        //
    }
    
    public init(_ json: JSON) {
        version = json["version"].stringValue
        if version == "v2" { //标识版本，方便移动端兼容。固定传值v2，代表使用新的ESB对接方式
            firstHead = json["firstHead"].stringValue
            secondHead = HTAppPublicCommonData(json["secondHead"])
            form = HTAppPublicCommonData(json["form"])
            buttonList = json["buttonList"].arrayValue.map({ each in
                return HTAppPublicButtonData(each)
            })
        } else { // 旧接口
            type = PublicServiceModelType(rawValue: json["type"].intValue) ?? .Unknown
            if type.rawValue > PublicServiceModelType.InfoDetailNoMore.rawValue {
                title = "当前版本不支持该信息，请升级最新版本"
                return
            }
            template = json["template"].arrayValue.map({ (each) -> PSInfoObject in
                return PSInfoObject(each)
            })
            if json["template"] == JSON.null {
                type = .Normal
            }
            head = json["head"].stringValue
            title = json["title"].stringValue

            url = json["url"].stringValue
            id = json["id"].intValue
            
            endTitle = json["endTitle"].stringValue
            if endTitle == "" {
                endTitle = "查看更多"
            }
            if type == .InfoDetailNoMore {
                endTitle = ""
            }
        }
    }
    var shouldShowInfoDetail: Bool {
        get {
            if type == .Unknown || type == .Normal || type == .VideoMeeting || type == .Question || type == .InfoDetailNoMore {
                return false
            }
            return true
        }
    }
    public func getHyperLinkTitle(_ label: TTTAttributedLabel? = nil, _ block: ((_ url: [String], _ range: [NSRange])->())? = nil) -> String {
        let leftString: String = "#*￥$#{"
        let rightString: String = "}#*￥$#"
        let totalLength: Int = leftString.count - 1
        var leftRanges: [NSRange] = []
        var rightRanges: [NSRange] = []
        if #available(iOS 10.2, *) {
            leftRanges = title.nsranges(of: leftString)
            rightRanges = title.nsranges(of: rightString)
        } else {
            let leftRange: NSRange = (title as NSString).range(of: leftString)
            let rightRange: NSRange = (title as NSString).range(of: rightString)
            leftRanges = [leftRange]
            rightRanges = [rightRange]
        }

        var newContent: String = title
        if leftRanges.count > 0 && rightRanges.count > 0 && leftRanges.count <= rightRanges.count {
            var linkContents: [String] = []
            var linkValues: [String] = []
            var hyperLinkRanges: [NSRange] = []
            var newUrlStrings: [String] = []
            var minusValueCount: Int = 0
            for (index, leftRange) in leftRanges.enumerated() {
                let rightRange = rightRanges[index]
                let location: Int = leftRange.location + totalLength
                let length: Int = rightRange.location - leftRange.location - (totalLength - 1)
                let linkRange = NSRange(location: location, length: length)
                let linkContent: String = (newContent as NSString).substring(with: linkRange)
                let jsonValue: JSON = JSON.init(parseJSON: linkContent)
                let linkName: String = jsonValue["viewName"].stringValue
                let linkValue: String = "{\(linkName)}"
                linkContents.append(linkContent)
                linkValues.append(linkValue)
                let hyperLinkRange = NSRange(location: leftRange.location - minusValueCount, length: linkValue.count)
                hyperLinkRanges.append(hyperLinkRange)
                let newUrlString: String = "scheme://?type=\(jsonValue["type"])&url=\(jsonValue["url"])&viewName=\(jsonValue["viewName"])"
                newUrlStrings.append(newUrlString)
                minusValueCount = minusValueCount + (linkContent.count - linkValue.count) + totalLength * 2
            }
            for (index, linkContent) in linkContents.enumerated() {
                newContent = (newContent as NSString).replacingOccurrences(of: linkContent, with: linkValues[index])
            }
            newContent = (newContent as NSString).replacingOccurrences(of: leftString, with: " ")
            newContent = (newContent as NSString).replacingOccurrences(of: rightString, with: " ")

            if let _ = label {
                if let handle = block {
                    handle(newUrlStrings, hyperLinkRanges)
                }
            }
            return newContent
        }
        return title
    }
    //MARK: -----------  获取超链接文本内容 ------------
    public func getHyperLinkTemplateContent(_ content: String? = nil,
                                     _ label: UILabel? = nil,
                                     _ block: ((_ url: [String], _ range: [NSRange])->())? = nil) -> String {
        if let formContent = content {
            let leftString: String = "<esbhref>{"
            let rightString: String = "}</esbhref>"
            let totalLength: Int = leftString.count - 1
            let allTotalLength: Int = totalLength + rightString.count - 1
            var leftRanges: [NSRange] = []
            var rightRanges: [NSRange] = []
            if #available(iOS 10.2, *) {
                leftRanges = formContent.nsranges(of: leftString)
                rightRanges = formContent.nsranges(of: rightString)
            } else {
                let leftRange: NSRange = (formContent as NSString).range(of: leftString)
                let rightRange: NSRange = (formContent as NSString).range(of: rightString)
                leftRanges = [leftRange]
                rightRanges = [rightRange]
            }

            var newContent: String = formContent
            if leftRanges.count > 0 && rightRanges.count > 0 && leftRanges.count <= rightRanges.count {
                var linkContents: [String] = []
                var linkValues: [String] = []
                var hyperLinkRanges: [NSRange] = []
                var newUrlStrings: [String] = []
                var minusValueCount: Int = 0
                for (index, leftRange) in leftRanges.enumerated() {
                    let rightRange = rightRanges[index]
                    let location: Int = leftRange.location + totalLength
                    let length: Int = rightRange.location - leftRange.location - (totalLength - 1)
                    let linkRange = NSRange(location: location, length: length)
                    let linkContent: String = (newContent as NSString).substring(with: linkRange)
                    let jsonValue: JSON = JSON.init(parseJSON: linkContent)
                    let linkName: String = jsonValue["showText"].stringValue
                    let linkValue: String = "{\(linkName)}"
                    linkContents.append(linkContent)
                    linkValues.append(linkValue)
                    let hyperLinkRange = NSRange(location: leftRange.location - minusValueCount, length: linkValue.count)
                    hyperLinkRanges.append(hyperLinkRange)
                    let newUrlString: String = "scheme://?hrefType=\(jsonValue["hrefType"])&url=\(jsonValue["url"])&showText=\(jsonValue["showText"])&secret=\(jsonValue["secret"])&fileType=\(jsonValue["fileType"])"
                    newUrlStrings.append(newUrlString)
                    minusValueCount = minusValueCount + (linkContent.count - linkValue.count) + allTotalLength
                }
                for (index, linkContent) in linkContents.enumerated() {
                    newContent = (newContent as NSString).replacingOccurrences(of: linkContent, with: linkValues[index])
                }
                newContent = (newContent as NSString).replacingOccurrences(of: leftString, with: " ")
                newContent = (newContent as NSString).replacingOccurrences(of: rightString, with: " ")

                if let _ = label {
                    if let handle = block {
                        handle(newUrlStrings, hyperLinkRanges)
                    }
                }
                return newContent
            }
            return formContent
        }
        return ""
    }

    public func modelHeight(_ width: Double = 0.0) -> CGFloat {
        if version != "" {
            return templateInfoDetailHeight(width)
        }
        if type == .Unknown || type == .Normal {
            return normalHeight(width)
        } else {
            if type == .Question {
                return infoQuestionHeight()
            }
            return infoDetailHeight(width)
        }
    }
    public func templateHeight(_ width: Double = 0.0) -> CGFloat {
        var totalHeight: CGFloat = 0.0
        template.forEach { (info) in
            let titleHeight = labelHeight(content: info.title + " : " + info.value, width: viewLabelContentWidth(width), font: descriptionFont)
            totalHeight =  totalHeight + titleHeight
        }
        return totalHeight + HTAdapter.suitW(20)
    }
    func questionTemplateHeight(_ width: Double = 0.0) -> CGFloat {
        var totalHeight: CGFloat = HTAdapter.suitW(4.0)
        var index: Int = 1
        template.forEach { (info) in
            let titleHeight = descriptionFont.HTAppSize(of: "\(index)." + info.title + "12345", constrainedToWidth: viewLabelContentWidth(width)).height
            totalHeight =  totalHeight + titleHeight + HTAdapter.suitW(8.0)
            index = index + 1
        }
        return totalHeight + HTAdapter.suitW(4.0)
    }

    private func normalHeight(_ width: Double = 0.0) -> CGFloat {
        let content: String = getHyperLinkTitle()
        let titleHeight: CGFloat = labelHeight(content: content, width: viewLabelContentWidth(width), font: descriptionFont)
        return HTAdapter.suitW(20) + titleHeight
    }
    
    private func infoDetailHeight(_ width: Double = 0.0) -> CGFloat {
        let contentWidth: Double = viewLabelContentWidth(width)
        var resultHeight: CGFloat = HTAdapter.suitW(10)
        if head != "" {
            let titleHeight: CGFloat = labelHeight(content: head, width: contentWidth, font: titleFont)
            resultHeight = resultHeight + titleHeight
        }
        /// 描述字段非空
        if title != "" {
            let detailHeight: CGFloat = labelHeight(content: title, width: contentWidth, font: descriptionFont)
            resultHeight = resultHeight + HTAdapter.suitW(8) + detailHeight
        }
        let totalHeight: CGFloat = templateHeight()
        /// 分段字段非空
        if template.count > 0 {
            resultHeight = resultHeight + HTAdapter.suitW(8) + totalHeight
        } else {
            resultHeight = resultHeight + HTAdapter.suitW(20)
        }
        /// 是否显示查看更多
        if type != .InfoDetailNoMore {
            resultHeight = resultHeight + HTAdapter.suitW(44)
        }
        return resultHeight
    }
    //MARK: -----------  模板内容高度 ------------
    private func templateInfoDetailHeight(_ width: Double = 0.0) -> CGFloat {
        let contentWidth: Double = viewLabelContentWidth(width)
        var resultHeight: CGFloat = HTAdapter.suitW(10)
        /// 主标题
        if firstHead != "" {
            let titleHeight: CGFloat = labelHeight(content: firstHead, width: contentWidth, font: titleFont)
            resultHeight = resultHeight + titleHeight
        }
        /// 副标题
        if secondHead?.content != "" {
            let content: String = getHyperLinkTemplateContent(secondHead?.content)
            let detailHeight: CGFloat = labelHeight(content: content, width: contentWidth, font: descriptionFont)
            resultHeight = resultHeight + HTAdapter.suitW(8) + detailHeight
        }
        /// 表项
        if form?.content != "" {
            let content: String = getHyperLinkTemplateContent(form?.content)
            let detailHeight: CGFloat = labelHeight(content: content, width: contentWidth, font: descriptionFont)
            resultHeight = resultHeight + HTAdapter.suitW(8) + detailHeight
        }
        resultHeight = resultHeight + HTAdapter.suitW(8)
        /// 是否显示查看更多
        if buttonList.count > 0 {
            var btnCount: Int = buttonList.count
            btnCount = (btnCount % 2 == 1) ? (1 + btnCount / 2) : btnCount / 2
            resultHeight = resultHeight + HTAdapter.suitW(44) * CGFloat(btnCount)
        }
        return resultHeight
    }

    private func infoQuestionHeight() -> CGFloat {
        let contentWidth: Double = viewLabelContentWidth()
        var titleHeight: CGFloat = 0
        if head != "" {
            titleHeight = descriptionFont.HTAppSize(of: head, constrainedToWidth: contentWidth).height + HTAdapter.suitW(8)
        }
        let totalHeight: CGFloat = questionTemplateHeight()
        return HTAdapter.suitW(10) + titleHeight + totalHeight
    }
    
    private func labelHeight(content: String, width: Double, font: UIFont) -> CGFloat {
        let attrString = NSMutableAttributedString.init(string: content);
        let paragrapStyle = NSMutableParagraphStyle()
        paragrapStyle.lineSpacing = 5
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragrapStyle, range: NSRange.init(location: 0, length: content.count))
        attrString.addAttribute(NSAttributedString.Key.font, value: font, range: NSRange.init(location: 0, length: content.count))
        let height: CGFloat = TTTAttributedLabel.sizeThatFitsAttributedString(attrString, withConstraints: CGSize.init(width: width, height: Double(MAXFLOAT)), limitedToNumberOfLines: 0).height
        return height
    }
}


