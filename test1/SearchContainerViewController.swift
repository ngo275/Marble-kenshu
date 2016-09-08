//
//  SearchContainerViewController.swift
//  test1
//
//  Created by ShuichiNagao on 8/17/16.
//  Copyright © 2016 ShuichiNagao. All rights reserved.
//

import UIKit

class SearchContainerViewController: UINavigationController {

    var statusBarStyle: UIStatusBarStyle = UIStatusBarStyle.Default
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        //        print("preferredStatusBarStyle: \(statusBarStyle)")
        return statusBarStyle
    }
    
}
