//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Ryan Harri on 2016-10-28.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import UIKit
import MapKit

/// Responds to the map view actions of the view.
class MapViewController: UIViewController, MKMapViewDelegate, Alertable, Linkable {

    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: View Controller Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        /* Marianna (2014) SWIFT uiviewcontroller init
         Available at: http://stackoverflow.com/q/26702948 (Accessed: 30 Oct 2016) */
        super.init(coder: aDecoder)
        
        /* dreamlax (2010) Send and receive messages through NSNotificationCenter in Objective-C? [closed]
         Available at: http://stackoverflow.com/a/2191802 (Accessed: 30 Oct 2016) */
        NotificationCenter.default.addObserver(self, selector: #selector(pinStudentInformation), name: OnTheMapConstants.NotificationName.dataReceivedFromParse, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(noStudentInformation), name: OnTheMapConstants.NotificationName.noDataReceivedFromParse, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the map view delegate
        mapView.delegate = self
    }
    
    // MARK: Instance Methods
    
    /**
     
        Handles the "NoDataReceivedFromParse" notification.
     
    */
    @objc private func noStudentInformation() {
        DispatchQueue.main.async() {
            self.displayAlert(title: "Student Information", message: "Unable to get student information from Udacity.")
        }
    }
    
    /**
     
        Handles creating the annotations and adding them to the map view.
     
    */
    @objc private func pinStudentInformation() {
        DispatchQueue.main.async() {
            // Remove any existng annotations before updating the map
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            if let studentContainer = DataService.students {
                for student in studentContainer {
                    if let latitude  = student.latitude,
                       let longitude = student.longitude,
                       let firstName = student.firstName,
                       let lastName  = student.lastName,
                       let mediaURL  = student.mediaURL {
                        
                        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
                        
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate
                        annotation.title = "\(firstName) \(lastName)"
                        annotation.subtitle = mediaURL
                        
                        self.mapView.addAnnotation(annotation)
                    }
                }
            }
        }
    }
    
    // MARK: MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Use an existing annotation view
        if let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: OnTheMapConstants.MapView.pinAnnotationViewReuseIdentifier) as? MKPinAnnotationView {
            pinView.annotation = annotation
            return pinView
        } else {
            // Create a new annotation view
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: OnTheMapConstants.MapView.pinAnnotationViewReuseIdentifier)
            pinView.tintColor = OnTheMapConstants.MapView.pinTintColour
            pinView.canShowCallout = true
            pinView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return pinView
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation, let subtitle = annotation.subtitle! as String? {
            openURL(subtitle)
        }
    }
}
