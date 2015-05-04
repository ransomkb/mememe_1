//
//  Meme.swift
//  MemeMe
//
//  Created by Ransom Barber on 4/30/15.
//  Copyright (c) 2015 Hart Book. All rights reserved.
//

import Foundation
import UIKit

// Model for storing Meme data
struct Meme {
    // Text properties
    var topText: String?
    var bottomText: String?
    
    // Image properties
    var originalImage: UIImage!
    var memedImage: UIImage!
    
    // Initializer as requested, but I thought all structures had a default one, if you used the properties' names.
    init(topText: String!, bottomText: String!, originalImage: UIImage!, memedImage: UIImage) {
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.memedImage = memedImage
    }
}
