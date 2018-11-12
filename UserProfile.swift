//
//  UserProfile.swift
//  Line Version 1
//
//  Created by Mauricio Figueiredo Mattos Costa on 10/11/18.
//  Copyright © 2018 Mauricio Figueiredo. All rights reserved.
//

import Foundation

class UserProfile {

    var username: String
    var uid: String
    var photoURL: URL
    
    init(username: String, uid: String, photoURL: URL){
        self.username = username
        self.uid = uid
        self.photoURL = photoURL
    }
}
