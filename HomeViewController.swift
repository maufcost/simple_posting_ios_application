//
//  HomeViewController.swift
//  Line Version 1
//
//  Created by Mauricio Figueiredo Mattos Costa on 08/11/18.
//  Copyright © 2018 Mauricio Figueiredo. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView!
    
    var posts = [Post]()
    
    // Setting up some variables for infinite scrolling.
    var fetchingMore = false
    var endReached = false
    let leadingScreensForBatching: CGFloat = 3 // Number of screens forr  the program to start fetching new posts.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Creating the Table View.
        tableView = UITableView(frame: view.bounds, style: .plain)
        
        // Importing the .xib file.
        let cellNib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "postCell")
        view.addSubview(tableView)
        
        // Setting table constraints.
        let layoutGuide: UILayoutGuide! = view.layoutMarginsGuide // iPhone X (iOS 11): .safeAreaLayoutGuide
        tableView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        
        // Making the cell height resizable (we need both statements below)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        
        // Final table setup
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView() // Gets rid of empty space in the bottom of the table (when there were only three posts, remember?
        tableView.reloadData()
        
        // The first call (the first 20 posts). This function will only be called again when the user scrolls through the table.
        beginBatchFetch()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
        cell.set(post: posts[indexPath.row])
        return cell
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        }catch {
            print("Error signing out")
            return
        }
    }
    
    func observePosts(completion: @escaping (_ posts: [Post])->()) {
        // Fetches posts.
        let postsRef = Database.database().reference().child("posts")
        let lastPost = self.posts.last
        var queryRef: DatabaseQuery
        
        if lastPost == nil {
            // First call to this method.
            queryRef = postsRef.queryOrdered(byChild: "timestamp").queryLimited(toLast: 20)
        }else {
            // Subsequent calls to this method.
            let lastTimeStamp = lastPost!.createdAt.timeIntervalSince1970 * 1000
            queryRef = postsRef.queryOrdered(byChild: "timestamp").queryEnding(atValue: lastTimeStamp).queryLimited(toLast: 20) // inclusive (!)1.
        }
        
        queryRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            var tempPosts: [Post] = []
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot, // 'childSnapshot' is the right format that we need to use the retrieved data. It is also needed for us to use they id of the retrieved child below.
                    let dict = childSnapshot.value as? [String:Any],
                    let author = dict["author"] as? [String:Any],
                    let uid = author["uid"] as? String,
                    let username = author["username"] as? String,
                    let photoURL = author["photoURL"] as? String,
                    let url = URL(string: photoURL),
                    let text = dict["text"] as? String,
                    let timestamp = dict["timestamp"] as? Double {
                    
                    // (!)1 Eliminating the included (repeated) post fetched above.
                    if childSnapshot.key != lastPost?.id {
                        let userProfile = UserProfile(username: username, uid: uid, photoURL: url)
                        let post = Post(id: childSnapshot.key, author: userProfile, text: text, timestamp: timestamp)
                        tempPosts.insert(post, at: 0)
                    }
                    
                }else {
                    print("Error detected when I was trying to retrieve posts.")
                }
            }
            completion(tempPosts)
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // This function is called when our table is scrolled by the user.
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.size.height * self.leadingScreensForBatching {
            
            if !self.fetchingMore && !self.endReached {
                beginBatchFetch()
            }
        }
    }
    
    func beginBatchFetch() {
        self.fetchingMore = true
        
        // Fetching posts.
        observePosts { (newPosts) in
            self.posts.append(contentsOf: newPosts)
            self.endReached = newPosts.count == 0
            self.fetchingMore = false
            self.tableView.reloadData()
        }
    }
}








