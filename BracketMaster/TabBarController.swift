//
//  TabBarController.swift
//  BracketMaster
//
//  Created by Praneet Chakraborty on 4/26/18.
//  Copyright © 2018 CSSE Department. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    var buttons: [UITabBarItem]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttons = tabBar.items
        buttons[0].image = #imageLiteral(resourceName: "home-7")
        buttons[1].image = #imageLiteral(resourceName: "trophy-7")
        buttons[2].image = #imageLiteral(resourceName: "circle-user-7")
    }
}
