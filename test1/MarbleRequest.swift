//
//  MarbleRequest.swift
//  test1
//
//  Created by ShuichiNagao on 2017/01/25.
//  Copyright © 2017 ShuichiNagao. All rights reserved.
//

import Foundation
import APIKit

protocol MarbleRequest: Request {}

extension MarbleRequest {
    var baseURL: URL { return URL(string: "http://api.topicks.jp/api/v1")! }
}
