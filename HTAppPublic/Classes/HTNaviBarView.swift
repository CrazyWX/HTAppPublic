//
//  HTNaviBarView.swift
//  HTOA
//
//  Created by 王霞 on 2021/7/23.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import SnapKit

@objcMembers class HTNaviBarView: UIView {

    let kPadding : CGFloat = 15
    
    var rightSubItem: UIView?
    
    var rightSubBadgeView : UIView?
    
    var leftButtonLabel : UILabel?
    
    var items = [UIView]()
    
    var centerItem : UIView!
    
    var leftItem   : UIView?
    
    var leftItems : [UIView] = []
    
    var rightItem  : UIView?
    
    var centerTitleColor = HTUIColorFromRGB(rgbValue: 0x373d46)
    
    var sepLineColor = HTTheme.backgroundColor {
        didSet {
            setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        
        centerItem = UILabel()
        addSubview(centerItem)
        updateCenterItemConstraints()
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //分割线
    override func draw(_ rect: CGRect) {
        let context : CGContext = UIGraphicsGetCurrentContext()!;
        context.setLineWidth(1.0)
        UIGraphicsGetCurrentContext()!.setStrokeColor(sepLineColor.cgColor)
        UIGraphicsGetCurrentContext()!.beginPath()
        context.move(to: CGPoint(x: 0, y: self.bounds.height))
        context.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height))
        UIGraphicsGetCurrentContext()!.closePath()
        context.strokePath()
    }
    
    func configureLeftButton(image : UIImage?){
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setImage(image, for: UIControl.State.normal)
        button.accpetEventInterval = 0.8
        configureLeftButton(button: button)
    }
    
    func configureLeftButton(text : String, textColor: UIColor = HTTheme.aTextColor, font: UIFont = UIFont.HTAppRegularFont(with: 16)){
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setTitle(text, for:UIControl.State.normal)
        button.accpetEventInterval = 0.8
        configureLeftButton(button: button, textColor: textColor, font: font)
    }
    
    func configureLeftButton(text : String, image : UIImage?){
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setTitle(text, for:UIControl.State.normal)
        button.setImage(image, for: UIControl.State.normal)
        button.accpetEventInterval = 0.8
        configureLeftButton(button: button)
    }
    
    func configureLeftButtons(image: UIImage?, text1: String, text2: String) {
        let button1 = UIButton(type: .custom)
        button1.setTitle(text1, for: .normal)
        button1.setImage(image, for: .normal)
        button1.accpetEventInterval = 0.8
        let button2 = UIButton(type: .custom)
        button2.setTitle(text2, for: .normal)
        button2.accpetEventInterval = 0.8
        configureLeftButtons(button1: button1, button2: button2)
    }
    
    func configureRightButton(image : UIImage?){
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setImage(image, for: .normal)
        button.accpetEventInterval = 0.8
        configureRightButton(button: button)
    }
    
    func configureRightButton(text : String, _ textColor: UIColor = HTTheme.btnColor){
        let button = UIButton(type: UIButton.ButtonType.system)
        button.setTitle(text, for: UIControl.State.normal)
        button.accpetEventInterval = 0.8
        configureRightButton(button: button, textColor)
    }
    
    func addLeftButtonTarget(target: AnyObject?, action: Selector, forControlEvents controlEvents: UIControl.Event){
        (leftItem as? UIButton)?.addTarget(target, action: action, for: controlEvents)
    }
    func addLeftButtonsTarget(target: AnyObject?, action1: Selector, action2: Selector) {
        (leftItems[0] as? UIButton)?.addTarget(target, action: action1, for: .touchUpInside)
        (leftItems[1] as? UIButton)?.addTarget(target, action: action2, for: .touchUpInside)
    }
    
    func addRightButtonTarget(target: AnyObject?, action: Selector, forControlEvents controlEvents: UIControl.Event){
        (rightItem as? UIButton)?.addTarget(target, action: action, for: controlEvents)
    }
    
    func addCenterButtonTarget(target: AnyObject?, action: Selector, forControlEvents controlEvents: UIControl.Event){
        (centerItem as? UIButton)?.addTarget(target, action: action, for: controlEvents)
    }
    
    func configureRightSubItem(withImage image: UIImage?){
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setImage(image, for: UIControl.State.normal)
        button.accpetEventInterval = 0.8
        configureRightSubButton(button: button)
        
    }
    
    func configureRightSubItem(withTarget target: AnyObject?, action: Selector, forControlEvents controlEvents: UIControl.Event){
        (rightSubItem as? UIButton)?.addTarget(target, action: action, for: controlEvents)
    }
    
    func configureCenterTitle(title : String){
        let button = UIButton(type: UIButton.ButtonType.system)
        button.setTitle(title, for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.HTAppRegularFont(with: 17)
        button.isUserInteractionEnabled = false
        configureCenterButton(button: button)
    }
    
    func showBadgeOnRighSubItem() {
        self.rightSubBadgeView?.isHidden = false
    }
    
    func hiddenBadgeOnRightSubItem() {
        self.rightSubBadgeView?.isHidden = true
    }
    
    func configureCenterItem(item : UIView){
        centerItem.removeFromSuperview()
        centerItem = item
        addSubview(item)
        updateCenterItemConstraints()
    }
    
    func centerTitle()->String {
        if let centerBtn = (centerItem as? UIButton) {
            return centerBtn.titleLabel?.text ?? ""
        }
        return ""
    }
}
extension HTNaviBarView {
    
