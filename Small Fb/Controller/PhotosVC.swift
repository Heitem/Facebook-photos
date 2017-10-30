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

class PhotosVC: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    var previewed: Bool = false
    
    var photos = [Photo]()
    var urls = [String]()
    //var photo: Photo!
    var token: FBSDKAccessToken!
    var uid: String!
    
    var selectedPhotos = [Int: UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        lpgr.minimumPressDuration = 0.2
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.collectionView.addGestureRecognizer(lpgr)
        
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
                            let firebasePost = DataService.ds.REF_USER_CURRENT.child("images").childByAutoId()
                            firebasePost.setValue(imagePost)
                        }
                    }
                })
            }
        }
        let alertController = UIAlertController(title: "Success", message:
            "Selected pictures have been successfully saved to Firebase", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //let height = self.view.frame.size.height
        
        let width  = self.view.frame.size.width
        
        return CGSize(width: width * 0.465, height: width * 0.465)
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
    
    @IBAction func shareTapped(_ sender: Any) {
        
        var images = [UIImage]()
        for (_, img) in selectedPhotos {
            images.append(img)
        }
        let activityViewController = UIActivityViewController(activityItems: images, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list
        //activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        
        if gestureReconizer.state == UIGestureRecognizerState.ended {
            return
        }
        
        let p = gestureReconizer.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: p)
        
        if let index = indexPath {
            if let cell = self.collectionView.cellForItem(at: index) as? PhotoCell {
                if let image = cell.image.image {
                    if previewed == false {
                        performSegue(withIdentifier: "previewImage", sender: image)
                        previewed = true
                    }
                }
            }
            
        } else {
            print("Could not find index path")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ImagePreviewVC {
            if let photo = sender as? UIImage {
                destination.p = photo
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        previewed = false
    }
}
