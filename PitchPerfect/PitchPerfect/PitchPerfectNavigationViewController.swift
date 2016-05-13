//
//  PitchPerfectNavigationViewController.swift
//  PitchPerfect
//
//  Created by Ryan Harri on 2016-05-10.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import UIKit

class PitchPerfectNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setNeedsStatusBarAppearanceUpdate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* Jay Bhalani (2015) Change status bar text color to light in iOS 9 with Objective C.
     Available at: http://stackoverflow.com/a/33104084 (Accessed: 5 May 2016) */
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}
