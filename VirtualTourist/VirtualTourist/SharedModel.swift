//
//  SharedModel.swift
//  VirtualTourist
//
//  Created by Ryan Harri on 2016-12-07.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation
import MapKit

typealias Model = SharedModel

struct SharedModel {
    
    // MARK: - Empty Model
    
    static var empty: SharedModel {
        return SharedModel(page: 0, photos: [GeotagPhoto](), coordinate: CLLocationCoordinate2D())
    }
    
    // MARK: Instance Properties
    private var _page: Int
    
    var page: Int {
        return _page
    }
    
    var nextPage: Int {
        let currentPage = _page
        return currentPage + 1
    }
    
    private var _photos: [GeotagPhoto]
    
    var photos: [GeotagPhoto] {
        return _photos
    }
    
    var hasPhotos: Bool {
        return _photos.count > 0
    }
    
    private var _coordinate: CLLocationCoordinate2D
    
    var coordinate: CLLocationCoordinate2D {
        return _coordinate
    }
    
    // MARK: - Initialization
    
    init(page: Int, photos: [GeotagPhoto], coordinate: CLLocationCoordinate2D) {
        _page = page
        _photos = photos
        _coordinate = coordinate
    }
    
    // MARK: - Page Mutations
    
    mutating func setPage(_ page: Int) {
        _page = page
    }
    
    // MARK: - Photos Mutations
    
    mutating func append(_ photo: GeotagPhoto) {
        _photos.append(photo)
    }
    
    mutating func removePhoto(at index: Int) {
        _photos.remove(at: index)
    }
    
    mutating func removeAllPhotos() {
        _photos.removeAll()
    }
    
    mutating func setImage(_ data: Data, at index: Int) {
        _photos[index].image = data
    }
    
    // MARK: - Coordinate Mutations
    
    mutating func setCoordinate(_ coordinate: CLLocationCoordinate2D) {
        _coordinate = coordinate
    }
}
