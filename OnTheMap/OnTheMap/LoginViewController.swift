//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Ryan Harri on 2016-10-20.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import UIKit

/// Responds to the login actions of the view.
class LoginViewController: UIViewController, Alertable, Linkable {
    
    // MARK: Outlets
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Instance Properties
    
    /// A shared UdacityClient instance.
    private var udacityClient = UdacityClient.shared
    
    // MARK: Instance Methods
    
    /**
     
        Handles the touch action of the login with Udacity UIButton.
     
        - Parameters:
            - sender:
     
    */
    @IBAction func loginWithUdacityPressed(_ sender: AnyObject) {
        func loginAnimation () {
            self.username.alpha = 1.0
            self.password.alpha = 1.0
            self.signUp.alpha = 1.0
            self.login.alpha = 1.0
        }
        
        // Animate the display of the login fields and buttons
        UIView.animate(withDuration: 0.5, animations: loginAnimation) {
            finished in
            
            /* rckoenes (2011) How to set focus to a textfield in iphone?
             Available at: http://stackoverflow.com/a/7525498 (Accessed: 21 Oct 2016) */
            self.username.becomeFirstResponder()
        }
    }
    
    /**
     
        Handles the touch action of the sign up UIButton.
     
        - Parameters:
            - sender:
     
    */
    @IBAction func signUpPressed(_ sender: AnyObject) {
        openURL(UdacityClient.Constants.SignUp.URL)
    }
    
    /**
     
        Handles the touch action of the login UIButton.
     
        - Parameters:
            - sender:
     
    */
    @IBAction func loginPressed(_ sender: AnyObject) {
        guard let usernameIsEmpty = username.text?.isEmpty, let passwordIsEmpty = password.text?.isEmpty else {
            return
        }
        
        switch (usernameIsEmpty, passwordIsEmpty) {
        case (true, true):
            username.shake(.right)
            password.shake(.left)
            return
        case (true, false):
            username.shake(.right)
            return
        case (false, true):
            password.shake(.left)
            return
        case (false, false):
            break
        }
        
        if let username = username.text, let password = password.text {
            activityIndicator.startAnimating()
            udacityClient.login(withUsername: username, andPassword: password) { (success, errorMessage) in
                guard (errorMessage == nil) else {
                    DispatchQueue.main.async() {
                        self.displayAlert(title: "Unable to Login", message: errorMessage)
                        self.activityIndicator.stopAnimating()
                    }
                    return
                }
                
                if success {
                    DispatchQueue.main.async() {
                        self.activityIndicator.stopAnimating()
                        self.completeLogin()
                    }
                }
            }
        }
    }
    
    /**
     
        Completes the login operation.
     
    */
    private func completeLogin() {
        let controller = storyboard?.instantiateViewController(withIdentifier: "OnTheMapNavigationController") as! UINavigationController
        present(controller, animated: true, completion: nil)
    }
}

// MARK: UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        /* Sudha Tiwari (2011) UIKeyboard next button not going to next UITextField
         Available at: http://stackoverflow.com/a/14952636 (Accessed: 28 Oct 2016) */
        
        if textField == username {
            password.becomeFirstResponder() // Next
        } else if textField == password {
            loginPressed(password) // Go
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

