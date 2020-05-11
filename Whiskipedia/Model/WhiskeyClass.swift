//
//  WhiskeyClass.swift
//  InputJson
//
//  Created by ZHI XUAN MO on 3/25/20.
//  Copyright © 2020 zhixuan mo. All rights reserved.
//

import Foundation




class Whiskey : Decodable{
    let Whisky:String?
    let Meta_Critic: Double?
    let STDEV:Double?
    let NumOfReviewsBasedOn:Int?
    let Cost:String?
    let Class:String?
    let Super_Cluster:String?
    let Cluster: String?
    let Country: String?
    let type:String?
}


//
//func readJSONFromFile(fileName: String) //-> [Whiskey]?
//{
//
////    var eachWhiskey: Whiskey?
//
//    if let path = Bundle.main.path(forResource: "WhiskeyDatabase", ofType: "json") {
//        do {
//            let fileUrl = URL(fileURLWithPath: path)
//            // Getting data from JSON file using the file URL
//            let data = try? Data(contentsOf: fileUrl, options: .mappedIfSafe)
//            let json = try JSONSerialization.jsonObject(with: data! , options: .mutableContainers)
//            print(json)
//
//
//        } catch {
//            // Handle error here
//
//        }
//    }
//
//    //return results
//
//
//
//
//}
//

func read ()
{
    if let path = Bundle.main.path(forResource: "WhiskeyDatabase", ofType: "json") {
        do {
              let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
              let jsonResult = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
               print(jsonResult!)
          } catch {
               // handle error
          }
    }
}
