//
//  HTAppPublicStringExt.swift
//  GDCA
//
//  Created by 余藩 on 2017/2/27.
//  Copyright © 2017年 CA. All rights reserved.
//

import UIKit
//import CryptoSwift
public extension String {
    
    //字符串为空检查
    var HTisEmptyString: Bool {
        get {
            if self == "<null>" || self == "null" || self == "(null)"{
                return true
            }
            return self.isEmpty
        }
    }
    
    //NSRange 转 range
    func HTtoRange(_ range: NSRange) -> Range<String.Index>? {
        guard let from16 = utf16.index(utf16.startIndex, offsetBy: range.location, limitedBy: utf16.endIndex) else { return nil }
        guard let to16 = utf16.index(from16, offsetBy: range.length, limitedBy: utf16.endIndex) else { return nil }
        guard let from = String.Index(from16, within: self) else { return nil }
        guard let to = String.Index(to16, within: self) else { return nil }
        return from ..< to
    }
    
    func HTtoInt() -> Int? {
        let scanner = Scanner(string: self)
        var u: Int = 0
        if scanner.scanInt(&u)  && scanner.isAtEnd {
            return Int(u)
        }
        return 0
    }
    //将原始的url编码为合法的url
    func HTurlEncoded() -> String {
      let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
          .urlQueryAllowed)
      return encodeUrlString ?? ""
    }

    //将编码后的url转换回原始的url
    func HTurlDecoded() -> String {
      return self.removingPercentEncoding ?? ""
    }
    
    func ranges(of string: String) -> [Range<String.Index>] {
        var rangeArray = [Range<String.Index>]()
        var searchedRange: Range<String.Index>
        guard let sr = self.range(of: self) else {
            return rangeArray
        }
        searchedRange = sr
        
        var resultRange = self.range(of: string, options: .caseInsensitive, range: searchedRange, locale: nil)
        while let range = resultRange {
            rangeArray.append(range)
            searchedRange = Range(uncheckedBounds: (range.upperBound, searchedRange.upperBound))
            resultRange = self.range(of: string, options: .caseInsensitive, range: searchedRange, locale: nil)
        }
        return rangeArray
    }
    func nsrange(fromRange range : Range<String.Index>) -> NSRange {
        return NSRange(range, in: self)
    }
    func nsranges(of string: String) -> [NSRange] {
        return ranges(of: string).map { (range) -> NSRange in
            self.nsrange(fromRange: range)
        }
    }
    /// 从String中截取出参数
    var HTurlParameters: [String: AnyObject]? {
            // 截取是否有参数
        guard let urlComponents = NSURLComponents(string: self), let queryItems = urlComponents.queryItems else {
                return nil
            }
            // 参数字典
            var parameters = [String: AnyObject]()

            // 遍历参数
            queryItems.forEach({ (item) in
                parameters[item.name] = item.value as AnyObject?
            })

            return parameters
        }
}

extension String {
    //返回字数
    var HTcount: Int {
        let string_NS = self as NSString
        return string_NS.length
    }
}
