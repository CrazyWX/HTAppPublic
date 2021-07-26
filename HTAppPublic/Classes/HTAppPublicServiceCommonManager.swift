//
//  HTAppPublicServiceCommonManager.swift
//  HTOA
//
//  Created by 王霞 on 2021/7/21.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import RongIMKit
import RongIMLib
import AudioToolbox

class HTAppPublicServiceCommonManager: NSObject {
    static let shared: HTAppPublicServiceCommonManager = HTAppPublicServiceCommonManager()
    
    var targetName: String = ""
    var targetId: String = ""
    var userId: String = ""
    var userName: String = ""
    private var targetIdList: [String] = []

    public func addTargetId(_ id: String) {
        if targetIdList.contains(id) == false {
            targetIdList.append(id)
        }
    }
    
    private func clear() {
        targetId = ""
        targetName = ""
        targetIdList.removeAll()
        userId = ""
        userName = ""
    }

    static func clearCacheAndToken() {
        HTAppPublicServiceCommonManager.shared.targetIdList.forEach { (id) in
            RCIMClient.shared()?.clearMessagesUnreadStatus(.ConversationType_APPSERVICE, targetId: id)
        }
        HTAppPublicServiceCommonManager.shared.clear()
        RCDataBaseManager.shareInstance()?.clearFriendsData()
        RCDataBaseManager.shareInstance()?.closeDBForDisconnect()
        RCIMClient.shared()?.logout()
    }
    
    var currentUserInfo: RCUserInfo? {
        get {
            return RCIM.shared()?.currentUserInfo
        }
    }
    
    var rcimIsConnect: Bool {
        get {
            if RCIM.shared()?.getConnectionStatus() == RCConnectionStatus.ConnectionStatus_NETWORK_UNAVAILABLE || RCIM.shared()?.getConnectionStatus() == RCConnectionStatus.ConnectionStatus_Unconnected {
                return false
            }
            return true
        }
    }
    
    func configureRCIM(rongYunKey: String, groupDataSource: NSObject?, userInfoDataSource: HTAPServiceDataSource) {
        RCIM.shared().initWithAppKey(rongYunKey)
        
        // IMKit连接状态的监听器
        RCIM.shared()?.connectionStatusDelegate = self
        // 开启用户信息和群组信息的持久化
        RCIM.shared()?.enablePersistentUserInfoCache = true
        // 设置接收消息代理
        RCIM.shared()?.receiveMessageDelegate = self
        // 开启输入状态监听
        RCIM.shared()?.enableTypingStatus = true
        // 开启发送已读回执
        RCIM.shared()?.enabledReadReceiptConversationTypeList = [RCConversationType.ConversationType_PRIVATE.rawValue,
                                                                 RCConversationType.ConversationType_GROUP.rawValue,
                                                                 RCConversationType.ConversationType_APPSERVICE.rawValue,
                                                                 RCConversationType.ConversationType_DISCUSSION.rawValue]
        
        HTAPIMUserManager.shared.userInfoDataSource = userInfoDataSource
        RCIM.shared()?.userInfoDataSource = HTAPIMUserManager.shared
        if let dataSource = groupDataSource {
            RCIM.shared()?.groupInfoDataSource = dataSource as? RCIMGroupInfoDataSource
            RCIM.shared()?.groupMemberDataSource = dataSource as? RCIMGroupMemberDataSource
        }
        
        //会话列表会话的头像样式
        RCIM.shared()?.globalConversationAvatarStyle = .USER_AVATAR_CYCLE
        //会话的头像样式
        RCIM.shared()?.globalMessageAvatarStyle = .USER_AVATAR_CYCLE
        // 开启多端未读状态同步
        RCIM.shared()?.enableSyncReadStatus = true
        // 开启消息@功能（只支持群聊和讨论组, App需要实现群成员数据源groupMemberDataSource）
        RCIM.shared()?.enableMessageMentioned = true
        // 开启消息撤回功能
        RCIM.shared()?.enableMessageRecall = true
        //   设置优先使用WebView打开URL
        RCIM.shared()?.embeddedWebViewPreferred = false
//        RCIM.shared().showUnkownMessageNotificaiton = true
        // 开发阶段打印详细log
        RCIMClient.shared().logLevel = RCLogLevel.log_Level_Info
        //合并转发功能
        RCIM.shared().enableSendCombineMessage = true
//        RCIM.shared()?.isMediaSelectorContainVideo = true
        // 阅后即焚属性
        RCIM.shared()?.enableBurnMessage = false
        RCIM.shared()?.globalNavigationBarTintColor = HTTheme.aTextColor
        
//        RCIM.shared()?.registerMessageType(IMCustomModel.classForCoder())
        NotificationCenter.default.addObserver(self, selector: #selector(handleNoti), name: Notification.Name.RCKitDispatchMessage, object: nil)
        
        connetIMServer()
    }
    public func applicationWillResignActive(_ application: UIApplication) {
        let status = RCIMClient.shared()?.getConnectionStatus()
        if !(status == RCConnectionStatus.ConnectionStatus_SignUp) {
            let unreadMsgCount: Int = getRCIMClientUnReadCount()
            application.applicationIconBadgeNumber = unreadMsgCount
        }
    }

}

extension HTAppPublicServiceCommonManager: RCIMConnectionStatusDelegate, RCIMReceiveMessageDelegate {
    func RCIMDisplayConversationTypes() -> [UInt] {
        return [RCConversationType.ConversationType_PRIVATE.rawValue,
        RCConversationType.ConversationType_DISCUSSION.rawValue,
        RCConversationType.ConversationType_GROUP.rawValue,
        RCConversationType.ConversationType_CHATROOM.rawValue,
        RCConversationType.ConversationType_CUSTOMERSERVICE.rawValue,
        RCConversationType.ConversationType_SYSTEM.rawValue,
        RCConversationType.ConversationType_APPSERVICE.rawValue]
    }

