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
import SwiftyJSON

class Album {
    private var _albumImage: UIImage!
    private var _title: String!
    private var _numberOfPhotos: Int!
    
    var albumImage: UIImage {
        return _albumImage
    }
    
    var title: String {
        return _title
    }
    
    var numberOfphotos: Int {
        return _numberOfPhotos
    }
    
    init(albumImage: UIImage, title: String, numberOfPhotos: Int) {
        self._albumImage = albumImage
        self._title = title
        self._numberOfPhotos = numberOfPhotos
    }
    
    func downloadAlbums(completed: @escaping DownloadComplete) {
        FBSDKGraphRequest(graphPath: "/me/albums", parameters: ["fields":"id,name,user_photos"], httpMethod: "GET").start { (connection, result, error) in
            
            if let error = error {
                print(error.localizedDescription)
            } else {
                let json = JSON(result!)
                print(json)
            }
            
//            self._albumImage = UIImage()
//            self._title = ""
//            self._numberOfPhotos = 10
        }
        
        completed()
    }
}
