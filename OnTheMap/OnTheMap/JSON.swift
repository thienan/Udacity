//
//  JSON.swift
//  OnTheMap
//
//  Created by Ryan Harri on 2016-10-26.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation

/// An abstraction of the Foundation's JSONSerialization methods for serializing and deserializing JSON objects.
class JSON {
    
    // MARK: Type Methods
    
    /**
     
        Attempts to deserialize a JSON object.
     
        - Parameters:
            - data: A byte representation of the JSON object
            - opt: The JSONSerialization.ReadingOptions to use for deserializing the JSON object.
     
        - Throws: Rethrows the error from the JSONSerialization.jsonObject method.
     
        - Returns: An untyped object representation of the provided JSON object.
     
     */
    static func deserialize(_ data: Data, options opt: JSONSerialization.ReadingOptions = .allowFragments) throws -> AnyObject {
        var result: AnyObject
        do {
            result = try JSONSerialization.jsonObject(with: data, options: opt) as AnyObject
        } catch {
            throw error
        }
        return result
    }
    
    /**
     
        Attempts to serialize a JSON object.
     
        - Parameters:
            - data: A byte representation of the data to serialize.
            - opt: The JSONSerialization.WritingOptions to use for serializing the JSON object.
     
        - Throws: Rethrows the error from the JSONSerialization.data method.
     
        - Returns: A byte representation of the JSON object.
     
     */
    static func serialize(_ data: Any, options opt: JSONSerialization.WritingOptions = []) throws -> Data {
        var result: Data
        do {
            result = try JSONSerialization.data(withJSONObject: data, options: opt)
        } catch {
            throw error
        }
        return result
    }
}
