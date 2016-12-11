//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Ryan Harri on 2016-11-27.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    lazy var dataController = DataController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        guard let navigationController = window?.rootViewController as? UINavigationController, let viewController = navigationController.topViewController as? LocationViewController else {
            return true
        }
        
        viewController.dataSource = Flickr()
        viewController.dataController = dataController
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        dataController.save() { _ in }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        dataController.save() { _ in }
    }
}
