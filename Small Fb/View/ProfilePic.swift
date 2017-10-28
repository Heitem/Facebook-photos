//
//  ProfilePic.swift
//  Small Fb
//
//  Created by Heitem OULED-LAGHRIYEB on 10/28/17.
//  Copyright © 2017 Heitem OULED-LAGHRIYEB. All rights reserved.
//

import UIKit

class ProfilePic: UIImageView {

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 1.0
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
}
