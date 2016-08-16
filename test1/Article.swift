//
//  Article.swift
//  test1
//
//  Created by ShuichiNagao on 8/11/16.
//  Copyright © 2016 ShuichiNagao. All rights reserved.
//


import UIKit
import SwiftyJSON
import Alamofire

//protocol JSONSerializable {
//    func toJson() -> JSON
//}

//struct Article: JSONSerializable {

struct Article {

    let id: Int
    let title: String
    let body: String
    let categoryId: Int
    let categoryName: String
    let itemOrder: String
    let modified: Int
    let onePage: Int
    let provider: String
    let published: Int
    let thumb: String
    let thumbNormal: String
    let thumbOriginal: String
    let thumbStatus: Int
    let thumbUpdated: NSDate
    let userData: User
    
    init(json: JSON) {
        let article = json["Article"]
        id = article["id"].intValue
        title = article["title"].stringValue
        body = article["body"].stringValue
        categoryId = article["category_id"].intValue
        categoryName = article["category_name"].stringValue
        itemOrder = article["item_order"].stringValue
        modified = article["modified"].intValue
        onePage = article["one_page"].intValue
        provider = json["provider"].stringValue
        published = article["published"].intValue
        thumb = article["thumb"].stringValue
        thumbNormal = article["thumb_normal"].stringValue
        thumbOriginal = article["thumb_original"].stringValue
        thumbStatus = article["thumb_status"].intValue
        thumbUpdated = NSDate.dateFromString(article["thumb_updated"].stringValue) ?? NSDate()
        userData = User(json: json["User"])
        
    }
    
//    func toJson() -> JSON {
//        let dict: [String: AnyObject] = [
//            "Article": [
//                "id": self.id,
//                "title": self.title,
//                "body": self.body,
//                "category_id": self.categoryId,
//                "category_name": self.categoryName,
//                "item_order": self.itemOrder,
//                "modified": self.modified,
//                "one_page": self.onePage,
//                "provider": self.provider,
//                "published": self.published,
//                "thumb": String(self.thumb),
//                "thumb_normal": String(self.thumbNormal),
//                "thumb_original": String(self.thumbOriginal),
//                "thumb_status": self.thumbStatus,
//                "thumb_updated": String(self.thumbUpdated),
//            ],
//            "User": [
//                "id": self.userData.id,
//                "username": self.userData.userName,
//                "screenname": self.userData.screenName
//            ]
//        ]
//        return JSON(dict)
//    }
}

struct ArticleSerializer: ResponseSerializerType {
    
    typealias SerializedObject = (max: Int, articles: [Article])
    typealias ErrorObject = NSError
    
    var serializeResponse: (NSURLRequest?, NSHTTPURLResponse?, NSData?, NSError?) -> Result<SerializedObject, ErrorObject> = { (request, response, data, error) in
        
        if let error = error {
            return Result.Failure(error)
        }
        
        guard let responseData = data else {
            return Result.Failure(Utils.createErrorObject("データの取得に失敗しました"))
        }
        
        let json = JSON(data: responseData)
        
        if let message = json["message"].string {
            return Result.Failure(Utils.createErrorObject(message))
        }
        
        let max = json["meta"]["count"].int ?? 0
        let articles = json["results"].arrayValue.map { Article(json: $0) }
        return Result.Success((max, articles))
    }
}
