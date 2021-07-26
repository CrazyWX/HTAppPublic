//
//  HTSon_Protocol.swift
//  Personal
//
//  Created by 余藩 on 2017/9/29.
//  Copyright © 2017年 Personal. All rights reserved.
//

import UIKit

protocol HTSon {}

extension HTSon where Self: AnyObject {
    
    func HTSon(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
    
    func HTSon(_ block: () -> Void) -> Self {
        block()
        return self
    }
}
extension NSObject: HTSon {}
