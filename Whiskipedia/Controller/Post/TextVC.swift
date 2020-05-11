//
//  TextVC.swift
//  Whiskipedia
//
//  Created by ZHI XUAN MO on 4/25/20.
//  Copyright © 2020 zhixuan mo. All rights reserved.
//

import UIKit
import Firebase

protocol TextVCdelegate {
    func reload()
}

class TextVC: UIViewController,UITextFieldDelegate {

    //MARK: - Property Setup
    @IBOutlet weak var Image: UIImageView!
    
    @IBOutlet weak var NameField: UITextField!
    
    @IBOutlet weak var ColorField: UITextField!
    
    @IBOutlet weak var NoseField: UITextField!
    
    @IBOutlet weak var PalateField: UITextField!
    
    @IBOutlet weak var FinishField: UITextField!
    
    @IBOutlet weak var ScoreField: UITextField!
    
    @IBOutlet weak var PublishBtn: UIBarButtonItem!
    
    var UserLoaded : Bool = false
    
    var PostImage : UIImage?
    
    var selected_whisky : Whisky?
    
    var user : User?
    
    let storage = Storage.storage()
    var delegate : TextVCdelegate?
    var UserUpdated : Bool = false
    var WhiskyUpdated : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        ColorField.delegate = self
        NoseField.delegate = self
        PalateField.delegate = self
        FinishField.delegate = self
        ScoreField.delegate = self
        
        ColorField.addTarget(self, action: #selector(validation), for: .editingChanged)
        NoseField.addTarget(self, action: #selector(validation), for: .editingChanged)
        PalateField.addTarget(self, action: #selector(validation), for: .editingChanged)
        FinishField.addTarget(self, action: #selector(validation), for: .editingChanged)
        ScoreField.addTarget(self, action: #selector(validation), for: .editingChanged)
        
        loadUser(uid: Auth.auth().currentUser!.uid )
        PublishBtn.isEnabled = false
        if let name = selected_whisky?.Whiskyname{
        NameField.text = name
        }
        if let selected_image = PostImage
        {
            Image.image = selected_image    
        }
    }
    
    //MARK: - Retrive Keyboard When Touch Begin
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
              self.view.endEditing(true)
          }
          
          func textFieldShouldReturn(_ textField: UITextField) -> Bool {
              textField.resignFirstResponder()
              return true
          }
    
    //MARK: - API Methods
    
    func loadUser(uid: String)
    {
        let userFile = db.collection("user").document(uid)
            userFile.getDocument { (querysnapshot, error) in
                if error != nil
                {
                    print(error!.localizedDescription)
                    return
                }
                else
                {
                    let doc = querysnapshot!.data()! as Dictionary<String,AnyObject>
                    self.user = constructUser(uid: uid, dic: doc)
                    self.UserLoaded = true
                    self.validation()
                }
            }
    }
    
   
    
    func update(postID : String , score : Double)
    {
        let myid = Auth.auth().currentUser?.uid
        let myRef = db.collection("user").document(myid!)
        
        let Whiskyid = self.selected_whisky?.ID
        let WhiskyRef = db.collection("Whisky").document(Whiskyid!)
        print("Whiskyid is \(Whiskyid!)")
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            //Update Whisky
            let WhiskyDoc : DocumentSnapshot
                       do{
                           try  WhiskyDoc = transaction.getDocument(WhiskyRef)
                       }
                       catch let fetchError as NSError
                       {
                           errorPointer?.pointee = fetchError
                           return nil
                       }
            guard var Whisky_Posts = WhiskyDoc.data()?["posts"] as? [String]
            else
            {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve population from  posts snapshot \(WhiskyDoc)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            guard let oldScore = WhiskyDoc.data()?["Score"] as? Double
            else
            {
                print(WhiskyDoc.data()?["Score"] as? String as Any)
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve population from Score snapshot \(WhiskyDoc)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            
            guard let oldBaseNum = WhiskyDoc.data()?["NumOfReviewsBasedOn"] as? Int
            else
            {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve population from Num snapshot \(WhiskyDoc)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            print("old score is \(oldScore)")
            print("old basenum is \(oldBaseNum)")
            print("score is \(score)")
            let total = oldScore * Double(oldBaseNum) + score
            let newBaseNum = oldBaseNum + 1
            let newScore = total / Double(newBaseNum)
            
            if !Whisky_Posts.contains(postID)
            {
                Whisky_Posts.append(postID)
            }
            
            
            //Update user
            let myDoc : DocumentSnapshot
                       do{
                           try  myDoc = transaction.getDocument(myRef)
                       }
                       catch let fetchError as NSError
                       {
                           errorPointer?.pointee = fetchError
                           return nil
                       }
            guard var My_Posts = myDoc.data()?["posts"] as? [String]
            else
            {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(myDoc)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            if !My_Posts.contains(postID)
            {
                My_Posts.append(postID)
            }
            
            
            
            
            
            
            
            
            transaction.updateData(["posts":My_Posts], forDocument: myRef)
            transaction.updateData(["posts":Whisky_Posts,"Score":newScore , "NumOfReviewsBasedOn":newBaseNum], forDocument: WhiskyRef)
            return nil
        }) { (object, error) in
            if let error = error
            {
                print("Transaction Failed: \(error.localizedDescription)")
            }
            else
            {
                print("Transaction Finish")
                self.delegate?.reload()
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    
    @IBAction func PublishPressed(_ sender: Any) {
        PublishBtn.isEnabled = false 
        var dic : Dictionary<String,Any> = ["authorID":user?.UID as Any , "color":ColorField.text as Any , "finish":FinishField.text as Any , "likeList":[String]() , "nose":NoseField.text as Any , "palate":PalateField.text as Any ,"score":ScoreField.text as Any , "username":user?.username as Any , "whiskyname":selected_whisky?.Whiskyname as Any , "time":Date().timeIntervalSince1970]
        guard let ImageData = self.Image.image?.jpegData(compressionQuality: 0.3)
            else {return}
        let filename = NSUUID().uuidString
        let profileRef = self.storage.reference().child("post_image").child(filename)
        let uploadtask = profileRef.putData(ImageData, metadata: nil) { (metadata, error) in
            if let e = error
            {
                print(e.localizedDescription)
            }
            else
            {
                profileRef.downloadURL { (url, error) in
                    if let er = error{
                        print(er.localizedDescription)
                    }
                    else
                    {
                        dic["imageURL"] = url?.absoluteString
                        var ref : DocumentReference? = nil
                         ref = db.collection("reviews").addDocument(data: dic) { (error) in
                                        if let error = error
                                        {
                                            print(error.localizedDescription)
                                        }
                                        else
                                        {
                                            print("updated Review, now update user and whisky")
                                            let score = (self.ScoreField.text! as NSString).doubleValue
                                            self.update(postID: ref!.documentID , score: score)
                                        }
                                    }
                                   
                    }
                }
            }
        }
        uploadtask.observe(.success) { (snapshot) in
            print("Upload successful")
        }
        
        
        
    }
    
    
    
    
    
    
    
     
    
    
    //MARK: - Validation
    
    
    @objc func validation()
    {
        print("Triggered")
        if ColorField.hasText && NoseField.hasText && PalateField.hasText && FinishField.hasText && ScoreField.hasText && UserLoaded
        {
            PublishBtn.isEnabled = true
        }
    }
    
    func check()  {
        if UserUpdated && WhiskyUpdated
        {
            print("Updated!")
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    

  

}
