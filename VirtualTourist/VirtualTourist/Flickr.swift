//
//  Flickr.swift
//  VirtualTourist
//
//  Created by Ryan Harri on 2016-12-06.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation
import MapKit

typealias JavaScriptObject = [String: Any]
typealias JSONResponse = (Any?) -> Void

struct Flickr: GeotagPhotoDataSource {
    
    // MARK: - Type Properties
    
    fileprivate enum Parameter: String {
        case apiKey = "api_key"
        case method = "method"
        case privacyFilter = "privacy_filter"
        case safeSearch = "safe_search"
        case lat = "lat"
        case lon = "lon"
        case format = "format"
        case nojsoncallback = "nojsoncallback"
        case extras = "extras"
        case perPage = "per_page"
        case page = "page"
    }
    
    fileprivate struct API {
        static let baseURL = "https://api.flickr.com/services/rest/"
    }
    
    fileprivate struct ParameterValue {
        static let photosSearch = "flickr.photos.search"
        static let publicPhotos = "1"
        static let safe = "1"
        static let json = "json"
        static let nojsoncallback = "1"
        static let extras = "url_q"
        static let perPage = "50"
    }
    
    internal enum Key: String {
        case photos = "photos"
        case photo = "photo"
        case page = "page"
        case urlq = "url_q"
    }
}

// MARK: - Methods

extension Flickr {
    
    /// Searches for photos with a latitude and longitude using the Flickr API.
    func searchForPhotos(with page: Page?, coordinate: CLLocationCoordinate2D, callback: @escaping DataSourceSearchResult) {
        var arguments: [Parameter: String] = [
            Parameter.apiKey: PrivateConstants.Flickr.apiKey,
            Parameter.method: ParameterValue.photosSearch,
            Parameter.privacyFilter: ParameterValue.publicPhotos,
            Parameter.safeSearch: ParameterValue.safe,
            Parameter.format: ParameterValue.json,
            Parameter.nojsoncallback: ParameterValue.nojsoncallback,
            Parameter.extras: ParameterValue.extras,
            Parameter.perPage: ParameterValue.perPage,
            Parameter.lat: "\(coordinate.latitude)",
            Parameter.lon: "\(coordinate.longitude)"
        ]
        
        if let page = page {
            arguments[Parameter.page] = "\(page)"
        }
        
        guard let url = url(with: arguments) else {
            callback(.failure)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            self.json(from: (data, response, error)) { json in
                guard let json = json else {
                    callback(.failure)
                    return
                }
                
                guard let root = json as? JavaScriptObject else {
                    callback(.failure)
                    return
                }
                
                guard let photos = root[Key.photos.rawValue] as? JavaScriptObject else {
                    callback(.failure)
                    return
                }
                
                guard let page = photos[Key.page.rawValue] as? Page else {
                    callback(.failure)
                    return
                }
                
                guard let photo = photos[Key.photo.rawValue] as? [JavaScriptObject] else {
                    callback(.failure)
                    return
                }
                
                var flickrPhotos = [FlickrPhoto]()
                
                for item in photo {
                    guard let flickrPhoto = FlickrPhoto(json: item) else {
                        continue
                    }
                    flickrPhotos.append(flickrPhoto)
                }
                callback(.success(page, flickrPhotos))
            }
        }
        
        task.resume()
    }
    
    func image(from url: URL, callback: @escaping DataSourceImageResult) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil, let response = response, let data = data else {
                callback(.failure)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                callback(.failure)
                return
            }
            
            guard httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299 else {
                callback(.failure)
                return
            }
            
            callback(.success(data))
        }
        
        task.resume()
    }
}

extension Flickr {
    
    fileprivate func json(from taskResult: (Data?, URLResponse?, Error?), _ json: JSONResponse) {
        guard taskResult.2 == nil, let response = taskResult.1, let data = taskResult.0 else {
            json(nil)
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            json(nil)
            return
        }
        
        guard httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299 else {
            json(nil)
            return
        }
        
        guard let representation = try? JSONSerialization.jsonObject(with: data, options: []) else {
            json(nil)
            return
        }
        
        json(representation)
    }
    
    /// Returns a URL created with the Flickr API based URL and the specified arguments.
    fileprivate func url(with arguments: [Parameter: String]) -> URL? {
        guard let components = URLComponents(string: API.baseURL) else {
            return nil
        }
        
        var mutableComponents = components
        
        let queryItems = arguments.map { URLQueryItem(name: $0.key.rawValue, value: $0.value) }
        
        mutableComponents.queryItems = queryItems
        
        return mutableComponents.url
    }
}
