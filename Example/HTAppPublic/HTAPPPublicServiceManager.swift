//
//  HTAPPPublicServiceManager.swift
//  HTOA
//
//  Created by 王霞 on 2021/4/26.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import SwiftyJSON
import HTAppPublic
import RongIMKit

public class HTAPPPublicServiceManager: NSObject, HTAppPublicServiceDelegate, HTAPServiceDataSource {
    static var shared: HTAPPPublicServiceManager = HTAPPPublicServiceManager()
    
    override init() {
        super.init()
        configCellManager()
    }
    
    func configCellManager() {
        let shared = HTAppPublicServiceCellManager.shared
        shared.hrefContentClickActionBlock = { (hrefType, hyperLink, hyperName, secret) in
            if hrefType == 1, hyperLink != "" { // H5
                print("-----> 我是url连接：\(hyperLink)")
            } else if hrefType == 2 { // 原生
                print("-----> 我是原生接口：\(hyperLink)")
                /*/// 以下是调用的方法和规则：
                var urlComponents: [String: AnyObject]?
                if #available(iOS 10.2, *) {
                    urlComponents = hyperLink.HTurlParameters
                } else {
                    // Fallback on earlier versions
                }
                let typeId: String = (hyperLink as NSString).substring(to: (hyperLink as NSString).range(of: "?").location)
                let type = typeId.HTtoInt() ?? 0
                if let urlParam = urlComponents { // 各个参数
                    
                }*/
            } else if hrefType == 4 { // esb接口
                print("-----> 我是esb接口：\(hyperLink)")
                /*/// 以下是调用的方法和规则：
                let userId: String = HTAppPublicServiceCommonManager.shared.userId
                let officialAccountId: String = HTAppPublicServiceCommonManager.shared.targetId
                //时间戳
                let timestamp: String = "\(Int(Date().timeIntervalSince1970 * 1000))"
                //8位随机数
                let random: String = "\(Int(arc4random_uniform(89999999) + 10000000))"
                let secret: String = secret
                //md5方式生成，md5(userId+officialAccountId+timestamp+random+secret)
                var token: String = userId + officialAccountId
                token = token + timestamp
                token = token + random
                token = token + secret
                token = token.md5()
                let headers: HTTPHeaders = [
                    "userId": userId,
                    "officialAccountId": officialAccountId,
                    "timestamp":timestamp,
                    "random":random,
                    "token":token
                ]
                Alamofire.request(hyperLink, method: .get, parameters: [:], encoding: URLEncoding.default, headers: headers).response { response in
                    guard  response.error == nil else {
                        if let error = response.error as NSError? {
                            if error.code == NSURLErrorNotConnectedToInternet {
                                currentVc.failure(code: -1, msg: "网络连接失败，请稍后再试")
                            }else if error.code == NSURLErrorTimedOut {
                                currentVc.failure(code: -1, msg: "网络超时")
                            }else {
                                currentVc.failure(code: -1, msg: "请求失败，请稍后再试")
                            }
                        }
                        return
                    }
                    
                    if let data = response.data , let json = try? JSON(data: data){
                        if (json["code"].intValue == 0){
                        }else{
                            currentVc.failure(code: json["code"].intValue, msg: json["msg"].stringValue)
                        }
                    }else{
                        currentVc.failure(code: -1, msg: "数据解析失败")
                    }
                }*/
            }
        }
        shared.attributedLabelDidSelectedLink = { (url) in
            print("-----> 我是超链接：\(url)")
        }
        shared.shareToWechatBlock = { (title, content, thumbNail, fileUrl) in
            print("-----> 我是分享到微信")
            /*Share.Instrance.shareToWechat(title, content: content, thumbNail: thumbNail, fileUrl: fileUrl, success: { (response) in
                
            }) { (errorMsg) in
                
            }*/
        }
    }
    //MARK: -
    static func goToAppPublicServiceController(_ targetId: String = "123456",
                                               _ conversationType: RCConversationType = .ConversationType_APPSERVICE,
                                               _ conversationTitle: String = "小钉助手",
                                               success : @escaping () -> Void,
                                               failure : @escaping (_ code:Int, _ msg:String) -> Void) {
        HTAPPPublicServiceManager.shared.goToViewController(targetId, conversationType, conversationTitle)
    }
    func goToViewController(_ targetId: String = "123456",
                            _ conversationType: RCConversationType = .ConversationType_APPSERVICE,
                                   _ conversationTitle: String) {
        if let currentVc = HTAPCurrentViewController() {
            RCIMClient.shared()?.clearMessagesUnreadStatus(conversationType, targetId: targetId)
            let conversationVC = PublicServiceViewController()
            conversationVC.conversationType = conversationType
            conversationVC.targetId = targetId
            conversationVC.chatTitle = conversationTitle
            conversationVC.displayUserNameInCell = false
            conversationVC.delegate = self
            /*/// 设置公众号的聊天背景图
            let waterMaskText = "我是水印"
            conversationVC.waterMaskImage = nil
 */
            currentVc.navigationController?.pushViewController(conversationVC, animated: true)
            /// 当前公众号的id和name
            HTAppPublicServiceCommonManager.shared.targetId = targetId
            HTAppPublicServiceCommonManager.shared.targetName = conversationTitle
            /// 当前登录账号的id和name
            HTAppPublicServiceCommonManager.shared.userId = "49112"
            HTAppPublicServiceCommonManager.shared.userName = "王霞"
        }
    }
    // MARK: - 导航栏右侧按钮
    public func naviBarRightButtonTitle(_ targetId: String) -> String? {
        return nil
    }
    public func naviBarRightButtonAction() {
    }

