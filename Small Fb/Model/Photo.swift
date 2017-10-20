//
//  Album.swift
//  Small Fb
//
//  Created by Heitem OULED-LAGHRIYEB on 10/19/17.
//  Copyright © 2017 Heitem OULED-LAGHRIYEB. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class Photo {
    private var _image: UIImage!
    
    var image: UIImage {
        return _image
    }
    
    init(image: UIImage) {
        self._image = image
    }
}
