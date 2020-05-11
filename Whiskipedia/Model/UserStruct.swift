//
//  UserClass.swift
//  Whiskipedia
//
//  Created by ZHI XUAN MO on 4/7/20.
//  Copyright © 2020 zhixuan mo. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

let db = Firestore.firestore()

struct User {
    var username : String!
    var email: String!
    var profileImageURL : String!
    var UID : String!
    var Following : [String]?
    var Followers : [String]?
    var posts : [String]?
    
}

func constructUser(uid:String , dic: Dictionary<String,AnyObject>) -> User{
    var newuser = User()
    
    newuser.UID = uid
    
    if let posts = dic["posts"] as? [String]
    {
        newuser.posts = posts
    }
    
    if let username  = dic["username"] as? String
    {
        newuser.username = username
    }
    
    if let email = dic["email"] as? String
    {
        newuser.email = email
    }
    
    if let profileURL = dic["profileImageURL"] as? String
    {
        newuser.profileImageURL = profileURL
    }
    if let followers = dic["Followers"] as? [String]
    {
        newuser.Followers = followers
        for all in newuser.Followers!
        {
            print(all)
        }
    }
    if let following = dic["Following"] as? [String]
    {
        newuser.Following = following
    }
    
    return newuser
    
}


func fetchUser(with userID: String) -> User
{
    var currentUser = User()
    let userFile = db.collection("user").document(userID)
        userFile.getDocument { (querysnapshot, error) in
            if error != nil
            {
                print(error!.localizedDescription)
                return
            }
            else
            {
                let doc = querysnapshot!.data() as! Dictionary<String,AnyObject>
                currentUser = constructUser(uid: userID, dic: doc)
            }
            
        }
    return currentUser
}

func updateUser(user: User)
{
   
            do{
                try db.collection("user").document(user.UID).setData(["email":user.email! , "username":user.username!, "profileImageURL":user.profileImageURL! , "Following":user.Following  , "Followers":user.Followers])
            }
            catch
            {
                print(error.localizedDescription)
            }
}



    
func follow_unfollow(uid: String , follow : Bool)
{
    var me = fetchUser(with: Auth.auth().currentUser!.uid)
    var target = fetchUser(with: uid)
    if follow
    {
        if !(target.Followers?.contains(me.UID))! && !(me.Following?.contains(uid))!
        {
        me.Following?.append(uid)
        target.Followers?.append(me.UID)
        updateUser(user: me)
        updateUser(user: target)
        }
        else
        {
            print("You are already following this User")
        }
    }
    else if !follow
    {
        if  (target.Followers?.contains(me.UID))! && (me.Following?.contains(uid))!
        {
        me.Following?.remove(object: uid)
        target.Followers?.remove(object: me.UID)
        updateUser(user: me)
        updateUser(user: target)
        }
        else
        {
            print("You are not following this User")
        }
    }
    
}




