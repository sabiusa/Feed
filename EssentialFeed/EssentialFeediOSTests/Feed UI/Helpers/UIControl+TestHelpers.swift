//
//  UIControl+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Saba Khutsishvili on 3/14/21.
//

import UIKit

extension UIControl {
    
    func simulate(event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach { action in
                (target as NSObject).perform(Selector(action))
            }
        }
    }
}
