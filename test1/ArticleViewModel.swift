//
//  ArticleViewModel.swift
//  test1
//
//  Created by ShuichiNagao on 8/11/16.
//  Copyright © 2016 ShuichiNagao. All rights reserved.
//

import UIKit
import BrightFutures
import SwiftyJSON
import Alamofire

class ArticleViewModel: NSObject {
    
    var articles: [Article]?
    //    var articles: [[String: String?]] = []
    //    let table = UITableView()
    //    var max: Int = 0
    private let apiManager = APIManager.sharedInstance
    
    func fetchArticleList(params: [String: AnyObject]) -> Future<(Int,[Article]), NSError>  {
        let serializer = ArticleSerializer()
        let url = APIUrl.articleList
        return apiManager.get(url, params: params, serializer: serializer)
    }
    
//    private func mergeArticles(articles: [Article]) -> [Article] {
//        if let _ = self.articles {
//            let newArticles = self.articles! + articles
//            return newArticles
//        } else {
//            return articles
//        }
//    }
    
}
