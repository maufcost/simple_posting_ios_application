//
//  UserService.swift
//  Line Version 1
//
//  Created by Mauricio Figueiredo Mattos Costa on 10/11/18.
//  Copyright © 2018 Mauricio Figueiredo. All rights reserved.
//

import Foundation
import Firebase

class UserService {
    
    static var currentUserProfile: UserProfile? // Whoever is logged in.
    
    static func observeUserProfile(_ uid: String, completion: @escaping (_ userProfile: UserProfile?)->()) {
        // Gets user object based on its uid.
        let userRef = Database.database().reference().child("users/profile/\(uid)")
        
        userRef.observe(.value, with: { snapshot in
            var userProfile: UserProfile?
            
            if let dict = snapshot.value as? [String:Any],
                let username = dict["username"] as? String,
                let photoURL = dict["photoURL"] as? String,
                let url = URL(string: photoURL){
                
                userProfile = UserProfile(username: username, uid: snapshot.key, photoURL: url)
            }
            
            completion(userProfile)
        })
    }
}
// A little bit more about closures: https://www.andrewcbancroft.com/2017/04/26/what-in-the-world-is-an-escaping-closure-in-swift/
