//
//  ViewController.swift
//  Small Fb
//
//  Created by Heitem OULED-LAGHRIYEB on 10/18/17.
//  Copyright © 2017 Heitem OULED-LAGHRIYEB. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class SignUpVC: UIViewController {
    
    @IBOutlet weak var emailField: SignUpTextField!
    @IBOutlet weak var passwordField: SignUpTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let _ = KeychainWrapper.standard.string(forKey: "uid") {
            performSegue(withIdentifier: "goToFbConnect", sender: nil)
        }
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        if let email = emailField.text, let password = passwordField.text {
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    print("Heitem: Email user authenticated successfully with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    Auth.auth().createUser(withEmail: email, password: password, completion: { (user , error) in
                        if error != nil {
                            print("Heitem: Unable to authenticate with Firebase using email \(String(describing: error))")
                        } else {
                            print("Heitem: Successfully authenticated with Firebase")
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                self.completeSignIn(id: user.uid, userData: userData)
                            }
                        }
                    })
                }
            })
        }
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: "uid")
        print("Heitem: Data saved to keychain \(keychainResult)")
        performSegue(withIdentifier: "goToFbConnect", sender: nil)
    }
}

