//
//  AddCompetitionViewController.swift
//  BracketMaster
//
//  Created by Praneet Chakraborty on 5/10/18.
//  Copyright © 2018 CSSE Department. All rights reserved.
//

import UIKit

class AddCompetitionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var textField: UITextField!
    
    let competitionTypes = ["Round Robin", "League"]
    let numberOfParticipants = ["1", "2", "3", "4", "5", "6", "7", "8"]
    
    var state = false //false if selecting type of competition, true if selecting number of players
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        label.text = "Is this a "
        label.sizeToFit()
        pickerView.isHidden = false
        pickerView.isOpaque = false
        textField.isHidden = true
        
        navigationItem.title = "Add New Competition"
        navigationItem.leftBarButtonItem = navigationItem.backBarButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(doneAction))
    }
    
    @objc func doneAction() {
        if textField.text == "" {
            let alertController = UIAlertController(title: "Please input a name for your competition", message: nil, preferredStyle: .alert)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if !state {
            return competitionTypes.count
        }
        return numberOfParticipants.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if !state {
            return competitionTypes[row]
        }
        return numberOfParticipants[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if !state {
            state = true
            label.text = "How many people will participate in this \(competitionTypes[row])?"
            label.sizeToFit()
            pickerView.reloadAllComponents()
        } else {
            state = false
            label.text = "What would you like to call this tournament?"
            pickerView.isHidden = true
            textField.isHidden = false
            
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
