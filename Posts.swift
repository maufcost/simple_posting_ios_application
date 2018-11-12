//
//  Posts.swift
//  Line Version 1
//
//  Created by Mauricio Figueiredo Mattos Costa on 09/11/18.
//  Copyright © 2018 Mauricio Figueiredo. All rights reserved.
//

import Foundation

class Post {
    var id: String
    var author: UserProfile
    var text: String
    var createdAt: Date
    
    init(id: String, author: UserProfile, text: String, timestamp: Double) {
        self.id = id
        self.author = author
        self.text = text
        self.createdAt = Date(timeIntervalSince1970: timestamp/1000)
    }
}
