//
//  Where.swift
//  OnTheMap
//
//  Created by Ryan Harri on 2016-11-01.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation

/// Represents a where parameter for the Student Location API.
struct Where: ParseParameterType {
    
    // MARK: Instance Properties
    
    /// The name of the parameter.
    var name: String {
        return "where"
    }
    
    /// The name of the property in the where clause.
    let keyName: String
    
    /// The value to match.
    let value: String
}
