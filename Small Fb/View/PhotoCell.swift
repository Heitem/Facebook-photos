//
//  AlbumCell.swift
//  Small Fb
//
//  Created by Heitem OULED-LAGHRIYEB on 10/19/17.
//  Copyright © 2017 Heitem OULED-LAGHRIYEB. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var selectionView: UIView!
    //    @IBOutlet weak var title: UILabel!
//    @IBOutlet weak var numberImages: UILabel!
    
    var photo: Photo!
    
    func configureCell( _ photo: Photo) {
        self.photo = photo
        image.image = photo.image
    }
}
