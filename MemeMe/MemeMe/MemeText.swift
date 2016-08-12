//
//  MemeText.swift
//  MemeMe
//
//  Created by Ryan Harri on 2016-08-12.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import UIKit

class MemeText {
    
    /* rougeExciter (2014) How to enumerate an enum with String type?
     Available at: http://stackoverflow.com/a/24137319 (Accessed: 12 Aug 2016) */
    enum Font: String {
        case Impact = "Impact"
        case HelveticaNeueCondensedBlack = "HelveticaNeue-CondensedBlack"
        case MarkerFelt = "Marker Felt"
        case AmericanTypewriter = "American Typewriter"
        
        static let fonts = [Impact, HelveticaNeueCondensedBlack, MarkerFelt, AmericanTypewriter]
    }
    
    private let defaultFontSize: CGFloat
    private var fontIndex: Int
    private var fonts = [UIFont]()
    
    let defaultFont: UIFont
    let textAttributes: [String: AnyObject]?
    let textAlignment: NSTextAlignment
    let autocapitalizationType: UITextAutocapitalizationType
    
    var nextFont: UIFont {
        // Cycles through the array of available fonts
        get {
            let font = fonts[fontIndex]
            
            if fontIndex == fonts.count - 1 {
                fontIndex = 0
            } else {
                fontIndex += 1
            }
            return font
        }
    }
    
    init() {
        defaultFontSize = CGFloat(40)
        fontIndex = 1
        
        /* Dipen Panchasara (2013) uifont 'Impact' not working for iOS
         Available at: http://stackoverflow.com/a/15598079 (Accessed: 10 Aug 2016) */
        if let impactFont = UIFont(name: Font.Impact.rawValue, size: defaultFontSize) {
            defaultFont = impactFont
        } else {
            defaultFont = UIFont(name: Font.HelveticaNeueCondensedBlack.rawValue, size: defaultFontSize)!
        }
        
        textAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : defaultFont,
            NSStrokeWidthAttributeName : -2.0
        ]
        
        textAlignment = .Center
        autocapitalizationType = .AllCharacters
        
        // Build an array of fonts to support the nextFont computed property
        for font in Font.fonts {
            if let fontToAppend = UIFont(name: font.rawValue, size: defaultFontSize) {
                fonts.append(fontToAppend)
            }
        }
    }
}