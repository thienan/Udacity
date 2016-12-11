//
//  GeotagPhotoDataSource.swift
//  VirtualTourist
//
//  Created by Ryan Harri on 2016-12-07.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation
import MapKit

typealias Page = Int
typealias DataSourceSearchResult = (GeotagPhotoSearchResult) -> Void
typealias DataSourceImageResult = (ImageResult) -> Void

protocol GeotagPhotoDataSource {
    func searchForPhotos(with: Page?, coordinate: CLLocationCoordinate2D, callback: @escaping DataSourceSearchResult)
    func image(from url: URL, callback: @escaping DataSourceImageResult)
}
