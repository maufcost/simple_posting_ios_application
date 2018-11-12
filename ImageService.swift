//
//  ImageService.swift
//  Line Version 1
//
//  Created by Mauricio Figueiredo Mattos Costa on 10/11/18.
//  Copyright © 2018 Mauricio Figueiredo. All rights reserved.
//

import Foundation
import UIKit

class ImageService {
    
    static func downloadImage(withURL url:URL, completion: @escaping (_ image:UIImage?) -> ()) {
        // Downloads the specified image from the url from Firebase.
        
        // URLSession is an API that makes it easier for us to make these downloads.
        // Using the shared session to fetch the contents of a URL to memory.
        let dataTask = URLSession.shared.dataTask(with: url) { (data, url, error) in
            
            var downloadedImage: UIImage?
            
            if let data = data {
                downloadedImage = UIImage(data: data)
            }
            
            completion(downloadedImage)
        }
        
        // Actually starts the task.
        dataTask.resume()
    }
    
    static func getImage(withURL url:URL, completion: @escaping (_ image:UIImage?) -> ()) {
        
    }
}
