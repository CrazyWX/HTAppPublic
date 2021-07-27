//
//  HTAppPublicServiceCommon.swift
//  HTOA
//
//  Created by 王霞 on 2021/4/26.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit
import MBProgressHUD

public let kHTScreenBounds = UIScreen.main.bounds
public let kHTScreenSize   = kHTScreenBounds.size
public let kHTScreenWidth  = kHTScreenSize.width
public let kHTScreenHeight = kHTScreenSize.height

struct HTAdapter {
    
    static func configureButtonStyle(_ button:UIButton, title: String, titleFont: UIFont? = nil, titleColor: UIColor? = nil, bgColor: UIColor? = nil,borderColor:UIColor? = nil, target:Selector? = nil, targetItem: Any? = nil) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = titleFont
        button.setTitleColor(titleColor, for: .normal)
        button.backgroundColor = bgColor
        button.layer.borderColor = borderColor?.cgColor
        if let target = target {
            button.addTarget(targetItem, action: target, for: .touchUpInside)
        }
    }
    
    
    static func configureLabelStyle(_ label: UILabel, text:String? = nil, font: UIFont, textColor: UIColor? = nil, aligment: NSTextAlignment? = nil) {
        label.text = text ?? ""
        label.font = font
        label.textColor = textColor ?? UIColor.black
        label.textAlignment = aligment ?? .center
    }
    
    static func adjustFont(_ fontSize:CGFloat) ->CGFloat{
        var _fontSize:CGFloat = 0
        if (kHTScreenHeight == 667){
            _fontSize = fontSize
        }else if (kHTScreenHeight == 736){
            _fontSize = fontSize + 1
        }else if (kHTScreenHeight == 568){
            _fontSize = fontSize - 2
        }else{
            _fontSize = fontSize
        }
        return _fontSize
    }
    
    static func suitW(_ width:CGFloat) ->CGFloat {
        return kHTScreenWidth / 375 * width
    }
    
    static func suitH(_ height:CGFloat) -> CGFloat {
        return kHTScreenHeight / 667 * height
    }
    
    static func setShadow(_ view:UIView ,color:UIColor){
        view.layer.shadowColor = color.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 1.0
    }
}

struct HTTheme {
    
    static let btnColor = HTUIColorFromRGB(rgbValue: 0x4a88fb)
    
    static let whiteBackColor = HTUIColorFromRGB(rgbValue: 0xffffff)
    
    static let backgroundColor = HTUIColorFromRGB(rgbValue: 0xf6f7fb)
    
    static let lineColor = HTUIColorFromRGB(rgbValue: 0xeef1f6)
    
    static let aTextColor = HTUIColorFromRGB(rgbValue: 0x373d46)
    
    static let bTextColor = HTUIColorFromRGB(rgbValue: 0x8f9296)
    
    static let tagColor = HTUIColorFromRGB(rgbValue: 0xc1c2c5)
    
    static let redAssColor = HTUIColorFromRGB(rgbValue: 0xf16164)
    
    static let orgAssColor = HTUIColorFromRGB(rgbValue: 0xffba6d)
    
    static let greeAssColor = HTUIColorFromRGB(rgbValue: 0x46ae6e)
    
    static let cTextColor = HTUIColorFromRGB(rgbValue: 0x5c5e63)

}

extension UIFont {
    func HTAppSize(of string: String, constrainedToWidth width: Double) -> CGSize {
        return NSString(string: string).boundingRect(with: CGSize(width: width, height: Double.greatestFiniteMagnitude),
                                                     options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                     attributes: [NSAttributedString.Key.font: self],
                                                     context: nil).size
    }
    
    func HTAppSize(of string: String, constrainedToHeigh heigh: Double) -> CGSize {
        return NSString(string: string).boundingRect(with: CGSize(width: Double.greatestFiniteMagnitude, height: heigh),
                                                     options: NSStringDrawingOptions.usesFontLeading,
                                                     attributes: [NSAttributedString.Key.font: self],
                                                     context: nil).size
    }
    
