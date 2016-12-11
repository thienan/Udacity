//
//  MKMapView+Annotate.swift
//  VirtualTourist
//
//  Created by Ryan Harri on 2016-12-07.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation
import MapKit

// MARK: - Annotation

extension MKMapView {
    func annotate(with point: CGPoint) -> CLLocationCoordinate2D {
        let coordinate = self.convert(point, toCoordinateFrom: self)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        self.addAnnotation(annotation)
        
        return coordinate
    }
    
    func annotate(at coordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        self.addAnnotation(annotation)
        
        return coordinate
    }
}

// MARK: - Region

extension MKMapView {
    func setRegion(withDelta delta: Double) {
        var region = self.region
        region.span.latitudeDelta /= delta
        region.span.longitudeDelta /= delta
        self.region = region
    }
}
