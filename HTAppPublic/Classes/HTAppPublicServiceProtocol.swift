//
//  HTAppPublicServiceProtocol.swift
//  HTOA
//
//  Created by 王霞 on 2021/4/26.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import RongIMKit

@objc public protocol HTAppPublicServiceDelegate {
    @objc optional func naviBarRightButtonTitle(_ targetId: String) -> String?
    @objc optional func naviBarRightButtonImage(_ targetId: String) -> UIImage?
    @objc optional func naviBarRightButtonAction(_ targetId: String)
    @objc optional func appPublicServiceBottomView(_ targetId: String) -> UIView?
    @objc optional func appPublicServiceHeaderView() -> UIView?
    // 如果需要欢迎语，需要实现该方法
    // 出参字典的key保持不动：["appId":"","secret":"","interval":""]
    @objc optional func appWelcomMessageParam(_ targetId: String) -> [String:String]
    // 头部欢迎语的数据更新
    @objc optional func appPublicServiceRefreshNoticeHeader(_ targetId: String, _ topView: UIView)
    // 分享文件或者图片到微信时的title字段
    @objc optional func appPublicServiceShareTitle() -> String?
    // 点击输入框按钮
    @objc optional func appPublicServiceMenuDidSeleted(_ menuId: NSInteger)
    // 点击跳转h5
    @objc optional func appPublicServiceTapUrl(_ url: String?)
    @objc optional func scrollViewWillBeginDragging()
    
    @objc optional func publicServiceMenuList() -> [RCPublicServiceMenuItem]
    @objc optional func pluginBoardView(_ tag: NSInteger) -> ObjCBool
//    @objc optional func doubleTapTextMessage(_ content: String)
    
    @objc optional func presentImagePreviewController(_ model: RCMessageModel!)
}

public class HTAppPublicServiceCellManager: NSObject {
    public static let shared: HTAppPublicServiceCellManager = HTAppPublicServiceCellManager()
    // 纯文本超链接 (非必实现)
    public var doOnlyTextHyperLinkActionBlock: ((URL)->())?
    // 文本里包含的超链接
    public var attributedLabelDidSelectedLink: ((URL)->())?
    // 查看详情卡片点击查看更多事件 (非必实现)
    public var showMoreActionBlock: ((PublicServiceModelType, String)->())?
    // 点击了跳转 （链接类型Int, 链接地址String, 名字String, 后台授权密钥String）
    public var hrefContentClickActionBlock: ((Int, String, String, String)->())?
    // 分享到微信
    public var shareToWechatBlock:((String, String, UIImage?, URL?)->())?
    // 旧版本：两个按钮情况
    public var infoMessageButtonClickAction: ((Int,Int)->())?
}

@objc public protocol HTAPServiceDataSource {
    @objc optional func getUserInfo(withUserId userId: String!, completion: ((RCUserInfo?) -> Void)!)
    /// 获取IM 的token
    @objc optional func getCurrentUserToken(_ complete: @escaping (_ imToken:String) -> Void, failure: @escaping (_ code:Int, _ msg:String) -> Void)
}
