//
//  ArticleViewController.swift
//  test1
//
//  Created by ShuichiNagao on 8/11/16.
//  Copyright © 2016 ShuichiNagao. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import Result

class ArticleViewController: UIViewController {

    
    fileprivate let viewmodel = ArticleViewModel()
    fileprivate let apiManager: APIManager = APIManager.sharedInstance
    fileprivate var articles: [Article]? {
        get {
            return viewmodel.articles
        }
        set(newValue) {
            viewmodel.articles = newValue
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "MARBLE"
        load()
        initTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initTableView() {
        tableView!.register(registerCell: ArticleTableViewCell.self)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 105.0
    }
    
    fileprivate func load() {
        let params: [String: AnyObject] = [
            "search_type": "category" as AnyObject,
            "limit": 30 as AnyObject,
            //            "category_id": categoryId
        ]
        viewmodel.fetchArticleList(params)
            .onSuccess { [weak self] data in
                self?.articles = data.1
                self?.tableView.reloadData()
                print(data.1)
            }
            .onFailure { [weak self] error in
                self?.showErrorAlert(error.localizedDescription, completion: nil)
        }
    }
    
    fileprivate func showErrorAlert(_ message: String, completion: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: "MARBLE",
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: completion))
        present(alert, animated: true, completion: nil)
    }

}

extension ArticleViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UITableViewDataSource
    
    // return the number of tableCells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles?.count ?? 0
    }
    // draw the tableCells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ArticleTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.bindDataCell(articles![indexPath.row])
        return cell
    }
    // action when a cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let next: ArticleDetailViewController = Utils.createViewController()
        next.article = articles![indexPath.row]
        navigationController?.pushViewController(next, animated: true)
//        let storyboard: UIStoryboard = UIStoryboard(name: "ArticleDetail", bundle: nil)
//        if let next: ArticleDetailViewController = storyboard.instantiateViewControllerWithIdentifier("ArticleDetail") as? ArticleDetailViewController {
//            next.article = articles![indexPath.row]
//            navigationController?.pushViewController(next, animated: true)
//        }
    }
}

// MARK - StoryboardLoadable
extension UIViewController: StoryboardLoadable {}


