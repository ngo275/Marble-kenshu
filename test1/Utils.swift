//
//  Utils.swift
//  test1
//
//  Created by ShuichiNagao on 8/15/16.
//  Copyright © 2016 ShuichiNagao. All rights reserved.
//

import UIKit

class Utils {
    
    static func createErrorObject(_ message: String, code: Int = 100) -> NSError {
        let domain = "jp.co.candle.app.marble"
        
        return NSError(domain: domain, code: 100, userInfo: [NSLocalizedDescriptionKey: message])
    }
    
    static func createViewController<T: StoryboardLoadable>() -> T {
        let sb = UIStoryboard(name: T.storyboardName, bundle: nil)
        return sb.instantiateInitialViewController() as! T
    }
    
}

