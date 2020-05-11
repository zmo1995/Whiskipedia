//
//  addWhiskyVC.swift
//  Whiskipedia
//
//  Created by ZHI XUAN MO on 4/26/20.
//  Copyright © 2020 zhixuan mo. All rights reserved.
//

import UIKit
import Firebase


protocol addWhiskyVCdelegate {
    func addWhisky(with newWhisky:Whisky)
}


class addWhiskyVC: UIViewController {
    
    //MARK: - Property Setup

    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var typeField: UITextField!
    
    @IBOutlet weak var costField: UITextField!
    
    @IBOutlet weak var countryField: UITextField!
    
    @IBOutlet weak var finishBtn: UIButton!
    
    let db = Firestore.firestore()
    var delegate : addWhiskyVCdelegate?
    var post_delegate : addWhiskyVCdelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        finishBtn.isEnabled = false
        nameField.addTarget(self, action: #selector(validation), for: .editingChanged)
        typeField.addTarget(self, action: #selector(validation), for: .editingChanged)
        costField.addTarget(self, action: #selector(validation), for: .editingChanged)
        countryField.addTarget(self, action: #selector(validation), for: .editingChanged)
    }
    
    
    // MARK: - Translate Cost into Dollar Signs
    func configureCost() -> String
    {
        if let costInFloat = Float( costField.text!)
        {
        if costInFloat < 30 {return "$"}
        else if costInFloat >= 30 && costInFloat < 50 {return "$$"}
        else if costInFloat >= 50 && costInFloat < 70 {return "$$$"}
        else if costInFloat >= 70 && costInFloat < 125 {return "$$$$"}
        else if costInFloat >= 125 && costInFloat < 300 {return "$$$$$"}
        else {return "$$$$$+"}
        }
        else
        {
            return "unknown"
        }
        
    }
    
    
    //MARK: - Handle Validation of Entered information
    @objc func validation()
    {
        if nameField.hasText &&
           typeField.hasText &&
        costField.hasText &&
        countryField.hasText
        {
            finishBtn.isEnabled = true
        }
        else
        {
            finishBtn.isEnabled = false
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
    
    //MARK: - Handle Upload new Whisky
    
    
    @IBAction func FinishBtnPressed(_ sender: UIButton) {
        let dic : Dictionary<String,Any> = ["Name":nameField.text! , "Cost":configureCost() ,"Country":countryField.text! , "Type":typeField.text! ]
        let newWhisky = Whisky(dic: dic as Dictionary<String, AnyObject>)
        uploadWhisky(with: newWhisky)
    }
    
    func uploadWhisky(with newwhisky:Whisky)
    {
        let postList = [String]()
        let id = db.collection("Whisky").addDocument(data: [
            "Name" : newwhisky.Whiskyname as Any ,
            "Cost": newwhisky.Cost as Any ,
            "Country":newwhisky.Country as Any ,
            "Type":newwhisky.type as Any ,
            "NumOfReviewsBasedOn":newwhisky.NumOfReviewsBasedOn as Any ,
            "Score":newwhisky.Score as Any,
        "posts":postList]) { (error) in
            if let e = error
            {
                print(e.localizedDescription)
            }
            else
            {
                if let _ = self.post_delegate
                {
                    self.post_delegate?.addWhisky(with: newwhisky)
                }
                self.delegate?.addWhisky(with: newwhisky)
                self.navigationController?.popViewController(animated: true)
            }
        }.documentID
        print("New Whisky's ID is " + id)
    }
    
    

}
