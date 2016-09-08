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

    
    private let viewmodel = ArticleViewModel()
    private let apiManager: APIManager = APIManager.sharedInstance
    private var articles: [Article]? {
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
    
    private func initTableView() {
        tableView!.register(registerCell: ArticleTableViewCell.self)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 105.0
    }
    
    private func load() {
        let params: [String: AnyObject] = [
            "search_type": "category",
            "limit": 30,
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
    
    private func showErrorAlert(message: String, completion: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: "MARBLE",
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.Alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: completion))
        presentViewController(alert, animated: true, completion: nil)
    }

}

extension ArticleViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UITableViewDataSource
    
    // return the number of tableCells
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles?.count ?? 0
    }
    // draw the tableCells
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ArticleTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.bindDataCell(articles![indexPath.row])
        return cell
    }
    // action when a cell is tapped
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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


