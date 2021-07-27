//
//  IMTextViewController.swift
//  HTOA
//
//  Created by 余藩 on 2019/2/22.
//  Copyright © 2019 Personal. All rights reserved.
//

import UIKit

public class IMTextViewController: UIViewController {

    public var text = "" {
        didSet {
            textView.text = text
        }
    }
    
    let textView = UITextView().HTSon {
        $0.font = UIFont.HTAppRegularFont(with: HTAdapter.adjustFont(24))
        $0.textColor = UIColor.black
        $0.isEditable = false
    }
    
    var height:CGFloat! {
        let tHeight = UIFont.HTAppRegularFont(with: HTAdapter.adjustFont(24)).HTAppSize(of: text, constrainedToWidth: Double(kHTScreenWidth - HTAdapter.suitW(30))).height + 5
        if tHeight < kHTScreenHeight {
            return tHeight
        }else {
            return kHTScreenHeight
        }
    }
    
    public override func viewDidLoad() {
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
        self.dismiss(animated: true, completion: nil)
    }
}
