//
//  LYExtension.swift
//
//  Copyright © 2017年 ly_coder. All rights reserved.
//
//  GitHub地址：https://github.com/LY-Coder/LYPlayer
//

import UIKit
import AVFoundation

extension CALayer {
    func ocb_applyAnimation(_ animation: CABasicAnimation) {
        let copy = animation.copy() as! CABasicAnimation
        
        if copy.fromValue == nil {
            copy.fromValue = self.presentation()!.value(forKeyPath: copy.keyPath!)
        }
        
        self.add(copy, forKey: copy.keyPath)
        self.setValue(copy.toValue, forKeyPath:copy.keyPath!)
    }
}

public var key: UIInterfaceOrientation = .portrait

extension UIResponder {
    
    /// 屏幕方向
    var interfaceOrientation: UIInterfaceOrientation {
        get {
            guard let value = objc_getAssociatedObject(self, &key) as? UIInterfaceOrientation else {
                return .portrait
            }
            return value
        }
        set {
            objc_setAssociatedObject(self, &key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            UIDevice.current.setValue(newValue.rawValue, forKey: "orientation")
        }
    }
    
    @objc(application:supportedInterfaceOrientationsForWindow:) func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if interfaceOrientation.isLandscape {
            // 水平
            return .landscapeRight
        } else {
            // 竖直
            return .portrait
        }
    }
}

extension UIImage {
    convenience init(_ name: String) {
        self.init(named: name, in: Bundle(for: LYPlayer.self), compatibleWith: nil)!
    }
}
