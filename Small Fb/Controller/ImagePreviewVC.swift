//
//  ImagePreviewVC.swift
//  Small Fb
//
//  Created by Heitem OULED-LAGHRIYEB on 10/28/17.
//  Copyright © 2017 Heitem OULED-LAGHRIYEB. All rights reserved.
//

import UIKit
import ImageScrollView

class ImagePreviewVC: UIViewController{
    
    @IBOutlet weak var imageScrollView: ImageScrollView!
    
    var p: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        imageScrollView.display(image: p)
    }
}
