//
//  Limit.swift
//  OnTheMap
//
//  Created by Ryan Harri on 2016-11-01.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation

/// Represents a limit parameter for the Student Location Parse API.
struct Limit: ParseParameterType {
    
    // MARK: Instance Properties
    
    /// The name of the parameter.
    var name: String {
        return "limit"
    }
    
    /// The value used to limit the number of records retrieved.
    let limit: Int
}