    func HTAppSize(of string: String) -> CGSize {
        return NSString(string: string).size(withAttributes: [NSAttributedString.Key.font : self])
    }
    
    
    static func HTAppBoldFont(with size : CGFloat) -> UIFont{
        return UIFont(name: "PingFang-SC-Semibold", size: size)!
    }
    static func HTAppMediumFont(with size : CGFloat) -> UIFont{
        return UIFont(name: "PingFang-SC-Medium", size: size)!
    }
    static func HTAppRegularFont(with size : CGFloat) -> UIFont{
        return UIFont(name: "PingFang-SC-Regular", size: size)!
    }
    static func HTAppLightFont(with size : CGFloat) -> UIFont{
        return UIFont(name: "PingFang-SC-Light", size: size)!
    }
    static func HTAppThinFont(with size : CGFloat) -> UIFont{
        return UIFont(name: "PingFang-SC-Thin", size: size)!
    }
    /// 用于数字显示的字体
    static func HTAppMathFont(with size : CGFloat) -> UIFont {
        return UIFont(name: "DINAlternate-Bold", size: size)!
    }
    
    static func HTAppDynamicLightFont(with size : CGFloat) -> UIFont{
        return UIFont.HTAppDynamicLightFont(with: size, delta: 1)
    }
    
    static func HTAppDynamicLightFont(with size : CGFloat ,
                                 delta : CGFloat) -> UIFont{
        return UIFont.HTAppLightFont(with: kHTScreenWidth == 320 ? size - delta : size)
    }
    
    static func HTAppDynamicRegularFont(with size : CGFloat)->UIFont{
        return UIFont.HTAppDynamicRegularFont(with: size,
                                         delta: 1)
    }
    
    static func HTAppDynamicRegularFont(with size : CGFloat,
                                   delta : CGFloat) -> UIFont{
        return UIFont.HTAppRegularFont(with: kHTScreenWidth == 320 ? size - delta : size)
    }
    
    
    static func HTAppDynamicMediumFont(with size : CGFloat) -> UIFont{
        return UIFont.HTAppDynamicMediumFont(with: size, delta: 1)
    }
    
    static func HTAppDynamicMediumFont(with size : CGFloat ,
                                  delta : CGFloat) -> UIFont{
        return UIFont.HTAppMediumFont(with: kHTScreenWidth == 320 ? size - delta : size)
    }
}

/**
 RGB 16进制值颜色
 
 - parameter rgbValue: 16进制色值
 
 - returns: 返回颜色
 */
func HTUIColorFromRGB(rgbValue: UInt, alpha: CGFloat? = nil) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(alpha ?? 1.0)
    )
}
 func HTAPCurrentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
    if let nav = base as? UINavigationController {
        return HTAPCurrentViewController(base: nav.visibleViewController)
    }
    if let tab = base as? UITabBarController {
        return HTAPCurrentViewController(base: tab.selectedViewController)
    }
    if let presented = base?.presentedViewController {
        return HTAPCurrentViewController(base: presented)
    }
    return base
}

func HTAPShowTip(tips:String,delay:Double = 1.5, viewController: UIViewController) {
    let hud:MBProgressHUD = MBProgressHUD.showAdded(to: viewController.view, animated: true)
    hud.mode = MBProgressHUDMode.text;
//        hud.bezelView.color = UIColor.black
    hud.bezelView.style = .solidColor
    hud.bezelView.color = HTUIColorFromRGB(rgbValue: 0x111111,
                                         alpha: 0.7)
    hud.detailsLabel.textColor = UIColor.white
    hud.detailsLabel.text = tips
    hud.detailsLabel.font = hud.label.font
    hud.removeFromSuperViewOnHide = true;
    hud.hide(animated: true, afterDelay: delay)

}
extension UIDevice {
    public func HTisIphoneX() -> Bool {
        var isPhoneX = false;
        if #available(iOS 11.0,*) {
            if let window = UIApplication.shared.delegate?.window {
                if let safeAreaInsets = window?.safeAreaInsets {
                    isPhoneX = safeAreaInsets.bottom > 0.0
                }
            }
        }
        return isPhoneX
    }
}
