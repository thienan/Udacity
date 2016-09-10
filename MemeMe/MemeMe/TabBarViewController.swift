//
//  TabBarViewController.swift
//  MemeMe
//
//  Created by Ryan Harri on 2016-09-08.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        /* chancyWu (2014) Change tab bar item selected color in a storyboard
         Available at: http://stackoverflow.com/a/26838507 (Accessed: 08 Sep 2016) */
        UITabBar.appearance().tintColor = UIColor.whiteColor()
    }
}
