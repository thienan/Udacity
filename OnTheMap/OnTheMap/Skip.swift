//
//  Skip.swift
//  OnTheMap
//
//  Created by Ryan Harri on 2016-11-01.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation

/// Represents a skip parameter for the Student Location Parse API.
struct Skip: ParseParameterType {
    
    // MARK: Instance Properties
    
    /// The name of the parameter.
    var name: String {
        return "skip"
    }
    
    /// The number of records to skip.
    let skip: Int
}
