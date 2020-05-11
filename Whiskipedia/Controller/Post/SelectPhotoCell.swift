//
//  SelectPhotoCell.swift
//  Whiskipedia
//
//  Created by ZHI XUAN MO on 4/24/20.
//  Copyright © 2020 zhixuan mo. All rights reserved.
//

import UIKit

class SelectPhotoCell: UICollectionViewCell {
    
    let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .black
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    
    
   override init(frame: CGRect) {
    super.init(frame: frame)
    setimage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Make Image Covers the whole Cell 
    
    func setimage()
     {
         self.addSubview(photoImageView)
               photoImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 0).isActive = true
               photoImageView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: 0).isActive = true
               photoImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        photoImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
               
        photoImageView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: 0).isActive = true
               
        photoImageView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: 0).isActive = true
     }
}
