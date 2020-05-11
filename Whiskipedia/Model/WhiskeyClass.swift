//
//  WhiskeyClass.swift
//  InputJson
//
//  Created by ZHI XUAN MO on 3/25/20.
//  Copyright © 2020 zhixuan mo. All rights reserved.
//

import Foundation




class Whisky : Decodable{
    let Whiskyname:String?
    let Score: Double?
    let NumOfReviewsBasedOn:Int?
    let Cost:String?
    let Country: String?
    let type:String?
    let posts:[String]?
    var ID : String?
    
    
    init(dic:Dictionary<String,AnyObject>) {
        if let posts = dic["posts"] as? [String]
        {
            self.posts = posts
        }
        else
        {self.posts = [String]()}
        if let Whiskyname = dic["Name"] as? String
        {
            self.Whiskyname = Whiskyname
        }
        else {self.Whiskyname = "N/A"}
        if let Score = dic["Score"] as? Double
        {
            self.Score = Score
        }
        else {self.Score = 0.0}
        
        if let numOfReviewBasedOn = dic["NumOfReviewsBasedOn"] as? Int
        {
            self.NumOfReviewsBasedOn = numOfReviewBasedOn
        }
        else {self.NumOfReviewsBasedOn = 0}
        if let cost = dic["Cost"] as? String
        {
            self.Cost = cost
        }
        else{self.Cost = "$"}
        if let country = dic["Country"] as? String
        {
            self.Country = country
        }
        else {self.Country = "N/A"}
        if let whiskyType = dic["Type"] as? String
        {
            self.type = whiskyType
        }
        else {self.type  = "N/A"}
        
        
        
        
    }
}

