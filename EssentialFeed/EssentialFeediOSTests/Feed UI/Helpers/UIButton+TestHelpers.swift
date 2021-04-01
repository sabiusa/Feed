//
//  UIButton+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Saba Khutsishvili on 3/14/21.
//

import UIKit

extension UIButton {
    
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
