//
//  TableViewUtils.swift
//  test1
//
//  Created by ShuichiNagao on 8/15/16.
//  Copyright © 2016 ShuichiNagao. All rights reserved.
//

import UIKit

extension UITableView {
    
    /*func register<T: UITableViewCell>(registerCell _: T.Type) where T: Reusable {
        self.register(T.self, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }*/
    
    func register<T: UITableViewCell>(registerCell _: T.Type) where T: Reusable & NibLoadable  {
        let nib = UINib(nibName: T.nibName, bundle: nil)
        self.register(nib, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T where T: Reusable {
        guard let cell = self.dequeueReusableCell(withIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }
        
        return cell
    }
}


// MARK - Reusable
extension UITableViewCell: Reusable {}

// MARK - NibLoadable
extension UITableViewCell: NibLoadable {}

