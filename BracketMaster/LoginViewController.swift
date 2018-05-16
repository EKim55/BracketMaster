//
//  LoginViewController.swift
//  BracketMaster
//
//  Created by Praneet Chakraborty on 4/25/18.
//  Copyright © 2018 CSSE Department. All rights reserved.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var googleLoginButton: GIDSignInButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
    }

}
