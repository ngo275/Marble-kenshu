//
//  APIUrl.swift
//  test1
//
//  Created by ShuichiNagao on 8/15/16.
//  Copyright © 2016 ShuichiNagao. All rights reserved.
//

import Foundation

class APIUrl {
    fileprivate static let host = "https://api.topicks.jp"
    
    static var articleList: String {
        return host + "/api/v1/articles/list.json"
    }
    
    static var articleDetail: String {
        return host + "/api/v1/articles/show.json"
    }
    
}
