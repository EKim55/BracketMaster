//
//  HomeViewController.swift
//  BracketMaster
//
//  Created by CSSE Department on 4/26/18.
//  Copyright © 2018 CSSE Department. All rights reserved.
//

import UIKit
import Firebase

class HomeTableViewController: UIViewController {
    
    var competitionsRef: CollectionReference!
    var competitionsListener: ListenerRegistration!
    
    let bracketCellIdentifier = "BracketCell"
    let noCompetitionsCellIdentifier = "NoCompetitionsCell"
    var competitions = [Competition]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Your Competitions"
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
 

}
