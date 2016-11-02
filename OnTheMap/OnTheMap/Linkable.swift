//
//  Linkable.swift
//  OnTheMap
//
//  Created by Ryan Harri on 2016-10-28.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import UIKit

// MARK: Protocol

/// A blueprint for UIViewController's to conform to that provides an unified method of opening URLs in Safari.
protocol Linkable { }

// MARK: Protocol Extension

/// An extension of the Linkable protocol that implements the functionality of opening URLs in Safari.
extension Linkable where Self: UIViewController {
    
    // MARK: Methods
    
    /**
     
        Open's a URL using the shared instance UIApplication.
     
        - Parameters:
            - string: The string representation of the URL to be opened.
 
    */
    func openURL(_ string: String) {
        if let url = URL(string: string) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    /**
     
        Determines if a URL can be opened using the shared instance UIApplication.
     
        - Parameters:
            - string: The string representation of the URL to test.
     
        - Returns: True if the URL can be opened, otherwise false.

     */
    func canOpenURL(_ string: String) -> Bool {
        if let url = URL(string: string) {
            return UIApplication.shared.canOpenURL(url)
        } else {
            return false
        }
    }
}
