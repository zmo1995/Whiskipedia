//
//  RegViewController.swift
//  Whiskipedia
//
//  Created by ZHI XUAN MO on 3/28/20.
//  Copyright © 2020 zhixuan mo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class RegViewController: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate , UITextFieldDelegate  {
    
    //MARK: -  Property setup
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var UsernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var IconSelectBtn: UIButton!
    
    @IBOutlet weak var signUpBtn: UIButton!
    
    var imageSelected = false
    
    let storage = Storage.storage()
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        UsernameTextField.delegate = self
        passwordTextField.delegate = self
        signUpBtn.isEnabled = false
        emailTextField.addTarget(self, action: #selector(infoValidation), for: .editingChanged)
        UsernameTextField.addTarget(self, action: #selector(infoValidation), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(infoValidation), for: .editingChanged)
    }
    
    //MARK: - Retrive Keyboard when Touch begin
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //MARK: - API functions
    @IBAction func signUpBtnPressed(_ sender: UIButton)
    {
        print("sign up pressed")
        if let email = emailTextField.text , let password = passwordTextField.text , let username = UsernameTextField.text //, let userImage = IconSelectBtn.imageView?.image
        {
            Auth.auth().createUser(withEmail: email, password: password) {  authResult, error in
                if error != nil
                        {
                            let alert = UIAlertController(title: "Error!", message: error?.localizedDescription , preferredStyle: .alert)
                            let action = UIAlertAction(title: "OK", style: .default) { (action) in
                                alert.dismiss(animated: true, completion: nil)
                            }
                            alert.addAction(action)
                            self.present(alert, animated: true, completion: nil)
                            return
                        }
                else
                {
                    // Create user file
                    var newUser =  User()
                    newUser.email = email
                    newUser.username = username
                    newUser.UID = authResult?.user.uid
                    //Upload Image to firebase Storage
                    let userImage = self.IconSelectBtn.imageView?.image
                    guard let profileImage = userImage?.jpegData(compressionQuality: 0.1)   else { print(error!.localizedDescription); return}
                    let filename = NSUUID().uuidString
                    let profileRef = self.storage.reference().child("profile_image").child(filename)
                    let uploadTask = profileRef.putData(profileImage , metadata: nil)
                    {
                        (metadata, error) in
                        print("inside upload task")
                        if error != nil
                        {
                            let alert = UIAlertController(title: "Error!", message: error?.localizedDescription , preferredStyle: .alert)
                            let action = UIAlertAction(title: "OK", style: .default)
                            {   (action) in
                                alert.dismiss(animated: true, completion: nil)
                            }
                            alert.addAction(action)
                            self.present(alert, animated: true, completion: nil)
                            return
                        }
                        profileRef.downloadURL(completion:
                        { (url, error) in
                           if error != nil
                            {
                            print("Unable to Get Profile Image's Download URL")
                            }
                           else
                            {
                                newUser.profileImageURL = url?.absoluteString
                                 self.uploadUser(with: newUser)
                            }
                        })
                           
                    }
                    uploadTask.observe(.success) { snapshot in
                      // Upload completed successfully
                        print("upload success ")
                        self.performSegue(withIdentifier: "RegToMain", sender: self)
                    }
                }
            }
        }
        else {return}
    }
    
    func uploadUser(with user: User)
    {
        let follower = [String]()
        let following = [String]()
        let posts = [String]()
        db.collection("user").document(user.UID).setData(["email":user.email! , "username":user.username!, "profileImageURL":user.profileImageURL! , "Following":following , "Followers":follower,"posts":posts])
        
    }
    
    
    //MARK: - Image Picker
    @IBAction func IconSelectPressed(_ sender: Any)
    {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true , completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            IconSelectBtn.layer.cornerRadius = IconSelectBtn.frame.width/2
            IconSelectBtn.layer.masksToBounds = true
            IconSelectBtn.layer.borderColor = UIColor.black.cgColor
            IconSelectBtn.setImage(pickedImage, for: .normal)
            imageSelected = true
            
            picker.dismiss(animated: true, completion: nil)
        }
        infoValidation()
    }
    
    //MARK: - Validation of entered information
   @objc func infoValidation()
    {
        guard
            emailTextField.hasText ,
            passwordTextField.hasText ,
            UsernameTextField.hasText,
            imageSelected
            else
                {
                signUpBtn.isEnabled = false
                signUpBtn.titleLabel?.textColor = #colorLiteral(red: 0.6904727817, green: 0.3829051852, blue: 0.1476225555, alpha: 0.3020387414)
                return
                }
        signUpBtn.isEnabled = true
        signUpBtn.titleLabel?.textColor = #colorLiteral(red: 0.6904727817, green: 0.3829051852, blue: 0.1476225555, alpha: 1)
    }
   
    
}
