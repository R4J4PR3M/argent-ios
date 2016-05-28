//
//  Extensions.swift
//  app-ios
//
//  Created by Sinan Ulkuatam on 5/12/16.
//  Copyright © 2016 Sinan Ulkuatam. All rights reserved.
//

import Foundation
import Alamofire
import CWStatusBarNotification

let globalNotification = CWStatusBarNotification()

extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}

extension UIImage{
    
    func alpha(value:CGFloat)->UIImage
    {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        
        let ctx = UIGraphicsGetCurrentContext();
        let area = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height);
        
        CGContextScaleCTM(ctx, 1, -1);
        CGContextTranslateCTM(ctx, 0, -area.size.height);
        CGContextSetBlendMode(ctx, CGBlendMode.Multiply);
        CGContextSetAlpha(ctx, value);
        CGContextDrawImage(ctx, area, self.CGImage);
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
}


// Fix Push notification bug: _handleNonLaunchSpecificActions
extension UIApplication {
    func _handleNonLaunchSpecificActions(arg1: AnyObject, forScene arg2: AnyObject, withTransitionContext arg3: AnyObject, completion completionHandler: () -> Void) {
        //catching handleNonLaunchSpecificActions:forScene exception on app close
    }
}

extension UIColor {
    static func mediumBlue() -> UIColor {
        return UIColor(rgba: "#2c3441")
    }
    static func darkBlue() -> UIColor {
        return UIColor(rgba: "#141c29")
    }
    static func lightBlue() -> UIColor {
        return UIColor(rgba: "#7b8999")
    }
    static func limeGreen() -> UIColor {
        return UIColor(rgba: "#d8ff52")
    }
    static func slateBlue() -> UIColor {
        return UIColor(rgba: "#2c3441")
    }
    static func brandYellow() -> UIColor {
        return UIColor(rgba: "#FFCF4B")
    }
    static func brandGreen() -> UIColor {
        return UIColor(rgba: "#2ECC71")
    }
    static func brandRed() -> UIColor {
        return UIColor(rgba: "#f74e1d")
    }
    static func offWhite() -> UIColor {
        return UIColor(rgba: "#f5f7fa")
    }
}

extension Float {
    func round(decimalPlace:Int)->Float{
        let format = NSString(format: "%%.%if", decimalPlace)
        let string = NSString(format: format, self)
        return Float(atof(string.UTF8String))
    }
}


extension NSMutableData {
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}

public func convertStringToDictionary(text: String) -> [String:AnyObject]? {
    if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
        } catch let error as NSError {
            print(error)
        }
    }
    return nil
}

func addSubviewWithBounce(view: UIView, parentView: UIViewController) {
    view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001)
    parentView.view.addSubview(view)
    UIView.animateWithDuration(0.3 / 1.5, animations: {() -> Void in
        view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0)
        }, completion: {(finished: Bool) -> Void in
            UIView.animateWithDuration(0.3 / 2, animations: {() -> Void in
                }, completion: {(finished: Bool) -> Void in
                    UIView.animateWithDuration(0.3 / 2, animations: {() -> Void in
                        view.transform = CGAffineTransformIdentity
                    })
            })
    })
}

func addSubviewWithFade(view: UIView, parentView: UIViewController) {
    view.alpha = 0.0
    parentView.view.addSubview(view)
    UIView.animateWithDuration(1.0, animations: {
        view.alpha = 1.0
    })
}

func showGlobalNotification(message: String, duration: NSTimeInterval, inStyle: CWNotificationAnimationStyle, outStyle: CWNotificationAnimationStyle, notificationStyle: CWNotificationStyle, color: UIColor) {
    globalNotification.notificationLabelBackgroundColor = color
    globalNotification.notificationAnimationInStyle = inStyle
    globalNotification.notificationAnimationOutStyle = outStyle
    globalNotification.notificationStyle = notificationStyle
    globalNotification.displayNotificationWithMessage(message, forDuration: duration)
}

func formattedCurrency(amount: String, fontName: String, superSize: CGFloat, size: CGFloat) -> NSAttributedString {
    let formatter = NSNumberFormatter()
    formatter.numberStyle = .CurrencyStyle
    let r = Range<String.Index>(start: amount.startIndex, end: amount.endIndex)
    let x = amount.substringWithRange(r)
    let amt = formatter.stringFromNumber(Float(x)!/100)
    let font:UIFont? = UIFont(name: fontName, size: size)
    let fontSuper:UIFont? = UIFont(name: fontName, size: superSize)
    let attString:NSMutableAttributedString = NSMutableAttributedString(string: amt!, attributes: [NSFontAttributeName:font!])
    if Float(x) < 0 {
        attString.setAttributes([NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:3], range: NSRange(location:1,length:1))
        attString.setAttributes([NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:3], range: NSRange(location:(amt?.characters.count)!-2,length:2))
    } else {
        attString.setAttributes([NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:3], range: NSRange(location:0,length:1))
        attString.setAttributes([NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:3], range: NSRange(location:(amt?.characters.count)!-2,length:2))
    }
    return attString
}
