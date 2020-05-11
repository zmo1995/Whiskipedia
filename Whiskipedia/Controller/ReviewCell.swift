//
//  ReviewCell.swift
//  Whiskipedia
//
//  Created by ZHI XUAN MO on 4/28/20.
//  Copyright © 2020 zhixuan mo. All rights reserved.
//

import UIKit
import Firebase


protocol reviewCellDelegate {
    func like_unlike(like : Bool , index : Int)
}

class ReviewCell: UITableViewCell {

    @IBOutlet weak var iconImage: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var whiskynameLabel: UILabel!
    
    @IBOutlet weak var LikeBtn: UIButton!
    
    @IBOutlet weak var whiskyImage: UIImageView!
    
    @IBOutlet weak var likeLabel: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var colorLabel: UILabel!
    
    @IBOutlet weak var noseLabel: UITextView!
    
    @IBOutlet weak var palateLabel: UITextView!
    
    @IBOutlet weak var finishLabel: UITextView!
    
    var delegate : reviewCellDelegate?
    var notlikeImage  =  UIImage(systemName: "heart")
    var likeImage = UIImage(systemName: "heart.fill")
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setup(with post : Post , url : String)
    {
        iconImage.layer.cornerRadius = iconImage.frame.width / 2
        iconImage.contentMode = .scaleAspectFill
        iconImage.layer.masksToBounds = true
        self.iconImage.SetURLImage(with: url)
        self.usernameLabel.text = post.username
        self.whiskynameLabel.text = post.whiskyname
        if (post.likeList?.contains(Auth.auth().currentUser!.uid))!
        {
        LikeBtn.setImage(likeImage, for: .normal)
        }
        else
        {
            LikeBtn.setImage(notlikeImage, for: .normal)
        }
        self.likeLabel.text = "\(post.likeList?.count ?? 0) Likes"
        print("Score:\(String(format: "%.1f", post.score!))")
        self.scoreLabel.text = "Score:\(String(format: "%.1f", post.score!))"
        self.colorLabel.text = post.color
        self.noseLabel.text = post.nose
        self.palateLabel.text = post.palate
        self.finishLabel.text = post.finish
        self.whiskyImage.SetURLImage(with: post.imageURL!)
        noseLabel.sizeToFit()
        noseLabel.textContainerInset = UIEdgeInsets(top: -4, left: 0, bottom: 0, right: 0)
        
        palateLabel.sizeToFit()
        palateLabel.textContainerInset = UIEdgeInsets(top: -4, left: 0, bottom: 0, right: 0)
        
        finishLabel.sizeToFit()
        finishLabel.textContainerInset = UIEdgeInsets(top: -4, left: 0, bottom: 0, right: 0)
    }
    
    
    @IBAction func LikeBtnPressed(_ sender: UIButton) {
        print("clicked")
        if self.LikeBtn.imageView?.image == notlikeImage
        {
            self.delegate?.like_unlike(like: true , index: self.LikeBtn.tag)
        }
        else
        {
            self.delegate?.like_unlike(like: false, index: self.LikeBtn.tag)
        }
        
    }
    
    
    
    
    
    
    
    
    
}
