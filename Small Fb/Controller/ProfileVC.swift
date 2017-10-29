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

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var dateBirthField: UITextField!
    var imagePicker: UIImagePickerController!
    var datePicker : UIDatePicker!
    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        dateBirthField.delegate = self
        
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
}
