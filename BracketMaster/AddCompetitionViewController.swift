//
//  AddCompetitionViewController.swift
//  BracketMaster
//
//  Created by Praneet Chakraborty on 5/10/18.
//  Copyright © 2018 CSSE Department. All rights reserved.
//

import UIKit
import Firebase

class AddCompetitionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var competitionRef: CollectionReference!

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    //new league variables to be filled out
    var competitionName: String = ""
    var numParticipants: Int = 0
    
    let backToHomeSegueIdentifier = "BackToHomeSegue"
    var pressedBack = false
    
    let numberOfParticipants = ["2", "3", "4", "5", "6", "7", "8"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        label.text = "How many players are part of this league?"
        label.sizeToFit()
        pickerView.isHidden = false
        textField.isHidden = true
        doneButton.isHidden = true
        textField.text = ""
        competitionRef = Firestore.firestore().collection("competitions")
    }
    
    @IBAction func pressedDone(_ sender: Any) {
        if textField.text == "" && !pressedBack{
            let alertController = UIAlertController(title: "Please input a name for your league.", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
            print(pressedBack)
            
        } else if textField.text == "    " {
            //handle case where pressing back might accidentally trigger this method
            
        } else {
            //pass information to previous VC
            competitionName = textField.text!
            print(competitionName)
            var people = [String]()
            for i in 0..<numParticipants {
                people.append("Player \(i+1)")
            }
            let newCompetition = Competition(isLeague: true, people: people, numberOfParticipants: numParticipants, competitionName: competitionName)
            competitionRef.addDocument(data: newCompetition.data)
        }
    }
    
    @IBAction func pressedBack(_ sender: Any) {
//        pressedBack = true
        textField.text = "    "
//        self.pressedDone((Any).self)
        //print(pressedBack)
        performSegue(withIdentifier: backToHomeSegueIdentifier, sender: sender)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numberOfParticipants.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return numberOfParticipants[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        numParticipants = row + 2
        label.text = "What would you like to call this league?"
        pickerView.isHidden = true
        textField.isHidden = false
        textField.backgroundColor = UIColor(ciColor: CIColor.white)
        doneButton.isHidden = false
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if textField.text == "" {
            pressedDone((Any).self)
        }
    }
}
