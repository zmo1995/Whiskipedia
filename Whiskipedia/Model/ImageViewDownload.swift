//
//  ImageViewDownload.swift
//  Whiskipedia
//
//  Created by ZHI XUAN MO on 4/7/20.
//  Copyright © 2020 zhixuan mo. All rights reserved.
//

import Foundation
import Firebase



extension UIImageView
{
    
    func SetURLImage(with url: String)
    {
        let ImageRef = Storage.storage().reference(forURL: url)
        ImageRef.getData(maxSize: 1*1024*1024) { (data, error) in
            if let error = error
            {
                self.image = #imageLiteral(resourceName: "logo")
                print("Unable to retrive Image")
            }
            else
            {
                let image = UIImage(data: data!)
                self.image = image
            }
        }
        
        
    }
    
    
    
    
    
    
    
}
