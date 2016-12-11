//
//  LocationViewController.swift
//  VirtualTourist
//
//  Created by Ryan Harri on 2016-11-27.
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

class LocationViewController: UIViewController, Alertable {
    
    // MARK: - Outlets

    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Instance Properties
    
    fileprivate var model = Model.empty
    fileprivate var state = State.ready
    
    fileprivate enum Identifier: String {
        case pin = "Pin"
        case album = "Album"
    }
    
    // MARK: - Data Source
    
    var dataSource: GeotagPhotoDataSource!
    var dataController: DataController!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        if let coordinates = dataController.locationCoordinates() {
            for coordinate in coordinates {
                _ = mapView.annotate(at: coordinate)
            }
            
        }
        
        stateDidChange()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mutate { model, _ in
            model.removeAllPhotos()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {

            mutate { _, state in
                state = State.annotate
                
                let coordinate = self.mapView.annotate(with: sender.location(in: self.mapView))
                    
                self.mutate { model, _ in
                    model.setCoordinate(coordinate)
                }
            }
            
            mutate { _, state in
                state = State.searching
                
                dataSource.searchForPhotos(with: nil, coordinate: model.coordinate) { result in
                    switch result {
                    case .success(let page, let photos):
                        self.mutate { model, _ in
                            model.removeAllPhotos()
                            
                            model.setPage(page)
                            
                            for photo in photos {
                                model.append(photo)
                            }
                        }
                    case .failure:
                        break
                    }
                }
            }
            
            mutate { _, state in
                state = State.saving
                dataController.save(coordinate: model.coordinate) { response in
                    switch response {
                    case .success:
                        break
                    case .failure(_, _):
                        displayAlert(withTitle: "Save Failed", message: "Unable to save this pin.", buttonTitle: "OK")
                    }
                }
            }
        }
    }
}

// MARK: - Model and State Mutations

extension LocationViewController {
    fileprivate func mutate(_ mutations: (inout Model, inout State) -> Void) {
        mutations(&model, &state)
        stateDidChange()
    }
}

// MARK: - State Management

extension LocationViewController {
    fileprivate enum State {
        case ready
        case annotate
        case searching
        case saving
    }
    
    fileprivate func stateDidChange() {
        switch state {
        case .ready:
            break
        case .annotate:
            mutate { _, state in state = .ready }
        case .searching:
            mutate { _, state in state = .ready }
        case .saving:
            mutate { _, state in state = .ready }
        }
    }
}

// MARK: - Map View Delegate

extension LocationViewController: MKMapViewDelegate {
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else {
            return
        }
        
        if let albumViewController = storyboard?.instantiateViewController(withIdentifier: Identifier.album.rawValue) as? PhotoAlbumViewController {
            
            guard let page = dataController.pageNumber(with: annotation.coordinate) else {
                return
            }
            
            mutate { model, _ in
                if model.coordinate == annotation.coordinate {
                    let _ = page == 0 ? model.setPage(1) : model.setPage(page)
                    
                    albumViewController.sharedModel = model
                    model.setCoordinate(CLLocationCoordinate2D())
                } else {
                    model.removeAllPhotos()
                    model.setCoordinate(annotation.coordinate)
                    model.setPage(page)
                    
                    albumViewController.sharedModel = model
                }
                
                albumViewController.dataSource = dataSource
                albumViewController.dataController = dataController
                self.navigationController?.pushViewController(albumViewController, animated: true)
            }
            
            /* 
                Once the album view is popped off of the navigation stack, the annotation will still be selected. It should not be,
                since the user may want to select the same annotation again.
            */
            mapView.deselectAnnotation(annotation, animated: false)
        }
    }
}
