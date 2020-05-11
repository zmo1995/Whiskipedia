//
//  LoginViewController.swift
//  Whiskipedia
//
//  Created by ZHI XUAN MO on 3/31/20.
//  Copyright © 2020 zhixuan mo. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: ViewController
{

    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
    }
    
    
    @IBAction func SigninPressed(_ sender: UIButton)
    {
        if let email = emailTextField.text , let password = passwordTextField.text
        {
            Auth.auth().signIn(withEmail: email, password: password) {  authResult, error in
                if error != nil
                        {
                            print(error!)
                            let alert = UIAlertController(title: "Error!", message: "Plesase Try Again" , preferredStyle: .alert)
                            let action = UIAlertAction(title: "OK", style: .default) { (action) in
                                alert.dismiss(animated: true, completion: nil)
                            }
                            alert.addAction(action)
                            self.present(alert, animated: true, completion: nil)
                            return
                        }
                else
                {
                    self.performSegue(withIdentifier: "LoginToMain", sender: self)
                }
            }
            
            
            
            
        }
        
        
        
        
        
        
        
        
    }
    
    
    
    
    
    
    

}
