//
//  LoginViewController.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginViaWebsiteButton: UIButton!
    
    func getTokenHelper(success: Bool, error: Error?) -> Void {
        if success {
            print(TMDBClient.Auth.requestToken)
            DispatchQueue.main.async {
                TMDBClient.login(userName: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "", completion: self.handleLoginResponse(succes:Error:))
            }
            TMDBClient.getRequestSessionId(completion: handleSessionResponse(success:error:))
        }
        
    }
    func handleSessionResponse(success: Bool, error: Error?){
        if success{
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "completeLogin", sender: nil)
            }
        }
    }
    func handleLoginResponse(succes: Bool, Error: Error?){
        print(TMDBClient.Auth.requestToken)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
       TMDBClient.getRequestToken(completion: getTokenHelper(success:error:))
    }
    
    @IBAction func loginViaWebsiteTapped() {
        TMDBClient.getRequestToken{ (success,error) in
            if success{
                DispatchQueue.main.async {
                  UIApplication.shared.open(TMDBClient.Endpoints.webAuth.url, options: [:], completionHandler: nil)
                    self.performSegue(withIdentifier: "completeLogin", sender: nil)
                }
            }
        }
    }
}
