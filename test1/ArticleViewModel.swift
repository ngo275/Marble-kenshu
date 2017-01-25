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
import APIKit
import WebImage

class ArticleViewModel {
    
    var max: Int = 0
    var articles = [Article]()
    var operations = [SDWebImageOperation?]()
    
    func fetchArticles(params: [String: Any], isReset: Bool = false) -> Future<GetArticlesRequest.Response, SessionTaskError> {
        
        return APIManager.send(request: GetArticlesRequest())
    }
    
    
    //    var articles: [[String: String?]] = []
    //    let table = UITableView()
    //    var max: Int = 0
    //fileprivate let apiManager = APIManager.sharedInstance
    
    /*func fetchArticleList(_ params: [String: AnyObject]) -> Future<(Int,[Article]), NSError>  {
        let serializer = ArticleSerializer()
        let url = APIUrl.articleList
        return apiManager.get(url, params: params, serializer: serializer)
    }*/
    
//    private func mergeArticles(articles: [Article]) -> [Article] {
//        if let _ = self.articles {
//            let newArticles = self.articles! + articles
//            return newArticles
//        } else {
//            return articles
//        }
//    }
    
}
