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
    
//MARK: - Property setup
    @IBOutlet weak var UserImage: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var whiskyLabel: UILabel!
    
    @IBOutlet weak var LikeBtn: UIButton!
    
    @IBOutlet weak var whiskyImage: UIImageView!
    
    @IBOutlet weak var LikeNumber: UILabel!
    
    @IBOutlet weak var ScoreLabel: UILabel!
    
    @IBOutlet weak var colorLabel: UILabel!
    
    @IBOutlet weak var noseLabel: UITextView!
    
    @IBOutlet weak var palateLabel: UITextView!
    
    @IBOutlet weak var finishLabel: UITextView!
    
    var selectedPost : Post?
    var usericon : UIImage?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorLabel.textAlignment = .left
        UserImage.layer.cornerRadius = UserImage.frame.width/2
        
        setup()
    }
    
    // MARK: - Setup View using a post object
    
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
            self.LikeNumber.text = "\(selectedPost.likeList?.count ?? 0) Likes"
            self.ScoreLabel.text = "Score:\(String(describing: selectedPost.score!))"
            self.colorLabel.text = selectedPost.color
            self.noseLabel.text = selectedPost.nose
            self.palateLabel.text = selectedPost.palate
            self.finishLabel.text = selectedPost.finish
            self.whiskyImage.SetURLImage(with: selectedPost.imageURL!)
            noseLabel.sizeToFit()
            noseLabel.textContainerInset = UIEdgeInsets(top: -4, left: 0, bottom: 0, right: 0)
            
            palateLabel.sizeToFit()
            palateLabel.textContainerInset = UIEdgeInsets(top: -4, left: 0, bottom: 0, right: 0)
            
            finishLabel.sizeToFit()
            finishLabel.textContainerInset = UIEdgeInsets(top: -4, left: 0, bottom: 0, right: 0)
        }
    }
   
    
    
    //MARK: - Handle Like and Unlike 
    @IBAction func LikeBtnPressed(_ sender: UIButton) {
        LikeBtn.isEnabled = false
        let ref = db.collection("reviews").document((self.selectedPost?.postID!)!)
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            
            let postdoc : DocumentSnapshot
                do{
                    try postdoc = transaction.getDocument(ref)
                  }
                catch let fetchError as NSError{
                errorPointer?.pointee = fetchError
                return nil
                    }
            guard var likelist = postdoc.data()?["likeList"] as? [String]
            else
            {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve population from  likeList snapshot \(postdoc)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            likelist.append(Auth.auth().currentUser!.uid)
            transaction.updateData(["likeList":likelist], forDocument: ref)
            
            
            return nil
        }) { (object, error) in
            if let error = error
            {
                print(error.localizedDescription)
            }
            else
            {
                self.selectedPost?.likeList?.append(Auth.auth().currentUser!.uid)
                self.setup()
                self.LikeBtn.isEnabled = true
            }
        }
        
        
    }
    
    
    
}