    func getRCIMClientUnReadCount() -> Int {
        var count: Int = 0
        let type = self.RCIMDisplayConversationTypes()
        if let unreadMsgCount = RCIMClient.shared()?.getUnreadCount(type) {
            count = Int(max(0, unreadMsgCount))
        }
        return count
    }
    
    func connetIMServer() {
        HTAPIMUserManager.shared.getCurrentUserToken({ (imToken) in
            HTAPIMUserManager.shared.RCIMConnect(imToken, success: { (userID) in
                print("userID: \(userID).........")
                HTAPIMUserManager.shared.getUserInfo(withUserId: userID, completion: { (userInfo) in

                })
            }, tokenInConnect: {
                print("token过期或者不正确,")
                
            }) { (code, msg) in
                print("code:\(code)....msg:\(msg)..")
            }
        }) { (code, msg) in
            
        }
    }
    
    func onRCIMConnectionStatusChanged(_ status: RCConnectionStatus) {
        if status == RCConnectionStatus.ConnectionStatus_TOKEN_INCORRECT {
            connetIMServer()
        }
    }
    
    @objc func handleNoti(_ noti:Notification) {
        if noti.name == Notification.Name.RCKitDispatchMessage {
            if let left = noti.userInfo?["left"] as? Int {
                if RCIMClient.shared()?.sdkRunningMode == RCSDKRunningMode.background && left == 0 {
                    let unreadMsgCount: Int = getRCIMClientUnReadCount()
                    DispatchQueue.main.async {
                        UIApplication.shared.applicationIconBadgeNumber = unreadMsgCount
                    }
                }
            }
        }
    }
    
    func onRCIMReceive(_ message: RCMessage!, left: Int32) {
        DispatchQueue.main.async {
            let applicationState: UIApplication.State = UIApplication.shared.applicationState
            if applicationState == .active {/// "前台"
                /// 震动
                //        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                /// 震动+声音
                AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate) {
                }
            }
        }
    }
}
