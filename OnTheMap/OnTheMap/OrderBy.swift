//
//  OrderBy.swift
//  OnTheMap
//
//  Created by Ryan Harri on 2016-11-01.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation

/// Represents a order parameter for the Student Location Parse API.
struct OrderBy: ParseParameterType {
    
    // MARK: Instance Properties
    
    /// The name of the parameter.
    var name: String {
        return "order"
    }
    
    /// The name of the property to order by.
    let keyName: String
    
    /// The order in which to retrieve the data by.
    let order: Order
    
    // MARK: Type Properties
    
    /// Constants that specify the order in which the OrderBy parameter is to be performed.
    enum Order: String {
        case ascending = ""
        case descending = "-"
    }
}
