//
//  UITableView+Dequeueing.swift
//  EssentialFeediOS
//
//  Created by Saba Khutsishvili on 3/31/21.
//

import UIKit

extension UITableView {
    
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! T
    }
}
