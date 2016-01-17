import Foundation
import UIKit

import CleanroomLogger
import Motif
import Eureka

func initializeTheming() {
    UIView.mtf_registerThemeProperty("borderWidth", requiringValueOfClass: NSNumber.self) { width, view, _ in
        view.layer.borderWidth = CGFloat(width.floatValue)
        return true
    }

    UIView.mtf_registerThemeProperty("borderColor", requiringValueOfClass: UIColor.self) { color, view, _ in
        view.layer.borderColor = color.CGColor
        return true
    }
    
    UIView.mtf_registerThemeProperty("backgroundColor", requiringValueOfClass: UIColor.self) { color, view, _ in
        // This has been an issue for some reason
        if let view = view as? UIView, color = color as? UIColor {
            view.backgroundColor = color
            return true
        }
        return false
    }
    
    UIView.mtf_registerThemeProperty("cornerRadius", requiringValueOfClass: NSNumber.self) { radius, view, _ in
        view.layer.cornerRadius = CGFloat(radius.floatValue)
        view.layer.masksToBounds = true
        return true
    }
    
    UIButton.mtf_registerThemeProperty("titleText", requiringValueOfClass: MTFTheme.self) { cls, button, errPointer in
        do {
            try (cls as! MTFThemeClass).applyTo(button)
            return true
        }
        catch let e as NSError {
            errPointer.memory = e
            return false
        }
    }
}

extension MTFTheme {
    func constantColorForName(name: String) -> UIColor? {
        let transformer = NSValueTransformer(forName: "MTFColorFromStringTransformerName")
        if let value = self.constantValueForName(name) {
            return transformer?.transformedValue(value) as? UIColor
        }
        return nil
    }
    
    func applyClass(name: String, to object: AnyObject) {
        do {
            try applyClassWithName(name, to: object)
        }
        catch let e {
            Log.warning?.message("Error applying class \(name) to \(object): \(e)")
        }
    }
}

protocol AppTheme {
    var primaryColor: UIColor { get }
    var primaryLightColor: UIColor { get }
    var primaryDarkColor: UIColor { get }
    var accentColor: UIColor { get }
    
    var facebookColor: UIColor { get }
    var twitterColor: UIColor { get }
}

extension MTFTheme: AppTheme {
    var primaryColor: UIColor {
        return constantColorForName("PrimaryColor")!
    }
    
    var primaryLightColor: UIColor {
        return constantColorForName("PrimaryLightColor")!
    }
    
    var primaryDarkColor: UIColor {
        return constantColorForName("PrimaryDarkColor")!
    }
    
    var accentColor: UIColor {
        return constantColorForName("AccentColor")!
    }
    
    var facebookColor: UIColor {
        return constantColorForName("FacebookColor")!
    }
    
    var twitterColor: UIColor {
        return constantColorForName("TwitterColor")!
    }
}