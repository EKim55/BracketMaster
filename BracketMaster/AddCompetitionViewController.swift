//
//  AddCompetitionViewController.swift
//  BracketMaster
//
//  Created by Praneet Chakraborty on 5/10/18.
//  Copyright © 2018 CSSE Department. All rights reserved.
//

import UIKit

class AddCompetitionViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = "Is this a "
        var picker = UIPickerView()
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
