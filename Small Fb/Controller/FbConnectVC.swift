//
//  FbConnectVC.swift
//  Small Fb
//
//  Created by Heitem OULED-LAGHRIYEB on 10/19/17.
//  Copyright © 2017 Heitem OULED-LAGHRIYEB. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import SwiftKeychainWrapper

class FbConnectVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        if (FBSDKAccessToken.current()) != nil {

            self.performSegue(withIdentifier: "goToAlbums", sender: nil)
        }
        if Auth.auth().currentUser == nil {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func fbConnectTapped(_ sender: Any) {
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["user_photos", "email"], from: self) { (result, error) in
            if error != nil {
                print("Heitem: Unable to authentiate with Facebook. \(String(describing: error!))")
            }
            else if result?.isCancelled == true {
                print("Heitem: User cancelled Facebook authentication")
            }
            else {
                print("Heitem: Successfully authenticated with Facebook")
                
                let params = ["fields":"email,name,picture"]
                FBSDKGraphRequest(graphPath: "me", parameters: params, httpMethod: "GET").start { (connection, result, error) in
                    if error != nil {
                        print("Heitem: \(error!)")
                        return
                    } else {
                        if let dict = result as? NSDictionary {
                            print("Heitem: \(connection?.urlResponse!), \(result!)")
                            if let name = dict["name"] as? String {
                                DataService.ds.REF_USER_CURRENT.child("name").setValue(name)
                                DataService.ds.REF_USER_CURRENT.child("email").setValue(Auth.auth().currentUser?.email)
                            }
                        }
                    }
                }
                //self.performSegue(withIdentifier: "goToAlbums", sender: nil)
            }
        }
    }
}
