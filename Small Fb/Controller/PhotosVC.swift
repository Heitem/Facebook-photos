//
//  AlbumsVC.swift
//  Small Fb
//
//  Created by Heitem OULED-LAGHRIYEB on 10/19/17.
//  Copyright © 2017 Heitem OULED-LAGHRIYEB. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import SwiftKeychainWrapper
import Firebase

class PhotosVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var photos = [Photo]()
    //var photo: Photo!
    var token: FBSDKAccessToken!
    var uid: String!
    
    var selectedPhotos: [UIImage]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        
        token = FBSDKAccessToken.current()
        if token != nil {
            uid = token.userID
            print("Heitem: \(uid!)")
            print("Heitem: \(token.tokenString!)")
            fetchPhotos()
        }
    }
    
    func fetchPhotos() {
        print("Heitem: Fetching photos")
        let params = ["type":"uploaded"]
        FBSDKGraphRequest(graphPath: "/me/photos", parameters: params, httpMethod: "GET").start { (connection, result, error) in
            if error != nil {
                print("Heitem: \(error!)")
                return
            } else {
                print("Heitem: result = \(result!)")
                if let dict = result.result.value["data"] as? Dictionary<String, AnyObject> {
                    
                    //Get photos URL
                }
            }
        }
    }
    
    func storeImage(images: [UIImage]){
        for img in images {
            let imageData = UIImageJPEGRepresentation(img, 1.0)
            let uploadRef = DataService.ds.REF_PHOTOS.child("\(randomString(length: 5)).jpg")
            
            uploadRef.putData(imageData!, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print("Heitem: Error while storing image \(String(describing: error))")
                } else {
                    print("Heitem: Image stored successfully in Firebase")
                }
            })
        }
    }
    
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoCell {
            let photo = photos[indexPath.row]
            cell.configureCell(photo)
            
            return cell
            
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell{
            if let image = cell.image.image {
                selectedPhotos.append(image)
            }
        }
    }

    
    @IBAction func signOutTapped(_ sender: Any) {
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: "uid")
        print("ID removed from keychain \(keychainResult)")
        FBSDKLoginManager().logOut()
        try! Auth.auth().signOut()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func storeTapped(_ sender: Any) {
        storeImage(images: selectedPhotos)
    }
}
