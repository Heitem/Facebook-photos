//
//  ProfileVC.swift
//  Small Fb
//
//  Created by Heitem OULED-LAGHRIYEB on 10/27/17.
//  Copyright © 2017 Heitem OULED-LAGHRIYEB. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import Firebase

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var dateBirthField: UITextField!
    @IBOutlet weak var infosView: UIView!
    @IBOutlet weak var photosView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var imagePicker: UIImagePickerController!
    var datePicker : UIDatePicker!
    var user: User!
    var firstTimeLoaded = false
    var photos = [Photo]()
    var photosUrl = [String]()
    var previewed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        lpgr.minimumPressDuration = 0.2
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.collectionView.addGestureRecognizer(lpgr)
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        dateBirthField.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        photosView.isHidden = true
        
        DataService.ds.REF_USER_CURRENT.observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let email = value?["email"] as? String
            let name = value?["name"] as? String
            var dateBirth = value?["date_birth"] as? String
            var profilePicUrl = value?["profile_pic"] as? String
            if dateBirth == nil {
                dateBirth = ""
            }
            if profilePicUrl == nil {
                profilePicUrl = ""
            }
            self.user = User(email: email!, name: name!, dateBirth: dateBirth!, profilePicUrl: profilePicUrl!)
            self.emailField.text = self.user.email
            self.nameField.text = self.user.name
            self.dateBirthField.text = self.user.dateBirth
            
            //print("Heitem: \(value!)")
            
            DataRequest.addAcceptableImageContentTypes(["image/jpg"])
            Alamofire.request(profilePicUrl!).responseImage { response in
                
                debugPrint(response)
                debugPrint(response.result)
                
                if let image = response.result.value {
                    self.profileImg.image = image
                    print("Heitem: Image downloaded successfully")
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImg.image = image
        } else {
            print("A valid image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        user.email = emailField.text!
        user.name = nameField.text!
        user.dateBirth = dateBirthField.text!
        if profileImg.image != UIImage(named: "profile-placeholder") {
            if let imageData = UIImageJPEGRepresentation(profileImg.image!, 0.2) {
                let metaData = StorageMetadata()
                let imgUid = NSUUID().uuidString
                metaData.contentType = "image/jpeg"
                DataService.ds.REF_PHOTOS.child(imgUid).putData(imageData, metadata: metaData, completion: { (metadata, error) in
                    if error != nil {
                        print("Heitem: Error while storing image")
                    } else {
                        let downloadUrl = metadata?.downloadURL()?.absoluteString
                        if let url = downloadUrl {
                            print("URL = \(url)")
                            self.user.profilePicUrl = url
                            let user: Dictionary<String, String> = [
                                "email": self.user.email,
                                "name": self.user.name,
                                "date_birth": self.user.dateBirth,
                                "profile_pic": self.user.profilePicUrl
                            ]
                            DataService.ds.REF_USER_CURRENT.setValue(user)
                            print("Heitem:  Image stored successfully in Firebase")
                            let alertController = UIAlertController(title: "Success", message:
                                "Your profile informations have been successfully saved", preferredStyle: UIAlertControllerStyle.alert)
                            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
                            
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                })
            }
        }
        
    }
    @IBAction func addImageTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func pickUpDate(_ textField : UITextField){
        
        // DatePicker
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.datePicker.backgroundColor = UIColor.white
        self.datePicker.datePickerMode = UIDatePickerMode.date
        textField.inputView = self.datePicker
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
    }
    
    @objc func doneClick() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateBirthField.text = dateFormatter.string(from: datePicker.date)
        dateBirthField.resignFirstResponder()
    }
    @objc func cancelClick() {
        dateBirthField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.pickUpDate(self.dateBirthField)
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            infosView.isHidden = false
            photosView.isHidden = true
        case 1:
            infosView.isHidden = true
            photosView.isHidden = false
            if firstTimeLoaded == false {
                activityIndicator.startAnimating()
                DataService.ds.REF_USER_CURRENT.child("images").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let value = snapshot.value as? [String: AnyObject] {
                        for photo in value {
                            if let imageUrl = photo.value["imageUrl"] as? String {
                                print("Heitem: \(imageUrl)")
                                self.photosUrl.append(imageUrl)
                                DataRequest.addAcceptableImageContentTypes(["image/jpg"])
                                Alamofire.request(imageUrl).responseImage { response in
                                    
                                    debugPrint(response)
                                    print(response.request!)
                                    print(response.response!)
                                    debugPrint(response.result)
                                    
                                    if let image = response.result.value {
                                        self.photos.append(Photo(image: image))
                                        print("Heitem: Images downloaded successfully: \(image)")
                                        print("Heitem: photos \(self.photos.count)")
                                        self.activityIndicator.stopAnimating()
                                        self.collectionView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                    
                }) { (error) in
                    print(error.localizedDescription)
                }
                firstTimeLoaded = true
            }
        default:
            break
        }
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //let height = self.view.frame.size.height
        
        let width  = self.view.frame.size.width
        
        return CGSize(width: width * 0.465, height: width * 0.465)
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
                        performSegue(withIdentifier: "toPreview", sender: image)
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
