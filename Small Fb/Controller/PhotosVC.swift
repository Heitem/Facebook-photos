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
import Alamofire
import AlamofireImage

class PhotosVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    var photos = [Photo]()
    var urls = [String]()
    //var photo: Photo!
    var token: FBSDKAccessToken!
    var uid: String!
    
    var selectedPhotos = [Int: UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        token = FBSDKAccessToken.current()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        
        activityIndicator.startAnimating()
        
        if token != nil {
            uid = token.userID
            //print("Heitem: \(uid!)")
            //print("Heitem: \(token.tokenString!)")
            getUrls {
                
                print("Heitem: urls \(self.urls.count)")
                self.getImages {
                    //print("Heitem: photos \(self.photos.count)")
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    func getUrls(completed: @escaping DownloadComplete) {
        print("Heitem: Fetching photos")
        let params = ["type":"uploaded"]
        FBSDKGraphRequest(graphPath: "/me/photos", parameters: params, httpMethod: "GET").start { (connection, result, error) in
            if error != nil {
                print("Heitem: \(error!)")
                return
            } else {
                if let dict = result as? NSDictionary {
                    //print("H: \(dict)")
                    if let data = dict["data"] as? [Dictionary<String, String>], data.count > 0 {
                        for d in data {
                            if let id = d["id"] {
                                //print("HH: \(id)")
                                let imageUrl = "\(URL_BASE)/\(id)/picture?access_token=\(self.token.tokenString!)"
                                //print("Heitem: \(imageUrl)")
                                self.urls.append(imageUrl)
                            }
                        }
                        completed()
                    }
                }
            }
        }
    }
    
    func getImages(completed: @escaping DownloadComplete) {
        DataRequest.addAcceptableImageContentTypes(["image/jpg"])
        for imageUrl in urls {
            
            Alamofire.request(imageUrl).responseImage { response in
                
                debugPrint(response)
                print(response.request!)
                print(response.response!)
                debugPrint(response.result)
                
                if let image = response.result.value {
                    self.photos.append(Photo(image: image))
                    print("Heitem: Images downloaded successfully: \(image)")
                    print("Heitem: photos \(self.photos.count)")
                    self.collectionView.reloadData()
                }
            }
        }
        completed()
    }
    
//    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            completion(data, response, error)
//            }.resume()
//    }
//
//    func downloadImage(url: URL) -> UIImage {
//        print("Download Started")
//        var image: UIImage!
//        getDataFromUrl(url: url) { data, response, error in
//            guard let data = data, error == nil else { return }
//            print(response?.suggestedFilename ?? url.lastPathComponent)
//            print("Download Finished")
//            image = UIImage(data: data)
//        }
//        return image
//    }
    
    func storeImage(images: [Int:UIImage]){
        print("Heitem: Storing selected images")
        for (_, img) in images {
            if let imageData = UIImageJPEGRepresentation(img, 0.2) {
                let metaData = StorageMetadata()
                let imgUid = NSUUID().uuidString
                metaData.contentType = "image/jpeg"
                DataService.ds.REF_PHOTOS.child(imgUid).putData(imageData, metadata: metaData, completion: { (metadata, error) in
                    if error != nil {
                        print("Heitem: Error while storing image")
                    } else {
                        print("Heitem:  Image stored successfully in Firebase")
                        let downloadUrl = metadata?.downloadURL()?.absoluteString
                        if let url = downloadUrl {
                            print("URL = \(url)")
                            let imagePost: Dictionary<String, AnyObject> = [
                                "imageUrl": url as AnyObject
                            ]
                            let firebasePost = DataService.ds.REF_IMAGE_RECORD.childByAutoId()
                            firebasePost.setValue(imagePost)
                        }
                    }
                })
            }
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
            cell.selectionView.isHidden = false
            if let image = cell.image.image {
                selectedPhotos[indexPath.row] = image
            }
            print("Heitem: Image selected, selectedPhotos: \(selectedPhotos.count)")
            toolbar.isHidden = false
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell{
            cell.selectionView.isHidden = true
            selectedPhotos[indexPath.row] = nil
            print("Heitem: Image deselected, selectedPhotos: \(selectedPhotos.count)")
        }
        
        if(selectedPhotos.count != 0) {
            toolbar.isHidden = false
        } else {
            toolbar.isHidden = true
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
