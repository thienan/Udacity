//
//  SegueHandlerType.swift
//  PitchPerfect
//
//  Created by Ryan Harri on 2016-05-11.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import UIKit

/* Apple (2015) Swift in Practice.
 Available at: https://developer.apple.com/videos/play/wwdc2015/411/ (Accessed: 11 May 2016) */

protocol SegueHandlerType {
    // Conforming type should have enum called SegueIdentifier
    associatedtype SegueIdentifier: RawRepresentable
}

extension SegueHandlerType where Self: UIViewController, SegueIdentifier.RawValue == String {
    func performSegueWithIdentifier(segueIdentifier: SegueIdentifier, sender: AnyObject?) {
        performSegueWithIdentifier(segueIdentifier.rawValue, sender: sender)
    }
    
    func segueIdentifierForSegue(segue: UIStoryboardSegue) -> SegueIdentifier? {
        guard let identifier = segue.identifier, let segueIdentifier = SegueIdentifier(rawValue: identifier) else {
            return nil
        }
        return segueIdentifier
    }
}