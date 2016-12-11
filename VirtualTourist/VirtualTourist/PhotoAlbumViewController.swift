//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Ryan Harri on 2016-11-28.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import UIKit
import MapKit
import CoreData

/*
 The overall implementation of this view controller is inspired by the WWDC 2016 session 419
 ("Protocol and value oriented programming in UIKIT apps") and analysis of the Lucid Dreams
 sample application.
 */

class PhotoAlbumViewController: UIViewController, Alertable {

    // MARK: - Outlets

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    // MARK: - Instance Properties
    
    var sharedModel: SharedModel!
    fileprivate var model = Model.empty
    fileprivate var state = State.ready
    
    fileprivate enum Identifier: String {
        case pin = "Pin"
        case photo = "Photo"
        case placeholder = "Placeholder"
    }
    
    // MARK: - Data Source
    
    var dataSource: GeotagPhotoDataSource!
    var dataController: DataController!
    
    // MARK: - View Lifecycle
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mutate { model, _ in
            model.removeAllPhotos()
            model = sharedModel
        }
        
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        DispatchQueue.main.async {
            self.mapView.setRegion(withDelta: 12.0)
            self.mapView.setCenter(self.model.coordinate, animated: false)
            _ = self.mapView.annotate(at: self.model.coordinate)
        }
        
        if model.hasPhotos == false {
            mutate { _, state in state = .loading }
            
            let photos = dataController.locatablePhotos(for: model.page, coordinate: model.coordinate)
            
            if photos.count > 0 {
                mutate { model, _ in
                    for photo in photos {
                        let flickrPhoto = FlickrPhoto(url: photo.key, image: photo.value)
                        model.append(flickrPhoto)
                    }
                }
            } else {
                dataSource.searchForPhotos(with: nil, coordinate: model.coordinate) { result in
                    switch result {
                    case .success(let page, let photos):
                        self.mutate { model, status in
                            if photos.count == 0 {
                                status = .noPhotos
                            } else {
                                status = .havePhotos
                                model.setPage(page)
                            }
                            
                            for photo in photos {
                                model.append(photo)
                            }
                        }
                    case .failure:
                        break
                    }
                }
            }
        } else {
            mutate { _, state in state = .loading }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if model.hasPhotos {
            mutate { _, state in state = .saving }
            
            dataController.save(page: model.page, coordinate: model.coordinate, photos: model.photos) { response in
                switch response {
                case .success:
                    break
                case .failure(_, _):
                    displayAlert(withTitle: "Save Failed", message: "Unable to save photos.", buttonTitle: "OK")
                }
            }
        }
        
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Actions
    
    @IBAction func newCollectionTapped(_ sender: UIBarButtonItem) {
        dataSource.searchForPhotos(with: model.nextPage, coordinate: model.coordinate) { result in
            switch result {
            case .success(let page, let photos):
                self.mutate { model, status in
                    model.removeAllPhotos()
                    if photos.count == 0 {
                        status = .noPhotos
                    } else {
                        status = .havePhotos
                        model.setPage(page)
                        
                        for photo in photos {
                            model.append(photo)
                        }
                    }
                }
            case .failure:
                break
            }
        }
    }
}

// MARK: - Model and State Mutations

extension PhotoAlbumViewController {
    /// Model and state mutations with side-effects
    fileprivate func mutate(_ mutations: (inout Model, inout State) -> Void) {
        mutations(&model, &state)
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
        stateDidChange()
    }
    
    /// Model mutation without side-effects
    fileprivate func mutated(_ mutations: (inout Model) -> Void) {
        mutations(&model)
    }
}

// MARK: - State Management

extension PhotoAlbumViewController {
    fileprivate enum State {
        case ready
        case loading
        case havePhotos
        case noPhotos
        case saving
    }
    
    fileprivate func stateDidChange() {
        switch state {
        case .ready:
            break
        case .loading:
            mutate { _, state in state = .ready }
        case .saving:
            mutate { _, state in state = .ready }
        case .havePhotos, .noPhotos:
            DispatchQueue.main.async {
                self.noImagesLabel.isHidden = self.model.hasPhotos
                self.newCollectionButton.isEnabled = self.model.hasPhotos
            }
            mutate { _, state in state = .ready }
        }
    }
}

// MARK: Map View Delegate

extension PhotoAlbumViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Identifier.pin.rawValue) {
            annotationView.annotation = annotation
            return annotationView
        } else {
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Identifier.pin.rawValue)
            annotationView.animatesDrop = true
            annotationView.canShowCallout = false
            return annotationView
        }
    }
}

// MARK: - Collection View Data Source

extension PhotoAlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.photo.rawValue, for: indexPath) as! PhotoCollectionViewCell
        
        let photo = model.photos[indexPath.row]
        
        if let data = photo.image, let image = UIImage(data: data) {
            cell.imageView.image = image
        } else {
            cell.imageView.image = UIImage(named: Identifier.placeholder.rawValue)
        }
        return cell
    }
}

// MARK: - Collection View Delegate

extension PhotoAlbumViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photo = model.photos[indexPath.row]
        
        /*
            iOS Programming: The Big Nerd Ranch Guide (5th Edition)
            Chapter 20, "Collection Views"
            pg. 346
         
            Used this approach to download the image data when the cell in the collection view
            will be displayed.
        */
        
        if photo.image == nil {
            dataSource.image(from: photo.url) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        self.mutated { model in
                            model.setImage(data, at: indexPath.row)
                        }
                        
                        guard let photoIndex = self.model.photos.index(where: { $0.url == photo.url }) else {
                            return
                        }
                        
                        let photoIndexPath = IndexPath(row: photoIndex, section: 0)
                        
                        if let cell = self.collectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell {
                            if let image = UIImage(data: data) {
                                cell.imageView.image = image
                            }
                        }
                        
                    case .failure:
                        break
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        mutate { model, _ in
            let photo = model.photos[indexPath.row]
            dataController.deletePhoto(with: model.coordinate, url: photo.url)
            
            model.removePhoto(at: indexPath.row)
        }
        
        collectionView.deleteItems(at: [indexPath])
    }
}
