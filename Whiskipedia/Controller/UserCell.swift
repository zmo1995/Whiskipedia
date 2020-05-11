//
//  UserCell.swift
//  Whiskipedia
//
//  Created by ZHI XUAN MO on 4/10/20.
//  Copyright © 2020 zhixuan mo. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var FollowingLabel: UILabel!
    @IBOutlet weak var UsernameLabel: UILabel!
    @IBOutlet weak var ProfileImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    //MARK: - Setup Cell using UserObject
    func setup(with user: User)
    {
        UsernameLabel.text = user.username
        ProfileImage.SetURLImage(with: user.profileImageURL)
        ProfileImage.layer.cornerRadius = ProfileImage.frame.height / 2
        ProfileImage.layer.borderWidth = 1.0
        ProfileImage.layer.borderColor = UIColor.black.cgColor
        ProfileImage.layer.masksToBounds = true
    }
    
    
    
    
}
