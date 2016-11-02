//
//  ParseParameter.swift
//  OnTheMap
//
//  Created by Ryan Harri on 2016-10-27.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation

/// A representation of parameters specific to the Student Location Parse API. These parameter values allow the
/// client interfacing with the Parse API to request operations to be applied to the data being retrieved or queried.
struct ParseParameter {
    
    // MARK: Instance Properties
    
    /// The operation to be performed.
    let operation: Operation
    
    /// The parameter to use for the operation.
    let parameter: ParseParameterType
    
    // MARK: Type Properties
    
    /// Constants that specify the kind of operations that can be performed on a call to the Student Location Parse API.
    enum Operation {
        case orderBy
        case limit
        case skip
        case whereClause
    }
}
