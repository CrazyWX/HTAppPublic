//
//  HTAPIMDataSource.swift
//  HTOA
//
//  Created by 王霞 on 2021/7/23.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import RongIMKit

class HTAPIMUserManager: NSObject, RCIMUserInfoDataSource{
    
    static let shared: HTAPIMUserManager = {
        return HTAPIMUserManager()
    }()
    weak var userInfoDataSource: HTAPServiceDataSource? = nil
}

extension HTAPIMUserManager {
    
    func getUserInfo(withUserId userId: String!, completion: ((RCUserInfo?) -> Void)!) {
        if let del = userInfoDataSource {
            del.getUserInfo?(withUserId: userId, completion: completion)
        }
    }
        
    func getUserInfo(withUserId userId: String!, inGroup groupId: String!, completion: ((RCUserInfo?) -> Void)!) {
        
    }
        
    func RCIMConnect(_ token:String,
                            success: @escaping (_ userID: String) -> Void,
                            tokenInConnect: @escaping () -> Void,
                            failure: @escaping (_ code:Int, _ msg:String) -> Void) {
        
        RCIM.shared().connect(withToken: token, success: { (userID) in
            success(userID ?? "")
        }, error: { (status) in
            failure(status.rawValue, "\(status)")
        }, tokenIncorrect: tokenInConnect)
    }
    
    /// 获取IM 的token
    func getCurrentUserToken(_ complete: @escaping (_ imToken:String) -> Void, failure: @escaping (_ code:Int, _ msg:String) -> Void) {
        if let del = userInfoDataSource {
            del.getCurrentUserToken?(complete, failure: failure)
        }
    }
}
