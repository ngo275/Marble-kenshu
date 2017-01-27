//
//  ArticleDetailViewController.swift
//  test1
//
//  Created by ShuichiNagao on 8/11/16.
//  Copyright © 2016 ShuichiNagao. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire


class ArticleDetailViewController: UIViewController {

    //let apiManager: APIManager = APIManager.sharedInstance
    var article: Article?
    
    @IBOutlet weak var text: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let article = article {
            text.text = article.body
            text.isEditable = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}
