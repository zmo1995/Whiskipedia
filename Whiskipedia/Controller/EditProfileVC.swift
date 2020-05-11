//
//  EditProfileVC.swift
//  Whiskipedia
//
//  Created by ZHI XUAN MO on 4/23/20.
//  Copyright © 2020 zhixuan mo. All rights reserved.
//

import UIKit
import Firebase


protocol editProfileVCdelegate {
    func reloadUser(with user : User)
}

class EditProfileVC: UIViewController,UIImagePickerControllerDelegate , UINavigationControllerDelegate{

    //MARK: - Property setup
    @IBOutlet weak var ProfileImageBtn: UIButton!
    
    @IBOutlet weak var usernameField: UITextField!
    
    var delegate : UserInfoViewController?
    var myImage :UIImage?
    var user: User?
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchMyInfo()
        if let myimage = myImage
        {
        ProfileImageBtn.layer.cornerRadius = ProfileImageBtn.frame.width/2
        ProfileImageBtn.layer.masksToBounds = true
        ProfileImageBtn.layer.borderColor = UIColor.black.cgColor
        ProfileImageBtn.setImage(myimage, for: .normal)
        }
    }



  

    //MARK: -  Handle Image Picker
    @IBAction func ImageBtnPressed(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            ProfileImageBtn.layer.cornerRadius = ProfileImageBtn.frame.width/2
            ProfileImageBtn.layer.masksToBounds = true
            ProfileImageBtn.layer.borderColor = UIColor.black.cgColor
            ProfileImageBtn.setImage(pickedImage, for: .normal)
            picker.dismiss(animated: true, completion: nil)
        }
         
    }
    
    
    //MARK: - API Methods
    func fetchMyInfo()
    {
        guard let uid = Auth.auth().currentUser?.uid else {return}
               
        let userFile = db.collection("user").document(uid)
        userFile.getDocument { (querysnapshot, error) in
            if error != nil
            {
            print(error!.localizedDescription)
            return
            }
            else
            {
            let doc = querysnapshot!.data() as! Dictionary<String,AnyObject>
                self.user = constructUser(uid: uid, dic: doc)
                self.usernameField.text = self.user?.username
            }
        }
           
    }
    
    @IBAction func FinishBtnPressed(_ sender: UIButton) {
        if let username = usernameField.text
        {
            self.user?.username = username
        }
        else
        {
            print("Please enter a username")
            return
        }
        let oldImageURL = (user?.profileImageURL)!
        let userImage = self.ProfileImageBtn.imageView?.image!
        guard let profileImage = userImage?.jpegData(compressionQuality: 0.1)   else { return}
        let filename = NSUUID().uuidString
        let profileRef = self.storage.reference().child("profile_image").child(filename)
        //profileRef.child("profile_image").child(filename)
        let uploadtask = profileRef.putData(profileImage, metadata: nil) { (metadata, error) in
            if let e = error
            {
                print(e.localizedDescription)
            }
            else
            {
                profileRef.downloadURL { (url, error) in
                    if let er = error
                    {
                        print(er.localizedDescription)
                    }
                    else
                    {
                        self.user?.profileImageURL = url?.absoluteString
                        self.uploadUser()
                    }
                }
            }
        }
        uploadtask.observe(.success) { (snapshot) in
            let oldRef = self.storage.reference(forURL: oldImageURL)
            oldRef.delete { (error) in
                if let e = error
                {
                    print(e.localizedDescription)
                }
                else
                {
                    print("User Info Updated and old Image deleted")
                    self.delegate?.reloadUser(with: self.user!)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
    
    
    func uploadUser()
    {
        db.collection("user").document(user!.UID).setData(["email":user?.email! as Any , "username":user?.username! as Any, "profileImageURL":user?.profileImageURL! as Any , "Following":user?.Following as Any , "Followers":user?.Followers as Any , "posts":user?.posts as Any])
    }
    
}
