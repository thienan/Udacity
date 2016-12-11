//
//  DataController.swift
//  VirtualTourist
//
//  Created by Ryan Harri on 2016-12-06.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

typealias LocatablePhoto = [URL: Data?]
typealias DataControllerSaveResponse = (SaveResponse) -> Void

class DataController: NSObject {
    
    // MARK: - Type Properties
        
    fileprivate enum Constant: String {
        case resource = "Virtual Tourist"
        case `extension` = "momd"
        case sqliteFilename = "VirtualTourist.sqlite"
    }
    
    fileprivate enum Entity: String {
        case pin = "Pin"
    }
    
    // MARK: - Instance Properties
    
    var managedObjectContext: NSManagedObjectContext
    
    
    // MARK: - Initialization
    
    /*
        The initialization of the Core Data stack is based on the example provided here:
        https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreData/InitializingtheCoreDataStack.html
    */
    
    override init() {
        // This resource is the same name as your xcdatamodeld contained in your project.
        guard let modelURL = Bundle.main.url(forResource: Constant.resource.rawValue, withExtension: Constant.extension.rawValue) else {
            fatalError("Error loading model from bundle")
        }
        
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = psc
        
        DispatchQueue.global(qos: .background).async {
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let docURL = urls[urls.endIndex-1]
            
            let storeURL = docURL.appendingPathComponent(Constant.sqliteFilename.rawValue)
            do {
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
            } catch {
                fatalError("Error migrating store: \(error)")
            }
        }
    }
}

extension DataController {
    
    // MARK: - Saving
    
    func save(callback: DataControllerSaveResponse) {
        do {
            try managedObjectContext.save()
        } catch {
            callback(.failure("Failed to save context", error))
        }
        
        callback(.success)
    }
    
    func save(coordinate: CLLocationCoordinate2D, callback: DataControllerSaveResponse) {
        let pin = Pin(context: managedObjectContext)
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        pin.page = 0
        
        save() { response in
            callback(response)
        }
    }
    
    func save(page: Page, coordinate: CLLocationCoordinate2D, photos geotagPhotos: [GeotagPhoto], callback: DataControllerSaveResponse) {
        guard let pin = pin(with: coordinate) else {
            return
        }
        
        let page = Int64(page)
        
        if pin.page != page {
            if let photos = pin.photos?.array as? [Photo] {
                for photo in photos {
                    managedObjectContext.delete(photo)
                }
            }
            
            for geotagPhoto in geotagPhotos {
                let photo = Photo(context: managedObjectContext)
                photo.imageURL = geotagPhoto.url.absoluteString
                photo.image = geotagPhoto.image as NSData?
                pin.addToPhotos(photo)
            }
            
            pin.page = page
            
            save() { response in
                callback(response)
            }
        } else {
            if let photos = pin.photos?.array as? [Photo] {
                var hasChanges = false
                for geotagPhoto in geotagPhotos {
                    for photo in photos {
                        guard let urlString = photo.imageURL, let url = URL(string: urlString) else {
                            continue
                        }
                        
                        if url == geotagPhoto.url && photo.image == nil {
                            photo.image = geotagPhoto.image as NSData?
                            hasChanges = true
                        }
                    }
                }
                
                if hasChanges {
                    save() { response in
                        callback(response)
                    }
                }
            }
        }
    }
    
    // MARK: - Delete
    
    func deletePhoto(with coordinate: CLLocationCoordinate2D, url: URL) {
        guard let photo = locatablePhoto(with: coordinate, url: url) else {
            return
        }
        
        managedObjectContext.delete(photo)
        save() { _ in }
    }
    
    // MARK: - Fetching
    
    func locationCoordinates() -> [CLLocationCoordinate2D]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        
        var coordinates = [CLLocationCoordinate2D]()
        
        do {
            let pins = try managedObjectContext.fetch(fetchRequest) as! [Pin]
            
            for pin in pins {
                let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                coordinates.append(coordinate)
            }
        } catch {
            return nil
        }
        
        return coordinates
    }
    
    func pageNumber(with coordinate: CLLocationCoordinate2D) -> Page? {
        guard let pin = pin(with: coordinate) else {
            return nil
        }
        
        let page = Int.init(pin.page)
        
        return page
    }
    
    func locatablePhotos(for page: Page, coordinate: CLLocationCoordinate2D) -> LocatablePhoto {
        var locatablePhotos = LocatablePhoto()
        
        guard let pin = pin(with: coordinate), let photos = pin.photos?.array as? [Photo] else {
            return locatablePhotos
        }
        
        for photo in photos {
            guard let urlString = photo.imageURL, let url = URL(string: urlString) else {
                continue
            }
            
            if let data = photo.image as? Data {
                locatablePhotos.updateValue(data, forKey: url)
            } else {
                locatablePhotos.updateValue(nil, forKey: url)
            }
        }
        
        return locatablePhotos
    }
    
    private func locatablePhoto(with coordinate: CLLocationCoordinate2D, url: URL) -> Photo? {
        guard let pin = pin(with: coordinate), let photos = pin.photos?.array as? [Photo] else {
            return nil
        }
        
        var matchedPhoto: Photo? = nil
        
        for photo in photos {
            guard let urlString = photo.imageURL, let imageURL = URL(string: urlString) else {
                continue
            }
            
            if imageURL == url {
                matchedPhoto = photo
                break
            }
        }
        
        return matchedPhoto
    }
    
    private func pin(with coordinate: CLLocationCoordinate2D) -> Pin? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.pin.rawValue)
        fetchRequest.predicate = NSPredicate(format: "latitude == %lf && longitude == %lf", coordinate.latitude, coordinate.longitude)
        
        var pin: Pin? = nil
        
        do {
            let pins = try managedObjectContext.fetch(fetchRequest) as! [Pin]
            pin = pins.first
        } catch {
            return nil
        }
        
        return pin
    }
    
    private func pin(for page: Page, coordinate: CLLocationCoordinate2D) -> Pin? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.pin.rawValue)
        fetchRequest.predicate = NSPredicate(format: "latitude == %lf && longitude == %lf && page == %lf", coordinate.latitude, coordinate.longitude, page)
        
        var pin: Pin? = nil
        
        do {
            let pins = try managedObjectContext.fetch(fetchRequest) as! [Pin]
            pin = pins.first
        } catch {
            return nil
        }
        
        return pin
    }
}
