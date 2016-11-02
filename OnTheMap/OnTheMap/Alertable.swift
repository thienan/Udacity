//
//  Alertable.swift
//  OnTheMap
//
//  Created by Ryan Harri on 2016-10-26.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import UIKit

// MARK: Protocol

/// A blueprint for UIViewController's to conform to that provides a simple, unified method of presenting UIAlertController's.
protocol Alertable { }

// MARK: Protocol Extension

/// An extension of the Alertable protocol that implements the functionality of presenting UIAlertController's.
extension Alertable where Self: UIViewController {
    
    // MARK: Methods
    
    /**
        
        Presents a UIAlertController with the provided title and message.
     
        - Parameters:
            - title: The title of the UIAlertController.
            - message: The message to be displayed in the UIAlertController.
 
    */
    func displayAlert(title: String?, message: String?) {
        guard let message = message else {
            return
        }
        
        // Keur, C. and Hillegass, A. (2015) iOS Programming: The Big Nerd Ranch Guide. 5th edn. Big Nerd Ranch Guides
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
