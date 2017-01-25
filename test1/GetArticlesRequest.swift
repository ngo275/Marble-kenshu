//
//  GetArticlesRequest.swift
//  test1
//
//  Created by ShuichiNagao on 2017/01/25.
//  Copyright © 2017 ShuichiNagao. All rights reserved.
//

import Foundation
import APIKit
import SwiftyJSON

struct GetArticlesRequest: MarbleRequest {
    
    typealias Response = (max: Int, articles: [Article])
    
    var queryParameters: [String : Any]?
    var method: HTTPMethod { return .get }
    var path: String { return "/articles/list.json" }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> (max: Int, articles: [Article]) {
        let json = JSON(object)
        
        if let message = json["message"].string {
            throw ResponseError.unexpectedObject(message)
        }
        
        let max = json["meta"]["count"].int ?? 0
        let articles = json["results"].arrayValue.map { Article(json: $0) }
        
        return (max, articles)
    }
}
