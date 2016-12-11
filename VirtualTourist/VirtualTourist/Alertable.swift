//
//  Alertable.swift
//  VirtualTourist
//
//  Created by Ryan Harri on 2016-12-09.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation
import UIKit

protocol Alertable { }

extension Alertable where Self: UIViewController {
    func displayAlert(withTitle title: String, message: String, buttonTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
        alert.addAction(ok)
        
        present(alert, animated: true, completion: nil)
    }
}
