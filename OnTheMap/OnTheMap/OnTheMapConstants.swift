//
//  OnTheMapConstants.swift
//  OnTheMap
//
//  Created by Ryan Harri on 2016-10-30.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import UIKit

/// A value type used to represent constants used in the various view controllers.
struct OnTheMapConstants {
    
    /// Constant values that are used in conjunction with NotificationCenter.
    struct NotificationName {
        /// The notification name used when data is received from the Parse API.
        static let dataReceivedFromParse = Notification.Name(rawValue: "DataReceivedFromParse")
        
        /// The notification name used when no data is received from the Parse API.
        static let noDataReceivedFromParse = Notification.Name(rawValue: "NoDataReceivedFromParse")
    }
    
    /// Constant values that are used with table views.
    struct TableView {
        static let cellReuseIdentifier = "StudentCell"
    }
    
    /// Constant values that are used with the map views.
    struct MapView {
        static let pinAnnotationViewReuseIdentifier = "OnTheMapAnnotation"
        static let pinTintColour = UIColor(colorLiteralRed: 245.0/255.0, green: 166.0/255.0, blue: 35.0/255.0, alpha: 1.0)
        static let zoomLevel = 12.0
    }
    
    /// Constants values that are used with alert controller views.
    struct Alert {
        static let invalidWebsiteTitle = "Invalid Website Address"
        static let invalidWebsiteMessage = "Please provide a valid website URL (example: https://www.apple.com)."
        
        static let locationErrorTitle = "Location Error"
        static let locationErrorMessage = "Unable to find this location: "
        
        static let postErrorTitle = "Post Error"
        static let postErrorMessage = "Unable to post your location. Please try again."
    }
}
