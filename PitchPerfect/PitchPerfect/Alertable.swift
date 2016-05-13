//
//  Alertable.swift
//  PitchPerfect
//
//  Created by Ryan Harri on 2016-05-11.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import UIKit

protocol Alertable { }

extension Alertable where Self: UIViewController {
    func displayAlert(title: String?, message: String?) {
        guard let message = message else {
            return
        }
        
        // Keur, C. and Hillegass, A. (2015) iOS Programming: The Big Nerd Ranch Guide. 5th edn. Big Nerd Ranch Guides
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
}