    // MARK: - 底部view
    public func appPublicServiceBottomView(_ targetId: String) -> UIView? {
        return nil
    }
    
    // MARK: - 头部view
    public func appPublicServiceHeaderView() -> UIView? {
        return nil
    }
    
    public func appPublicServiceRefreshNoticeHeader(_ targetId: String, _ topView: UIView) {
    }
    
    public func scrollViewWillBeginDragging() {
    }
    // MARK: - 点击url跳转到h5
    public func appPublicServiceTapUrl(_ urlString: String?) {
        print("-----> 跳转h5")
    }
    // MARK: - 输入框上按钮的数据源以及点击事件
    public func publicServiceMenuList() -> [RCPublicServiceMenuItem] {
        var menuList: [RCPublicServiceMenuItem] = []
//        menuContainerList.forEach { (model) in
//            let menu: RCPublicServiceMenuItem = RCPublicServiceMenuItem.init()
//            menu.id = "\(model.id)"
//            menu.name = model.name
//            menu.url = model.url
//            menu.type = .PUBLIC_SERVICE_MENU_ITEM_CLICK
//            menuList.append(menu)
//        }
        return menuList
    }

    public func appPublicServiceMenuDidSeleted(_ menuId: NSInteger) {
    }
    // MARK: - 分享
    public func appPublicServiceShareTitle() -> String? {
        return "我是分享名字"
    }
    // MARK: -
    public func pluginBoardView(_ tag: NSInteger) -> ObjCBool {
        if tag == 1006 { // 文件列表
            return false
        }
        return false
    }
    /* 可以自定义可以实现 (暂不支持)
    func doubleTapTextMessage(_ content: String) {
        guard let currentVc = UIViewController.currentViewController() else {
            return
        }
        let imText = IMTextViewController()
        imText.text = content
        currentVc.present(viewController: imText)
    }*/
    /* 可以自定义可以实现
    func presentImagePreviewController(_ model: RCMessageModel!) {
        guard let currentVc = UIViewController.currentViewController() else {
            return
        }
        let imageViewController = IMImageViewController()
        imageViewController.messageModel = model
        currentVc.present(viewController: imageViewController)
    }
    */
    /// 获取当前登录人的用户信息
    public func getUserInfo(withUserId userId: String!, completion: ((RCUserInfo?) -> Void)!) {
        let user = RCUserInfo()
        user.userId = "49112"
        user.name = "王霞"
        user.portraitUri = "http://htwuhan.oss-cn-beijing.aliyuncs.com/751bac9e77c340148f242b9e0c7ae91c.jpg"
//        RCDataBaseManager.shareInstance()?.insertUser(toDB: user)
        completion(user)
    }
    /// 获取IM 的token
    public func getCurrentUserToken(_ complete: @escaping (_ imToken:String) -> Void, failure: @escaping (_ code:Int, _ msg:String) -> Void) {
        let rcUser = RCUserInfo(userId: "49112" , name: "王霞", portrait: "http://htwuhan.oss-cn-beijing.aliyuncs.com/751bac9e77c340148f242b9e0c7ae91c.jpg")
        RCIM.shared()?.refreshUserInfoCache(rcUser, withUserId: "49112")
        RCIM.shared()?.currentUserInfo = rcUser
//        RCDataBaseManager.shareInstance()?.insertUser(toDB: rcUser)
        complete("LdEfTRPQTpxGSqHACSG7adctZK2+iweElodzluV88Gc=@ugjz.cn.rongnav.com;ugjz.cn.rongcfg.com")
    }
}
