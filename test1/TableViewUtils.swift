//
//  TableViewUtils.swift
//  test1
//
//  Created by ShuichiNagao on 8/15/16.
//  Copyright © 2016 ShuichiNagao. All rights reserved.
//

import UIKit

extension UITableView {
    
    func register<T: UITableViewCell where T: Reusable>(registerCell _: T.Type) {
        registerClass(T.self, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func register<T: UITableViewCell where T: protocol<Reusable, NibLoadable> >(registerCell _: T.Type) {
        let nib = UINib(nibName: T.nibName, bundle: nil)
        registerNib(nib, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell where T: Reusable>(forIndexPath indexPath: NSIndexPath) -> T {
        guard let cell = dequeueReusableCellWithIdentifier(T.defaultReuseIdentifier, forIndexPath: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }
        
        return cell
    }
}


// MARK - Reusable
extension UITableViewCell: Reusable {}

// MARK - NibLoadable
extension UITableViewCell: NibLoadable {}

