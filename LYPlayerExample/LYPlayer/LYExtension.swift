//
//  CALayer+Extension.swift
//  PlayButton
//
//  Created by ShuYan Feng on 2017/3/25.
//  Copyright © 2017年 ShuYan Feng. All rights reserved.
//

import UIKit

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

public var key: Void?

extension UIResponder {
    
    var allowRotation: Bool? {
        get {
            return objc_getAssociatedObject(self, &key) as? Bool
        }
        set(newValue) {
            objc_setAssociatedObject(self, &key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc(application:supportedInterfaceOrientationsForWindow:) func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if allowRotation == true {
            return .landscapeRight
        } else {
            return .portrait
        }
    }
}
