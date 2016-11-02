//
//  LocationService.swift
//  OnTheMap
//
//  Created by Ryan Harri on 2016-10-31.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation
import CoreLocation

/// A singleton class that provides an abstraction of the geocoding methods provided by CoreLocation.
final class LocationService {
    
    // MARK: Instance Properties
    
    /// A cache to store CLPlacemark instances.
    private var placemarkCache: [String:CLPlacemark] = [:]
    
    /// The geocoder to use for geocoding operations.
    private let geocoder = CLGeocoder()
    
    // MARK: Type Properties
    
    // UdacityClient shared instance
    static let shared = LocationService()
    
    /// Constants that specify the types of Errors that can occur while using the LocationService.
    enum LocationServiceError: Error {
        case noPlacemark
    }
    
    // MARK: Type Identifiers
    
    typealias GeocodingCompletionHandler = (_ location: String, _ placemark: CLPlacemark?, _ error: Error?) -> Void
    
    // MARK: Initializers
    
    private init() {
        // Do not allow this class to be directly instantiated
    }

    /**
     
        Performs geocoding operation on the string representation of the location.
     
        - Parameters:
            - location: The location to geocode.
            - completionHandler: Handler that is invoked to handle the outcome of the geocoding operation.
     
     */
    func geocode(location: String, completionHandler: @escaping GeocodingCompletionHandler) {
        if let placemark = placemarkCache[location] {
            completionHandler(location, placemark, nil)
            return
        }
        
        geocoder.geocodeAddressString(location) { (placemark, error) in
            // Was there an error?
            guard (error == nil) else {
                completionHandler(location, nil, error)
                return
            }
            
            // Is there at least one placemark instance?
            guard let placemark = placemark?[0] else {
                completionHandler(location, nil, LocationServiceError.noPlacemark)
                return
            }
            
            // Add this location to the cache
            self.placemarkCache[location] = placemark
            
            completionHandler(location, placemark, nil)
        }
    }
}
