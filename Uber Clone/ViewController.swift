//
//  ViewController.swift
//  Uber Clone
//
//  Created by Liz Healy on 2/21/17.
//  Copyright © 2017 netGALAXY Studios. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {
    
    var isSignedUp = false
    
    var activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet weak var riderLabel: UILabel!
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var usernameTextfield: UITextField!
    
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBOutlet weak var isRider: UISwitch!
    
    @IBOutlet weak var signupOrLoginButton: UIButton!
    
    @IBOutlet weak var alreadyHaveButton: UIButton!
    
    
    @IBAction func alreadyHavePressed(_ sender: Any) {
        
        if isSignedUp == false {
            
            isSignedUp = true
            riderLabel.alpha = 0
            driverLabel.alpha = 0
            alreadyHaveButton.setTitle("Return to Login", for: .normal)
            isRider.alpha = 0
            signupOrLoginButton.setTitle("Login", for: .normal)
            
        } else {
            
            isSignedUp = false
            riderLabel.alpha = 1
            driverLabel.alpha = 1
            alreadyHaveButton.setTitle("Already have an account?", for: .normal)
            isRider.alpha = 1
            signupOrLoginButton.setTitle("Sign up", for: .normal)
            
            
            
        }
        
        
        
    }
    
    @IBAction func signupOrLogin(_ sender: Any) {
        
        if isSignedUp {
            
            //Login
            
            PFUser.logInWithUsername(inBackground: usernameTextfield.text!, password: passwordTextfield.text!, block:  { (user, error) in
                
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
                if error != nil {
                    
                    var displayErrorMessage = "Please try again later"
                    
                    if let errorMessage = (error! as NSError).userInfo["error"] as? String {
                        print(error)
                        
                        displayErrorMessage = errorMessage
                    }
                    
                    self.createAlert(title: "Login Error", message: displayErrorMessage)
                    
                } else {
                    //self.performSegue(withIdentifier: "showUserTable", sender: self)
                    print("Logged in")
                    
                    PFUser.current()?.fetchInBackground(block: { (object, error) in
                        
                        let isRider = (PFUser.current()?.object(forKey: "isRider") as AnyObject).boolValue
                        
                        if isRider == true {
                            
                            print(isRider) // Output console displays "true"
                        
                            print("Rider Segue")
                            self.performSegue(withIdentifier: "RiderSegue", sender: self)
                        
                        } else {
                        
                            print("Driver Segue")
                            self.performSegue(withIdentifier: "DriverSegue", sender: self)
                    }
                
                })
                }
                
            })

            
        } else {
            
            //SignUp
            
            let user = PFUser()
            
            user.username = usernameTextfield.text
            user.password = passwordTextfield.text
            
            if isRider.isOn {
                
                user["isRider"] = true
                
            } else {
                
                user["isRider"] = false
                
            }

            
            user.signUpInBackground( block: {(success, error) in
                
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
                if error != nil {
                    
                    var displayErrorMessage = "Please try again later"
                    
                    if let errorMessage = (error! as NSError).userInfo["error"] as? String {
                        print(error)
                        
                        displayErrorMessage = errorMessage
                    }
                    
                    self.createAlert(title: "Sign Up Error", message: displayErrorMessage)
                    
                    
                    
                } else {
                    
                    print("User signed up")
                    
                    if self.isRider.isOn {
                        
                        print("Rider Segue")
                        self.performSegue(withIdentifier: "RiderSegue", sender: self)
                        
                    } else {
                        
                        print("Driver Segue")
                        self.performSegue(withIdentifier: "DriverSegue", sender: self)
                        
                    }
                    
                }
            })

            
        }
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }


}

