//
//  StudentContainer.swift
//  OnTheMap
//
//  Created by Ryan Harri on 2016-10-27.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation

/// An ordered collection of StudentInformation objects.
struct StudentContainer: Sequence {
    
    // MARK: Instance Properties
    
    /// Returns the total number of objects in the collection.
    var count: Int {
        return container.count
    }
    
    /// The internal collection being used to store StudentInformation objects
    private var container: [StudentInformation] = []
    
    // MARK: Instance Methods
    
    /**
        
        Adds a StudentInformation object to the collection.
     
        - Parameters:
            - student: The StudentInformation object to add to the collection.
 
    */
    mutating func add(_ student: StudentInformation) {
        container.append(student)
    }
    
    /**
     
        Removes a StudentInformation object from the collection.
     
        - Parameters:
            - index: The index to remove from the collection.
     
        - Returns: The StudentInformation object that was removed from the collection.
     
    */
    mutating func remove(_ index: Int) -> StudentInformation {
        return container.remove(at: index)
    }
        
    func makeIterator() -> IndexingIterator<[StudentInformation]> {
        return container.makeIterator()
    }
    
    // MARK: Subscript
    
    /// Provides access to the internal collection's values.
    subscript(index: Int) -> StudentInformation? {
        get {
            return container[index]
        }
        set (newValue) {
            if let newValue = newValue {
                container[index] = newValue
            }
        }
    }
}
