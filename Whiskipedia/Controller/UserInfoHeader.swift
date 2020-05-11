//
//  UserInfoHeader.swift
//  Whiskipedia
//
//  Created by ZHI XUAN MO on 4/7/20.
//  Copyright © 2020 zhixuan mo. All rights reserved.
//

import UIKit
import Firebase


protocol UserHeaderDelegate {
    func btnPressedHandler(_ header: UserInfoHeader , action : Bool)
}


class UserInfoHeader: UICollectionViewCell {
    //MARK: - Property setup
    var user = User()
    
    var delegate : UserHeaderDelegate?
    
    @IBOutlet weak var ProfileImage: UIImageView!
    
    @IBOutlet weak var PostNumberLabel: UILabel!
    
    @IBOutlet weak var FollowingNumberLabel: UILabel!
    
    @IBOutlet weak var FollowerNumberLabel: UILabel!
    
    @IBOutlet weak var UsernameLabel: UILabel!
    
    @IBOutlet weak var EditOrFollowBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bringSubviewToFront(EditOrFollowBtn)
    }

    //MARK: - Setup view with a User
    func setup(with user: User?)
    {
        guard let currentUID = Auth.auth().currentUser?.uid else {return}
        self.user = user!
        if let user = user
        {
            if (user.Followers?.count) != nil {
                FollowerNumberLabel.text = String((user.Followers?.count)!)
            }
            else {
                FollowerNumberLabel.text = String(0)
            }
            
            if (user.Following?.count) != nil{
                FollowingNumberLabel.text = String((user.Following?.count)!)
            }
            else{
                FollowingNumberLabel.text = String(0)
            }
            
            if let post_num = user.posts?.count{
                PostNumberLabel.text = String(post_num)
            }
            else{
                PostNumberLabel.text = String(0)
            }
               
            ProfileImage.layer.cornerRadius = ProfileImage.frame.width/2
            ProfileImage.layer.borderColor = UIColor.black.cgColor
            ProfileImage.SetURLImage(with: user.profileImageURL)
            UsernameLabel.text = user.username
            
            if user.UID == currentUID
            {
                EditOrFollowBtn.setTitle("Edit Profile", for: .normal)
            }
            else
            {
                print("Current User ID is " + currentUID)
                for everyone in user.Followers!
                {
                    print("Current User ID is " + everyone)
                    if everyone == currentUID
                    {
                        print("bingo!!!")
                    }
                }
                
                if let followerList = user.Followers //,
                {
                    if followerList.contains(currentUID)
                    {
                        EditOrFollowBtn.setTitle("Unfollow", for: .normal)
                    }
                    else
                    {
                        EditOrFollowBtn.setTitle("Follow", for: .normal)
                    }
                }
                else
                {
                EditOrFollowBtn.setTitle("Follow", for: .normal)
                }
                
                EditOrFollowBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
                EditOrFollowBtn.backgroundColor = #colorLiteral(red: 0.6904727817, green: 0.3829051852, blue: 0.1476225555, alpha: 1)
            }
        }
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 10.0, y: self.frame.height-10 , width: self.frame.width-20, height: 1.0)
        bottomLine.backgroundColor = #colorLiteral(red: 0.6656478643, green: 0.5618721247, blue: 0.4100859165, alpha: 1)
        self.layer.addSublayer(bottomLine)
    }
    
    //MARK: - Handle Btn Press event with Delegate's handler 
    @objc func btnPressedHandler(_ sender : UIButton)
    {
        delegate?.btnPressedHandler(self,action:true)
    }
    
}




