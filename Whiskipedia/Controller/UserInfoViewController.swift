//
//  UserInfoViewController.swift
//  Whiskipedia
//
//  Created by ZHI XUAN MO on 4/7/20.
//  Copyright © 2020 zhixuan mo. All rights reserved.
//

import UIKit
import Firebase


private let CellreuseIdentifier = "PostCell"
private let HeaderreuseIdentifier = "UserInfoHeader"
private let PostSegueID = "InfoToPost"


protocol UserinfoVCdelecate {
    func reset()
}


class UserInfoViewController: UICollectionViewController , UICollectionViewDelegateFlowLayout , UserHeaderDelegate , editProfileVCdelegate{
    
    
    
    
    @objc func btnPressedHandler(_ header: UserInfoHeader, action: Bool) {
        print(self.header!.EditOrFollowBtn.title(for: .normal))
        
        if self.header?.EditOrFollowBtn.title(for: .normal) == "Edit Profile"
        {
            let profileChangeVC = EditProfileVC()
            profileChangeVC.myImage = self.header?.ProfileImage.image
            profileChangeVC.delegate = self
            self.navigationController?.pushViewController(profileChangeVC, animated: true)
        }
        else if self.header?.EditOrFollowBtn.title(for: .normal) == "Follow" ||  self.header?.EditOrFollowBtn.title(for: .normal) == "Unfollow"
        {
        self.follow_unfollow(uid: (self.header?.user.UID)!, action: self.header!.EditOrFollowBtn.title(for: .normal)!)
        }
    }
    
    //MARK: - Property setup
    var user : User?
    var guestUser : User?
    let db = Firestore.firestore()
    var Loading = 0
    var header : UserInfoHeader?
    var delegate : UserSearchViewController?
    var postIDs : [String]?
    var postlIst : [Post] = [Post]()
    var selectedPost : Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnSetup()
        self.collectionView!.register(UINib(nibName: HeaderreuseIdentifier, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderreuseIdentifier)
        self.collectionView.register(PostCell.self, forCellWithReuseIdentifier: CellreuseIdentifier)
        // Load User
        if guestUser == nil { loadUser(uid: Auth.auth().currentUser!.uid) }
        else { loadUser(uid: guestUser!.UID) }
    }
    
    func reloadUser(with user: User) {
        self.user = user
        self.collectionView.reloadData()
    }
    
    
    func btnSetup()
    {
        if let _ = delegate
        {
        self.navigationItem.hidesBackButton = true
        let button = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(goBack))
        self.navigationItem.leftBarButtonItem = button
        }
    }
     
    @objc func goBack()
    {
        delegate!.reset()
        self.navigationController?.popViewController(animated: true)
    }

   
    // MARK: - Header Setup
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderreuseIdentifier, for: indexPath) as! UserInfoHeader
        header.delegate = self 
        if let user = self.user{
            header.setup(with: user)
            self.navigationItem.title = user.username
        }
        else if let guestuser = self.guestUser
            {
                header.setup(with: guestuser)
                self.navigationItem.title = guestuser.username
            }
        header.EditOrFollowBtn.tag = 0
        header.EditOrFollowBtn.addTarget(self, action: #selector(self.btnPressedHandler(_:action:)), for: .touchUpInside)
        self.header = header
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 150)
    }
    
    
    // MARK: CollectionView DataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Loading
    }

    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postlIst.count ?? 0
    }

    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellreuseIdentifier, for: indexPath) as! PostCell
        cell.photoImageView.SetURLImage(with: postlIst[indexPath.row].imageURL!)
        return cell
    }
    
    
    //MARK: - UICollectionView Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ((self.view.frame.width - 3 ) / 4), height: (self.collectionView.frame.width - 3) / 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
       
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    //MARK: - Transition to Detail View
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedPost = postlIst[indexPath.row]
        performSegue(withIdentifier: PostSegueID, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PostSegueID
        {
            let destination = segue.destination as! PostDetailVC
            destination.selectedPost = self.selectedPost
            destination.usericon = self.header?.ProfileImage.image
        }
    }
    

  // MARK: - API methods

    func loadUser(uid: String)
    {
        //guard let userID = Auth.auth().currentUser?.uid else { return }

        let userFile = db.collection("user").document(uid)
            userFile.getDocument { (querysnapshot, error) in
                if error != nil
                {
                    print(error!.localizedDescription)
                    return
                }
                else
                {   
                    let doc = querysnapshot!.data() as! Dictionary<String,AnyObject>
                    self.user = constructUser(uid: uid, dic: doc)
                    self.navigationItem.title = self.user?.username!
                    self.postIDs = self.user?.posts
                    self.Loading = 1
                    self.loadPost()
                    self.collectionView.reloadData()
                }
            }
    }
    
    func loadPost()
    {
        LoadingIndicator.start(style: .large, color: .white);

        self.postlIst = [Post]()
        print("loading post")
        print(postIDs?.count)
        for postID in postIDs!
        {
            print(postID)
            db.collection("reviews").document(postID).getDocument { (snapshot, error) in
                if let e = error
                {
                    print(e.localizedDescription)
                }
                else
                {
                    let dic = snapshot!.data() as! Dictionary<String,AnyObject>
                    let loaded_post = Post(dic: dic)
                    loaded_post.postID = snapshot?.documentID
                    self.postlIst.append(loaded_post)
                    self.collectionView.reloadData()
                    LoadingIndicator.stop();
                }
            }
        }
    }
    
    
    
    
    func follow_unfollow(uid:String , action: String)
    {
        let myid = Auth.auth().currentUser?.uid
        let myRef = db.collection("user").document(myid!)
        let targetRef = db.collection("user").document(uid)
        LoadingIndicator.start(style: .large, color: .white);

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            
            let myDoc : DocumentSnapshot
            do{
                try  myDoc = transaction.getDocument(myRef)
            }
            catch let fetchError as NSError
            {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            let targetDoc : DocumentSnapshot
            do {
                try targetDoc = transaction.getDocument(targetRef)
            }
            catch let fetchError as NSError
            {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var My_Following_List = myDoc.data()?["Following"] as? [String] else
            {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(myDoc)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            guard var Target_Follower_List = targetDoc.data()?["Followers"] as? [String] else
                   {
                       let error = NSError(
                           domain: "AppErrorDomain",
                           code: -1,
                           userInfo: [
                               NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(targetDoc)"
                           ]
                       )
                       errorPointer?.pointee = error
                       return nil
                   }
            
            if action == "Follow" && !(Target_Follower_List.contains(myid!)) && !(My_Following_List.contains(uid))
            {
                Target_Follower_List.append(myid!)
                My_Following_List.append(uid)
            }
            else if action == "Unfollow" && Target_Follower_List.contains(myid!) && My_Following_List.contains(uid)
            {
                Target_Follower_List.remove(object: myid!)
                My_Following_List.remove(object: uid)
            }
            
            transaction.updateData(["Following":My_Following_List], forDocument: myRef)
            transaction.updateData(["Followers":Target_Follower_List], forDocument: targetRef)
            
            return nil
        }) { (object, error) in
            if let error = error
            {
                print("Transaction failed: \(error.localizedDescription)")
            }
            else
            {
                self.loadUser(uid: self.guestUser!.UID)
                LoadingIndicator.stop();
                print("Transaction Successful")
            }
            
        }
    }

   

}

