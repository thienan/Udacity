//
//  Meme.swift
//  MemeMe
//
//  Created by Ryan Harri on 2016-08-10.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import UIKit

struct Meme {
    let topText: String
    let bottomText: String
    let image: UIImage
    let memedImage: UIImage
    
    init?(topText: String, bottomText: String, image: UIImage, memedImage: UIImage) {
        if topText.isEmpty || bottomText.isEmpty {
            return nil
        }
        
        self.topText = topText
        self.bottomText = bottomText
        self.image = image
        self.memedImage = memedImage
    }
}