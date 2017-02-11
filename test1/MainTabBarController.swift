//
//  MainTabBarController.swift
//  test1
//
//  Created by ShuichiNagao on 8/17/16.
//  Copyright © 2016 ShuichiNagao. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let articleStoryboard = UIStoryboard(name: "Article", bundle: nil)
        let searchStoryboard = UIStoryboard(name: "Search", bundle: nil)
        let likeStoryboard = UIStoryboard(name: "Like", bundle: nil)
        let mypageStoryboard = UIStoryboard(name: "Mypage", bundle: nil)
        let articleViewController = articleStoryboard.instantiateInitialViewController() as! UINavigationController
        let searchViewController = searchStoryboard.instantiateInitialViewController() as! UINavigationController
        let likeViewController = likeStoryboard.instantiateInitialViewController() as! UINavigationController
        let mypageViewController = mypageStoryboard.instantiateInitialViewController() as! UINavigationController
        let viewControllers = [articleViewController, searchViewController, likeViewController, mypageViewController]
        self.setViewControllers(viewControllers, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
