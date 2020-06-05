//
//  HomeViewController.swift
//  Whiskipedia
//
//  Created by ZHI XUAN MO on 4/8/20.
//  Copyright © 2020 zhixuan mo. All rights reserved.
//

import UIKit
import Firebase

internal let RefreshControl = UIRefreshControl()

class HomeViewController: UITableViewController,reviewCellDelegate{

    //MARK: - Property setup
    private let cellID = "ReviewCell"
    var followingUsers : Dictionary<String,String> = Dictionary<String,String>()
    var followingList = [String]()
    var postsToShow : [Post] = [Post]()
    let db = Firestore.firestore()
    var index : DocumentSnapshot?
    var postsNum = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.refreshControl = RefreshControl
        btnsetup()
        RefreshControl.tintColor = .brown
        RefreshControl.attributedTitle = NSAttributedString(string: "Loading Posts")
        RefreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        loadFollowingList()
        navigationItem.title = "Whiskipedia"
    }

    func btnsetup()
    {
        let logoutBtn = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
        self.navigationItem.leftBarButtonItem = logoutBtn
    }
    
    @objc func refresh()
    {
        loadFollowingList()
    }
    
    
    //MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsToShow.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:cellID) as! ReviewCell
        let url = followingUsers[postsToShow[indexPath.row].authorID]
        cell.setup(with: postsToShow[indexPath.row], url: url!)
        cell.LikeBtn.tag = indexPath.row
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == postsToShow.count - 1 && postsToShow.count < postsNum
        {
            print("Triggered")
            print("INdex path is \(indexPath.row)")
            print("posttoshow has \(postsToShow.count) elements ")
            loadPost()
        }
    }
    
    //MARK: - Table view layout
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 680
    }
    
    //MARK: - API methods
    
    func loadFollowingList()
    {
        let myref = db.collection("user").document(Auth.auth().currentUser!.uid)
        let usersRef = db.collection("user")
        LoadingIndicator.start(style: .large, color: .white);
        myref.getDocument { (snapshot, error) in
            if let e = error
            {
                print(e.localizedDescription)
            }
            else
            {
                let doc = snapshot?.data()
                let myurl = doc!["profileImageURL"] as! String
                self.followingUsers[Auth.auth().currentUser!.uid] = myurl
                let followingList = doc!["Following"] as! [String]
                self.followingList = followingList
                var posts = [String]()
                print("Start Loading Posts")
                for ids in followingList
                {
                    usersRef.document(ids).getDocument { (Usersnapshot, error) in
                        if let e = error
                        { print(e.localizedDescription) }
                        else
                        {
                            let dic = Usersnapshot!.data()! as Dictionary<String,AnyObject>
                            let postIDs = dic["posts"] as! [String]
                            posts.append(contentsOf: postIDs)
                            self.postsNum = posts.count
                            self.followingUsers[Usersnapshot!.documentID] = (dic["profileImageURL"] as! String)
                            if ids == followingList[0]
                            {
                                print("PostIDs Loading Finish")
                                self.loadPost()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func loadPost()
    {
        var reviewRef = db.collection("reviews").whereField("authorID", in: self.followingList).order(by: "time", descending: true).limit(to: 2)
        if let snapshot = self.index
        {
            reviewRef = reviewRef.start(afterDocument: snapshot)
        }
        
        reviewRef.getDocuments { (reviewSnapshot, error) in
            if let e = error
            {
                print(e.localizedDescription)
            }
            else
            {
                for doc in reviewSnapshot!.documents
                {
                    let reviewData = doc.data() as Dictionary<String,AnyObject>
                    let postToAdd = Post(dic: reviewData)
                    postToAdd.postID = doc.documentID
//                    if let likeList = reviewData["likeList"] as? [String]
//                    {
//                        print("Likelist has \(likeList.count) users")
//                        for user in likeList
//                        {
//                            print("Like User is : " + user)
//                        }
//                    }
                    self.postsToShow.append(postToAdd)
                    self.index = doc
                }
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
                LoadingIndicator.stop();
                
                
            }
        }
        
        
    }
    

    
    @objc func like_unlike(like: Bool, index: Int) {
        LoadingIndicator.start(style: .large, color: .white);
        print("Like/Unlike index is \(index)")
        print("action is \(like ? "Like":"Unlike")")
        let myuid = Auth.auth().currentUser!.uid;
        if like{ postsToShow[index].likeList?.append(myuid)}
        else
        {
            postsToShow[index].likeList?.remove(object: myuid)
        }
        let postRef = db.collection("reviews").document(postsToShow[index].postID!)
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let postDoc : DocumentSnapshot
            do {
                try postDoc = transaction.getDocument(postRef)
            }
            catch let fetchError as NSError
            {
                errorPointer?.pointee = fetchError
                return nil
            }
            guard var LikeList = postDoc.data()?["likeList"] as? [String]
            else
            {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve population from likelist snapshot \(postDoc)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            if like && !LikeList.contains(myuid)
            {
                LikeList.append(myuid)
                print("Liked  \(postRef.documentID)")
            }
            else if !like && LikeList.contains(myuid)
            {
                LikeList.remove(object: myuid)
                print("Unliked  \(postRef.documentID)")
            }
            
            postRef.updateData(["likeList":LikeList])
            return nil
            
        }) { (object, error) in
            if let e = error
            {
                print(e.localizedDescription)
            }
            else
            {
                print("Transaction Successful")
                LoadingIndicator.stop();
                self.tableView.reloadData()
            }
        }
        
    }
    
    
    @objc func logout()
       {
           do {
           try Auth.auth().signOut()
        self.tabBarController?.navigationController?.popToRootViewController(animated: true)
           }
           catch
           {
               print(error.localizedDescription)
           }
       }
    
    
    
    
    
}
  
