//
//  GeotagPhoto.swift
//  VirtualTourist
//
//  Created by Ryan Harri on 2016-12-07.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation

protocol GeotagPhoto {
    var url: URL { get }
    var image: Data? { get set }
}