    func configureLeftButton(button : UIButton, textColor: UIColor = HTTheme.aTextColor, font: UIFont = UIFont.regularFont(with: 16)){
        leftItem?.removeFromSuperview()
        leftItem = button
        addSubview(button)
        button.titleLabel?.font = font
        button.setTitleColor(textColor, for: UIControl.State.normal)
        button.snp.makeConstraints { (make) in
            make.centerY.equalTo(self).offset(UIDevice().HTisIphoneX() ? 15 : 10)
            if button.titleLabel?.text?.count == nil {
                make.leading.equalTo(self)
            }else {
                make.leading.equalTo(self).offset(15)
            }
            if button.titleLabel?.text?.count == nil {
                if button.bounds.height < CGFloat(44) && button.bounds.width < CGFloat(44) {
                    make.size.equalTo(CGSize(width: 44, height: 44)).priority(1000)
                }
            }
        }
        updateCenterItemConstraints()
    }
    
    func configureLeftButtons(button1: UIButton, button2: UIButton) {
        leftItems = []
        leftItems.append(button1)
        addSubview(button1)
        button1.titleLabel?.font = UIFont.HTAppRegularFont(with: 16)
        button1.setTitleColor(HTUIColorFromRGB(rgbValue: 0x007AFF), for: UIControl.State.normal)
        button1.snp.makeConstraints { (make) in
            make.centerY.equalTo(self).offset(UIDevice().HTisIphoneX() ? 15 : 10)
            if button1.titleLabel?.text?.count == nil {
                make.leading.equalTo(self)
            }else {
                make.leading.equalTo(self).offset(15)
            }
            if button1.titleLabel?.text?.count == nil {
                if button1.bounds.height < CGFloat(44) && button1.bounds.width < CGFloat(44) {
                    make.size.equalTo(CGSize(width: 44, height: 44)).priority(1000)
                }
            }
        }
        leftItems.append(button2)
        addSubview(button2)
        button2.titleLabel?.font = UIFont.HTAppRegularFont(with: 16)
        button2.setTitleColor(HTUIColorFromRGB(rgbValue: 0x007AFF), for: UIControl.State.normal)
        button2.snp.makeConstraints { (make) in
            make.centerY.equalTo(button1)
            make.size.equalTo(button1)
            make.leading.equalTo(button1.snp.trailing).offset(10)
        }
        updateCenterItemConstraints()
    }
    
    func configureCenterButton(button : UIButton){
        centerItem?.removeFromSuperview()
        centerItem = button
        addSubview(button)
        button.titleLabel?.font = UIFont.HTAppMediumFont(with: 18.5)
        button.setTitleColor(centerTitleColor, for: UIControl.State.normal)
        updateCenterItemConstraints()
    }
    
    func configureRightButton(button : UIButton, _ btnColor: UIColor = HTTheme.btnColor){
        rightItem?.removeFromSuperview()
        rightItem = button
        addSubview(button)
        button.titleLabel?.font = UIFont.HTAppRegularFont(with: 16)
        button.setTitleColor(btnColor, for: UIControl.State.normal)
        button.snp.makeConstraints { (make) in
            make.centerY.equalTo(self).offset(UIDevice().HTisIphoneX() ? 15 : 10)
            let image = button.image(for: UIControl.State.normal)
            if image != nil {
                if image!.size.height < CGFloat(44) && image!.size.width < CGFloat(44) {
                    make.size.equalTo(CGSize(width: 44, height: 44)).priority(1000)
                } else {
                    if button.bounds.height < CGFloat(44) && button.bounds.width < CGFloat(44) {
                        make.size.equalTo(CGSize(width: 44, height: 44)).priority(1000)
                    }else {
                        make.size.equalTo(button.bounds.size).priority(1000)
                    }
                }
                make.trailing.equalTo(self).offset(-10)
            }else {
                make.trailing.equalTo(self).offset(-15)
            }
            
        }
        updateCenterItemConstraints()
    }
    
    func configureRightSubButton(button : UIButton){
        if rightItem == nil {
            configureRightButton(button: button)
        }else {
            rightSubItem?.removeFromSuperview()
            rightSubItem = button
            addSubview(button)
            button.titleLabel?.font = UIFont.HTAppDynamicMediumFont(with: 12)
            button.setTitleColor(HTUIColorFromRGB(rgbValue: 0x373d46), for: UIControl.State.normal)
            button.snp.makeConstraints({ (make) in
                make.centerY.equalTo(self).offset(UIDevice().HTisIphoneX() ? 15 : 10)
                if button.bounds.height < CGFloat(44) && button.bounds.width < CGFloat(44) {
                    make.size.equalTo(CGSize(width: 44, height: 44)).priority(1000)
                }else {
                    make.size.equalTo(button.bounds.size).priority(1000)
                }
                make.trailing.equalTo(self.rightItem!.snp.leading)
                
            })
            updateCenterItemConstraints()
        }
    }
    
    func updateCenterItemConstraints(){
        centerItem.snp.remakeConstraints { (make) in
            make.centerY.equalTo(self).offset(UIDevice().HTisIphoneX() ? 15 : 10)
            make.centerX.equalTo(self).priority(250)
            if leftItem == nil {
                make.leading.greaterThanOrEqualTo(self).offset(kPadding)
            }else {
                make.leading.greaterThanOrEqualTo(self.leftItem!.snp.trailing).offset(5)
            }
            if rightSubItem == nil {
                if rightItem == nil {
                    make.trailing.lessThanOrEqualTo(self).offset(-kPadding)
                }else {
                    make.trailing.lessThanOrEqualTo(self.rightItem!.snp.leading).offset(-5)
                }
            }else {
                make.trailing.lessThanOrEqualTo(self.rightSubItem!.snp.leading).offset(-5)
            }
        }
    }
}
