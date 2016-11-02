//
//  PostViewController.swift
//  OnTheMap
//
//  Created by Ryan Harri on 2016-10-31.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import UIKit
import MapKit

/// Responds to the posting actions of the view.
class PostViewController: UIViewController, Alertable, Linkable {

    // MARK: Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var pinMapImage: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    // MARK: Instance Properties
    
    /// A shared UdacityClient instance.
    private var activityIndicator = UIActivityIndicatorView()
    
    /// A shared LocationService instance.
    private let locationService = LocationService.shared
    
    /// True if the map view has been set, false otherwise.
    private var zoomSet = false
    
    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show/Hide views
        doneButton.isHidden = true
        mapView.delegate = self
        mapView.isHidden = true
        
        // Set yext field delegates
        locationTextField.delegate = self
        websiteTextField.delegate = self
        
        // Set the properties of the UIActivityIndicatorView
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.color = UIColor.black
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
    }
    
    // MARK: Instance Methods

    /**
     
        Handles the touch action of the cancel UIButton.
     
        - Parameters:
            - sender:
     
    */
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /**
     
        Handles the touch action of the done UIButton.
     
        - Parameters:
            - sender:
     
    */
    @IBAction func donePressed(_ sender: Any) {
        dismiss(animated: true) {
            DataService.loadStudents()
        }
    }
    
    /**
     
        Handles the touch action of the submit UIButton.
     
        - Parameters:
            - sender:
     
    */
    @IBAction func submitPressed(_ sender: Any) {
        guard let locationIsEmpty = locationTextField?.text?.isEmpty, let websiteIsEmpty = websiteTextField?.text?.isEmpty else {
            return
        }
        
        switch (locationIsEmpty, websiteIsEmpty) {
        case (true, true):
            locationTextField.shake(.right)
            websiteTextField.shake(.left)
            return
        case (true, false):
            locationTextField.shake(.right)
            return
        case (false, true):
            websiteTextField.shake(.left)
            return
        case (false, false):
            break
        }
        
        guard let website = websiteTextField.text else {
            displayAlert(title: OnTheMapConstants.Alert.invalidWebsiteTitle, message: OnTheMapConstants.Alert.invalidWebsiteMessage)
            return
        }
        
        if !canOpenURL(website) {
            displayAlert(title: OnTheMapConstants.Alert.invalidWebsiteTitle, message: OnTheMapConstants.Alert.invalidWebsiteMessage)
            return
        }
        
        if let location = locationTextField.text {
            activityIndicator.startAnimating()
            
            // Use the location service to geocode the location string provided by the user
            locationService.geocode(location: location) { (location, placemark, error) in
                // Was there an error?
                guard (error == nil) else {
                    DispatchQueue.main.async {
                        self.displayAlert(title: OnTheMapConstants.Alert.locationErrorTitle, message: OnTheMapConstants.Alert.locationErrorMessage + location)
                        self.activityIndicator.stopAnimating()
                    }
                    return
                }
                
                // Is there a placemark?
                guard let placemark = placemark, let placemarkLocation = placemark.location else {
                    DispatchQueue.main.async {
                        self.displayAlert(title: OnTheMapConstants.Alert.locationErrorTitle, message: OnTheMapConstants.Alert.locationErrorMessage + location)
                        self.activityIndicator.stopAnimating()
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    // Remove any existing annotations
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    
                    // Hide the image and display the map
                    self.pinMapImage.isHidden = true
                    self.mapView.isHidden = false
                    
                    // Set the pin
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = placemarkLocation.coordinate
                    
                    self.mapView.addAnnotation(annotation)
                    
                    // Zooming and panning map content
                    // https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/LocationAwarenessPG/MapKit/MapKit.html#//apple_ref/doc/uid/TP40009497-CH3-SW42
                    if !self.zoomSet {
                        var theRegion = self.mapView.region
                        theRegion.span.longitudeDelta /= OnTheMapConstants.MapView.zoomLevel
                        theRegion.span.latitudeDelta /= OnTheMapConstants.MapView.zoomLevel
                        
                        self.mapView.region = theRegion
                        self.zoomSet = true
                    }
                    
                    // Centre the map on the user's location
                    self.mapView.setCenter(placemarkLocation.coordinate, animated: true)
                }
                
                // Post the student's location
                DataService.postStudentLocation(locationString: location, latitude: placemarkLocation.coordinate.latitude, longitude: placemarkLocation.coordinate.longitude, website: website) {
                    (success) in
                    
                    guard success == true else {
                        DispatchQueue.main.async {
                            self.displayAlert(title: OnTheMapConstants.Alert.postErrorTitle, message: OnTheMapConstants.Alert.postErrorMessage)
                        }
                        return
                    }
                    
                    // Update the UI
                    DispatchQueue.main.async {
                        // Stop animating the activity indicator
                        self.activityIndicator.stopAnimating()
                        
                        self.cancelButton.isHidden = true
                        self.locationTextField.isEnabled = false
                        self.websiteTextField.isEnabled = false
                        self.submitButton.isHidden = true
                        self.doneButton.isHidden = false
                    }
                }
            }
        }
    }
}

// MARK: MKMapViewDelegate

extension PostViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Use an existing annotation view
        if let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: OnTheMapConstants.MapView.pinAnnotationViewReuseIdentifier) as? MKPinAnnotationView {
            pinView.annotation = annotation
            return pinView
        } else {
            // Create a new annotation view
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: OnTheMapConstants.MapView.pinAnnotationViewReuseIdentifier)
            pinView.canShowCallout = false
            return pinView
        }
    }
}

// MARK: UITextFieldDelegate

extension PostViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if locationTextField.isFirstResponder {
            return locationTextField.resignFirstResponder()
        } else if websiteTextField.isFirstResponder {
            return websiteTextField.resignFirstResponder()
        } else {
            return false
        }
    }
}
