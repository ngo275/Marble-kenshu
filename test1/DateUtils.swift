//
//  DateUtils.swift
//  test1
//
//  Created by ShuichiNagao on 8/15/16.
//  Copyright © 2016 ShuichiNagao. All rights reserved.
//

import UIKit

extension NSDate {
    static func dateFromString(string: String, format: String = "yyyy-MM-dd HH:mm:ss") -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
        dateFormatter.dateFormat = format
        
        return dateFormatter.dateFromString(string)
    }
}
