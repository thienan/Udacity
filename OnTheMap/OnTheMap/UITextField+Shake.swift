//
//  UITextField+Shake.swift
//  OnTheMap
//
//  Created by Ryan Harri on 2016-10-21.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import UIKit

/// An extension of the UITextField (from UIKit).
extension UITextField {
    
    // MARK: Type Properties
    
    /// Supported directions to shake the UITextField
    enum Direction {
        case right, left
    }
    
    // MARK: Methods
    
    /**
     
        Animates the movement of a UITextField from right-to-left, or left-to-right, displaying a sense
        of shaking.
     
        - Parameters:
            - direction: The direction to shake the UITextField
            - offset: The value in which to increase or decrease the UITextField's center.x property.
     
     */
    func shake(_ direction: Direction, offset: CGFloat = 10.0) {
        UIView.animate(withDuration: 0.2, animations: {
            if direction == .right {
                self.center.x += offset // Right
            } else {
                self.center.x -= offset // Left
            }
            
            }, completion: {
                finished in
                UIView.animate(withDuration: 0.2) {
                    if direction == .right {
                        self.center.x -= offset // Right
                    } else {
                        self.center.x += offset // Left
                    }
                    
                    UIView.animate(withDuration: 0.2, animations: {
                        if direction == .right {
                            self.center.x -= offset // Right
                        } else {
                            self.center.x += offset // Left
                        }
                        
                        }, completion: {
                            finished in
                            UIView.animate(withDuration: 0.2) {
                                if direction == .right {
                                    self.center.x += offset // Right
                                } else {
                                    self.center.x -= offset // Left
                                }
                            }
                    })
                }
        })
    }
}
