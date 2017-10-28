//
//  DataService.swift
//  Small Fb
//
//  Created by Heitem OULED-LAGHRIYEB on 10/19/17.
//  Copyright © 2017 Heitem OULED-LAGHRIYEB. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper

let DB_BASE = Database.database().reference()
let STORAGE_BASE = Storage.storage().reference()

class DataService {
    static let ds = DataService()
    
    //Database references
    private var _REF_BASE = DB_BASE
    private var _REF_IMAGE_RECORD = DB_BASE.child("images")
    private var _REF_USERS = DB_BASE.child("users")
    
    //Storage references
    private var _REF_PHOTOS = STORAGE_BASE.child("photos")
    
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_IMAGE_RECORD: DatabaseReference {
        return _REF_IMAGE_RECORD
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_USER_CURRENT: DatabaseReference {
        let uid = KeychainWrapper.standard.string(forKey: "uid")
        let user = REF_USERS.child(uid!)
        return user
    }
    
    var REF_PHOTOS: StorageReference {
        return _REF_PHOTOS
    }
    
    func createFirebaseDBUser(uid: String, userData: Dictionary<String, String>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
}
