//
//  PostDetailVC.swift
//  Whiskipedia
//
//  Created by ZHI XUAN MO on 4/27/20.
//  Copyright © 2020 zhixuan mo. All rights reserved.
//

import UIKit
import Firebase

class PostDetailVC: UIViewController {

    @IBOutlet weak var UserImage: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var whiskyLabel: UILabel!
    
    @IBOutlet weak var LikeBtn: UIButton!
    
    @IBOutlet weak var whiskyImage: UIImageView!
    
    @IBOutlet weak var LikeNumber: UILabel!
    
    @IBOutlet weak var ScoreLabel: UILabel!
    
    @IBOutlet weak var colorLabel: UILabel!
    
    @IBOutlet weak var noseLabel: UILabel!
    
    @IBOutlet weak var palateLabel: UILabel!
    
    @IBOutlet weak var finishLabel: UILabel!
    
    var selectedPost : Post?
    var usericon : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup()
    {
        if let selectedPost = self.selectedPost , let icon = usericon
        {
            self.UserImage.image = icon
            self.usernameLabel.text = selectedPost.username
            self.whiskyLabel.text = selectedPost.whiskyname
            if (selectedPost.likeList?.contains(Auth.auth().currentUser!.uid))!
            {
            LikeBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            }
            self.ScoreLabel.text = "Score: \(String(describing: selectedPost.score))"
            self.colorLabel.text = selectedPost.color
            self.noseLabel.text = selectedPost.nose
            self.palateLabel.text = selectedPost.palate
            self.finishLabel.text = selectedPost.finish
            
        }
    }
   
}
