//
//  MainTabBarController.swift
//  test1
//
//  Created by ShuichiNagao on 8/17/16.
//  Copyright © 2016 ShuichiNagao. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.tabBar.translucent = true
    }
    
    override func viewDidLoad() {
        let articleStoryboard = UIStoryboard(name: "Article", bundle: nil)
        let searchStoryboard = UIStoryboard(name: "Search", bundle: nil)
        let likeStoryboard = UIStoryboard(name: "Like", bundle: nil)
        let mypageStoryboard = UIStoryboard(name: "Mypage", bundle: nil)
        let articleViewController = articleStoryboard.instantiateInitialViewController() as! ArticleContainerViewController
        let searchViewController = searchStoryboard.instantiateInitialViewController() as! SearchContainerViewController
        let likeViewController = likeStoryboard.instantiateInitialViewController() as! LikeContainerViewController
        let mypageViewController = mypageStoryboard.instantiateInitialViewController() as! MypageContainerViewController
        let viewControllers = [articleViewController, searchViewController, likeViewController, mypageViewController]
        self.setViewControllers(viewControllers, animated: false)

        super.viewDidLoad()


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
