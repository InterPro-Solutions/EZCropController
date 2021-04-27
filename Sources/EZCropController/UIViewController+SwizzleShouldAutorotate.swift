//
//  UIViewController+SwizzleShouldAutorotate.swift
//  
//
//  Created by Xiang Li on 4/9/21.
//

import UIKit

public extension UIViewController {
    @objc private func swizzledShouldAutorotate()->Bool{
        if let presentedController = self.presentedViewController{
            return presentedController.shouldAutorotate
        }
        if
            let nav = self as? UINavigationController,
            let topViewController = nav.topViewController
        {
            return topViewController.shouldAutorotate
        }
        return true
    }
    /**
     Call this Method will make the `shouldAutorotate` of `EZCropController` as the value of `rootViewController` of `UIWindow`
     Call this method again to disable swizzling.
     */
    @objc static func swizzleShouldAutorotate() {
        let orignal: Selector = #selector(getter: UIViewController.shouldAutorotate)
        let swizzled: Selector = #selector(swizzledShouldAutorotate)

        let originalMethod: Method? = class_getInstanceMethod(self, orignal)
        let swizzledMethod: Method? = class_getInstanceMethod(self, swizzled)

        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}
