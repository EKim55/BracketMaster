//
//  ProfileViewController.swift
//  BracketMaster
//
//  Created by Praneet Chakraborty on 4/26/18.
//  Copyright © 2018 CSSE Department. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var signOutButton: UIBarButtonItem!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func pressedSignOut(_ sender: Any) {
        appDelegate.handleLogout()
    }
}
