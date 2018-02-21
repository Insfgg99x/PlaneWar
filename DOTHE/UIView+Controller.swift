//
//  UIView+Controller.swift
//  DOTHE
//
//  Created by xgf on 2018/2/8.
//  Copyright © 2018年 xgf. All rights reserved.
//

import UIKit

extension UIView {
    func controller() -> UIViewController? {
        var nextResponder = next
        while !(nextResponder is UIViewController) {
            nextResponder = nextResponder?.next
        }
        return nextResponder as? UIViewController
    }
}
