//
//  FlickrPhoto.swift
//  VirtualTourist
//
//  Created by Ryan Harri on 2016-12-06.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation

struct FlickrPhoto: GeotagPhoto {
    
    // MARK: - Instance Properties
    
    let url: URL
    var image: Data?
    
    // MARK: - Initialization
    
    init(url: URL, image: Data?) {
        self.url = url
        self.image = image
    }
    
    init?(json: [String: Any]) {
        guard let urlString = json[Flickr.Key.urlq.rawValue] as? String else {
            return nil
        }
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        self.url = url
    }
}
