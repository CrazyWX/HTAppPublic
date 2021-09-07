//
//  HTAppPublicNetwork.swift
//  HTAppPublic
//
//  Created by 王霞 on 2021/7/29.
//

import UIKit
import Alamofire
import SwiftyJSON

public class HTAppPublicNetwork: NSObject {
    static func urlRequestWithRawBody(urlString: String, rawBody: Data? = nil, headers: HTTPHeaders) -> URLRequestConvertible {
        
        var mutableURLRequest = URLRequest(url: URL(string: urlString)!)
        mutableURLRequest.httpMethod = "POST"
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers.forEach { (key, value) in
            mutableURLRequest.setValue(value, forHTTPHeaderField: key)
        }
        if let rawBody = rawBody {
            mutableURLRequest.httpBody = rawBody
        }
        mutableURLRequest.timeoutInterval = 20
        
        return try! Alamofire.URLEncoding().encode(mutableURLRequest, with: nil)
    }
    
    public static func apiRequest(_ url: String,
                            parameters: [String: Any]? = nil,
                            headers: HTTPHeaders,
                            timeOutHandle: (()->Void)? = nil,
                            notConnectInternet: (()->Void)? = nil,
                            completionHandler: @escaping ((JSON?, Error?) -> Void)) {
        
        var rawBody: Data? = nil
        if let parameters = parameters {
            let paramData = try? JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.prettyPrinted)
            rawBody =  paramData
        }
        let request = urlRequestWithRawBody(urlString: url, rawBody: rawBody, headers: headers)
        Alamofire.request(request).response { (response) in
            guard  response.error == nil else {
                if let error = response.error as NSError? {
                    if error.code == NSURLErrorNotConnectedToInternet {
                    }else if error.code == NSURLErrorTimedOut {
                        timeOutHandle?()
                    }else {
                        completionHandler(nil, response.error)
                    }
                }
                return
            }
            var json: JSON?
            if let data = response.data {
                json = try? JSON(data: data)
//                let jsonStr:String = String(data: data, encoding: String.Encoding.utf8)!
//                HTPrint("\(json ?? "")-------------fullURL:\(fullURL)++")
//                HTPrint("jsonStr: \(jsonStr)-------------fullURL:\(fullURL)++")
            }
//            Global.sharedInstance.networkStatus = .ViaWiFi
            completionHandler(json, response.error)
        }
    }

    public static func defaultESBMethod(hyperLink:String,userId:String,officialAccountId:String,secret:String) { // esb接口
        print("-----> 我是esb接口：\(hyperLink)")
        /// 以下是调用的方法和规则：
        //时间戳
        let timestamp: String = "\(Int(Date().timeIntervalSince1970 * 1000))"
        //8位随机数
        let random: String = "\(Int(arc4random_uniform(89999999) + 10000000))"
        //md5方式生成，md5(userId+officialAccountId+timestamp+random+secret)
        var token: String = userId + officialAccountId
        token = token + timestamp
        token = token + random
        token = token + secret
        token = token.md5()
        let headers: HTTPHeaders = [
            "userId": userId,
            "officialAccountCode": officialAccountId,
            "timestamp":timestamp,
            "random":random,
            "token":token
        ]
        Alamofire.request(hyperLink, method: .get, parameters: [:], encoding: URLEncoding.default, headers: headers).response { response in
            guard  response.error == nil else {
                if let error = response.error as NSError? {
                    if error.code == NSURLErrorNotConnectedToInternet {
                        print("网络连接失败，请稍后再试")
                    }else if error.code == NSURLErrorTimedOut {
                        print("网络超时")
                    }else {
                        print("请求失败，请稍后再试")
                    }
                }
                return
            }
            
            if let data = response.data , let json = try? JSON(data: data){
                if (json["code"].intValue == 0){
                }else{
                    print(json["msg"].stringValue)
                }
            }else{
                print("数据解析失败")
            }
        }
    }
}
