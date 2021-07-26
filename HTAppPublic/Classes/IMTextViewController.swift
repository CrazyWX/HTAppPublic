//
//  IMTextViewController.swift
//  HTOA
//
//  Created by 余藩 on 2019/2/22.
//  Copyright © 2019 Personal. All rights reserved.
//

import UIKit

class IMTextViewController: UIViewController {

    var text = "" {
        didSet {
            textView.text = text
        }
    }
    
    let textView = UITextView().son {
        $0.font = UIFont.HTAppRegularFont(with: HTAdapter.adjustFont(24))
        $0.textColor = UIColor.black
        $0.isEditable = false
    }
    
    var height:CGFloat! {
        let tHeight = UIFont.HTAppRegularFont(with: HTAdapter.adjustFont(24)).size(of: text, constrainedToWidth: Double(kHTScreenWidth - HTAdapter.suitW(30))).height + 5
        if tHeight < kHTScreenHeight {
            return tHeight
        }else {
            return kHTScreenHeight
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubview()
    }

    func configureSubview() {
        view.backgroundColor = HTTheme.whiteBackColor
        view.addSubview(textView)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapTextView)))
        textView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapTextView)))
        textView.snp.makeConstraints { (make) in
            make.center.equalTo(view)
            make.width.equalTo(kHTScreenWidth - HTAdapter.suitW(30))
            make.height.equalTo(height)
        }
    }

    @objc func tapTextView() {
        self.dismissViewController()
    }
}
