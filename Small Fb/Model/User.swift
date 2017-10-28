//
//  User.swift
//  Small Fb
//
//  Created by Heitem OULED-LAGHRIYEB on 10/28/17.
//  Copyright © 2017 Heitem OULED-LAGHRIYEB. All rights reserved.
//

import Foundation
import UIKit

class User {
    private var _name: String!
    private var _email: String!
    private var _dateBirth: String!
    private var _profilePicUrl: String!
    
    var name: String {
        get {
            return _name
        }
        set {
            _name = newValue
        }
    }
    
    var email: String {
        get {
            return _email
        }
        set {
            _email = newValue
        }
    }
    
    var dateBirth: String {
        get {
            return _dateBirth
        }
        set {
            _dateBirth = newValue
        }
    }
    
    var profilePicUrl: String {
        get {
            return _profilePicUrl
        }
        set {
            _profilePicUrl = newValue
        }
    }
    
    init(email: String, name: String, dateBirth: String, profilePicUrl: String) {
        _email = email
        _name = name
        _dateBirth = dateBirth
        _profilePicUrl = profilePicUrl
    }
    
    init() {
        
    }
}
