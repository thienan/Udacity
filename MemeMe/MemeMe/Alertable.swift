//
//  Alertable.swift
//  MemeMe
//
//  Created by Ryan Harri on 2016-08-12.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import UIKit

protocol Alertable { }

extension Alertable where Self: UIViewController {
    func displayAlert(title: String?, message: String?) {
        guard let title = title, message = message else {
            return
        }
        
        // Keur, C. and Hillegass, A. (2015) iOS Programming: The Big Nerd Ranch Guide. 5th edn. Big Nerd Ranch Guides
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func displayAlert(title: String?, message: String?, cancelAction: UIAlertAction, okAction: UIAlertAction) {
        guard let title = title, message = message else {
            return
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
}