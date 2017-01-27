//
//  StoryboardLoadable.swift
//  test1
//
//  Created by ShuichiNagao on 8/16/16.
//  Copyright © 2016 ShuichiNagao. All rights reserved.
//

import UIKit

protocol StoryboardLoadable: class {
    static var storyboardName: String { get }
}

extension StoryboardLoadable where Self: UIViewController {

    static var storyboardName: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!.replacingOccurrences(of: "ViewController", with: "")
    }
    
}
