//
//  UserSearchViewController.swift
//  Whiskipedia
//
//  Created by ZHI XUAN MO on 4/10/20.
//  Copyright © 2020 zhixuan mo. All rights reserved.
//

import UIKit
import Firebase

class UserSearchViewController: UITableViewController,UserinfoVCdelecate {

    //MARK: - Property Setup
    var UserList : [User] = []
    let db = Firestore.firestore()
    let identifier = "UserCell"
    var my_following_list : [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        navigationItem.title = "Users"
        tableView.separatorStyle = .singleLine
        LoadFollowingList()
        LoadUser()
    }
    
    func reset()
    {
        print("Reset Called")
        LoadFollowingList()
        LoadUser()
        self.tableView.reloadData()
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return UserList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! UserCell
        cell.setup(with: UserList[indexPath.row])
        if my_following_list.contains(UserList[indexPath.row].UID)
        {
            cell.FollowingLabel.isHidden = false
        }
        else
        {
            cell.FollowingLabel.isHidden = true
        }
        return cell 
        
    }
    
    // MARK: - TableView Layout
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = UserList[indexPath.row]
        let userprofileVC = self.storyboard?.instantiateViewController(withIdentifier: "UserProfileView") as! UserInfoViewController
        userprofileVC.delegate = self
        userprofileVC.guestUser = user
        userprofileVC.view.backgroundColor = #colorLiteral(red: 0.135846734, green: 0.08868866414, blue: 0.08197902888, alpha: 1)
        navigationController?.pushViewController(userprofileVC, animated: true)
    }


    
}



//MARK: - API Methods 
extension UserSearchViewController
{
    func LoadUser()
    {
        let ref = db.collection("user")
        ref.addSnapshotListener
        { (querySnapshot, error) in
            if let e = error
            {
                print(e.localizedDescription)
            }
            else
            {
                for doc in querySnapshot!.documents
                {
                    let userDic = doc.data() as Dictionary<String,AnyObject>
                    let thisUser =  constructUser(uid: doc.documentID, dic: userDic)
                    self.setUser(with: thisUser)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func LoadFollowingList()
    {
        let myid = Auth.auth().currentUser?.uid
        let ref = db.collection("user").document(myid!)
        ref.getDocument { (snapshot, error) in
            if let e = error
            {
                print(e.localizedDescription)
            }
            else
            {
                let myDoc = snapshot?.data()
                self.my_following_list = myDoc!["Following"] as! [String]
                self.tableView.reloadData()
            }
        }
    }
    
    func setUser( with user : User)
    {
        var contains = false
        var index = 0
        for eachUser in UserList
        {
            
            if eachUser.UID == user.UID
            {
                contains = true
                UserList[index] = user
            }
            index += 1
        }
        if !contains
        {
            UserList.append(user)
        }
    }
    
    
    
    
    
    
    
    
}
