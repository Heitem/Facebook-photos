//
//  AlbumCell.swift
//  Small Fb
//
//  Created by Heitem OULED-LAGHRIYEB on 10/19/17.
//  Copyright © 2017 Heitem OULED-LAGHRIYEB. All rights reserved.
//

import UIKit

class AlbumCell: UICollectionViewCell {
    
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var numberImages: UILabel!
    
    var album: Album!
    
    func configureCell( _ album: Album) {
        self.album = album
        //albumImage.image =
        title.text = self.album.title.capitalized
        numberImages.text = "\(self.album.numberOfphotos)"
        //numberImages.image = UIImage(named: "\()")
    }
}
