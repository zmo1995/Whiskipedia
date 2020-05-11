//
//  PostClass.swift
//  Whiskipedia
//
//  Created by ZHI XUAN MO on 4/25/20.
//  Copyright © 2020 zhixuan mo. All rights reserved.
//

import Foundation
class Post {
    var postID : String?
    var username : String!
    var whiskyname : String!
    var authorID : String!
    var likeList : [String]?
    var imageURL : String?
    var color : String?
    var nose : String?
    var palate : String?
    var finish : String?
    var score  : Float?
    var time : Double?
    var expanded : Bool = false
    
    init(dic: Dictionary<String,AnyObject>) {
        if let time = dic["time"] as? Double
        {
            self.time = time
        }
        else {self.time = Date().timeIntervalSince1970}
        if let username = dic["username"] as? String
            {
            self.username = username
            }
        else {self.username = "Unknown User"}
        if let whiskyname = dic["whiskyname"] as? String
            {
                self.whiskyname = whiskyname
            }
        else {self.whiskyname = "Unknown Whisky"}
        if let imageURL = dic["imageURL"] as? String
            {
            self.imageURL = imageURL
            }
        else {self.imageURL = "N/A"}
        if let author = dic["authorID"] as? String
            {
            self.authorID = author
            }
        else {self.authorID = "unknown"}
        if let likeList = dic["likeList"] as? [String]
            {
                self.likeList = likeList
            }
        else {self.likeList = [String]()}
        if let nose = dic["nose"] as? String
            {
                self.nose = nose
            }
        else {self.nose = "N/A"}
        if let palate = dic["palate"] as? String
            {
                self.palate = palate
            }
        else {self.palate = "N/A"}
        if let finish = dic["finish"] as? String
            {
                self.finish = finish
            }
        else {self.finish = "N/A"}
        if let color = dic["color"] as? String
            {
                self.color = color
            }
        else {self.color = "N/A"}
        if let score = dic["score"] as? NSString
        {
            self.score = score.floatValue
        }
        else {self.score = 0}
        
        
        
        
    }
}
