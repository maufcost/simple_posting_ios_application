//
//  PostTableViewCell.swift
//  Line Version 1
//
//  Created by Mauricio Figueiredo Mattos Costa on 09/11/18.
//  Copyright © 2018 Mauricio Figueiredo. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var postTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(post: Post){
        ImageService.downloadImage(withURL: post.author.photoURL) { (image) in
            self.profileImageView.image = image
        }
        self.usernameLabel.text = post.author.username
        self.subtitleLabel.text = post.createdAt.calendarTimeNow()
        self.postTextLabel.text = post.text
    }
    
}
