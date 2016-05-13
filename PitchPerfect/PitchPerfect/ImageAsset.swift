//
//  ImageAsset.swift
//  PitchPerfect
//
//  Created by Ryan Harri on 2016-05-11.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import UIKit

extension UIImage {
    
    /* Apple (2015) Swift in Practice. 
     Available at: https://developer.apple.com/videos/play/wwdc2015/411/ (Accessed: 11 May 2016) */
    
    enum AssetIdentifier: String {
        case SnailButton = "Snail Button"
        case RabbitButton = "Rabbit Button"
        case ChipmunkButton = "Chipmunk Button"
        case TIEFighterButton = "TIE Fighter Button"
        case EchoButton = "Echo Button"
        case ReverbButton = "Reverb Button"
        case StopButtonLarge = "Stop Button Large"
        case SnailButtonSmall = "Snail Button Small"
        case RabbitButtonSmall = "Rabbit Button Small"
        case ChipmunkButtonSmall = "Chipmunk Button Small"
        case TIEFighterButtonSmall = "TIE Fighter Button Small"
        case EchoButtonSmall = "Echo Button Small"
        case ReverbButtonSmall = "Reverb Button Small"
        case StopButtonSmall = "Stop Button"
    }
    
    convenience init!(assetIdentifier: AssetIdentifier) {
        self.init(named: assetIdentifier.rawValue)
    }
}