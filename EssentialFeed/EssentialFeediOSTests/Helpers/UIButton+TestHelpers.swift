//
//  UIButton+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Saba Khutsishvili on 3/14/21.
//

import UIKit

extension UIButton {
    
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach { action in
                (target as NSObject).perform(Selector(action))
            }
        }
    }
}
