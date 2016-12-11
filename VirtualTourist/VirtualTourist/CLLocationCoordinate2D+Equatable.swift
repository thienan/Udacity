//
//  CLLocationCoordinate2D+Equatable.swift
//  VirtualTourist
//
//  Created by Ryan Harri on 2016-12-07.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation
import MapKit

// MARK: - Equatable

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
